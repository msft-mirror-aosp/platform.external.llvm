//===------------- PPCExpandISEL.cpp - Expand ISEL instruction ------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// A pass that expands the ISEL instruction into an if-then-else sequence.
// This pass must be run post-RA since all operands must be physical registers.
//
//===----------------------------------------------------------------------===//

#include "PPC.h"
#include "PPCInstrInfo.h"
#include "PPCSubtarget.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "ppc-expand-isel"

STATISTIC(NumExpanded, "Number of ISEL instructions expanded");
STATISTIC(NumRemoved, "Number of ISEL instructions removed");
STATISTIC(NumFolded, "Number of ISEL instructions folded");

// If -ppc-gen-isel=false is set, we will disable generating the ISEL
// instruction on all PPC targets. Otherwise, if the user set option
// -misel or the platform supports ISEL by default, still generate the
// ISEL instruction, else expand it.
static cl::opt<bool>
    GenerateISEL("ppc-gen-isel",
                 cl::desc("Enable generating the ISEL instruction."),
                 cl::init(true), cl::Hidden);

namespace {
class PPCExpandISEL : public MachineFunctionPass {
  DebugLoc dl;
  MachineFunction *MF;
  const TargetInstrInfo *TII;
  bool IsTrueBlockRequired;
  bool IsFalseBlockRequired;
  MachineBasicBlock *TrueBlock;
  MachineBasicBlock *FalseBlock;
  MachineBasicBlock *NewSuccessor;
  MachineBasicBlock::iterator TrueBlockI;
  MachineBasicBlock::iterator FalseBlockI;

  typedef SmallVector<MachineInstr *, 4> BlockISELList;
  typedef SmallDenseMap<int, BlockISELList> ISELInstructionList;

  // A map of MBB numbers to their lists of contained ISEL instructions.
  ISELInstructionList ISELInstructions;

  /// Initialize the object.
  void initialize(MachineFunction &MFParam);

  void handleSpecialCases(BlockISELList &BIL, MachineBasicBlock *MBB);
  void reorganizeBlockLayout(BlockISELList &BIL, MachineBasicBlock *MBB);
  void populateBlocks(BlockISELList &BIL);
  void expandMergeableISELs(BlockISELList &BIL);
  void expandAndMergeISELs();

  bool canMerge(MachineInstr *PrevPushedMI, MachineInstr *MI);

  ///  Is this instruction an ISEL or ISEL8?
  static bool isISEL(const MachineInstr &MI) {
    return (MI.getOpcode() == PPC::ISEL || MI.getOpcode() == PPC::ISEL8);
  }

  ///  Is this instruction an ISEL8?
  static bool isISEL8(const MachineInstr &MI) {
    return (MI.getOpcode() == PPC::ISEL8);
  }

  /// Are the two operands using the same register?
  bool useSameRegister(const MachineOperand &Op1, const MachineOperand &Op2) {
    return (Op1.getReg() == Op2.getReg());
  }

  ///
  ///  Collect all ISEL instructions from the current function.
  ///
  /// Walk the current function and collect all the ISEL instructions that are
  /// found. The instructions are placed in the ISELInstructions vector.
  ///
  /// \return true if any ISEL instructions were found, false otherwise
  ///
  bool collectISELInstructions();

public:
  static char ID;
  PPCExpandISEL() : MachineFunctionPass(ID) {
    initializePPCExpandISELPass(*PassRegistry::getPassRegistry());
  }

  ///
  ///  Determine whether to generate the ISEL instruction or expand it.
  ///
  /// Expand ISEL instruction into if-then-else sequence when one of
  /// the following two conditions hold:
  /// (1) -ppc-gen-isel=false
  /// (2) hasISEL() return false
  /// Otherwise, still generate ISEL instruction.
  /// The -ppc-gen-isel option is set to true by default. Which means the ISEL
  /// instruction is still generated by default on targets that support them.
  ///
  /// \return true if ISEL should be expanded into if-then-else code sequence;
  ///         false if ISEL instruction should be generated, i.e. not expaned.
  ///
  static bool isExpandISELEnabled(const MachineFunction &MF);

#ifndef NDEBUG
  void DumpISELInstructions() const;
#endif

  bool runOnMachineFunction(MachineFunction &MF) override {
    if (!isExpandISELEnabled(MF))
      return false;

    DEBUG(dbgs() << "Function: "; MF.dump(); dbgs() << "\n");
    initialize(MF);

    if (!collectISELInstructions()) {
      DEBUG(dbgs() << "No ISEL instructions in this function\n");
      return false;
    }

#ifndef NDEBUG
    DumpISELInstructions();
#endif

    expandAndMergeISELs();

    return true;
  }
};
} // end anonymous namespace

