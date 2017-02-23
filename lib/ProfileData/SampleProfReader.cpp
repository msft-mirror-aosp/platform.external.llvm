//===- SampleProfReader.cpp - Read LLVM sample profile data ---------------===//
//
//                      The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the class that reads LLVM sample profiles. It
// supports three file formats: text, binary and gcov.
//
// The textual representation is useful for debugging and testing purposes. The
// binary representation is more compact, resulting in smaller file sizes.
//
// The gcov encoding is the one generated by GCC's AutoFDO profile creation
// tool (https://github.com/google/autofdo)
//
// All three encodings can be used interchangeably as an input sample profile.
//
//===----------------------------------------------------------------------===//

#include "llvm/ProfileData/SampleProfReader.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorOr.h"
#include "llvm/Support/LEB128.h"
#include "llvm/Support/LineIterator.h"
#include "llvm/Support/MemoryBuffer.h"

using namespace llvm::sampleprof;
using namespace llvm;

/// \brief Dump the function profile for \p FName.
///
/// \param FName Name of the function to print.
/// \param OS Stream to emit the output to.
void SampleProfileReader::dumpFunctionProfile(StringRef FName,
                                              raw_ostream &OS) {
  OS << "Function: " << FName << ": " << Profiles[FName];
}

/// \brief Dump all the function profiles found on stream \p OS.
void SampleProfileReader::dump(raw_ostream &OS) {
  for (const auto &I : Profiles)
    dumpFunctionProfile(I.getKey(), OS);
}

/// \brief Parse \p Input as function head.
///
/// Parse one line of \p Input, and update function name in \p FName,
/// function's total sample count in \p NumSamples, function's entry
/// count in \p NumHeadSamples.
///
/// \returns true if parsing is successful.
static bool ParseHead(const StringRef &Input, StringRef &FName,
                      uint64_t &NumSamples, uint64_t &NumHeadSamples) {
  if (Input[0] == ' ')
    return false;
  size_t n2 = Input.rfind(':');
  size_t n1 = Input.rfind(':', n2 - 1);
  FName = Input.substr(0, n1);
  if (Input.substr(n1 + 1, n2 - n1 - 1).getAsInteger(10, NumSamples))
    return false;
  if (Input.substr(n2 + 1).getAsInteger(10, NumHeadSamples))
    return false;
  return true;
}

/// \brief Returns true if line offset \p L is legal (only has 16 bits).
static bool isOffsetLegal(unsigned L) { return (L & 0xffff) == L; }

/// \brief Parse \p Input as line sample.
///
/// \param Input input line.
/// \param IsCallsite true if the line represents an inlined callsite.
/// \param Depth the depth of the inline stack.
/// \param NumSamples total samples of the line/inlined callsite.
/// \param LineOffset line offset to the start of the function.
/// \param Discriminator discriminator of the line.
/// \param TargetCountMap map from indirect call target to count.
///
/// returns true if parsing is successful.
static bool ParseLine(const StringRef &Input, bool &IsCallsite, uint32_t &Depth,
                      uint64_t &NumSamples, uint32_t &LineOffset,
                      uint32_t &Discriminator, StringRef &CalleeName,
                      DenseMap<StringRef, uint64_t> &TargetCountMap) {
  for (Depth = 0; Input[Depth] == ' '; Depth++)
    ;
  if (Depth == 0)
    return false;

  size_t n1 = Input.find(':');
  StringRef Loc = Input.substr(Depth, n1 - Depth);
  size_t n2 = Loc.find('.');
  if (n2 == StringRef::npos) {
    if (Loc.getAsInteger(10, LineOffset) || !isOffsetLegal(LineOffset))
      return false;
    Discriminator = 0;
  } else {
    if (Loc.substr(0, n2).getAsInteger(10, LineOffset))
      return false;
    if (Loc.substr(n2 + 1).getAsInteger(10, Discriminator))
      return false;
  }

  StringRef Rest = Input.substr(n1 + 2);
  if (Rest[0] >= '0' && Rest[0] <= '9') {
    IsCallsite = false;
    size_t n3 = Rest.find(' ');
    if (n3 == StringRef::npos) {
      if (Rest.getAsInteger(10, NumSamples))
        return false;
    } else {
      if (Rest.substr(0, n3).getAsInteger(10, NumSamples))
        return false;
    }
    while (n3 != StringRef::npos) {
      n3 += Rest.substr(n3).find_first_not_of(' ');
      Rest = Rest.substr(n3);
      n3 = Rest.find(' ');
      StringRef pair = Rest;
      if (n3 != StringRef::npos) {
        pair = Rest.substr(0, n3);
      }
      size_t n4 = pair.find(':');
      uint64_t count;
      if (pair.substr(n4 + 1).getAsInteger(10, count))
        return false;
      TargetCountMap[pair.substr(0, n4)] = count;
    }
  } else {
    IsCallsite = true;
    size_t n3 = Rest.find_last_of(':');
    CalleeName = Rest.substr(0, n3);
    if (Rest.substr(n3 + 1).getAsInteger(10, NumSamples))
      return false;
  }
  return true;
}

