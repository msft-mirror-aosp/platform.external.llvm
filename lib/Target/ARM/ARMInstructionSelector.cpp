//===- ARMInstructionSelector.cpp ----------------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the InstructionSelector class for ARM.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#include "ARMRegisterBankInfo.h"
#include "ARMSubtarget.h"
#include "ARMTargetMachine.h"
#include "llvm/CodeGen/GlobalISel/InstructionSelector.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "arm-isel"

#include "llvm/CodeGen/GlobalISel/InstructionSelectorImpl.h"

using namespace llvm;

namespace {

#define GET_GLOBALISEL_PREDICATE_BITSET
#include "ARMGenGlobalISel.inc"
#undef GET_GLOBALISEL_PREDICATE_BITSET

class ARMInstructionSelector : public InstructionSelector {
public:
  ARMInstructionSelector(const ARMBaseTargetMachine &TM, const ARMSubtarget &STI,
                         const ARMRegisterBankInfo &RBI);

  bool select(MachineInstr &I) const override;

private:
  bool selectImpl(MachineInstr &I) const;

  struct CmpConstants;
  struct InsertInfo;

  bool selectCmp(CmpConstants Helper, MachineInstrBuilder &MIB,
                 MachineRegisterInfo &MRI) const;

  // Helper for inserting a comparison sequence that sets \p ResReg to either 1
  // if \p LHSReg and \p RHSReg are in the relationship defined by \p Cond, or
  // \p PrevRes otherwise. In essence, it computes PrevRes OR (LHS Cond RHS).
  bool insertComparison(CmpConstants Helper, InsertInfo I, unsigned ResReg,
                        ARMCC::CondCodes Cond, unsigned LHSReg, unsigned RHSReg,
                        unsigned PrevRes) const;

  // Set \p DestReg to \p Constant.
  void putConstant(InsertInfo I, unsigned DestReg, unsigned Constant) const;

  bool selectGlobal(MachineInstrBuilder &MIB, MachineRegisterInfo &MRI) const;
  bool selectSelect(MachineInstrBuilder &MIB, MachineRegisterInfo &MRI) const;
  bool selectShift(unsigned ShiftOpc, MachineInstrBuilder &MIB) const;

  // Check if the types match and both operands have the expected size and
  // register bank.
  bool validOpRegPair(MachineRegisterInfo &MRI, unsigned LHS, unsigned RHS,
                      unsigned ExpectedSize, unsigned ExpectedRegBankID) const;

  // Check if the register has the expected size and register bank.
  bool validReg(MachineRegisterInfo &MRI, unsigned Reg, unsigned ExpectedSize,
                unsigned ExpectedRegBankID) const;

  const ARMBaseInstrInfo &TII;
  const ARMBaseRegisterInfo &TRI;
  const ARMBaseTargetMachine &TM;
  const ARMRegisterBankInfo &RBI;
  const ARMSubtarget &STI;

#define GET_GLOBALISEL_PREDICATES_DECL
#include "ARMGenGlobalISel.inc"
#undef GET_GLOBALISEL_PREDICATES_DECL

// We declare the temporaries used by selectImpl() in the class to minimize the
// cost of constructing placeholder values.
#define GET_GLOBALISEL_TEMPORARIES_DECL
#include "ARMGenGlobalISel.inc"
#undef GET_GLOBALISEL_TEMPORARIES_DECL
};
} // end anonymous namespace

namespace llvm {
InstructionSelector *
createARMInstructionSelector(const ARMBaseTargetMachine &TM,
                             const ARMSubtarget &STI,
                             const ARMRegisterBankInfo &RBI) {
  return new ARMInstructionSelector(TM, STI, RBI);
}
}

const unsigned zero_reg = 0;

#define GET_GLOBALISEL_IMPL
#include "ARMGenGlobalISel.inc"
#undef GET_GLOBALISEL_IMPL

ARMInstructionSelector::ARMInstructionSelector(const ARMBaseTargetMachine &TM,
                                               const ARMSubtarget &STI,
                                               const ARMRegisterBankInfo &RBI)
    : InstructionSelector(), TII(*STI.getInstrInfo()),
      TRI(*STI.getRegisterInfo()), TM(TM), RBI(RBI), STI(STI),
#define GET_GLOBALISEL_PREDICATES_INIT
#include "ARMGenGlobalISel.inc"
#undef GET_GLOBALISEL_PREDICATES_INIT
#define GET_GLOBALISEL_TEMPORARIES_INIT
#include "ARMGenGlobalISel.inc"
#undef GET_GLOBALISEL_TEMPORARIES_INIT
{
}

