; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: llc < %s -o - -mcpu=generic -march=x86-64 -mattr=+sse2 | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -o - -mcpu=generic -march=x86-64 -mattr=+avx | FileCheck %s --check-prefix=AVX

define <8 x i16> @foo(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: foo:
; SSE:       ## BB#0:
; SSE-NEXT:    pcmpeqw %xmm1, %xmm0
; SSE-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: foo:
; AVX:       ## BB#0:
; AVX-NEXT:    vpcmpeqw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
;
  %icmp = icmp eq <8 x i16> %a, %b
  %zext = zext <8 x i1> %icmp to <8 x i16>
  %shl = shl nuw nsw <8 x i16> %zext, <i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5>
  ret <8 x i16> %shl
}

; Don't fail with an assert due to an undef in the buildvector
define <8 x i16> @bar(<8 x i16> %a, <8 x i16> %b) {
; SSE-LABEL: bar:
; SSE:       ## BB#0:
; SSE-NEXT:    pcmpeqw %xmm1, %xmm0
; SSE-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE-NEXT:    psllw $5, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: bar:
; AVX:       ## BB#0:
; AVX-NEXT:    vpcmpeqw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpsllw $5, %xmm0, %xmm0
; AVX-NEXT:    retq
;
  %icmp = icmp eq <8 x i16> %a, %b
  %zext = zext <8 x i1> %icmp to <8 x i16>
  %shl = shl nuw nsw <8 x i16> %zext, <i16 5, i16 undef, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5>
  ret <8 x i16> %shl
}