/// \brief Load samples from a text file.
///
/// See the documentation at the top of the file for an explanation of
/// the expected format.
///
/// \returns true if the file was loaded successfully, false otherwise.
std::error_code SampleProfileReaderText::read() {
  line_iterator LineIt(*Buffer, /*SkipBlanks=*/true, '#');
  sampleprof_error Result = sampleprof_error::success;

  InlineCallStack InlineStack;

  for (; !LineIt.is_at_eof(); ++LineIt) {
    if ((*LineIt)[(*LineIt).find_first_not_of(' ')] == '#')
      continue;
    // Read the header of each function.
    //
    // Note that for function identifiers we are actually expecting
    // mangled names, but we may not always get them. This happens when
    // the compiler decides not to emit the function (e.g., it was inlined
    // and removed). In this case, the binary will not have the linkage
    // name for the function, so the profiler will emit the function's
    // unmangled name, which may contain characters like ':' and '>' in its
    // name (member functions, templates, etc).
    //
    // The only requirement we place on the identifier, then, is that it
    // should not begin with a number.
    if ((*LineIt)[0] != ' ') {
      uint64_t NumSamples, NumHeadSamples;
      StringRef FName;
      if (!ParseHead(*LineIt, FName, NumSamples, NumHeadSamples)) {
        reportError(LineIt.line_number(),
                    "Expected 'mangled_name:NUM:NUM', found " + *LineIt);
        return sampleprof_error::malformed;
      }
      Profiles[FName] = FunctionSamples();
      FunctionSamples &FProfile = Profiles[FName];
      FProfile.setName(FName);
      MergeResult(Result, FProfile.addTotalSamples(NumSamples));
      MergeResult(Result, FProfile.addHeadSamples(NumHeadSamples));
      InlineStack.clear();
      InlineStack.push_back(&FProfile);
    } else {
      uint64_t NumSamples;
      StringRef FName;
      DenseMap<StringRef, uint64_t> TargetCountMap;
      bool IsCallsite;
      uint32_t Depth, LineOffset, Discriminator;
      if (!ParseLine(*LineIt, IsCallsite, Depth, NumSamples, LineOffset,
                     Discriminator, FName, TargetCountMap)) {
        reportError(LineIt.line_number(),
                    "Expected 'NUM[.NUM]: NUM[ mangled_name:NUM]*', found " +
                        *LineIt);
        return sampleprof_error::malformed;
      }
      if (IsCallsite) {
        while (InlineStack.size() > Depth) {
          InlineStack.pop_back();
        }
        FunctionSamples &FSamples = InlineStack.back()->functionSamplesAt(
            LineLocation(LineOffset, Discriminator));
        FSamples.setName(FName);
        MergeResult(Result, FSamples.addTotalSamples(NumSamples));
        InlineStack.push_back(&FSamples);
      } else {
        while (InlineStack.size() > Depth) {
          InlineStack.pop_back();
        }
        FunctionSamples &FProfile = *InlineStack.back();
        for (const auto &name_count : TargetCountMap) {
          MergeResult(Result, FProfile.addCalledTargetSamples(
                                  LineOffset, Discriminator, name_count.first,
                                  name_count.second));
        }
        MergeResult(Result, FProfile.addBodySamples(LineOffset, Discriminator,
                                                    NumSamples));
      }
    }
  }
  if (Result == sampleprof_error::success)
    computeSummary();

  return Result;
}