void PPCExpandISEL::initialize(MachineFunction &MFParam) {
  MF = &MFParam;
  TII = MF->getSubtarget().getInstrInfo();
  ISELInstructions.clear();
}

bool PPCExpandISEL::isExpandISELEnabled(const MachineFunction &MF) {
  return !GenerateISEL || !MF.getSubtarget<PPCSubtarget>().hasISEL();
}

bool PPCExpandISEL::collectISELInstructions() {
  for (MachineBasicBlock &MBB : *MF) {
    BlockISELList thisBlockISELs;
    for (MachineInstr &MI : MBB)
      if (isISEL(MI))
        thisBlockISELs.push_back(&MI);
    if (!thisBlockISELs.empty())
      ISELInstructions.insert(std::make_pair(MBB.getNumber(), thisBlockISELs));
  }
  return !ISELInstructions.empty();
}

#ifndef NDEBUG
void PPCExpandISEL::DumpISELInstructions() const {
  for (const auto &I : ISELInstructions) {
    DEBUG(dbgs() << printMBBReference(*MF->getBlockNumbered(I.first)) << ":\n");
    for (const auto &VI : I.second)
      DEBUG(dbgs() << "    "; VI->print(dbgs()));
  }
}
#endif

/// Contiguous ISELs that have the same condition can be merged.
bool PPCExpandISEL::canMerge(MachineInstr *PrevPushedMI, MachineInstr *MI) {
  // Same Condition Register?
  if (!useSameRegister(PrevPushedMI->getOperand(3), MI->getOperand(3)))
    return false;

  MachineBasicBlock::iterator PrevPushedMBBI = *PrevPushedMI;
  MachineBasicBlock::iterator MBBI = *MI;
  return (std::prev(MBBI) == PrevPushedMBBI); // Contiguous ISELs?
}

void PPCExpandISEL::expandAndMergeISELs() {
  for (auto &BlockList : ISELInstructions) {

    DEBUG(dbgs() << printMBBReference(*MF->getBlockNumbered(BlockList.first))
                 << ":\n");
    DEBUG(dbgs() << "Expanding ISEL instructions in "
                 << printMBBReference(*MF->getBlockNumbered(BlockList.first))
                 << "\n");

    BlockISELList &CurrentISELList = BlockList.second;
    auto I = CurrentISELList.begin();
    auto E = CurrentISELList.end();

    while (I != E) {
      BlockISELList SubISELList;

      SubISELList.push_back(*I++);

      // Collect the ISELs that can be merged together.
      while (I != E && canMerge(SubISELList.back(), *I))
        SubISELList.push_back(*I++);

      expandMergeableISELs(SubISELList);
    }
  }
}

void PPCExpandISEL::handleSpecialCases(BlockISELList &BIL,
                                       MachineBasicBlock *MBB) {
  IsTrueBlockRequired = false;
  IsFalseBlockRequired = false;

  auto MI = BIL.begin();
  while (MI != BIL.end()) {
    assert(isISEL(**MI) && "Expecting an ISEL instruction");
    DEBUG(dbgs() << "ISEL: " << **MI << "\n");

    MachineOperand &Dest = (*MI)->getOperand(0);
    MachineOperand &TrueValue = (*MI)->getOperand(1);
    MachineOperand &FalseValue = (*MI)->getOperand(2);

    // If at least one of the ISEL instructions satisfy the following
    // condition, we need the True Block:
    // The Dest Register and True Value Register are not the same
    // Similarly, if at least one of the ISEL instructions satisfy the
    // following condition, we need the False Block:
    // The Dest Register and False Value Register are not the same.

    bool IsADDIInstRequired = !useSameRegister(Dest, TrueValue);
    bool IsORIInstRequired = !useSameRegister(Dest, FalseValue);

    // Special case 1, all registers used by ISEL are the same one.
    if (!IsADDIInstRequired && !IsORIInstRequired) {
      DEBUG(dbgs() << "Remove redudant ISEL instruction.");
      NumRemoved++;
      (*MI)->eraseFromParent();
      // Setting MI to the erase result keeps the iterator valid and increased.
      MI = BIL.erase(MI);
      continue;
    }

    // Special case 2, the two input registers used by ISEL are the same.
    // Note 1: We favor merging ISEL expansions over folding a single one. If
    // the passed list has multiple merge-able ISEL's, we won't fold any.
    // Note 2: There is no need to test for PPC::R0/PPC::X0 because PPC::ZERO/
    // PPC::ZERO8 will be used for the first operand if the value is meant to
    // be zero. In this case, the useSameRegister method will return false,
    // thereby preventing this ISEL from being folded.

    if (useSameRegister(TrueValue, FalseValue) && (BIL.size() == 1)) {
      DEBUG(dbgs() << "Fold the ISEL instruction to an unconditonal copy.");
      NumFolded++;
      BuildMI(*MBB, (*MI), dl, TII->get(isISEL8(**MI) ? PPC::ADDI8 : PPC::ADDI))
          .add(Dest)
          .add(TrueValue)
          .add(MachineOperand::CreateImm(0));
      (*MI)->eraseFromParent();
      // Setting MI to the erase result keeps the iterator valid and increased.
      MI = BIL.erase(MI);
      continue;
    }

    IsTrueBlockRequired |= IsADDIInstRequired;
    IsFalseBlockRequired |= IsORIInstRequired;
    MI++;
  }
}

