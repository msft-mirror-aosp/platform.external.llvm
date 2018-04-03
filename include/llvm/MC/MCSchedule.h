//===-- llvm/MC/MCSchedule.h - Scheduling -----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines the classes used to describe a subtarget's machine model
// for scheduling and other instruction cost heuristics.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCSCHEDULE_H
#define LLVM_MC_MCSCHEDULE_H

#include "llvm/ADT/Optional.h"
#include "llvm/Support/DataTypes.h"
#include <cassert>

namespace llvm {

struct InstrItinerary;
class MCSubtargetInfo;

/// Define a kind of processor resource that will be modeled by the scheduler.
struct MCProcResourceDesc {
  const char *Name;
  unsigned NumUnits; // Number of resource of this kind
  unsigned SuperIdx; // Index of the resources kind that contains this kind.

  // Number of resources that may be buffered.
  //
  // Buffered resources (BufferSize != 0) may be consumed at some indeterminate
  // cycle after dispatch. This should be used for out-of-order cpus when
  // instructions that use this resource can be buffered in a reservaton
  // station.
  //
  // Unbuffered resources (BufferSize == 0) always consume their resource some
  // fixed number of cycles after dispatch. If a resource is unbuffered, then
  // the scheduler will avoid scheduling instructions with conflicting resources
  // in the same cycle. This is for in-order cpus, or the in-order portion of
  // an out-of-order cpus.
  int BufferSize;

  // If the resource has sub-units, a pointer to the first element of an array
  // of `NumUnits` elements containing the ProcResourceIdx of the sub units.
  // nullptr if the resource does not have sub-units.
  const unsigned *SubUnitsIdxBegin;

  bool operator==(const MCProcResourceDesc &Other) const {
    return NumUnits == Other.NumUnits && SuperIdx == Other.SuperIdx
      && BufferSize == Other.BufferSize;
  }
};

/// Identify one of the processor resource kinds consumed by a particular
/// scheduling class for the specified number of cycles.
struct MCWriteProcResEntry {
  uint16_t ProcResourceIdx;
  uint16_t Cycles;

  bool operator==(const MCWriteProcResEntry &Other) const {
    return ProcResourceIdx == Other.ProcResourceIdx && Cycles == Other.Cycles;
  }
};

/// Specify the latency in cpu cycles for a particular scheduling class and def
/// index. -1 indicates an invalid latency. Heuristics would typically consider
/// an instruction with invalid latency to have infinite latency.  Also identify
/// the WriteResources of this def. When the operand expands to a sequence of
/// writes, this ID is the last write in the sequence.
struct MCWriteLatencyEntry {
  int16_t Cycles;
  uint16_t WriteResourceID;

  bool operator==(const MCWriteLatencyEntry &Other) const {
    return Cycles == Other.Cycles && WriteResourceID == Other.WriteResourceID;
  }
};

/// Specify the number of cycles allowed after instruction issue before a
/// particular use operand reads its registers. This effectively reduces the
/// write's latency. Here we allow negative cycles for corner cases where
/// latency increases. This rule only applies when the entry's WriteResource
/// matches the write's WriteResource.
///
/// MCReadAdvanceEntries are sorted first by operand index (UseIdx), then by
/// WriteResourceIdx.
struct MCReadAdvanceEntry {
  unsigned UseIdx;
  unsigned WriteResourceID;
  int Cycles;