bool SampleProfileReaderText::hasFormat(const MemoryBuffer &Buffer) {
  bool result = false;

  // Check that the first non-comment line is a valid function header.
  line_iterator LineIt(Buffer, /*SkipBlanks=*/true, '#');
  if (!LineIt.is_at_eof()) {
    if ((*LineIt)[0] != ' ') {
      uint64_t NumSamples, NumHeadSamples;
      StringRef FName;
      result = ParseHead(*LineIt, FName, NumSamples, NumHeadSamples);
    }
  }

  return result;
}

template <typename T> ErrorOr<T> SampleProfileReaderBinary::readNumber() {
  unsigned NumBytesRead = 0;
  std::error_code EC;
  uint64_t Val = decodeULEB128(Data, &NumBytesRead);

  if (Val > std::numeric_limits<T>::max())
    EC = sampleprof_error::malformed;
  else if (Data + NumBytesRead > End)
    EC = sampleprof_error::truncated;
  else
    EC = sampleprof_error::success;

  if (EC) {
    reportError(0, EC.message());
    return EC;
  }

  Data += NumBytesRead;
  return static_cast<T>(Val);
}

ErrorOr<StringRef> SampleProfileReaderBinary::readString() {
  std::error_code EC;
  StringRef Str(reinterpret_cast<const char *>(Data));
  if (Data + Str.size() + 1 > End) {
    EC = sampleprof_error::truncated;
    reportError(0, EC.message());
    return EC;
  }

  Data += Str.size() + 1;
  return Str;
}

ErrorOr<StringRef> SampleProfileReaderBinary::readStringFromTable() {
  std::error_code EC;
  auto Idx = readNumber<uint32_t>();
  if (std::error_code EC = Idx.getError())
    return EC;
  if (*Idx >= NameTable.size())
    return sampleprof_error::truncated_name_table;
  return NameTable[*Idx];
}

std::error_code
SampleProfileReaderBinary::readProfile(FunctionSamples &FProfile) {
  auto NumSamples = readNumber<uint64_t>();
  if (std::error_code EC = NumSamples.getError())
    return EC;
  FProfile.addTotalSamples(*NumSamples);

  // Read the samples in the body.
  auto NumRecords = readNumber<uint32_t>();
  if (std::error_code EC = NumRecords.getError())
    return EC;

  for (uint32_t I = 0; I < *NumRecords; ++I) {
    auto LineOffset = readNumber<uint64_t>();
    if (std::error_code EC = LineOffset.getError())
      return EC;

    if (!isOffsetLegal(*LineOffset)) {
      return std::error_code();
    }

    auto Discriminator = readNumber<uint64_t>();
    if (std::error_code EC = Discriminator.getError())
      return EC;

    auto NumSamples = readNumber<uint64_t>();
    if (std::error_code EC = NumSamples.getError())
      return EC;

    auto NumCalls = readNumber<uint32_t>();
    if (std::error_code EC = NumCalls.getError())
      return EC;

    for (uint32_t J = 0; J < *NumCalls; ++J) {
      auto CalledFunction(readStringFromTable());
      if (std::error_code EC = CalledFunction.getError())
        return EC;

      auto CalledFunctionSamples = readNumber<uint64_t>();
      if (std::error_code EC = CalledFunctionSamples.getError())
        return EC;

      FProfile.addCalledTargetSamples(*LineOffset, *Discriminator,
                                      *CalledFunction, *CalledFunctionSamples);
    }

    FProfile.addBodySamples(*LineOffset, *Discriminator, *NumSamples);
  }

  // Read all the samples for inlined function calls.
  auto NumCallsites = readNumber<uint32_t>();
  if (std::error_code EC = NumCallsites.getError())
    return EC;

  for (uint32_t J = 0; J < *NumCallsites; ++J) {
    auto LineOffset = readNumber<uint64_t>();
    if (std::error_code EC = LineOffset.getError())
      return EC;

    auto Discriminator = readNumber<uint64_t>();
    if (std::error_code EC = Discriminator.getError())
      return EC;

    auto FName(readStringFromTable());
    if (std::error_code EC = FName.getError())
      return EC;

    FunctionSamples &CalleeProfile =
        FProfile.functionSamplesAt(LineLocation(*LineOffset, *Discriminator));
    CalleeProfile.setName(*FName);
    if (std::error_code EC = readProfile(CalleeProfile))
      return EC;
  }

  return sampleprof_error::success;
}

