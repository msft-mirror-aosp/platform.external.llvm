//===-Caching.cpp - LLVM Link Time Optimizer Cache Handling ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements the Caching for ThinLTO.
//
//===----------------------------------------------------------------------===//

#include "llvm/LTO/Caching.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;
using namespace llvm::lto;

Expected<NativeObjectCache> lto::localCache(StringRef CacheDirectoryPath,
                                            AddFileFn AddFile) {
  if (std::error_code EC = sys::fs::create_directories(CacheDirectoryPath))
    return errorCodeToError(EC);

  return [=](unsigned Task, StringRef Key) -> AddStreamFn {
    // First, see if we have a cache hit.
    SmallString<64> EntryPath;
    sys::path::append(EntryPath, CacheDirectoryPath, Key);
    if (sys::fs::exists(EntryPath)) {
      AddFile(Task, EntryPath);
      return AddStreamFn();
    }

    // This native object stream is responsible for commiting the resulting
    // file to the cache and calling AddFile to add it to the link.
    struct CacheStream : NativeObjectStream {
      AddFileFn AddFile;
      std::string TempFilename;
      std::string EntryPath;
      unsigned Task;

      CacheStream(std::unique_ptr<raw_pwrite_stream> OS, AddFileFn AddFile,
                  std::string TempFilename, std::string EntryPath,
                  unsigned Task)
          : NativeObjectStream(std::move(OS)), AddFile(std::move(AddFile)),
            TempFilename(std::move(TempFilename)),
            EntryPath(std::move(EntryPath)), Task(Task) {}

      ~CacheStream() {
        // Make sure the file is closed before committing it.
        OS.reset();
        // This is atomic on POSIX systems.
        if (auto EC = sys::fs::rename(TempFilename, EntryPath))
          report_fatal_error(Twine("Failed to rename temporary file ") +
                             TempFilename + ": " + EC.message() + "\n");
        AddFile(Task, EntryPath);
      }
    };

    return [=](size_t Task) -> std::unique_ptr<NativeObjectStream> {
      // Write to a temporary to avoid race condition
      int TempFD;
      SmallString<64> TempFilenameModel, TempFilename;
      sys::path::append(TempFilenameModel, CacheDirectoryPath, "Thin-%%%%%%.tmp.o");
      std::error_code EC =
          sys::fs::createUniqueFile(TempFilenameModel, TempFD, TempFilename,
                                    sys::fs::owner_read | sys::fs::owner_write);
      if (EC) {
        errs() << "Error: " << EC.message() << "\n";
        report_fatal_error("ThinLTO: Can't get a temporary file");
      }

      // This CacheStream will move the temporary file into the cache when done.
      return llvm::make_unique<CacheStream>(
          llvm::make_unique<raw_fd_ostream>(TempFD, /* ShouldClose */ true),
          AddFile, TempFilename.str(), EntryPath.str(), Task);
    };
  };
}
