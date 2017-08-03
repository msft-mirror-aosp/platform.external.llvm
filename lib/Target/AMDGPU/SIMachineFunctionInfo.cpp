//===-- SIMachineFunctionInfo.cpp -------- SI Machine Function Info -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "SIMachineFunctionInfo.h"
#include "AMDGPUSubtarget.h"
#include "SIInstrInfo.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/LLVMContext.h"

#define MAX_LANES 64

using namespace llvm;

SIMachineFunctionInfo::SIMachineFunctionInfo(const MachineFunction &MF)
  : AMDGPUMachineFunction(MF),
    TIDReg(AMDGPU::NoRegister),
    ScratchRSrcReg(AMDGPU::PRIVATE_RSRC_REG),
    ScratchWaveOffsetReg(AMDGPU::SCRATCH_WAVE_OFFSET_REG),
    FrameOffsetReg(AMDGPU::FP_REG),
    StackPtrOffsetReg(AMDGPU::SP_REG),
    ArgInfo(),
    PSInputAddr(0),
    PSInputEnable(0),
    ReturnsVoid(true),
    FlatWorkGroupSizes(0, 0),
    WavesPerEU(0, 0),
    DebuggerWorkGroupIDStackObjectIndices({{0, 0, 0}}),
    DebuggerWorkItemIDStackObjectIndices({{0, 0, 0}}),
    LDSWaveSpillSize(0),
    NumUserSGPRs(0),
    NumSystemSGPRs(0),
    HasSpilledSGPRs(false),
    HasSpilledVGPRs(false),
    HasNonSpillStackObjects(false),
    NumSpilledSGPRs(0),
    NumSpilledVGPRs(0),
    PrivateSegmentBuffer(false),
    DispatchPtr(false),
    QueuePtr(false),
    KernargSegmentPtr(false),
    DispatchID(false),
    FlatScratchInit(false),
    GridWorkgroupCountX(false),
    GridWorkgroupCountY(false),
    GridWorkgroupCountZ(false),
    WorkGroupIDX(false),
    WorkGroupIDY(false),
    WorkGroupIDZ(false),
    WorkGroupInfo(false),
    PrivateSegmentWaveByteOffset(false),
    WorkItemIDX(false),
    WorkItemIDY(false),
    WorkItemIDZ(false),
    ImplicitBufferPtr(false) {
  const SISubtarget &ST = MF.getSubtarget<SISubtarget>();
  const Function *F = MF.getFunction();
  FlatWorkGroupSizes = ST.getFlatWorkGroupSizes(*F);
  WavesPerEU = ST.getWavesPerEU(*F);

  if (!isEntryFunction()) {
    // Non-entry functions have no special inputs for now, other registers
    // required for scratch access.
    ScratchRSrcReg = AMDGPU::SGPR0_SGPR1_SGPR2_SGPR3;
    ScratchWaveOffsetReg = AMDGPU::SGPR4;
    FrameOffsetReg = AMDGPU::SGPR5;
    StackPtrOffsetReg = AMDGPU::SGPR32;

    ArgInfo.PrivateSegmentBuffer =
      ArgDescriptor::createRegister(ScratchRSrcReg);
    ArgInfo.PrivateSegmentWaveByteOffset =
      ArgDescriptor::createRegister(ScratchWaveOffsetReg);

    if (F->hasFnAttribute("amdgpu-implicitarg-ptr"))
      ImplicitArgPtr = true;
  } else {
    if (F->hasFnAttribute("amdgpu-implicitarg-ptr"))
      KernargSegmentPtr = true;
  }

  CallingConv::ID CC = F->getCallingConv();
  if (CC == CallingConv::AMDGPU_KERNEL || CC == CallingConv::SPIR_KERNEL) {
    if (!F->arg_empty())
      KernargSegmentPtr = true;
    WorkGroupIDX = true;
    WorkItemIDX = true;
  } else if (CC == CallingConv::AMDGPU_PS) {
    PSInputAddr = AMDGPU::getInitialPSInputAddr(*F);
  }

  if (ST.debuggerEmitPrologue()) {
    // Enable everything.
    WorkGroupIDX = true;
    WorkGroupIDY = true;
    WorkGroupIDZ = true;
    WorkItemIDX = true;
    WorkItemIDY = true;
    WorkItemIDZ = true;
  } else {
    if (F->hasFnAttribute("amdgpu-work-group-id-x"))
      WorkGroupIDX = true;

    if (F->hasFnAttribute("amdgpu-work-group-id-y"))
      WorkGroupIDY = true;

    if (F->hasFnAttribute("amdgpu-work-group-id-z"))
      WorkGroupIDZ = true;

    if (F->hasFnAttribute("amdgpu-work-item-id-x"))
      WorkItemIDX = true;

    if (F->hasFnAttribute("amdgpu-work-item-id-y"))
      WorkItemIDY = true;

    if (F->hasFnAttribute("amdgpu-work-item-id-z"))
      WorkItemIDZ = true;
  }

  const MachineFrameInfo &FrameInfo = MF.getFrameInfo();
  bool MaySpill = ST.isVGPRSpillingEnabled(*F);
  bool HasStackObjects = FrameInfo.hasStackObjects();

  if (isEntryFunction()) {
    // X, XY, and XYZ are the only supported combinations, so make sure Y is
    // enabled if Z is.
    if (WorkItemIDZ)
      WorkItemIDY = true;

    if (HasStackObjects || MaySpill) {
      PrivateSegmentWaveByteOffset = true;

    // HS and GS always have the scratch wave offset in SGPR5 on GFX9.
    if (ST.getGeneration() >= AMDGPUSubtarget::GFX9 &&
        (CC == CallingConv::AMDGPU_HS || CC == CallingConv::AMDGPU_GS))
      ArgInfo.PrivateSegmentWaveByteOffset
        = ArgDescriptor::createRegister(AMDGPU::SGPR5);
    }
  }

  bool IsCOV2 = ST.isAmdCodeObjectV2(MF);
  if (IsCOV2) {
    if (HasStackObjects || MaySpill)
      PrivateSegmentBuffer = true;

    if (F->hasFnAttribute("amdgpu-dispatch-ptr"))
      DispatchPtr = true;

    if (F->hasFnAttribute("amdgpu-queue-ptr"))
      QueuePtr = true;

    if (F->hasFnAttribute("amdgpu-dispatch-id"))
      DispatchID = true;
  } else if (ST.isMesaGfxShader(MF)) {
    if (HasStackObjects || MaySpill)
      ImplicitBufferPtr = true;
  }

  if (F->hasFnAttribute("amdgpu-kernarg-segment-ptr"))
    KernargSegmentPtr = true;

  if (ST.hasFlatAddressSpace() && isEntryFunction() && IsCOV2) {
    // TODO: This could be refined a lot. The attribute is a poor way of
    // detecting calls that may require it before argument lowering.
    if (HasStackObjects || F->hasFnAttribute("amdgpu-flat-scratch"))
      FlatScratchInit = true;
  }
}

