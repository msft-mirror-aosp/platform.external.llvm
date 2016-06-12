//===-- XCoreISelDAGToDAG.cpp - A dag to dag inst selector for XCore ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines an instruction selector for the XCore target.
//
//===----------------------------------------------------------------------===//

#include "XCore.h"
#include "XCoreTargetMachine.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetLowering.h"
using namespace llvm;

/// XCoreDAGToDAGISel - XCore specific code to select XCore machine
/// instructions for SelectionDAG operations.
///
namespace {
  class XCoreDAGToDAGISel : public SelectionDAGISel {

  public:
    XCoreDAGToDAGISel(XCoreTargetMachine &TM, CodeGenOpt::Level OptLevel)
      : SelectionDAGISel(TM, OptLevel) {}

    void Select(SDNode *N) override;
    bool tryBRIND(SDNode *N);

    /// getI32Imm - Return a target constant with the specified value, of type
    /// i32.
    inline SDValue getI32Imm(unsigned Imm, const SDLoc &dl) {
      return CurDAG->getTargetConstant(Imm, dl, MVT::i32);
    }

    inline bool immMskBitp(SDNode *inN) const {
      ConstantSDNode *N = cast<ConstantSDNode>(inN);
      uint32_t value = (uint32_t)N->getZExtValue();
      if (!isMask_32(value)) {
        return false;
      }
      int msksize = 32 - countLeadingZeros(value);
      return (msksize >= 1 && msksize <= 8) ||
              msksize == 16 || msksize == 24 || msksize == 32;
    }

    // Complex Pattern Selectors.
    bool SelectADDRspii(SDValue Addr, SDValue &Base, SDValue &Offset);

    bool SelectInlineAsmMemoryOperand(const SDValue &Op, unsigned ConstraintID,
                                      std::vector<SDValue> &OutOps) override;

    const char *getPassName() const override {
      return "XCore DAG->DAG Pattern Instruction Selection";
    }

    // Include the pieces autogenerated from the target description.
  #include "XCoreGenDAGISel.inc"
  };
}  // end anonymous namespace

/// createXCoreISelDag - This pass converts a legalized DAG into a
/// XCore-specific DAG, ready for instruction scheduling.
///
FunctionPass *llvm::createXCoreISelDag(XCoreTargetMachine &TM,
                                       CodeGenOpt::Level OptLevel) {
  return new XCoreDAGToDAGISel(TM, OptLevel);
}

bool XCoreDAGToDAGISel::SelectADDRspii(SDValue Addr, SDValue &Base,
                                       SDValue &Offset) {
  FrameIndexSDNode *FIN = nullptr;
  if ((FIN = dyn_cast<FrameIndexSDNode>(Addr))) {
    Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
    Offset = CurDAG->getTargetConstant(0, SDLoc(Addr), MVT::i32);
    return true;
  }
  if (Addr.getOpcode() == ISD::ADD) {
    ConstantSDNode *CN = nullptr;
    if ((FIN = dyn_cast<FrameIndexSDNode>(Addr.getOperand(0)))
      && (CN = dyn_cast<ConstantSDNode>(Addr.getOperand(1)))
      && (CN->getSExtValue() % 4 == 0 && CN->getSExtValue() >= 0)) {
      // Constant positive word offset from frame index
      Base = CurDAG->getTargetFrameIndex(FIN->getIndex(), MVT::i32);
      Offset = CurDAG->getTargetConstant(CN->getSExtValue(), SDLoc(Addr),
                                         MVT::i32);
      return true;
    }
  }
  return false;
}

bool XCoreDAGToDAGISel::
SelectInlineAsmMemoryOperand(const SDValue &Op, unsigned ConstraintID,
                             std::vector<SDValue> &OutOps) {
  SDValue Reg;
  switch (ConstraintID) {
  default: return true;
  case InlineAsm::Constraint_m: // Memory.
    switch (Op.getOpcode()) {
    default: return true;
    case XCoreISD::CPRelativeWrapper:
      Reg = CurDAG->getRegister(XCore::CP, MVT::i32);
      break;
    case XCoreISD::DPRelativeWrapper:
      Reg = CurDAG->getRegister(XCore::DP, MVT::i32);
      break;
    }
  }
  OutOps.push_back(Reg);
  OutOps.push_back(Op.getOperand(0));
  return false;
}