std::error_code SampleProfileReaderBinary::read() {
  while (!at_eof()) {
    auto NumHeadSamples = readNumber<uint64_t>();
    if (std::error_code EC = NumHeadSamples.getError())
      return EC;

    auto FName(readStringFromTable());
    if (std::error_code EC = FName.getError())
      return EC;

    Profiles[*FName] = FunctionSamples();
    FunctionSamples &FProfile = Profiles[*FName];
    FProfile.setName(*FName);

    FProfile.addHeadSamples(*NumHeadSamples);

    if (std::error_code EC = readProfile(FProfile))
      return EC;
  }

  return sampleprof_error::success;
}

std::error_code SampleProfileReaderBinary::readHeader() {
  Data = reinterpret_cast<const uint8_t *>(Buffer->getBufferStart());
  End = Data + Buffer->getBufferSize();

  // Read and check the magic identifier.
  auto Magic = readNumber<uint64_t>();
  if (std::error_code EC = Magic.getError())
    return EC;
  else if (*Magic != SPMagic())
    return sampleprof_error::bad_magic;

  // Read the version number.
  auto Version = readNumber<uint64_t>();
  if (std::error_code EC = Version.getError())
    return EC;
  else if (*Version != SPVersion())
    return sampleprof_error::unsupported_version;

  if (std::error_code EC = readSummary())
    return EC;

  // Read the name table.
  auto Size = readNumber<uint32_t>();
  if (std::error_code EC = Size.getError())
    return EC;
  NameTable.reserve(*Size);
  for (uint32_t I = 0; I < *Size; ++I) {
    auto Name(readString());
    if (std::error_code EC = Name.getError())
      return EC;
    NameTable.push_back(*Name);
  }

  return sampleprof_error::success;
}

std::error_code SampleProfileReaderBinary::readSummaryEntry(
    std::vector<ProfileSummaryEntry> &Entries) {
  auto Cutoff = readNumber<uint64_t>();
  if (std::error_code EC = Cutoff.getError())
    return EC;

  auto MinBlockCount = readNumber<uint64_t>();
  if (std::error_code EC = MinBlockCount.getError())
    return EC;

  auto NumBlocks = readNumber<uint64_t>();
  if (std::error_code EC = NumBlocks.getError())
    return EC;

  Entries.emplace_back(*Cutoff, *MinBlockCount, *NumBlocks);
  return sampleprof_error::success;
}

std::error_code SampleProfileReaderBinary::readSummary() {
  auto TotalCount = readNumber<uint64_t>();
  if (std::error_code EC = TotalCount.getError())
    return EC;

  auto MaxBlockCount = readNumber<uint64_t>();
  if (std::error_code EC = MaxBlockCount.getError())
    return EC;

  auto MaxFunctionCount = readNumber<uint64_t>();
  if (std::error_code EC = MaxFunctionCount.getError())
    return EC;

  auto NumBlocks = readNumber<uint64_t>();
  if (std::error_code EC = NumBlocks.getError())
    return EC;

  auto NumFunctions = readNumber<uint64_t>();
  if (std::error_code EC = NumFunctions.getError())
    return EC;

  auto NumSummaryEntries = readNumber<uint64_t>();
  if (std::error_code EC = NumSummaryEntries.getError())
    return EC;

  std::vector<ProfileSummaryEntry> Entries;
  for (unsigned i = 0; i < *NumSummaryEntries; i++) {
    std::error_code EC = readSummaryEntry(Entries);
    if (EC != sampleprof_error::success)
      return EC;
  }
  Summary = llvm::make_unique<ProfileSummary>(
      ProfileSummary::PSK_Sample, Entries, *TotalCount, *MaxBlockCount, 0,
      *MaxFunctionCount, *NumBlocks, *NumFunctions);

  return sampleprof_error::success;
}

