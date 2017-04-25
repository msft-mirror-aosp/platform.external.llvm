; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: llc < %s -mtriple=x86_64-darwin | FileCheck %s

; CHECK-LABEL: LCPI0_0:
; CHECK-NEXT: .long 4286578688
; CHECK-LABEL: LCPI0_1:
; CHECK-NEXT: .long 2139095040

define x86_fp80 @foo(x86_fp80 %a) {
; CHECK-LABEL: foo:
; CHECK:       ## BB#0:
; CHECK-NEXT:    fldt {{[0-9]+}}(%rsp)
; CHECK-NEXT:    fstpt -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    testb $-128, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    flds LCPI0_0(%rip)
; CHECK-NEXT:    flds LCPI0_1(%rip)
; CHECK-NEXT:    fcmovne %st(1), %st(0)
; CHECK-NEXT:    fstp %st(1)
; CHECK-NEXT:    retq
;
  %1 = tail call x86_fp80 @copysignl(x86_fp80 0xK7FFF8000000000000000, x86_fp80 %a) nounwind readnone
  ret x86_fp80 %1
}

declare x86_fp80 @copysignl(x86_fp80, x86_fp80) nounwind readnone

; This would crash:
; https://llvm.org/bugs/show_bug.cgi?id=26070

define float @pr26070() {
; CHECK-LABEL: pr26070:
; CHECK:       ## BB#0:
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,0,0,0]
; CHECK-NEXT:    orps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
;
  %c = call float @copysignf(float 1.0, float undef) readnone
  ret float %c
}

declare float @copysignf(float, float)

