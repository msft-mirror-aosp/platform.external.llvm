//===-- TargetMachine.cpp - General Target Information ---------------------==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file describes the general parts of a Target machine.
//
//===----------------------------------------------------------------------===//

#include "llvm/Target/TargetMachine.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalAlias.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCSectionMachO.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/MC/SectionKind.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/Target/TargetLoweringObjectFile.h"
#include "llvm/Target/TargetSubtargetInfo.h"
using namespace llvm;

cl::opt<bool> EnableIPRA("enable-ipra", cl::init(false), cl::Hidden,
                         cl::desc("Enable interprocedural register allocation "
                                  "to reduce load/store at procedure calls."));

//---------------------------------------------------------------------------
// TargetMachine Class
//

TargetMachine::TargetMachine(const Target &T, StringRef DataLayoutString,
                             const Triple &TT, StringRef CPU, StringRef FS,
                             const TargetOptions &Options)
    : TheTarget(T), DL(DataLayoutString), TargetTriple(TT), TargetCPU(CPU),
      TargetFS(FS), AsmInfo(nullptr), MRI(nullptr), MII(nullptr), STI(nullptr),
      RequireStructuredCFG(false), Options(Options) {
  if (EnableIPRA.getNumOccurrences())
    this->Options.EnableIPRA = EnableIPRA;
}

TargetMachine::~TargetMachine() {
  delete AsmInfo;
  delete MRI;
  delete MII;
  delete STI;
}

bool TargetMachine::isPositionIndependent() const {
  return getRelocationModel() == Reloc::PIC_;
}

/// \brief Reset the target options based on the function's attributes.
// FIXME: This function needs to go away for a number of reasons:
// a) global state on the TargetMachine is terrible in general,
// b) there's no default state here to keep,
// c) these target options should be passed only on the function
//    and not on the TargetMachine (via TargetOptions) at all.
void TargetMachine::resetTargetOptions(const Function &F) const {
#define RESET_OPTION(X, Y)                                                     \
  do {                                                                         \
    if (F.hasFnAttribute(Y))                                                   \
      Options.X = (F.getFnAttribute(Y).getValueAsString() == "true");          \
  } while (0)

  RESET_OPTION(LessPreciseFPMADOption, "less-precise-fpmad");
  RESET_OPTION(UnsafeFPMath, "unsafe-fp-math");
  RESET_OPTION(NoInfsFPMath, "no-infs-fp-math");
  RESET_OPTION(NoNaNsFPMath, "no-nans-fp-math");
  RESET_OPTION(NoTrappingFPMath, "no-trapping-math");

  StringRef Denormal =
    F.getFnAttribute("denormal-fp-math").getValueAsString();
  if (Denormal == "ieee")
    Options.FPDenormalMode = FPDenormal::IEEE;
  else if (Denormal == "preserve-sign")
    Options.FPDenormalMode = FPDenormal::PreserveSign;
  else if (Denormal == "positive-zero")
    Options.FPDenormalMode = FPDenormal::PositiveZero;
}

/// Returns the code generation relocation model. The choices are static, PIC,
/// and dynamic-no-pic.
Reloc::Model TargetMachine::getRelocationModel() const { return RM; }

/// Returns the code model. The choices are small, kernel, medium, large, and
/// target default.
CodeModel::Model TargetMachine::getCodeModel() const { return CMModel; }

/// Get the IR-specified TLS model for Var.
static TLSModel::Model getSelectedTLSModel(const GlobalValue *GV) {
  switch (GV->getThreadLocalMode()) {
  case GlobalVariable::NotThreadLocal:
    llvm_unreachable("getSelectedTLSModel for non-TLS variable");
    break;
  case GlobalVariable::GeneralDynamicTLSModel:
    return TLSModel::GeneralDynamic;
  case GlobalVariable::LocalDynamicTLSModel:
    return TLSModel::LocalDynamic;
  case GlobalVariable::InitialExecTLSModel:
    return TLSModel::InitialExec;
  case GlobalVariable::LocalExecTLSModel:
    return TLSModel::LocalExec;
  }
  llvm_unreachable("invalid TLS model");
}