unsigned SIMachineFunctionInfo::addPrivateSegmentBuffer(
  const SIRegisterInfo &TRI) {
  ArgInfo.PrivateSegmentBuffer =
    ArgDescriptor::createRegister(TRI.getMatchingSuperReg(
    getNextUserSGPR(), AMDGPU::sub0, &AMDGPU::SReg_128RegClass));
  NumUserSGPRs += 4;
  return ArgInfo.PrivateSegmentBuffer.getRegister();
}

unsigned SIMachineFunctionInfo::addDispatchPtr(const SIRegisterInfo &TRI) {
  ArgInfo.DispatchPtr = ArgDescriptor::createRegister(TRI.getMatchingSuperReg(
    getNextUserSGPR(), AMDGPU::sub0, &AMDGPU::SReg_64RegClass));
  NumUserSGPRs += 2;
  return ArgInfo.DispatchPtr.getRegister();
}

unsigned SIMachineFunctionInfo::addQueuePtr(const SIRegisterInfo &TRI) {
  ArgInfo.QueuePtr = ArgDescriptor::createRegister(TRI.getMatchingSuperReg(
    getNextUserSGPR(), AMDGPU::sub0, &AMDGPU::SReg_64RegClass));
  NumUserSGPRs += 2;
  return ArgInfo.QueuePtr.getRegister();
}

unsigned SIMachineFunctionInfo::addKernargSegmentPtr(const SIRegisterInfo &TRI) {
  ArgInfo.KernargSegmentPtr
    = ArgDescriptor::createRegister(TRI.getMatchingSuperReg(
    getNextUserSGPR(), AMDGPU::sub0, &AMDGPU::SReg_64RegClass));
  NumUserSGPRs += 2;
  return ArgInfo.KernargSegmentPtr.getRegister();
}