  bool operator==(const MCReadAdvanceEntry &Other) const {
    return UseIdx == Other.UseIdx && WriteResourceID == Other.WriteResourceID
      && Cycles == Other.Cycles;
  }
};

/// Summarize the scheduling resources required for an instruction of a
/// particular scheduling class.
///
/// Defined as an aggregate struct for creating tables with initializer lists.
struct MCSchedClassDesc {
  static const unsigned short InvalidNumMicroOps = (1U << 14) - 1;
  static const unsigned short VariantNumMicroOps = InvalidNumMicroOps - 1;

#if !defined(NDEBUG) || defined(LLVM_ENABLE_DUMP)
  const char* Name;
#endif
  uint16_t NumMicroOps : 14;
  bool     BeginGroup : 1;
  bool     EndGroup : 1;
  uint16_t WriteProcResIdx; // First index into WriteProcResTable.
  uint16_t NumWriteProcResEntries;
  uint16_t WriteLatencyIdx; // First index into WriteLatencyTable.
  uint16_t NumWriteLatencyEntries;
  uint16_t ReadAdvanceIdx; // First index into ReadAdvanceTable.
  uint16_t NumReadAdvanceEntries;

  bool isValid() const {
    return NumMicroOps != InvalidNumMicroOps;
  }
  bool isVariant() const {
    return NumMicroOps == VariantNumMicroOps;
  }
};

/// Specify the cost of a register definition in terms of number of physical
/// register allocated at register renaming stage. For example, AMD Jaguar.
/// natively supports 128-bit data types, and operations on 256-bit registers
/// (i.e. YMM registers) are internally split into two COPs (complex operations)
/// and each COP updates a physical register. Basically, on Jaguar, a YMM
/// register write effectively consumes two physical registers. That means,
/// the cost of a YMM write in the BtVer2 model is 2.
struct MCRegisterCostEntry {
  unsigned RegisterClassID;
  unsigned Cost;
};

/// A register file descriptor.
///
/// This struct allows to describe processor register files. In particular, it
/// helps describing the size of the register file, as well as the cost of
/// allocating a register file at register renaming stage.
/// FIXME: this struct can be extended to provide information about the number
/// of read/write ports to the register file.  A value of zero for field
/// 'NumPhysRegs' means: this register file has an unbounded number of physical
/// registers.
struct MCRegisterFileDesc {
  const char *Name;
  uint16_t NumPhysRegs;
  uint16_t NumRegisterCostEntries;
  // Index of the first cost entry in MCExtraProcessorInfo::RegisterCostTable.
  uint16_t RegisterCostEntryIdx;
};

/// Provide extra details about the machine processor.
///
/// This is a collection of "optional" processor information that is not
/// normally used by the LLVM machine schedulers, but that can be consumed by
/// external tools like llvm-mca to improve the quality of the peformance
/// analysis.
/// In future, the plan is to extend this struct with extra information (for
/// example: maximum number of instructions retired per cycle; actual size of
/// the reorder buffer; etc.).
struct MCExtraProcessorInfo {
  const MCRegisterFileDesc *RegisterFiles;
  unsigned NumRegisterFiles;
  const MCRegisterCostEntry *RegisterCostTable;
  unsigned NumRegisterCostEntries;
};

/// Machine model for scheduling, bundling, and heuristics.
///
/// The machine model directly provides basic information about the
/// microarchitecture to the scheduler in the form of properties. It also
/// optionally refers to scheduler resource tables and itinerary
/// tables. Scheduler resource tables model the latency and cost for each
/// instruction type. Itinerary tables are an independent mechanism that
/// provides a detailed reservation table describing each cycle of instruction
/// execution. Subtargets may define any or all of the above categories of data
/// depending on the type of CPU and selected scheduler.
struct MCSchedModel {
  // IssueWidth is the maximum number of instructions that may be scheduled in
  // the same per-cycle group.
  unsigned IssueWidth;
  static const unsigned DefaultIssueWidth = 1;

  // MicroOpBufferSize is the number of micro-ops that the processor may buffer
  // for out-of-order execution.
  //
  // "0" means operations that are not ready in this cycle are not considered
  // for scheduling (they go in the pending queue). Latency is paramount. This
  // may be more efficient if many instructions are pending in a schedule.
  //
  // "1" means all instructions are considered for scheduling regardless of
  // whether they are ready in this cycle. Latency still causes issue stalls,
  // but we balance those stalls against other heuristics.
  //
  // "> 1" means the processor is out-of-order. This is a machine independent
  // estimate of highly machine specific characteristics such as the register
  // renaming pool and reorder buffer.
  unsigned MicroOpBufferSize;
  static const unsigned DefaultMicroOpBufferSize = 0;

