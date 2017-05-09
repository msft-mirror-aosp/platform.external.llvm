; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE42
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx512f | FileCheck %s --check-prefix=AVX --check-prefix=AVX512

define <2 x i64> @PR32907(<2 x i64> %astype.i, <2 x i64> %astype6.i) {
; SSE2-LABEL: PR32907:
; SSE2:       # BB#0: # %entry
; SSE2-NEXT:    psubq %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrad $31, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[1,1,3,3]
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    psubq %xmm0, %xmm1
; SSE2-NEXT:    pand %xmm2, %xmm1
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE42-LABEL: PR32907:
; SSE42:       # BB#0: # %entry
; SSE42-NEXT:    psubq %xmm1, %xmm0
; SSE42-NEXT:    pxor %xmm1, %xmm1
; SSE42-NEXT:    pcmpgtq %xmm0, %xmm1
; SSE42-NEXT:    pxor %xmm1, %xmm0
; SSE42-NEXT:    psubq %xmm1, %xmm0
; SSE42-NEXT:    retq
;
; AVX2-LABEL: PR32907:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpsubq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm1
; AVX2-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpsubq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: PR32907:
; AVX512:       # BB#0: # %entry
; AVX512-NEXT:    vpsubq %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsraq $63, %zmm0, %zmm1
; AVX512-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vpsubq %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
entry:
  %sub13.i = sub <2 x i64> %astype.i, %astype6.i
  %x.lobit.i.i = ashr <2 x i64> %sub13.i, <i64 63, i64 63>
  %sub.i.i = sub <2 x i64> zeroinitializer, %sub13.i
  %0 = xor <2 x i64> %x.lobit.i.i, <i64 -1, i64 -1>
  %1 = and <2 x i64> %sub13.i, %0
  %2 = and <2 x i64> %x.lobit.i.i, %sub.i.i
  %cond.i.i = or <2 x i64> %1, %2
  ret <2 x i64> %cond.i.i
}