static bool selectCopy(MachineInstr &I, const TargetInstrInfo &TII,
                       MachineRegisterInfo &MRI, const TargetRegisterInfo &TRI,
                       const RegisterBankInfo &RBI) {
  unsigned DstReg = I.getOperand(0).getReg();
  if (TargetRegisterInfo::isPhysicalRegister(DstReg))
    return true;

  const RegisterBank *RegBank = RBI.getRegBank(DstReg, MRI, TRI);
  (void)RegBank;
  assert(RegBank && "Can't get reg bank for virtual register");

  const unsigned DstSize = MRI.getType(DstReg).getSizeInBits();
  assert((RegBank->getID() == ARM::GPRRegBankID ||
          RegBank->getID() == ARM::FPRRegBankID) &&
         "Unsupported reg bank");

  const TargetRegisterClass *RC = &ARM::GPRRegClass;

  if (RegBank->getID() == ARM::FPRRegBankID) {
    if (DstSize == 32)
      RC = &ARM::SPRRegClass;
    else if (DstSize == 64)
      RC = &ARM::DPRRegClass;
    else
      llvm_unreachable("Unsupported destination size");
  }

  // No need to constrain SrcReg. It will get constrained when
  // we hit another of its uses or its defs.
  // Copies do not have constraints.
  if (!RBI.constrainGenericRegister(DstReg, *RC, MRI)) {
    DEBUG(dbgs() << "Failed to constrain " << TII.getName(I.getOpcode())
                 << " operand\n");
    return false;
  }
  return true;
}

static bool selectMergeValues(MachineInstrBuilder &MIB,
                              const ARMBaseInstrInfo &TII,
                              MachineRegisterInfo &MRI,
                              const TargetRegisterInfo &TRI,
                              const RegisterBankInfo &RBI) {
  assert(TII.getSubtarget().hasVFP2() && "Can't select merge without VFP");

  // We only support G_MERGE_VALUES as a way to stick together two scalar GPRs
  // into one DPR.
  unsigned VReg0 = MIB->getOperand(0).getReg();
  (void)VReg0;
  assert(MRI.getType(VReg0).getSizeInBits() == 64 &&
         RBI.getRegBank(VReg0, MRI, TRI)->getID() == ARM::FPRRegBankID &&
         "Unsupported operand for G_MERGE_VALUES");
  unsigned VReg1 = MIB->getOperand(1).getReg();
  (void)VReg1;
  assert(MRI.getType(VReg1).getSizeInBits() == 32 &&
         RBI.getRegBank(VReg1, MRI, TRI)->getID() == ARM::GPRRegBankID &&
         "Unsupported operand for G_MERGE_VALUES");
  unsigned VReg2 = MIB->getOperand(2).getReg();
  (void)VReg2;
  assert(MRI.getType(VReg2).getSizeInBits() == 32 &&
         RBI.getRegBank(VReg2, MRI, TRI)->getID() == ARM::GPRRegBankID &&
         "Unsupported operand for G_MERGE_VALUES");

  MIB->setDesc(TII.get(ARM::VMOVDRR));
  MIB.add(predOps(ARMCC::AL));

  return true;
}

static bool selectUnmergeValues(MachineInstrBuilder &MIB,
                                const ARMBaseInstrInfo &TII,
                                MachineRegisterInfo &MRI,
                                const TargetRegisterInfo &TRI,
                                const RegisterBankInfo &RBI) {
  assert(TII.getSubtarget().hasVFP2() && "Can't select unmerge without VFP");

  // We only support G_UNMERGE_VALUES as a way to break up one DPR into two
  // GPRs.
  unsigned VReg0 = MIB->getOperand(0).getReg();
  (void)VReg0;
  assert(MRI.getType(VReg0).getSizeInBits() == 32 &&
         RBI.getRegBank(VReg0, MRI, TRI)->getID() == ARM::GPRRegBankID &&
         "Unsupported operand for G_UNMERGE_VALUES");
  unsigned VReg1 = MIB->getOperand(1).getReg();
  (void)VReg1;
  assert(MRI.getType(VReg1).getSizeInBits() == 32 &&
         RBI.getRegBank(VReg1, MRI, TRI)->getID() == ARM::GPRRegBankID &&
         "Unsupported operand for G_UNMERGE_VALUES");
  unsigned VReg2 = MIB->getOperand(2).getReg();
  (void)VReg2;
  assert(MRI.getType(VReg2).getSizeInBits() == 64 &&
         RBI.getRegBank(VReg2, MRI, TRI)->getID() == ARM::FPRRegBankID &&
         "Unsupported operand for G_UNMERGE_VALUES");

  MIB->setDesc(TII.get(ARM::VMOVRRD));
  MIB.add(predOps(ARMCC::AL));

  return true;
}