void PPCExpandISEL::reorganizeBlockLayout(BlockISELList &BIL,
                                          MachineBasicBlock *MBB) {
  if (BIL.empty())
    return;

  assert((IsTrueBlockRequired || IsFalseBlockRequired) &&
         "Should have been handled by special cases earlier!");

  MachineBasicBlock *Successor = nullptr;
  const BasicBlock *LLVM_BB = MBB->getBasicBlock();
  MachineBasicBlock::iterator MBBI = (*BIL.back());
  NewSuccessor = (MBBI != MBB->getLastNonDebugInstr() || !MBB->canFallThrough())
                     // Another BB is needed to move the instructions that
                     // follow this ISEL.  If the ISEL is the last instruction
                     // in a block that can't fall through, we also need a block
                     // to branch to.
                     ? MF->CreateMachineBasicBlock(LLVM_BB)
                     : nullptr;

  MachineFunction::iterator It = MBB->getIterator();
  ++It; // Point to the successor block of MBB.

  // If NewSuccessor is NULL then the last ISEL in this group is the last
  // non-debug instruction in this block. Find the fall-through successor
  // of this block to use when updating the CFG below.
  if (!NewSuccessor) {
    for (auto &Succ : MBB->successors()) {
      if (MBB->isLayoutSuccessor(Succ)) {
        Successor = Succ;
        break;
      }
    }
  } else
    Successor = NewSuccessor;

  // The FalseBlock and TrueBlock are inserted after the MBB block but before
  // its successor.
  // Note this need to be done *after* the above setting the Successor code.
  if (IsFalseBlockRequired) {
    FalseBlock = MF->CreateMachineBasicBlock(LLVM_BB);
    MF->insert(It, FalseBlock);
  }

  if (IsTrueBlockRequired) {
    TrueBlock = MF->CreateMachineBasicBlock(LLVM_BB);
    MF->insert(It, TrueBlock);
  }

  if (NewSuccessor) {
    MF->insert(It, NewSuccessor);

    // Transfer the rest of this block into the new successor block.
    NewSuccessor->splice(NewSuccessor->end(), MBB,
                         std::next(MachineBasicBlock::iterator(BIL.back())),
                         MBB->end());
    NewSuccessor->transferSuccessorsAndUpdatePHIs(MBB);

    // Copy the original liveIns of MBB to NewSuccessor.
    for (auto &LI : MBB->liveins())
      NewSuccessor->addLiveIn(LI);

    // After splitting the NewSuccessor block, Regs defined but not killed
    // in MBB should be treated as liveins of NewSuccessor.
    // Note: Cannot use stepBackward instead since we are using the Reg
    // liveness state at the end of MBB (liveOut of MBB) as the liveIn for
    // NewSuccessor. Otherwise, will cause cyclic dependence.
    LivePhysRegs LPR(*MF->getSubtarget<PPCSubtarget>().getRegisterInfo());
    SmallVector<std::pair<unsigned, const MachineOperand *>, 2> Clobbers;
    for (MachineInstr &MI : *MBB)
      LPR.stepForward(MI, Clobbers);
    for (auto &LI : LPR)
      NewSuccessor->addLiveIn(LI);
  } else {
    // Remove successor from MBB.
    MBB->removeSuccessor(Successor);
  }

  // Note that this needs to be done *after* transfering the successors from MBB
  // to the NewSuccessor block, otherwise these blocks will also be transferred
  // as successors!
  MBB->addSuccessor(IsTrueBlockRequired ? TrueBlock : Successor);
  MBB->addSuccessor(IsFalseBlockRequired ? FalseBlock : Successor);

  if (IsTrueBlockRequired) {
    TrueBlockI = TrueBlock->begin();
    TrueBlock->addSuccessor(Successor);
  }

  if (IsFalseBlockRequired) {
    FalseBlockI = FalseBlock->begin();
    FalseBlock->addSuccessor(Successor);
  }

  // Conditional branch to the TrueBlock or Successor
  BuildMI(*MBB, BIL.back(), dl, TII->get(PPC::BC))
      .add(BIL.back()->getOperand(3))
      .addMBB(IsTrueBlockRequired ? TrueBlock : Successor);

  // Jump over the true block to the new successor if the condition is false.
  BuildMI(*(IsFalseBlockRequired ? FalseBlock : MBB),
          (IsFalseBlockRequired ? FalseBlockI : BIL.back()), dl,
          TII->get(PPC::B))
      .addMBB(Successor);

  if (IsFalseBlockRequired)
    FalseBlockI = FalseBlock->begin(); // get the position of PPC::B
}