  // LoopMicroOpBufferSize is the number of micro-ops that the processor may
  // buffer for optimized loop execution. More generally, this represents the
  // optimal number of micro-ops in a loop body. A loop may be partially
  // unrolled to bring the count of micro-ops in the loop body closer to this
  // number.
  unsigned LoopMicroOpBufferSize;
  static const unsigned DefaultLoopMicroOpBufferSize = 0;

  // LoadLatency is the expected latency of load instructions.
  unsigned LoadLatency;
  static const unsigned DefaultLoadLatency = 4;

  // HighLatency is the expected latency of "very high latency" operations.
  // See TargetInstrInfo::isHighLatencyDef().
  // By default, this is set to an arbitrarily high number of cycles
  // likely to have some impact on scheduling heuristics.
  unsigned HighLatency;
  static const unsigned DefaultHighLatency = 10;

  // MispredictPenalty is the typical number of extra cycles the processor
  // takes to recover from a branch misprediction.
  unsigned MispredictPenalty;
  static const unsigned DefaultMispredictPenalty = 10;

  bool PostRAScheduler; // default value is false

  bool CompleteModel;

  unsigned ProcID;
  const MCProcResourceDesc *ProcResourceTable;
  const MCSchedClassDesc *SchedClassTable;
  unsigned NumProcResourceKinds;
  unsigned NumSchedClasses;
  // Instruction itinerary tables used by InstrItineraryData.
  friend class InstrItineraryData;
  const InstrItinerary *InstrItineraries;

  const MCExtraProcessorInfo *ExtraProcessorInfo;

  bool hasExtraProcessorInfo() const { return ExtraProcessorInfo; }

  unsigned getProcessorID() const { return ProcID; }

  /// Does this machine model include instruction-level scheduling.
  bool hasInstrSchedModel() const { return SchedClassTable; }

  const MCExtraProcessorInfo &getExtraProcessorInfo() const {
    assert(hasExtraProcessorInfo() &&
           "No extra information available for this model");
    return *ExtraProcessorInfo;
  }

  /// Return true if this machine model data for all instructions with a
  /// scheduling class (itinerary class or SchedRW list).
  bool isComplete() const { return CompleteModel; }

  /// Return true if machine supports out of order execution.
  bool isOutOfOrder() const { return MicroOpBufferSize > 1; }

  unsigned getNumProcResourceKinds() const {
    return NumProcResourceKinds;
  }

  const MCProcResourceDesc *getProcResource(unsigned ProcResourceIdx) const {
    assert(hasInstrSchedModel() && "No scheduling machine model");

    assert(ProcResourceIdx < NumProcResourceKinds && "bad proc resource idx");
    return &ProcResourceTable[ProcResourceIdx];
  }

  const MCSchedClassDesc *getSchedClassDesc(unsigned SchedClassIdx) const {
    assert(hasInstrSchedModel() && "No scheduling machine model");

    assert(SchedClassIdx < NumSchedClasses && "bad scheduling class idx");
    return &SchedClassTable[SchedClassIdx];
  }

  /// Returns the latency value for the scheduling class.
  static int computeInstrLatency(const MCSubtargetInfo &STI,
                                 const MCSchedClassDesc &SCDesc);

  /// Returns the reciprocal throughput information from a MCSchedClassDesc.
  static Optional<double>
  getReciprocalThroughput(const MCSubtargetInfo &STI,
                          const MCSchedClassDesc &SCDesc);

  /// Returns the default initialized model.
  static const MCSchedModel &GetDefaultSchedModel() { return Default; }
  static const MCSchedModel Default;
};

} // End llvm namespace

#endif