bool SampleProfileReaderBinary::hasFormat(const MemoryBuffer &Buffer) {
  const uint8_t *Data =
      reinterpret_cast<const uint8_t *>(Buffer.getBufferStart());
  uint64_t Magic = decodeULEB128(Data);
  return Magic == SPMagic();
}

std::error_code SampleProfileReaderGCC::skipNextWord() {
  uint32_t dummy;
  if (!GcovBuffer.readInt(dummy))
    return sampleprof_error::truncated;
  return sampleprof_error::success;
}

template <typename T> ErrorOr<T> SampleProfileReaderGCC::readNumber() {
  if (sizeof(T) <= sizeof(uint32_t)) {
    uint32_t Val;
    if (GcovBuffer.readInt(Val) && Val <= std::numeric_limits<T>::max())
      return static_cast<T>(Val);
  } else if (sizeof(T) <= sizeof(uint64_t)) {
    uint64_t Val;
    if (GcovBuffer.readInt64(Val) && Val <= std::numeric_limits<T>::max())
      return static_cast<T>(Val);
  }

  std::error_code EC = sampleprof_error::malformed;
  reportError(0, EC.message());
  return EC;
}

ErrorOr<StringRef> SampleProfileReaderGCC::readString() {
  StringRef Str;
  if (!GcovBuffer.readString(Str))
    return sampleprof_error::truncated;
  return Str;
}

std::error_code SampleProfileReaderGCC::readHeader() {
  // Read the magic identifier.
  if (!GcovBuffer.readGCDAFormat())
    return sampleprof_error::unrecognized_format;

  // Read the version number. Note - the GCC reader does not validate this
  // version, but the profile creator generates v704.
  GCOV::GCOVVersion version;
  if (!GcovBuffer.readGCOVVersion(version))
    return sampleprof_error::unrecognized_format;

  if (version != GCOV::V704)
    return sampleprof_error::unsupported_version;

  // Skip the empty integer.
  if (std::error_code EC = skipNextWord())
    return EC;

  return sampleprof_error::success;
}

std::error_code SampleProfileReaderGCC::readSectionTag(uint32_t Expected) {
  uint32_t Tag;
  if (!GcovBuffer.readInt(Tag))
    return sampleprof_error::truncated;

  if (Tag != Expected)
    return sampleprof_error::malformed;

  if (std::error_code EC = skipNextWord())
    return EC;

  return sampleprof_error::success;
}

std::error_code SampleProfileReaderGCC::readNameTable() {
  if (std::error_code EC = readSectionTag(GCOVTagAFDOFileNames))
    return EC;

  uint32_t Size;
  if (!GcovBuffer.readInt(Size))
    return sampleprof_error::truncated;

  for (uint32_t I = 0; I < Size; ++I) {
    StringRef Str;
    if (!GcovBuffer.readString(Str))
      return sampleprof_error::truncated;
    Names.push_back(Str);
  }

  return sampleprof_error::success;
}

std::error_code SampleProfileReaderGCC::readFunctionProfiles() {
  if (std::error_code EC = readSectionTag(GCOVTagAFDOFunction))
    return EC;

  uint32_t NumFunctions;
  if (!GcovBuffer.readInt(NumFunctions))
    return sampleprof_error::truncated;

  InlineCallStack Stack;
  for (uint32_t I = 0; I < NumFunctions; ++I)
    if (std::error_code EC = readOneFunctionProfile(Stack, true, 0))
      return EC;

  computeSummary();
  return sampleprof_error::success;
}