unsigned SIMachineFunctionInfo::addDispatchID(const SIRegisterInfo &TRI) {
  ArgInfo.DispatchID = ArgDescriptor::createRegister(TRI.getMatchingSuperReg(
    getNextUserSGPR(), AMDGPU::sub0, &AMDGPU::SReg_64RegClass));
  NumUserSGPRs += 2;
  return ArgInfo.DispatchID.getRegister();
}

unsigned SIMachineFunctionInfo::addFlatScratchInit(const SIRegisterInfo &TRI) {
  ArgInfo.FlatScratchInit = ArgDescriptor::createRegister(TRI.getMatchingSuperReg(
    getNextUserSGPR(), AMDGPU::sub0, &AMDGPU::SReg_64RegClass));
  NumUserSGPRs += 2;
  return ArgInfo.FlatScratchInit.getRegister();
}

unsigned SIMachineFunctionInfo::addImplicitBufferPtr(const SIRegisterInfo &TRI) {
  ArgInfo.ImplicitBufferPtr = ArgDescriptor::createRegister(TRI.getMatchingSuperReg(
    getNextUserSGPR(), AMDGPU::sub0, &AMDGPU::SReg_64RegClass));
  NumUserSGPRs += 2;
  return ArgInfo.ImplicitBufferPtr.getRegister();
}

static bool isCalleeSavedReg(const MCPhysReg *CSRegs, MCPhysReg Reg) {
  for (unsigned I = 0; CSRegs[I]; ++I) {
    if (CSRegs[I] == Reg)
      return true;
  }

  return false;
}

/// Reserve a slice of a VGPR to support spilling for FrameIndex \p FI.
bool SIMachineFunctionInfo::allocateSGPRSpillToVGPR(MachineFunction &MF,
                                                    int FI) {
  std::vector<SpilledReg> &SpillLanes = SGPRToVGPRSpills[FI];

  // This has already been allocated.
  if (!SpillLanes.empty())
    return true;

  const SISubtarget &ST = MF.getSubtarget<SISubtarget>();
  const SIRegisterInfo *TRI = ST.getRegisterInfo();
  MachineFrameInfo &FrameInfo = MF.getFrameInfo();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  unsigned WaveSize = ST.getWavefrontSize();

  unsigned Size = FrameInfo.getObjectSize(FI);
  assert(Size >= 4 && Size <= 64 && "invalid sgpr spill size");
  assert(TRI->spillSGPRToVGPR() && "not spilling SGPRs to VGPRs");

  int NumLanes = Size / 4;

  const MCPhysReg *CSRegs = TRI->getCalleeSavedRegs(&MF);

  // Make sure to handle the case where a wide SGPR spill may span between two
  // VGPRs.
  for (int I = 0; I < NumLanes; ++I, ++NumVGPRSpillLanes) {
    unsigned LaneVGPR;
    unsigned VGPRIndex = (NumVGPRSpillLanes % WaveSize);

    if (VGPRIndex == 0) {
      LaneVGPR = TRI->findUnusedRegister(MRI, &AMDGPU::VGPR_32RegClass, MF);
      if (LaneVGPR == AMDGPU::NoRegister) {
        // We have no VGPRs left for spilling SGPRs. Reset because we won't
        // partially spill the SGPR to VGPRs.
        SGPRToVGPRSpills.erase(FI);
        NumVGPRSpillLanes -= I;
        return false;
      }

      Optional<int> CSRSpillFI;
      if (FrameInfo.hasCalls() && CSRegs && isCalleeSavedReg(CSRegs, LaneVGPR)) {
        // TODO: Should this be a CreateSpillStackObject? This is technically a
        // weird CSR spill.
        CSRSpillFI = FrameInfo.CreateStackObject(4, 4, false);
      }

      SpillVGPRs.push_back(SGPRSpillVGPRCSR(LaneVGPR, CSRSpillFI));

      // Add this register as live-in to all blocks to avoid machine verifer
      // complaining about use of an undefined physical register.
      for (MachineBasicBlock &BB : MF)
        BB.addLiveIn(LaneVGPR);
    } else {
      LaneVGPR = SpillVGPRs.back().VGPR;
    }

    SpillLanes.push_back(SpilledReg(LaneVGPR, VGPRIndex));
  }

  return true;
}

void SIMachineFunctionInfo::removeSGPRToVGPRFrameIndices(MachineFrameInfo &MFI) {
  for (auto &R : SGPRToVGPRSpills)
    MFI.RemoveStackObject(R.first);
}
