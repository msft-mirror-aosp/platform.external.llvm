; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; Check that 64-bit division is bypassed correctly.
; RUN: llc < %s -mattr=+idivq-to-divl -mtriple=x86_64-unknown-linux-gnu | FileCheck %s

; Additional tests for 64-bit divide bypass

define i64 @Test_get_quotient(i64 %a, i64 %b) nounwind {
; CHECK-LABEL: Test_get_quotient:
; CHECK:       # BB#0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    orq %rsi, %rax
; CHECK-NEXT:    shrq $32, %rax
; CHECK-NEXT:    je .LBB0_1
; CHECK-NEXT:  # BB#2:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    cqto
; CHECK-NEXT:    idivq %rsi
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    divl %esi
; CHECK-NEXT:    # kill: %eax<def> %eax<kill> %rax<def>
; CHECK-NEXT:    retq
  %result = sdiv i64 %a, %b
  ret i64 %result
}

define i64 @Test_get_remainder(i64 %a, i64 %b) nounwind {
; CHECK-LABEL: Test_get_remainder:
; CHECK:       # BB#0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    orq %rsi, %rax
; CHECK-NEXT:    shrq $32, %rax
; CHECK-NEXT:    je .LBB1_1
; CHECK-NEXT:  # BB#2:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    cqto
; CHECK-NEXT:    idivq %rsi
; CHECK-NEXT:    movq %rdx, %rax
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB1_1:
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    divl %esi
; CHECK-NEXT:    # kill: %edx<def> %edx<kill> %rdx<def>
; CHECK-NEXT:    movq %rdx, %rax
; CHECK-NEXT:    retq
  %result = srem i64 %a, %b
  ret i64 %result
}

define i64 @Test_get_quotient_and_remainder(i64 %a, i64 %b) nounwind {
; CHECK-LABEL: Test_get_quotient_and_remainder:
; CHECK:       # BB#0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    orq %rsi, %rax
; CHECK-NEXT:    shrq $32, %rax
; CHECK-NEXT:    je .LBB2_1
; CHECK-NEXT:  # BB#2:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    cqto
; CHECK-NEXT:    idivq %rsi
; CHECK-NEXT:    addq %rdx, %rax
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB2_1:
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    divl %esi
; CHECK-NEXT:    # kill: %edx<def> %edx<kill> %rdx<def>
; CHECK-NEXT:    # kill: %eax<def> %eax<kill> %rax<def>
; CHECK-NEXT:    addq %rdx, %rax
; CHECK-NEXT:    retq
  %resultdiv = sdiv i64 %a, %b
  %resultrem = srem i64 %a, %b
  %result = add i64 %resultdiv, %resultrem
  ret i64 %result
}