std::error_code SampleProfileReaderGCC::readOneFunctionProfile(
    const InlineCallStack &InlineStack, bool Update, uint32_t Offset) {
  uint64_t HeadCount = 0;
  if (InlineStack.size() == 0)
    if (!GcovBuffer.readInt64(HeadCount))
      return sampleprof_error::truncated;

  uint32_t NameIdx;
  if (!GcovBuffer.readInt(NameIdx))
    return sampleprof_error::truncated;

  StringRef Name(Names[NameIdx]);

  uint32_t NumPosCounts;
  if (!GcovBuffer.readInt(NumPosCounts))
    return sampleprof_error::truncated;

  uint32_t NumCallsites;
  if (!GcovBuffer.readInt(NumCallsites))
    return sampleprof_error::truncated;

  FunctionSamples *FProfile = nullptr;
  if (InlineStack.size() == 0) {
    // If this is a top function that we have already processed, do not
    // update its profile again.  This happens in the presence of
    // function aliases.  Since these aliases share the same function
    // body, there will be identical replicated profiles for the
    // original function.  In this case, we simply not bother updating
    // the profile of the original function.
    FProfile = &Profiles[Name];
    FProfile->addHeadSamples(HeadCount);
    if (FProfile->getTotalSamples() > 0)
      Update = false;
  } else {
    // Otherwise, we are reading an inlined instance. The top of the
    // inline stack contains the profile of the caller. Insert this
    // callee in the caller's CallsiteMap.
    FunctionSamples *CallerProfile = InlineStack.front();
    uint32_t LineOffset = Offset >> 16;
    uint32_t Discriminator = Offset & 0xffff;
    FProfile = &CallerProfile->functionSamplesAt(
        LineLocation(LineOffset, Discriminator));
  }
  FProfile->setName(Name);

  for (uint32_t I = 0; I < NumPosCounts; ++I) {
    uint32_t Offset;
    if (!GcovBuffer.readInt(Offset))
      return sampleprof_error::truncated;

    uint32_t NumTargets;
    if (!GcovBuffer.readInt(NumTargets))
      return sampleprof_error::truncated;

    uint64_t Count;
    if (!GcovBuffer.readInt64(Count))
      return sampleprof_error::truncated;

    // The line location is encoded in the offset as:
    //   high 16 bits: line offset to the start of the function.
    //   low 16 bits: discriminator.
    uint32_t LineOffset = Offset >> 16;
    uint32_t Discriminator = Offset & 0xffff;

    InlineCallStack NewStack;
    NewStack.push_back(FProfile);
    NewStack.insert(NewStack.end(), InlineStack.begin(), InlineStack.end());
    if (Update) {
      // Walk up the inline stack, adding the samples on this line to
      // the total sample count of the callers in the chain.
      for (auto CallerProfile : NewStack)
        CallerProfile->addTotalSamples(Count);

      // Update the body samples for the current profile.
      FProfile->addBodySamples(LineOffset, Discriminator, Count);
    }

    // Process the list of functions called at an indirect call site.
    // These are all the targets that a function pointer (or virtual
    // function) resolved at runtime.
    for (uint32_t J = 0; J < NumTargets; J++) {
      uint32_t HistVal;
      if (!GcovBuffer.readInt(HistVal))
        return sampleprof_error::truncated;

      if (HistVal != HIST_TYPE_INDIR_CALL_TOPN)
        return sampleprof_error::malformed;

      uint64_t TargetIdx;
      if (!GcovBuffer.readInt64(TargetIdx))
        return sampleprof_error::truncated;
      StringRef TargetName(Names[TargetIdx]);

      uint64_t TargetCount;
      if (!GcovBuffer.readInt64(TargetCount))
        return sampleprof_error::truncated;

      if (Update)
        FProfile->addCalledTargetSamples(LineOffset, Discriminator,
                                         TargetName, TargetCount);
    }
  }

  // Process all the inlined callers into the current function. These
  // are all the callsites that were inlined into this function.
  for (uint32_t I = 0; I < NumCallsites; I++) {
    // The offset is encoded as:
    //   high 16 bits: line offset to the start of the function.
    //   low 16 bits: discriminator.
    uint32_t Offset;
    if (!GcovBuffer.readInt(Offset))
      return sampleprof_error::truncated;
    InlineCallStack NewStack;
    NewStack.push_back(FProfile);
    NewStack.insert(NewStack.end(), InlineStack.begin(), InlineStack.end());
    if (std::error_code EC = readOneFunctionProfile(NewStack, Update, Offset))
      return EC;
  }

  return sampleprof_error::success;
}