void XCoreDAGToDAGISel::Select(SDNode *N) {
  SDLoc dl(N);
  switch (N->getOpcode()) {
  default: break;
  case ISD::Constant: {
    uint64_t Val = cast<ConstantSDNode>(N)->getZExtValue();
    if (immMskBitp(N)) {
      // Transformation function: get the size of a mask
      // Look for the first non-zero bit
      SDValue MskSize = getI32Imm(32 - countLeadingZeros((uint32_t)Val), dl);
      ReplaceNode(N, CurDAG->getMachineNode(XCore::MKMSK_rus, dl,
                                            MVT::i32, MskSize));
      return;
    }
    else if (!isUInt<16>(Val)) {
      SDValue CPIdx = CurDAG->getTargetConstantPool(
          ConstantInt::get(Type::getInt32Ty(*CurDAG->getContext()), Val),
          getTargetLowering()->getPointerTy(CurDAG->getDataLayout()));
      SDNode *node = CurDAG->getMachineNode(XCore::LDWCP_lru6, dl, MVT::i32,
                                            MVT::Other, CPIdx,
                                            CurDAG->getEntryNode());
      MachineSDNode::mmo_iterator MemOp = MF->allocateMemRefsArray(1);
      MemOp[0] =
          MF->getMachineMemOperand(MachinePointerInfo::getConstantPool(*MF),
                                   MachineMemOperand::MOLoad, 4, 4);
      cast<MachineSDNode>(node)->setMemRefs(MemOp, MemOp + 1);
      ReplaceNode(N, node);
      return;
    }
    break;
  }
  case XCoreISD::LADD: {
    SDValue Ops[] = { N->getOperand(0), N->getOperand(1),
                        N->getOperand(2) };
    ReplaceNode(N, CurDAG->getMachineNode(XCore::LADD_l5r, dl, MVT::i32,
                                          MVT::i32, Ops));
    return;
  }
  case XCoreISD::LSUB: {
    SDValue Ops[] = { N->getOperand(0), N->getOperand(1),
                        N->getOperand(2) };
    ReplaceNode(N, CurDAG->getMachineNode(XCore::LSUB_l5r, dl, MVT::i32,
                                          MVT::i32, Ops));
    return;
  }
  case XCoreISD::MACCU: {
    SDValue Ops[] = { N->getOperand(0), N->getOperand(1),
                      N->getOperand(2), N->getOperand(3) };
    ReplaceNode(N, CurDAG->getMachineNode(XCore::MACCU_l4r, dl, MVT::i32,
                                          MVT::i32, Ops));
    return;
  }
  case XCoreISD::MACCS: {
    SDValue Ops[] = { N->getOperand(0), N->getOperand(1),
                      N->getOperand(2), N->getOperand(3) };
    ReplaceNode(N, CurDAG->getMachineNode(XCore::MACCS_l4r, dl, MVT::i32,
                                          MVT::i32, Ops));
    return;
  }
  case XCoreISD::LMUL: {
    SDValue Ops[] = { N->getOperand(0), N->getOperand(1),
                      N->getOperand(2), N->getOperand(3) };
    ReplaceNode(N, CurDAG->getMachineNode(XCore::LMUL_l6r, dl, MVT::i32,
                                          MVT::i32, Ops));
    return;
  }
  case XCoreISD::CRC8: {
    SDValue Ops[] = { N->getOperand(0), N->getOperand(1), N->getOperand(2) };
    ReplaceNode(N, CurDAG->getMachineNode(XCore::CRC8_l4r, dl, MVT::i32,
                                          MVT::i32, Ops));
    return;
  }
  case ISD::BRIND:
    if (tryBRIND(N))
      return;
    break;
  // Other cases are autogenerated.
  }
  SelectCode(N);
}

/// Given a chain return a new chain where any appearance of Old is replaced
/// by New. There must be at most one instruction between Old and Chain and
/// this instruction must be a TokenFactor. Returns an empty SDValue if
/// these conditions don't hold.
static SDValue
replaceInChain(SelectionDAG *CurDAG, SDValue Chain, SDValue Old, SDValue New)
{
  if (Chain == Old)
    return New;
  if (Chain->getOpcode() != ISD::TokenFactor)
    return SDValue();
  SmallVector<SDValue, 8> Ops;
  bool found = false;
  for (unsigned i = 0, e = Chain->getNumOperands(); i != e; ++i) {
    if (Chain->getOperand(i) == Old) {
      Ops.push_back(New);
      found = true;
    } else {
      Ops.push_back(Chain->getOperand(i));
    }
  }
  if (!found)
    return SDValue();
  return CurDAG->getNode(ISD::TokenFactor, SDLoc(Chain), MVT::Other, Ops);
}

bool XCoreDAGToDAGISel::tryBRIND(SDNode *N) {
  SDLoc dl(N);
  // (brind (int_xcore_checkevent (addr)))
  SDValue Chain = N->getOperand(0);
  SDValue Addr = N->getOperand(1);
  if (Addr->getOpcode() != ISD::INTRINSIC_W_CHAIN)
    return false;
  unsigned IntNo = cast<ConstantSDNode>(Addr->getOperand(1))->getZExtValue();
  if (IntNo != Intrinsic::xcore_checkevent)
    return false;
  SDValue nextAddr = Addr->getOperand(2);
  SDValue CheckEventChainOut(Addr.getNode(), 1);
  if (!CheckEventChainOut.use_empty()) {
    // If the chain out of the checkevent intrinsic is an operand of the
    // indirect branch or used in a TokenFactor which is the operand of the
    // indirect branch then build a new chain which uses the chain coming into
    // the checkevent intrinsic instead.
    SDValue CheckEventChainIn = Addr->getOperand(0);
    SDValue NewChain = replaceInChain(CurDAG, Chain, CheckEventChainOut,
                                      CheckEventChainIn);
    if (!NewChain.getNode())
      return false;
    Chain = NewChain;
  }
  // Enable events on the thread using setsr 1 and then disable them immediately
  // after with clrsr 1. If any resources owned by the thread are ready an event
  // will be taken. If no resource is ready we branch to the address which was
  // the operand to the checkevent intrinsic.
  SDValue constOne = getI32Imm(1, dl);
  SDValue Glue =
    SDValue(CurDAG->getMachineNode(XCore::SETSR_branch_u6, dl, MVT::Glue,
                                   constOne, Chain), 0);
  Glue =
    SDValue(CurDAG->getMachineNode(XCore::CLRSR_branch_u6, dl, MVT::Glue,
                                   constOne, Glue), 0);
  if (nextAddr->getOpcode() == XCoreISD::PCRelativeWrapper &&
      nextAddr->getOperand(0)->getOpcode() == ISD::TargetBlockAddress) {
    CurDAG->SelectNodeTo(N, XCore::BRFU_lu6, MVT::Other,
                         nextAddr->getOperand(0), Glue);
    return true;
  }
  CurDAG->SelectNodeTo(N, XCore::BAU_1r, MVT::Other, nextAddr, Glue);
  return true;
}
