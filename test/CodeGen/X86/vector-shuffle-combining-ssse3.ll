; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+ssse3 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx512f | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX512F
;
; Combine tests involving SSE3/SSSE3 target shuffles (MOVDDUP, MOVSHDUP, MOVSLDUP, PSHUFB)

declare <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8>, <16 x i8>)

define <16 x i8> @combine_vpshufb_as_zero(<16 x i8> %a0) {
; SSE-LABEL: combine_vpshufb_as_zero:
; SSE:       # BB#0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vpshufb_as_zero:
; AVX:       # BB#0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 128, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0>)
  %res1 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %res0, <16 x i8> <i8 0, i8 128, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0>)
  %res2 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %res1, <16 x i8> <i8 0, i8 1, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128>)
  ret <16 x i8> %res2
}

define <16 x i8> @combine_vpshufb_as_movq(<16 x i8> %a0) {
; SSE-LABEL: combine_vpshufb_as_movq:
; SSE:       # BB#0:
; SSE-NEXT:    movq {{.*#+}} xmm0 = xmm0[0],zero
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vpshufb_as_movq:
; AVX:       # BB#0:
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 0, i8 128, i8 1, i8 128, i8 2, i8 128, i8 3, i8 128, i8 4, i8 128, i8 5, i8 128, i8 6, i8 128, i8 7, i8 128>)
  %res1 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %res0, <16 x i8> <i8 0, i8 2, i8 4, i8 6, i8 8, i8 10, i8 12, i8 14, i8 1, i8 3, i8 5, i8 7, i8 9, i8 11, i8 13, i8 15>)
  ret <16 x i8> %res1
}

