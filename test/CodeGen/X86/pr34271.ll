; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu | FileCheck %s

; CHECK: .LCPI0_0:
; CHECK-NEXT: .zero 16,1

define <4 x i32> @f(<4 x i32> %a) {
; CHECK-LABEL: f:
; CHECK:       # %bb.0:
; CHECK-NEXT:    paddd .LCPI0_0(%rip), %xmm0
; CHECK-NEXT:    retq
  %v = add nuw nsw <4 x i32> %a, <i32 16843009, i32 16843009, i32 16843009, i32 16843009>
  ret <4 x i32> %v
}
