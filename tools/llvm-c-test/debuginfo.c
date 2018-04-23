/*===-- debuginfo.c - tool for testing libLLVM and llvm-c API -------------===*\
|*                                                                            *|
|*                     The LLVM Compiler Infrastructure                       *|
|*                                                                            *|
|* This file is distributed under the University of Illinois Open Source      *|
|* License. See LICENSE.TXT for details.                                      *|
|*                                                                            *|
|*===----------------------------------------------------------------------===*|
|*                                                                            *|
|* Tests for the LLVM C DebugInfo API                                         *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/

#include "llvm-c-test.h"
#include "llvm-c/Core.h"
#include "llvm-c/DebugInfo.h"
#include <stdio.h>
#include <string.h>

int llvm_test_dibuilder(void) {
  const char *Filename = "debuginfo.c";
  LLVMModuleRef M = LLVMModuleCreateWithName(Filename);
  LLVMDIBuilderRef DIB = LLVMCreateDIBuilder(M);

  LLVMMetadataRef File = LLVMDIBuilderCreateFile(DIB, Filename,
    strlen(Filename), ".", 1);

  LLVMMetadataRef CompileUnit = LLVMDIBuilderCreateCompileUnit(DIB,
    LLVMDWARFSourceLanguageC, File, "llvm-c-test", 11, 0, NULL, 0, 0,
    NULL, 0, LLVMDWARFEmissionFull, 0, 0, 0);

  LLVMMetadataRef Module =
    LLVMDIBuilderCreateModule(DIB, CompileUnit,
                              "llvm-c-test", 11,
                              "", 0,
                              "/test/include/llvm-c-test.h", 27,
                              "", 0);

  LLVMMetadataRef NameSpace =
    LLVMDIBuilderCreateNameSpace(DIB, Module, "NameSpace", 9, false);

  LLVMMetadataRef Int64Ty =
    LLVMDIBuilderCreateBasicType(DIB, "Int64", 5, 64, 0);

  LLVMMetadataRef StructDbgElts[] = {Int64Ty, Int64Ty, Int64Ty};
  LLVMMetadataRef StructDbgTy =
    LLVMDIBuilderCreateStructType(DIB, NameSpace, "MyStruct",
    8, File, 0, 192, 0, 0, NULL, StructDbgElts, 3,
    LLVMDWARFSourceLanguageC, NULL, "MyStruct", 8);

  LLVMMetadataRef StructDbgPtrTy =
    LLVMDIBuilderCreatePointerType(DIB, StructDbgTy, 192, 0, 0, "", 0);

  LLVMAddNamedMetadataOperand(M, "FooType",
    LLVMMetadataAsValue(LLVMGetModuleContext(M), StructDbgPtrTy));


  LLVMTypeRef FooParamTys[] = { LLVMInt64Type(), LLVMInt64Type() };
  LLVMTypeRef FooFuncTy = LLVMFunctionType(LLVMInt64Type(), FooParamTys, 2, 0);
  LLVMValueRef FooFunction = LLVMAddFunction(M, "foo", FooFuncTy);
  LLVMBasicBlockRef FooEntryBlock = LLVMAppendBasicBlock(FooFunction, "entry");

  LLVMMetadataRef ParamTypes[] = {Int64Ty, Int64Ty};
  LLVMMetadataRef FunctionTy =
    LLVMDIBuilderCreateSubroutineType(DIB, File, ParamTypes, 2, 0);
  LLVMMetadataRef FunctionMetadata =
    LLVMDIBuilderCreateFunction(DIB, File, "foo", 3, "foo", 3,
                                File, 42, FunctionTy, true, true,
                                42, 0, false);
  LLVMMetadataRef FooParamLocation =
    LLVMDIBuilderCreateDebugLocation(LLVMGetGlobalContext(), 42, 0,
                                     FunctionMetadata, NULL);
  LLVMMetadataRef FooParamExpression =
    LLVMDIBuilderCreateExpression(DIB, NULL, 0);
  LLVMMetadataRef FooParamVar1 =
    LLVMDIBuilderCreateParameterVariable(DIB, FunctionMetadata, "a", 1, 1, File,
                                         42, Int64Ty, true, 0);
  LLVMDIBuilderInsertDeclareAtEnd(DIB, LLVMConstInt(LLVMInt64Type(), 0, false),
                                  FooParamVar1, FooParamExpression,
                                  FooParamLocation, FooEntryBlock);
  LLVMMetadataRef FooParamVar2 =
    LLVMDIBuilderCreateParameterVariable(DIB, FunctionMetadata, "b", 1, 2, File,
                                         42, Int64Ty, true, 0);
  LLVMDIBuilderInsertDeclareAtEnd(DIB, LLVMConstInt(LLVMInt64Type(), 0, false),
                                  FooParamVar2, FooParamExpression,
                                  FooParamLocation, FooEntryBlock);
  LLVMSetSubprogram(FooFunction, FunctionMetadata);

  LLVMMetadataRef FooLexicalBlock =
    LLVMDIBuilderCreateLexicalBlock(DIB, FunctionMetadata, File, 42, 0);

  LLVMValueRef InnerFooFunction =
    LLVMAddFunction(M, "foo_inner_scope", FooFuncTy);
  LLVMMetadataRef InnerFunctionMetadata =
    LLVMDIBuilderCreateFunction(DIB, FooLexicalBlock, "foo_inner_scope", 15,
                                "foo_inner_scope", 15,
                                File, 42, FunctionTy, true, true,
                                42, 0, false);
  LLVMSetSubprogram(InnerFooFunction, InnerFunctionMetadata);

  LLVMDIBuilderFinalize(DIB);

  char *MStr = LLVMPrintModuleToString(M);
  puts(MStr);
  LLVMDisposeMessage(MStr);

  LLVMDisposeDIBuilder(DIB);
  LLVMDisposeModule(M);

  return 0;
}