define <2 x double> @combine_pshufb_as_movsd(<2 x double> %a0, <2 x double> %a1) {
; SSSE3-LABEL: combine_pshufb_as_movsd:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movsd {{.*#+}} xmm1 = xmm0[0],xmm1[1]
; SSSE3-NEXT:    movapd %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: combine_pshufb_as_movsd:
; SSE41:       # BB#0:
; SSE41-NEXT:    blendpd {{.*#+}} xmm0 = xmm0[0],xmm1[1]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: combine_pshufb_as_movsd:
; AVX1:       # BB#0:
; AVX1-NEXT:    vblendpd {{.*#+}} xmm0 = xmm0[0],xmm1[1]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_pshufb_as_movsd:
; AVX2:       # BB#0:
; AVX2-NEXT:    vblendpd {{.*#+}} xmm0 = xmm0[0],xmm1[1]
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: combine_pshufb_as_movsd:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovsd {{.*#+}} xmm0 = xmm0[0],xmm1[1]
; AVX512F-NEXT:    retq
  %1 = shufflevector <2 x double> %a0, <2 x double> %a1, <2 x i32> <i32 3, i32 0>
  %2 = bitcast <2 x double> %1 to <16 x i8>
  %3 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %2, <16 x i8> <i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>)
  %4 = bitcast <16 x i8> %3 to <2 x double>
  ret <2 x double> %4
}

define <4 x float> @combine_pshufb_as_movss(<4 x float> %a0, <4 x float> %a1) {
; SSSE3-LABEL: combine_pshufb_as_movss:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movss {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3]
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: combine_pshufb_as_movss:
; SSE41:       # BB#0:
; SSE41-NEXT:    blendps {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: combine_pshufb_as_movss:
; AVX1:       # BB#0:
; AVX1-NEXT:    vblendps {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_pshufb_as_movss:
; AVX2:       # BB#0:
; AVX2-NEXT:    vblendps {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3]
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: combine_pshufb_as_movss:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vmovss {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3]
; AVX512F-NEXT:    retq
  %1 = shufflevector <4 x float> %a0, <4 x float> %a1, <4 x i32> <i32 4, i32 3, i32 2, i32 1>
  %2 = bitcast <4 x float> %1 to <16 x i8>
  %3 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %2, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 12, i8 13, i8 14, i8 15, i8 8, i8 9, i8 10, i8 11, i8 4, i8 5, i8 6, i8 7>)
  %4 = bitcast <16 x i8> %3 to <4 x float>
  ret <4 x float> %4
}

define <2 x double> @combine_pshufb_as_vzmovl_64(<2 x double> %a0) {
; SSE-LABEL: combine_pshufb_as_vzmovl_64:
; SSE:       # BB#0:
; SSE-NEXT:    movq {{.*#+}} xmm0 = xmm0[0],zero
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_vzmovl_64:
; AVX:       # BB#0:
; AVX-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; AVX-NEXT:    retq
  %1 = bitcast <2 x double> %a0 to <16 x i8>
  %2 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>)
  %3 = bitcast <16 x i8> %2 to <2 x double>
  ret <2 x double> %3
}

define <4 x float> @combine_pshufb_as_vzmovl_32(<4 x float> %a0) {
; SSSE3-LABEL: combine_pshufb_as_vzmovl_32:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    xorps %xmm1, %xmm1
; SSSE3-NEXT:    movss {{.*#+}} xmm1 = xmm0[0],xmm1[1,2,3]
; SSSE3-NEXT:    movaps %xmm1, %xmm0
; SSSE3-NEXT:    retq
;
; SSE41-LABEL: combine_pshufb_as_vzmovl_32:
; SSE41:       # BB#0:
; SSE41-NEXT:    xorps %xmm1, %xmm1
; SSE41-NEXT:    blendps {{.*#+}} xmm0 = xmm0[0],xmm1[1,2,3]
; SSE41-NEXT:    retq
;
; AVX1-LABEL: combine_pshufb_as_vzmovl_32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vblendps {{.*#+}} xmm0 = xmm0[0],xmm1[1,2,3]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_pshufb_as_vzmovl_32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vblendps {{.*#+}} xmm0 = xmm0[0],xmm1[1,2,3]
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: combine_pshufb_as_vzmovl_32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; AVX512F-NEXT:    vmovss {{.*#+}} xmm0 = xmm0[0],xmm1[1,2,3]
; AVX512F-NEXT:    retq
  %1 = bitcast <4 x float> %a0 to <16 x i8>
  %2 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>)
  %3 = bitcast <16 x i8> %2 to <4 x float>
  ret <4 x float> %3
}

define <4 x float> @combine_pshufb_movddup(<4 x float> %a0) {
; SSE-LABEL: combine_pshufb_movddup:
; SSE:       # BB#0:
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[5,5,5,5,7,7,7,7,5,5,5,5,7,7,7,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_movddup:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[5,5,5,5,7,7,7,7,5,5,5,5,7,7,7,7]
; AVX-NEXT:    retq
  %1 = bitcast <4 x float> %a0 to <16 x i8>
  %2 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 5, i8 5, i8 5, i8 5, i8 7, i8 7, i8 7, i8 7, i8 1, i8 1, i8 1, i8 1, i8 3, i8 3, i8 3, i8 3>)
  %3 = bitcast <16 x i8> %2 to <4 x float>
  %4 = shufflevector <4 x float> %3, <4 x float> undef, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  ret <4 x float> %4
}

define <4 x float> @combine_pshufb_movshdup(<4 x float> %a0) {
; SSE-LABEL: combine_pshufb_movshdup:
; SSE:       # BB#0:
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[7,7,7,7,7,7,7,7,3,3,3,3,3,3,3,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_movshdup:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[7,7,7,7,7,7,7,7,3,3,3,3,3,3,3,3]
; AVX-NEXT:    retq
  %1 = bitcast <4 x float> %a0 to <16 x i8>
  %2 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 5, i8 5, i8 5, i8 5, i8 7, i8 7, i8 7, i8 7, i8 1, i8 1, i8 1, i8 1, i8 3, i8 3, i8 3, i8 3>)
  %3 = bitcast <16 x i8> %2 to <4 x float>
  %4 = shufflevector <4 x float> %3, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 3, i32 3>
  ret <4 x float> %4
}

define <4 x float> @combine_pshufb_movsldup(<4 x float> %a0) {
; SSE-LABEL: combine_pshufb_movsldup:
; SSE:       # BB#0:
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[5,5,5,5,5,5,5,5,1,1,1,1,1,1,1,1]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_movsldup:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[5,5,5,5,5,5,5,5,1,1,1,1,1,1,1,1]
; AVX-NEXT:    retq
  %1 = bitcast <4 x float> %a0 to <16 x i8>
  %2 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 5, i8 5, i8 5, i8 5, i8 7, i8 7, i8 7, i8 7, i8 1, i8 1, i8 1, i8 1, i8 3, i8 3, i8 3, i8 3>)
  %3 = bitcast <16 x i8> %2 to <4 x float>
  %4 = shufflevector <4 x float> %3, <4 x float> undef, <4 x i32> <i32 0, i32 0, i32 2, i32 2>
  ret <4 x float> %4
}

define <16 x i8> @combine_pshufb_palignr(<16 x i8> %a0, <16 x i8> %a1) {
; SSE-LABEL: combine_pshufb_palignr:
; SSE:       # BB#0:
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,2,3]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_palignr:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[2,3,2,3]
; AVX-NEXT:    retq
  %1 = shufflevector <16 x i8> %a0, <16 x i8> %a1, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  %2 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>)
  ret <16 x i8> %2
}

define <16 x i8> @combine_pshufb_pslldq(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_pslldq:
; SSE:       # BB#0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_pslldq:
; AVX:       # BB#0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>)
  %2 = shufflevector <16 x i8> %1, <16 x i8> zeroinitializer, <16 x i32> <i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <16 x i8> %2
}

define <16 x i8> @combine_pshufb_psrldq(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_psrldq:
; SSE:       # BB#0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_psrldq:
; AVX:       # BB#0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128>)
  %2 = shufflevector <16 x i8> %1, <16 x i8> zeroinitializer, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16, i32 16>
  ret <16 x i8> %2
}

define <16 x i8> @combine_pshufb_as_palignr(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_palignr:
; SSE:       # BB#0:
; SSE-NEXT:    palignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_palignr:
; AVX:       # BB#0:
; AVX-NEXT:    vpalignr {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0]
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 undef, i8 undef, i8 0>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_as_pslldq(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_pslldq:
; SSE:       # BB#0:
; SSE-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3,4,5]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_pslldq:
; AVX:       # BB#0:
; AVX-NEXT:    vpslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3,4,5]
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_as_psrldq(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_psrldq:
; SSE:       # BB#0:
; SSE-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_psrldq:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrldq {{.*#+}} xmm0 = xmm0[15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 15, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_as_psrlw(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_psrlw:
; SSE:       # BB#0:
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_psrlw:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrlw $8, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 1, i8 128, i8 3, i8 128, i8 5, i8 128, i8 7, i8 128, i8 9, i8 128, i8 11, i8 128, i8 13, i8 128, i8 15, i8 128>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_as_pslld(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_pslld:
; SSE:       # BB#0:
; SSE-NEXT:    pslld $24, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_pslld:
; AVX:       # BB#0:
; AVX-NEXT:    vpslld $24, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 128, i8 128, i8 128, i8 0, i8 128, i8 128, i8 128, i8 4, i8 128, i8 128, i8 128, i8 8, i8 128, i8 128, i8 128, i8 12>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_as_psrlq(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_psrlq:
; SSE:       # BB#0:
; SSE-NEXT:    psrlq $40, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_psrlq:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrlq $40, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 5, i8 6, i8 7, i8 128, i8 128, i8 128, i8 128, i8 128, i8 13, i8 14, i8 15, i8 128, i8 128, i8 128, i8 128, i8 128>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_as_pshuflw(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_pshuflw:
; SSE:       # BB#0:
; SSE-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[1,0,3,2,4,5,6,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_pshuflw:
; AVX:       # BB#0:
; AVX-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[1,0,3,2,4,5,6,7]
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 2, i8 3, i8 0, i8 1, i8 6, i8 7, i8 4, i8 5, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_as_pshufhw(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_pshufhw:
; SSE:       # BB#0:
; SSE-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,4,7,6]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_pshufhw:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,5,4,7,6]
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 10, i8 11, i8 8, i8 9, i8 14, i8 15, i8 12, i8 13>)
  ret <16 x i8> %res0
}

define <16 x i8> @combine_pshufb_not_as_pshufw(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_not_as_pshufw:
; SSE:       # BB#0:
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_not_as_pshufw:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13]
; AVX-NEXT:    retq
  %res0 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 2, i8 3, i8 0, i8 1, i8 6, i8 7, i8 4, i8 5, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>)
  %res1 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %res0, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 10, i8 11, i8 8, i8 9, i8 14, i8 15, i8 12, i8 13>)
  ret <16 x i8> %res1
}

define <16 x i8> @combine_pshufb_as_unary_unpcklbw(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_unary_unpcklbw:
; SSE:       # BB#0:
; SSE-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_unary_unpcklbw:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 0, i8 undef, i8 undef, i8 1, i8 2, i8 2, i8 3, i8 3, i8 4, i8 4, i8 5, i8 5, i8 6, i8 6, i8 7, i8 7>)
  ret <16 x i8> %1
}

define <16 x i8> @combine_pshufb_as_unary_unpckhwd(<16 x i8> %a0) {
; SSE-LABEL: combine_pshufb_as_unary_unpckhwd:
; SSE:       # BB#0:
; SSE-NEXT:    punpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pshufb_as_unary_unpckhwd:
; AVX:       # BB#0:
; AVX-NEXT:    vpunpckhwd {{.*#+}} xmm0 = xmm0[4,4,5,5,6,6,7,7]
; AVX-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a0, <16 x i8> <i8 8, i8 9, i8 8, i8 9, i8 10, i8 11, i8 10, i8 11, i8 12, i8 13, i8 12, i8 13, i8 14, i8 15, i8 undef, i8 undef>)
  ret <16 x i8> %1
}

define <16 x i8> @combine_psrlw_pshufb(<8 x i16> %a0) {
; SSE-LABEL: combine_psrlw_pshufb:
; SSE:       # BB#0:
; SSE-NEXT:    psrlw $8, %xmm0
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_psrlw_pshufb:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrlw $8, %xmm0, %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero
; AVX-NEXT:    retq
  %1 = lshr <8 x i16> %a0, <i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8>
  %2 = bitcast <8 x i16> %1 to <16 x i8>
  %3 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %2, <16 x i8> <i8 0, i8 -1, i8 -1, i8 -1, i8 0, i8 -1, i8 -1, i8 -1, i8 0, i8 -1, i8 -1, i8 -1, i8 0, i8 -1, i8 -1, i8 -1>)
  ret <16 x i8> %3
}

define <16 x i8> @combine_pslld_pshufb(<4 x i32> %a0) {
; SSE-LABEL: combine_pslld_pshufb:
; SSE:       # BB#0:
; SSE-NEXT:    pslld $8, %xmm0
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_pslld_pshufb:
; AVX:       # BB#0:
; AVX-NEXT:    vpslld $8, %xmm0, %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[3,2,1,0,7,6,5,4,11,10,9,8,15,14,13,12]
; AVX-NEXT:    retq
  %1 = shl <4 x i32> %a0, <i32 8, i32 8, i32 8, i32 8>
  %2 = bitcast <4 x i32> %1 to <16 x i8>
  %3 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %2, <16 x i8> <i8 3, i8 2, i8 1, i8 0, i8 7, i8 6, i8 5, i8 4, i8 11, i8 10, i8 9, i8 8, i8 15, i8 14, i8 13, i8 12>)
  ret <16 x i8> %3
}

define <16 x i8> @combine_psrlq_pshufb(<2 x i64> %a0) {
; SSE-LABEL: combine_psrlq_pshufb:
; SSE:       # BB#0:
; SSE-NEXT:    psrlq $48, %xmm0
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_psrlq_pshufb:
; AVX:       # BB#0:
; AVX-NEXT:    vpsrlq $48, %xmm0, %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8]
; AVX-NEXT:    retq
  %1 = lshr <2 x i64> %a0, <i64 48, i64 48>
  %2 = bitcast <2 x i64> %1 to <16 x i8>
  %3 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %2, <16 x i8> <i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0, i8 15, i8 14, i8 13, i8 12, i8 11, i8 10, i8 9, i8 8>)
  ret <16 x i8> %3
}

define <16 x i8> @combine_unpckl_arg0_pshufb(<16 x i8> %a0, <16 x i8> %a1) {
; SSE-LABEL: combine_unpckl_arg0_pshufb:
; SSE:       # BB#0:
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_unpckl_arg0_pshufb:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero,xmm0[0],zero,zero,zero
; AVX-NEXT:    retq
  %1 = shufflevector <16 x i8> %a0, <16 x i8> %a1, <16 x i32> <i32 0, i32 16, i32 1, i32 17, i32 2, i32 18, i32 3, i32 19, i32 4, i32 20, i32 5, i32 21, i32 6, i32 22, i32 7, i32 23>
  %2 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 0, i8 -1, i8 -1, i8 -1, i8 0, i8 -1, i8 -1, i8 -1, i8 0, i8 -1, i8 -1, i8 -1, i8 0, i8 -1, i8 -1, i8 -1>)
  ret <16 x i8> %2
}

define <16 x i8> @combine_unpckl_arg1_pshufb(<16 x i8> %a0, <16 x i8> %a1) {
; SSE-LABEL: combine_unpckl_arg1_pshufb:
; SSE:       # BB#0:
; SSE-NEXT:    pshufb {{.*#+}} xmm1 = xmm1[0],zero,zero,zero,xmm1[0],zero,zero,zero,xmm1[0],zero,zero,zero,xmm1[0],zero,zero,zero
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_unpckl_arg1_pshufb:
; AVX:       # BB#0:
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm1[0],zero,zero,zero,xmm1[0],zero,zero,zero,xmm1[0],zero,zero,zero,xmm1[0],zero,zero,zero
; AVX-NEXT:    retq
  %1 = shufflevector <16 x i8> %a0, <16 x i8> %a1, <16 x i32> <i32 0, i32 16, i32 1, i32 17, i32 2, i32 18, i32 3, i32 19, i32 4, i32 20, i32 5, i32 21, i32 6, i32 22, i32 7, i32 23>
  %2 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 1, i8 -1, i8 -1, i8 -1, i8 1, i8 -1, i8 -1, i8 -1, i8 1, i8 -1, i8 -1, i8 -1, i8 1, i8 -1, i8 -1, i8 -1>)
  ret <16 x i8> %2
}

define <16 x i8> @constant_fold_pshufb() {
; SSE-LABEL: constant_fold_pshufb:
; SSE:       # BB#0:
; SSE-NEXT:    movdqa {{.*#+}} xmm0 = [15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0]
; SSE-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[1],zero,zero,zero,xmm0[u,u],zero,zero,xmm0[15],zero,zero,zero,zero,zero,xmm0[7,6]
; SSE-NEXT:    retq
;
; AVX-LABEL: constant_fold_pshufb:
; AVX:       # BB#0:
; AVX-NEXT:    vmovdqa {{.*#+}} xmm0 = [15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0]
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[1],zero,zero,zero,xmm0[u,u],zero,zero,xmm0[15],zero,zero,zero,zero,zero,xmm0[7,6]
; AVX-NEXT:    retq
  %1 = tail call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> <i8 15, i8 14, i8 13, i8 12, i8 11, i8 10, i8 9, i8 8, i8 7, i8 6, i8 5, i8 4, i8 3, i8 2, i8 1, i8 0>, <16 x i8> <i8 1, i8 -1, i8 -1, i8 -1, i8 undef, i8 undef, i8 -1, i8 -1, i8 15, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 7, i8 6>)
  ret <16 x i8> %1
}