/// Select the opcode for simple extensions (that translate to a single SXT/UXT
/// instruction). Extension operations more complicated than that should not
/// invoke this. Returns the original opcode if it doesn't know how to select a
/// better one.
static unsigned selectSimpleExtOpc(unsigned Opc, unsigned Size) {
  using namespace TargetOpcode;

  if (Size != 8 && Size != 16)
    return Opc;

  if (Opc == G_SEXT)
    return Size == 8 ? ARM::SXTB : ARM::SXTH;

  if (Opc == G_ZEXT)
    return Size == 8 ? ARM::UXTB : ARM::UXTH;

  return Opc;
}

/// Select the opcode for simple loads and stores. For types smaller than 32
/// bits, the value will be zero extended. Returns the original opcode if it
/// doesn't know how to select a better one.
static unsigned selectLoadStoreOpCode(unsigned Opc, unsigned RegBank,
                                      unsigned Size) {
  bool isStore = Opc == TargetOpcode::G_STORE;

  if (RegBank == ARM::GPRRegBankID) {
    switch (Size) {
    case 1:
    case 8:
      return isStore ? ARM::STRBi12 : ARM::LDRBi12;
    case 16:
      return isStore ? ARM::STRH : ARM::LDRH;
    case 32:
      return isStore ? ARM::STRi12 : ARM::LDRi12;
    default:
      return Opc;
    }
  }

  if (RegBank == ARM::FPRRegBankID) {
    switch (Size) {
    case 32:
      return isStore ? ARM::VSTRS : ARM::VLDRS;
    case 64:
      return isStore ? ARM::VSTRD : ARM::VLDRD;
    default:
      return Opc;
    }
  }

  return Opc;
}

// When lowering comparisons, we sometimes need to perform two compares instead
// of just one. Get the condition codes for both comparisons. If only one is
// needed, the second member of the pair is ARMCC::AL.
static std::pair<ARMCC::CondCodes, ARMCC::CondCodes>
getComparePreds(CmpInst::Predicate Pred) {
  std::pair<ARMCC::CondCodes, ARMCC::CondCodes> Preds = {ARMCC::AL, ARMCC::AL};
  switch (Pred) {
  case CmpInst::FCMP_ONE:
    Preds = {ARMCC::GT, ARMCC::MI};
    break;
  case CmpInst::FCMP_UEQ:
    Preds = {ARMCC::EQ, ARMCC::VS};
    break;
  case CmpInst::ICMP_EQ:
  case CmpInst::FCMP_OEQ:
    Preds.first = ARMCC::EQ;
    break;
  case CmpInst::ICMP_SGT:
  case CmpInst::FCMP_OGT:
    Preds.first = ARMCC::GT;
    break;
  case CmpInst::ICMP_SGE:
  case CmpInst::FCMP_OGE:
    Preds.first = ARMCC::GE;
    break;
  case CmpInst::ICMP_UGT:
  case CmpInst::FCMP_UGT:
    Preds.first = ARMCC::HI;
    break;
  case CmpInst::FCMP_OLT:
    Preds.first = ARMCC::MI;
    break;
  case CmpInst::ICMP_ULE:
  case CmpInst::FCMP_OLE:
    Preds.first = ARMCC::LS;
    break;
  case CmpInst::FCMP_ORD:
    Preds.first = ARMCC::VC;
    break;
  case CmpInst::FCMP_UNO:
    Preds.first = ARMCC::VS;
    break;
  case CmpInst::FCMP_UGE:
    Preds.first = ARMCC::PL;
    break;
  case CmpInst::ICMP_SLT:
  case CmpInst::FCMP_ULT:
    Preds.first = ARMCC::LT;
    break;
  case CmpInst::ICMP_SLE:
  case CmpInst::FCMP_ULE:
    Preds.first = ARMCC::LE;
    break;
  case CmpInst::FCMP_UNE:
  case CmpInst::ICMP_NE:
    Preds.first = ARMCC::NE;
    break;
  case CmpInst::ICMP_UGE:
    Preds.first = ARMCC::HS;
    break;
  case CmpInst::ICMP_ULT:
    Preds.first = ARMCC::LO;
    break;
  default:
    break;
  }
  assert(Preds.first != ARMCC::AL && "No comparisons needed?");
  return Preds;
}