/// \brief Read a GCC AutoFDO profile.
///
/// This format is generated by the Linux Perf conversion tool at
/// https://github.com/google/autofdo.
std::error_code SampleProfileReaderGCC::read() {
  // Read the string table.
  if (std::error_code EC = readNameTable())
    return EC;

  // Read the source profile.
  if (std::error_code EC = readFunctionProfiles())
    return EC;

  return sampleprof_error::success;
}

bool SampleProfileReaderGCC::hasFormat(const MemoryBuffer &Buffer) {
  StringRef Magic(reinterpret_cast<const char *>(Buffer.getBufferStart()));
  return Magic == "adcg*704";
}

/// \brief Prepare a memory buffer for the contents of \p Filename.
///
/// \returns an error code indicating the status of the buffer.
static ErrorOr<std::unique_ptr<MemoryBuffer>>
setupMemoryBuffer(const Twine &Filename) {
  auto BufferOrErr = MemoryBuffer::getFileOrSTDIN(Filename);
  if (std::error_code EC = BufferOrErr.getError())
    return EC;
  auto Buffer = std::move(BufferOrErr.get());

  // Sanity check the file.
  if (Buffer->getBufferSize() > std::numeric_limits<uint32_t>::max())
    return sampleprof_error::too_large;

  return std::move(Buffer);
}

/// \brief Create a sample profile reader based on the format of the input file.
///
/// \param Filename The file to open.
///
/// \param Reader The reader to instantiate according to \p Filename's format.
///
/// \param C The LLVM context to use to emit diagnostics.
///
/// \returns an error code indicating the status of the created reader.
ErrorOr<std::unique_ptr<SampleProfileReader>>
SampleProfileReader::create(const Twine &Filename, LLVMContext &C) {
  auto BufferOrError = setupMemoryBuffer(Filename);
  if (std::error_code EC = BufferOrError.getError())
    return EC;
  return create(BufferOrError.get(), C);
}

/// \brief Create a sample profile reader based on the format of the input data.
///
/// \param B The memory buffer to create the reader from (assumes ownership).
///
/// \param Reader The reader to instantiate according to \p Filename's format.
///
/// \param C The LLVM context to use to emit diagnostics.
///
/// \returns an error code indicating the status of the created reader.
ErrorOr<std::unique_ptr<SampleProfileReader>>
SampleProfileReader::create(std::unique_ptr<MemoryBuffer> &B, LLVMContext &C) {
  std::unique_ptr<SampleProfileReader> Reader;
  if (SampleProfileReaderBinary::hasFormat(*B))
    Reader.reset(new SampleProfileReaderBinary(std::move(B), C));
  else if (SampleProfileReaderGCC::hasFormat(*B))
    Reader.reset(new SampleProfileReaderGCC(std::move(B), C));
  else if (SampleProfileReaderText::hasFormat(*B))
    Reader.reset(new SampleProfileReaderText(std::move(B), C));
  else
    return sampleprof_error::unrecognized_format;

  if (std::error_code EC = Reader->readHeader())
    return EC;

  return std::move(Reader);
}

// For text and GCC file formats, we compute the summary after reading the
// profile. Binary format has the profile summary in its header.
void SampleProfileReader::computeSummary() {
  SampleProfileSummaryBuilder Builder(ProfileSummaryBuilder::DefaultCutoffs);
  for (const auto &I : Profiles) {
    const FunctionSamples &Profile = I.second;
    Builder.addRecord(Profile);
  }
  Summary = Builder.getSummary();
}