bool TargetMachine::shouldAssumeDSOLocal(const Module &M,
                                         const GlobalValue *GV) const {
  Reloc::Model RM = getRelocationModel();
  const Triple &TT = getTargetTriple();

  // DLLImport explicitly marks the GV as external.
  if (GV && GV->hasDLLImportStorageClass())
    return false;

  // Every other GV is local on COFF.
  // Make an exception for windows OS in the triple: Some firmwares builds use
  // *-win32-macho triples. This (accidentally?) produced windows relocations
  // without GOT tables in older clang versions; Keep this behaviour.
  if (TT.isOSBinFormatCOFF() || (TT.isOSWindows() && TT.isOSBinFormatMachO()))
    return true;

  if (GV && (GV->hasLocalLinkage() || !GV->hasDefaultVisibility()))
    return true;

  if (TT.isOSBinFormatMachO()) {
    if (RM == Reloc::Static)
      return true;
    return GV && GV->isStrongDefinitionForLinker();
  }

  assert(TT.isOSBinFormatELF());
  assert(RM != Reloc::DynamicNoPIC);

  bool IsExecutable =
      RM == Reloc::Static || M.getPIELevel() != PIELevel::Default;
  if (IsExecutable) {
    // If the symbol is defined, it cannot be preempted.
    if (GV && !GV->isDeclarationForLinker())
      return true;

    bool IsTLS = GV && GV->isThreadLocal();
    bool IsAccessViaCopyRelocs =
        Options.MCOptions.MCPIECopyRelocations && GV && isa<GlobalVariable>(GV);
    // Check if we can use copy relocations.
    if (!IsTLS && (RM == Reloc::Static || IsAccessViaCopyRelocs))
      return true;
  }

  // ELF supports preemption of other symbols.
  return false;
}

TLSModel::Model TargetMachine::getTLSModel(const GlobalValue *GV) const {
  bool IsPIE = GV->getParent()->getPIELevel() != PIELevel::Default;
  Reloc::Model RM = getRelocationModel();
  bool IsSharedLibrary = RM == Reloc::PIC_ && !IsPIE;
  bool IsLocal = shouldAssumeDSOLocal(*GV->getParent(), GV);

  TLSModel::Model Model;
  if (IsSharedLibrary) {
    if (IsLocal)
      Model = TLSModel::LocalDynamic;
    else
      Model = TLSModel::GeneralDynamic;
  } else {
    if (IsLocal)
      Model = TLSModel::LocalExec;
    else
      Model = TLSModel::InitialExec;
  }

  // If the user specified a more specific model, use that.
  TLSModel::Model SelectedModel = getSelectedTLSModel(GV);
  if (SelectedModel > Model)
    return SelectedModel;

  return Model;
}

/// Returns the optimization level: None, Less, Default, or Aggressive.
CodeGenOpt::Level TargetMachine::getOptLevel() const { return OptLevel; }

void TargetMachine::setOptLevel(CodeGenOpt::Level Level) { OptLevel = Level; }

TargetIRAnalysis TargetMachine::getTargetIRAnalysis() {
  return TargetIRAnalysis([this](const Function &F) {
    return TargetTransformInfo(F.getParent()->getDataLayout());
  });
}

void TargetMachine::getNameWithPrefix(SmallVectorImpl<char> &Name,
                                      const GlobalValue *GV, Mangler &Mang,
                                      bool MayAlwaysUsePrivate) const {
  const TargetLoweringObjectFile *TLOF = getObjFileLowering();
  TLOF->getNameWithPrefix(Name, GV, *this);
}

MCSymbol *TargetMachine::getSymbol(const GlobalValue *GV, Mangler &Mang) const {
  SmallString<128> NameStr;
  const TargetLoweringObjectFile *TLOF = getObjFileLowering();
  TLOF->getNameWithPrefix(NameStr, GV, *this);
  return TLOF->getContext().getOrCreateSymbol(NameStr);
}