struct ARMInstructionSelector::CmpConstants {
  CmpConstants(unsigned CmpOpcode, unsigned FlagsOpcode, unsigned OpRegBank,
               unsigned OpSize)
      : ComparisonOpcode(CmpOpcode), ReadFlagsOpcode(FlagsOpcode),
        OperandRegBankID(OpRegBank), OperandSize(OpSize) {}

  // The opcode used for performing the comparison.
  const unsigned ComparisonOpcode;

  // The opcode used for reading the flags set by the comparison. May be
  // ARM::INSTRUCTION_LIST_END if we don't need to read the flags.
  const unsigned ReadFlagsOpcode;

  // The assumed register bank ID for the operands.
  const unsigned OperandRegBankID;

  // The assumed size in bits for the operands.
  const unsigned OperandSize;
};

struct ARMInstructionSelector::InsertInfo {
  InsertInfo(MachineInstrBuilder &MIB)
      : MBB(*MIB->getParent()), InsertBefore(std::next(MIB->getIterator())),
        DbgLoc(MIB->getDebugLoc()) {}

  MachineBasicBlock &MBB;
  const MachineBasicBlock::instr_iterator InsertBefore;
  const DebugLoc &DbgLoc;
};

void ARMInstructionSelector::putConstant(InsertInfo I, unsigned DestReg,
                                         unsigned Constant) const {
  (void)BuildMI(I.MBB, I.InsertBefore, I.DbgLoc, TII.get(ARM::MOVi))
      .addDef(DestReg)
      .addImm(Constant)
      .add(predOps(ARMCC::AL))
      .add(condCodeOp());
}

bool ARMInstructionSelector::validOpRegPair(MachineRegisterInfo &MRI,
                                            unsigned LHSReg, unsigned RHSReg,
                                            unsigned ExpectedSize,
                                            unsigned ExpectedRegBankID) const {
  return MRI.getType(LHSReg) == MRI.getType(RHSReg) &&
         validReg(MRI, LHSReg, ExpectedSize, ExpectedRegBankID) &&
         validReg(MRI, RHSReg, ExpectedSize, ExpectedRegBankID);
}

bool ARMInstructionSelector::validReg(MachineRegisterInfo &MRI, unsigned Reg,
                                      unsigned ExpectedSize,
                                      unsigned ExpectedRegBankID) const {
  if (MRI.getType(Reg).getSizeInBits() != ExpectedSize) {
    DEBUG(dbgs() << "Unexpected size for register");
    return false;
  }

  if (RBI.getRegBank(Reg, MRI, TRI)->getID() != ExpectedRegBankID) {
    DEBUG(dbgs() << "Unexpected register bank for register");
    return false;
  }

  return true;
}

bool ARMInstructionSelector::selectCmp(CmpConstants Helper,
                                       MachineInstrBuilder &MIB,
                                       MachineRegisterInfo &MRI) const {
  const InsertInfo I(MIB);

  auto ResReg = MIB->getOperand(0).getReg();
  if (!validReg(MRI, ResReg, 1, ARM::GPRRegBankID))
    return false;

  auto Cond =
      static_cast<CmpInst::Predicate>(MIB->getOperand(1).getPredicate());
  if (Cond == CmpInst::FCMP_TRUE || Cond == CmpInst::FCMP_FALSE) {
    putConstant(I, ResReg, Cond == CmpInst::FCMP_TRUE ? 1 : 0);
    MIB->eraseFromParent();
    return true;
  }

  auto LHSReg = MIB->getOperand(2).getReg();
  auto RHSReg = MIB->getOperand(3).getReg();
  if (!validOpRegPair(MRI, LHSReg, RHSReg, Helper.OperandSize,
                      Helper.OperandRegBankID))
    return false;

  auto ARMConds = getComparePreds(Cond);
  auto ZeroReg = MRI.createVirtualRegister(&ARM::GPRRegClass);
  putConstant(I, ZeroReg, 0);

  if (ARMConds.second == ARMCC::AL) {
    // Simple case, we only need one comparison and we're done.
    if (!insertComparison(Helper, I, ResReg, ARMConds.first, LHSReg, RHSReg,
                          ZeroReg))
      return false;
  } else {
    // Not so simple, we need two successive comparisons.
    auto IntermediateRes = MRI.createVirtualRegister(&ARM::GPRRegClass);
    if (!insertComparison(Helper, I, IntermediateRes, ARMConds.first, LHSReg,
                          RHSReg, ZeroReg))
      return false;
    if (!insertComparison(Helper, I, ResReg, ARMConds.second, LHSReg, RHSReg,
                          IntermediateRes))
      return false;
  }

  MIB->eraseFromParent();
  return true;
}