void PPCExpandISEL::populateBlocks(BlockISELList &BIL) {
  for (auto &MI : BIL) {
    assert(isISEL(*MI) && "Expecting an ISEL instruction");

    MachineOperand &Dest = MI->getOperand(0);       // location to store to
    MachineOperand &TrueValue = MI->getOperand(1);  // Value to store if
                                                       // condition is true
    MachineOperand &FalseValue = MI->getOperand(2); // Value to store if
                                                       // condition is false
    MachineOperand &ConditionRegister = MI->getOperand(3); // Condition

    DEBUG(dbgs() << "Dest: " << Dest << "\n");
    DEBUG(dbgs() << "TrueValue: " << TrueValue << "\n");
    DEBUG(dbgs() << "FalseValue: " << FalseValue << "\n");
    DEBUG(dbgs() << "ConditionRegister: " << ConditionRegister << "\n");


    // If the Dest Register and True Value Register are not the same one, we
    // need the True Block.
    bool IsADDIInstRequired = !useSameRegister(Dest, TrueValue);
    bool IsORIInstRequired = !useSameRegister(Dest, FalseValue);

    if (IsADDIInstRequired) {
      // Copy the result into the destination if the condition is true.
      BuildMI(*TrueBlock, TrueBlockI, dl,
              TII->get(isISEL8(*MI) ? PPC::ADDI8 : PPC::ADDI))
          .add(Dest)
          .add(TrueValue)
          .add(MachineOperand::CreateImm(0));

      // Add the LiveIn registers required by true block.
      TrueBlock->addLiveIn(TrueValue.getReg());
    }

    if (IsORIInstRequired) {
      // Add the LiveIn registers required by false block.
      FalseBlock->addLiveIn(FalseValue.getReg());
    }

    if (NewSuccessor) {
      // Add the LiveIn registers required by NewSuccessor block.
      NewSuccessor->addLiveIn(Dest.getReg());
      NewSuccessor->addLiveIn(TrueValue.getReg());
      NewSuccessor->addLiveIn(FalseValue.getReg());
      NewSuccessor->addLiveIn(ConditionRegister.getReg());
    }

    // Copy the value into the destination if the condition is false.
    if (IsORIInstRequired)
      BuildMI(*FalseBlock, FalseBlockI, dl,
              TII->get(isISEL8(*MI) ? PPC::ORI8 : PPC::ORI))
          .add(Dest)
          .add(FalseValue)
          .add(MachineOperand::CreateImm(0));

    MI->eraseFromParent(); // Remove the ISEL instruction.

    NumExpanded++;
  }
}

void PPCExpandISEL::expandMergeableISELs(BlockISELList &BIL) {
  // At this stage all the ISELs of BIL are in the same MBB.
  MachineBasicBlock *MBB = BIL.back()->getParent();

  handleSpecialCases(BIL, MBB);
  reorganizeBlockLayout(BIL, MBB);
  populateBlocks(BIL);
}

INITIALIZE_PASS(PPCExpandISEL, DEBUG_TYPE, "PowerPC Expand ISEL Generation",
                false, false)
char PPCExpandISEL::ID = 0;

FunctionPass *llvm::createPPCExpandISELPass() { return new PPCExpandISEL(); }
