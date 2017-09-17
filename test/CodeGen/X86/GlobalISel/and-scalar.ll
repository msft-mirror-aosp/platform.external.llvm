; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL

define i32 @test_and_i1(i32 %arg1, i32 %arg2) {
; ALL-LABEL: test_and_i1:
; ALL:       # BB#0:
; ALL-NEXT:    cmpl %esi, %edi
; ALL-NEXT:    sete %al
; ALL-NEXT:    andb %al, %al
; ALL-NEXT:    andl $1, %eax
; ALL-NEXT:    retq
  %c = icmp eq i32 %arg1, %arg2
  %x = and i1 %c , %c
  %ret = zext i1 %x to i32
  ret i32 %ret
}

define i8 @test_and_i8(i8 %arg1, i8 %arg2) {
; ALL-LABEL: test_and_i8:
; ALL:       # BB#0:
; ALL-NEXT:    andb %dil, %sil
; ALL-NEXT:    movl %esi, %eax
; ALL-NEXT:    retq
  %ret = and i8 %arg1, %arg2
  ret i8 %ret
}

define i16 @test_and_i16(i16 %arg1, i16 %arg2) {
; ALL-LABEL: test_and_i16:
; ALL:       # BB#0:
; ALL-NEXT:    andw %di, %si
; ALL-NEXT:    movl %esi, %eax
; ALL-NEXT:    retq
  %ret = and i16 %arg1, %arg2
  ret i16 %ret
}

define i32 @test_and_i32(i32 %arg1, i32 %arg2) {
; ALL-LABEL: test_and_i32:
; ALL:       # BB#0:
; ALL-NEXT:    andl %edi, %esi
; ALL-NEXT:    movl %esi, %eax
; ALL-NEXT:    retq
  %ret = and i32 %arg1, %arg2
  ret i32 %ret
}

define i64 @test_and_i64(i64 %arg1, i64 %arg2) {
; ALL-LABEL: test_and_i64:
; ALL:       # BB#0:
; ALL-NEXT:    andq %rdi, %rsi
; ALL-NEXT:    movq %rsi, %rax
; ALL-NEXT:    retq
  %ret = and i64 %arg1, %arg2
  ret i64 %ret
}