bool ARMInstructionSelector::insertComparison(CmpConstants Helper, InsertInfo I,
                                              unsigned ResReg,
                                              ARMCC::CondCodes Cond,
                                              unsigned LHSReg, unsigned RHSReg,
                                              unsigned PrevRes) const {
  // Perform the comparison.
  auto CmpI =
      BuildMI(I.MBB, I.InsertBefore, I.DbgLoc, TII.get(Helper.ComparisonOpcode))
          .addUse(LHSReg)
          .addUse(RHSReg)
          .add(predOps(ARMCC::AL));
  if (!constrainSelectedInstRegOperands(*CmpI, TII, TRI, RBI))
    return false;

  // Read the comparison flags (if necessary).
  if (Helper.ReadFlagsOpcode != ARM::INSTRUCTION_LIST_END) {
    auto ReadI = BuildMI(I.MBB, I.InsertBefore, I.DbgLoc,
                         TII.get(Helper.ReadFlagsOpcode))
                     .add(predOps(ARMCC::AL));
    if (!constrainSelectedInstRegOperands(*ReadI, TII, TRI, RBI))
      return false;
  }

  // Select either 1 or the previous result based on the value of the flags.
  auto Mov1I = BuildMI(I.MBB, I.InsertBefore, I.DbgLoc, TII.get(ARM::MOVCCi))
                   .addDef(ResReg)
                   .addUse(PrevRes)
                   .addImm(1)
                   .add(predOps(Cond, ARM::CPSR));
  if (!constrainSelectedInstRegOperands(*Mov1I, TII, TRI, RBI))
    return false;

  return true;
}

bool ARMInstructionSelector::selectGlobal(MachineInstrBuilder &MIB,
                                          MachineRegisterInfo &MRI) const {
  if ((STI.isROPI() || STI.isRWPI()) && !STI.isTargetELF()) {
    DEBUG(dbgs() << "ROPI and RWPI only supported for ELF\n");
    return false;
  }

  auto GV = MIB->getOperand(1).getGlobal();
  if (GV->isThreadLocal()) {
    DEBUG(dbgs() << "TLS variables not supported yet\n");
    return false;
  }

  auto &MBB = *MIB->getParent();
  auto &MF = *MBB.getParent();

  bool UseMovt = STI.useMovt(MF);

  unsigned Size = TM.getPointerSize();
  unsigned Alignment = 4;

  auto addOpsForConstantPoolLoad = [&MF, Alignment,
                                    Size](MachineInstrBuilder &MIB,
                                          const GlobalValue *GV, bool IsSBREL) {
    assert(MIB->getOpcode() == ARM::LDRi12 && "Unsupported instruction");
    auto ConstPool = MF.getConstantPool();
    auto CPIndex =
        // For SB relative entries we need a target-specific constant pool.
        // Otherwise, just use a regular constant pool entry.
        IsSBREL
            ? ConstPool->getConstantPoolIndex(
                  ARMConstantPoolConstant::Create(GV, ARMCP::SBREL), Alignment)
            : ConstPool->getConstantPoolIndex(GV, Alignment);
    MIB.addConstantPoolIndex(CPIndex, /*Offset*/ 0, /*TargetFlags*/ 0)
        .addMemOperand(
            MF.getMachineMemOperand(MachinePointerInfo::getConstantPool(MF),
                                    MachineMemOperand::MOLoad, Size, Alignment))
        .addImm(0)
        .add(predOps(ARMCC::AL));
  };

  if (TM.isPositionIndependent()) {
    bool Indirect = STI.isGVIndirectSymbol(GV);
    // FIXME: Taking advantage of MOVT for ELF is pretty involved, so we don't
    // support it yet. See PR28229.
    unsigned Opc =
        UseMovt && !STI.isTargetELF()
            ? (Indirect ? ARM::MOV_ga_pcrel_ldr : ARM::MOV_ga_pcrel)
            : (Indirect ? ARM::LDRLIT_ga_pcrel_ldr : ARM::LDRLIT_ga_pcrel);
    MIB->setDesc(TII.get(Opc));

    if (STI.isTargetDarwin())
      MIB->getOperand(1).setTargetFlags(ARMII::MO_NONLAZY);

    if (Indirect)
      MIB.addMemOperand(MF.getMachineMemOperand(
          MachinePointerInfo::getGOT(MF), MachineMemOperand::MOLoad,
          TM.getPointerSize(), Alignment));

    return constrainSelectedInstRegOperands(*MIB, TII, TRI, RBI);
  }

  bool isReadOnly = STI.getTargetLowering()->isReadOnly(GV);
  if (STI.isROPI() && isReadOnly) {
    unsigned Opc = UseMovt ? ARM::MOV_ga_pcrel : ARM::LDRLIT_ga_pcrel;
    MIB->setDesc(TII.get(Opc));
    return constrainSelectedInstRegOperands(*MIB, TII, TRI, RBI);
  }
  if (STI.isRWPI() && !isReadOnly) {
    auto Offset = MRI.createVirtualRegister(&ARM::GPRRegClass);
    MachineInstrBuilder OffsetMIB;
    if (UseMovt) {
      OffsetMIB = BuildMI(MBB, *MIB, MIB->getDebugLoc(),
                          TII.get(ARM::MOVi32imm), Offset);
      OffsetMIB.addGlobalAddress(GV, /*Offset*/ 0, ARMII::MO_SBREL);
    } else {
      // Load the offset from the constant pool.
      OffsetMIB =
          BuildMI(MBB, *MIB, MIB->getDebugLoc(), TII.get(ARM::LDRi12), Offset);
      addOpsForConstantPoolLoad(OffsetMIB, GV, /*IsSBREL*/ true);
    }
    if (!constrainSelectedInstRegOperands(*OffsetMIB, TII, TRI, RBI))
      return false;

    // Add the offset to the SB register.
    MIB->setDesc(TII.get(ARM::ADDrr));
    MIB->RemoveOperand(1);
    MIB.addReg(ARM::R9) // FIXME: don't hardcode R9
        .addReg(Offset)
        .add(predOps(ARMCC::AL))
        .add(condCodeOp());

    return constrainSelectedInstRegOperands(*MIB, TII, TRI, RBI);
  }

  if (STI.isTargetELF()) {
    if (UseMovt) {
      MIB->setDesc(TII.get(ARM::MOVi32imm));
    } else {
      // Load the global's address from the constant pool.
      MIB->setDesc(TII.get(ARM::LDRi12));
      MIB->RemoveOperand(1);
      addOpsForConstantPoolLoad(MIB, GV, /*IsSBREL*/ false);
    }
  } else if (STI.isTargetMachO()) {
    if (UseMovt)
      MIB->setDesc(TII.get(ARM::MOVi32imm));
    else
      MIB->setDesc(TII.get(ARM::LDRLIT_ga_abs));
  } else {
    DEBUG(dbgs() << "Object format not supported yet\n");
    return false;
  }

  return constrainSelectedInstRegOperands(*MIB, TII, TRI, RBI);
}

