; RUN: echo ".text.tin" > %t_order_lto.txt
; RUN: echo ".text._start" >> %t_order_lto.txt
; RUN: echo ".text.pat" >> %t_order_lto.txt
; RUN: llvm-as %s -o %t.o
; RUN: %gold -plugin %llvmshlibdir/LLVMgold.so \
; RUN:     -m elf_x86_64 -o %t.exe %t.o \
; RUN:     --section-ordering-file=%t_order_lto.txt
; RUN: llvm-readobj -elf-output-style=GNU -t %t.exe | FileCheck %s

; Check that the order of the sections is tin -> _start -> pat.

; CHECK: Symbol table '.symtab' contains 8 entries:
; CHECK-NEXT:    Num:    Value          Size Type    Bind   Vis      Ndx Name
; CHECK-NEXT:      0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
; CHECK-NEXT:      1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS ld-temp.o
; CHECK-NEXT:      2: 00000000004000d0     1 FUNC    LOCAL  DEFAULT    1 pat
; CHECK-NEXT:      3: 00000000004000b0     1 FUNC    LOCAL  DEFAULT    1 tin
; CHECK-NEXT:      4: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  ABS _end
; CHECK-NEXT:      5: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  ABS __bss_start
; CHECK-NEXT:      6: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  ABS _edata
; CHECK-NEXT:      7: 00000000004000c0    15 FUNC    GLOBAL DEFAULT    1 _start

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @pat() #0 {
  ret void
}

define void @tin() #0 {
  ret void
}

define i32 @_start() {
  call void @pat()
  call void @tin()
  ret i32 0
}

attributes #0 = { noinline optnone }