bool ARMInstructionSelector::selectSelect(MachineInstrBuilder &MIB,
                                          MachineRegisterInfo &MRI) const {
  auto &MBB = *MIB->getParent();
  auto InsertBefore = std::next(MIB->getIterator());
  auto &DbgLoc = MIB->getDebugLoc();

  // Compare the condition to 0.
  auto CondReg = MIB->getOperand(1).getReg();
  assert(validReg(MRI, CondReg, 1, ARM::GPRRegBankID) &&
         "Unsupported types for select operation");
  auto CmpI = BuildMI(MBB, InsertBefore, DbgLoc, TII.get(ARM::CMPri))
                  .addUse(CondReg)
                  .addImm(0)
                  .add(predOps(ARMCC::AL));
  if (!constrainSelectedInstRegOperands(*CmpI, TII, TRI, RBI))
    return false;

  // Move a value into the result register based on the result of the
  // comparison.
  auto ResReg = MIB->getOperand(0).getReg();
  auto TrueReg = MIB->getOperand(2).getReg();
  auto FalseReg = MIB->getOperand(3).getReg();
  assert(validOpRegPair(MRI, ResReg, TrueReg, 32, ARM::GPRRegBankID) &&
         validOpRegPair(MRI, TrueReg, FalseReg, 32, ARM::GPRRegBankID) &&
         "Unsupported types for select operation");
  auto Mov1I = BuildMI(MBB, InsertBefore, DbgLoc, TII.get(ARM::MOVCCr))
                   .addDef(ResReg)
                   .addUse(TrueReg)
                   .addUse(FalseReg)
                   .add(predOps(ARMCC::EQ, ARM::CPSR));
  if (!constrainSelectedInstRegOperands(*Mov1I, TII, TRI, RBI))
    return false;

  MIB->eraseFromParent();
  return true;
}

bool ARMInstructionSelector::selectShift(unsigned ShiftOpc,
                                         MachineInstrBuilder &MIB) const {
  MIB->setDesc(TII.get(ARM::MOVsr));
  MIB.addImm(ShiftOpc);
  MIB.add(predOps(ARMCC::AL)).add(condCodeOp());
  return constrainSelectedInstRegOperands(*MIB, TII, TRI, RBI);
}

bool ARMInstructionSelector::select(MachineInstr &I) const {
  assert(I.getParent() && "Instruction should be in a basic block!");
  assert(I.getParent()->getParent() && "Instruction should be in a function!");

  auto &MBB = *I.getParent();
  auto &MF = *MBB.getParent();
  auto &MRI = MF.getRegInfo();

  if (!isPreISelGenericOpcode(I.getOpcode())) {
    if (I.isCopy())
      return selectCopy(I, TII, MRI, TRI, RBI);

    return true;
  }

  if (selectImpl(I))
    return true;

  MachineInstrBuilder MIB{MF, I};
  bool isSExt = false;

  using namespace TargetOpcode;
  switch (I.getOpcode()) {
  case G_SEXT:
    isSExt = true;
    LLVM_FALLTHROUGH;
  case G_ZEXT: {
    LLT DstTy = MRI.getType(I.getOperand(0).getReg());
    // FIXME: Smaller destination sizes coming soon!
    if (DstTy.getSizeInBits() != 32) {
      DEBUG(dbgs() << "Unsupported destination size for extension");
      return false;
    }

    LLT SrcTy = MRI.getType(I.getOperand(1).getReg());
    unsigned SrcSize = SrcTy.getSizeInBits();
    switch (SrcSize) {
    case 1: {
      // ZExt boils down to & 0x1; for SExt we also subtract that from 0
      I.setDesc(TII.get(ARM::ANDri));
      MIB.addImm(1).add(predOps(ARMCC::AL)).add(condCodeOp());

      if (isSExt) {
        unsigned SExtResult = I.getOperand(0).getReg();

        // Use a new virtual register for the result of the AND
        unsigned AndResult = MRI.createVirtualRegister(&ARM::GPRRegClass);
        I.getOperand(0).setReg(AndResult);

        auto InsertBefore = std::next(I.getIterator());
        auto SubI =
            BuildMI(MBB, InsertBefore, I.getDebugLoc(), TII.get(ARM::RSBri))
                .addDef(SExtResult)
                .addUse(AndResult)
                .addImm(0)
                .add(predOps(ARMCC::AL))
                .add(condCodeOp());
        if (!constrainSelectedInstRegOperands(*SubI, TII, TRI, RBI))
          return false;
      }
      break;
    }
    case 8:
    case 16: {
      unsigned NewOpc = selectSimpleExtOpc(I.getOpcode(), SrcSize);
      if (NewOpc == I.getOpcode())
        return false;
      I.setDesc(TII.get(NewOpc));
      MIB.addImm(0).add(predOps(ARMCC::AL));
      break;
    }
    default:
      DEBUG(dbgs() << "Unsupported source size for extension");
      return false;
    }
    break;
  }
  case G_ANYEXT:
  case G_TRUNC: {
    // The high bits are undefined, so there's nothing special to do, just
    // treat it as a copy.
    auto SrcReg = I.getOperand(1).getReg();
    auto DstReg = I.getOperand(0).getReg();

    const auto &SrcRegBank = *RBI.getRegBank(SrcReg, MRI, TRI);
    const auto &DstRegBank = *RBI.getRegBank(DstReg, MRI, TRI);

    if (SrcRegBank.getID() != DstRegBank.getID()) {
      DEBUG(dbgs() << "G_TRUNC/G_ANYEXT operands on different register banks\n");
      return false;
    }

    if (SrcRegBank.getID() != ARM::GPRRegBankID) {
      DEBUG(dbgs() << "G_TRUNC/G_ANYEXT on non-GPR not supported yet\n");
      return false;
    }

    I.setDesc(TII.get(COPY));
    return selectCopy(I, TII, MRI, TRI, RBI);
  }
  case G_SELECT:
    return selectSelect(MIB, MRI);
  case G_ICMP: {
    CmpConstants Helper(ARM::CMPrr, ARM::INSTRUCTION_LIST_END,
                        ARM::GPRRegBankID, 32);
    return selectCmp(Helper, MIB, MRI);
  }
  case G_FCMP: {
    assert(STI.hasVFP2() && "Can't select fcmp without VFP");

    unsigned OpReg = I.getOperand(2).getReg();
    unsigned Size = MRI.getType(OpReg).getSizeInBits();

    if (Size == 64 && STI.isFPOnlySP()) {
      DEBUG(dbgs() << "Subtarget only supports single precision");
      return false;
    }
    if (Size != 32 && Size != 64) {
      DEBUG(dbgs() << "Unsupported size for G_FCMP operand");
      return false;
    }

    CmpConstants Helper(Size == 32 ? ARM::VCMPS : ARM::VCMPD, ARM::FMSTAT,
                        ARM::FPRRegBankID, Size);
    return selectCmp(Helper, MIB, MRI);
  }
  case G_LSHR:
    return selectShift(ARM_AM::ShiftOpc::lsr, MIB);
  case G_ASHR:
    return selectShift(ARM_AM::ShiftOpc::asr, MIB);
  case G_SHL: {
    return selectShift(ARM_AM::ShiftOpc::lsl, MIB);
  }
  case G_GEP:
    I.setDesc(TII.get(ARM::ADDrr));
    MIB.add(predOps(ARMCC::AL)).add(condCodeOp());
    break;
  case G_FRAME_INDEX:
    // Add 0 to the given frame index and hope it will eventually be folded into
    // the user(s).
    I.setDesc(TII.get(ARM::ADDri));
    MIB.addImm(0).add(predOps(ARMCC::AL)).add(condCodeOp());
    break;
  case G_CONSTANT: {
    unsigned Reg = I.getOperand(0).getReg();

    if (!validReg(MRI, Reg, 32, ARM::GPRRegBankID))
      return false;

    I.setDesc(TII.get(ARM::MOVi));
    MIB.add(predOps(ARMCC::AL)).add(condCodeOp());

    auto &Val = I.getOperand(1);
    if (Val.isCImm()) {
      if (Val.getCImm()->getBitWidth() > 32)
        return false;
      Val.ChangeToImmediate(Val.getCImm()->getZExtValue());
    }

    if (!Val.isImm()) {
      return false;
    }

    break;
  }
  case G_GLOBAL_VALUE:
    return selectGlobal(MIB, MRI);
  case G_STORE:
  case G_LOAD: {
    const auto &MemOp = **I.memoperands_begin();
    if (MemOp.getOrdering() != AtomicOrdering::NotAtomic) {
      DEBUG(dbgs() << "Atomic load/store not supported yet\n");
      return false;
    }

    unsigned Reg = I.getOperand(0).getReg();
    unsigned RegBank = RBI.getRegBank(Reg, MRI, TRI)->getID();

    LLT ValTy = MRI.getType(Reg);
    const auto ValSize = ValTy.getSizeInBits();

    assert((ValSize != 64 || STI.hasVFP2()) &&
           "Don't know how to load/store 64-bit value without VFP");

    const auto NewOpc = selectLoadStoreOpCode(I.getOpcode(), RegBank, ValSize);
    if (NewOpc == G_LOAD || NewOpc == G_STORE)
      return false;

    I.setDesc(TII.get(NewOpc));

    if (NewOpc == ARM::LDRH || NewOpc == ARM::STRH)
      // LDRH has a funny addressing mode (there's already a FIXME for it).
      MIB.addReg(0);
    MIB.addImm(0).add(predOps(ARMCC::AL));
    break;
  }
  case G_MERGE_VALUES: {
    if (!selectMergeValues(MIB, TII, MRI, TRI, RBI))
      return false;
    break;
  }
  case G_UNMERGE_VALUES: {
    if (!selectUnmergeValues(MIB, TII, MRI, TRI, RBI))
      return false;
    break;
  }
  case G_BRCOND: {
    if (!validReg(MRI, I.getOperand(0).getReg(), 1, ARM::GPRRegBankID)) {
      DEBUG(dbgs() << "Unsupported condition register for G_BRCOND");
      return false;
    }

    // Set the flags.
    auto Test = BuildMI(*I.getParent(), I, I.getDebugLoc(), TII.get(ARM::TSTri))
                    .addReg(I.getOperand(0).getReg())
                    .addImm(1)
                    .add(predOps(ARMCC::AL));
    if (!constrainSelectedInstRegOperands(*Test, TII, TRI, RBI))
      return false;

    // Branch conditionally.
    auto Branch = BuildMI(*I.getParent(), I, I.getDebugLoc(), TII.get(ARM::Bcc))
                      .add(I.getOperand(1))
                      .add(predOps(ARMCC::EQ, ARM::CPSR));
    if (!constrainSelectedInstRegOperands(*Branch, TII, TRI, RBI))
      return false;
    I.eraseFromParent();
    return true;
  }
  default:
    return false;
  }

  return constrainSelectedInstRegOperands(I, TII, TRI, RBI);
}
