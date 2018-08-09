; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -fast-isel -mtriple=i386-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=CHECK,X86,SSE,X86-SSE
; RUN: llc < %s -fast-isel -mtriple=i386-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,X86,AVX,X86-AVX,AVX1,X86-AVX1
; RUN: llc < %s -fast-isel -mtriple=i386-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X86,AVX,X86-AVX,AVX512,X86-AVX512
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=CHECK,X64,SSE,X64-SSE
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,X64,AVX,X64-AVX,AVX1,X64-AVX1
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512dq,+avx512vl | FileCheck %s --check-prefixes=CHECK,X64,AVX,X64-AVX,AVX512,X64-AVX512

; NOTE: This should use IR equivalent to what is generated by clang/test/CodeGen/sse41-builtins.c

define <2 x i64> @test_mm_blend_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_blend_epi16:
; SSE:       # %bb.0:
; SSE-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2],xmm1[3],xmm0[4],xmm1[5],xmm0[6,7]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_blend_epi16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0],xmm1[1],xmm0[2],xmm1[3],xmm0[4],xmm1[5],xmm0[6,7]
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %shuf = shufflevector <8 x i16> %arg0, <8 x i16> %arg1, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 7>
  %res = bitcast <8 x i16> %shuf to <2 x i64>
  ret <2 x i64> %res
}

define <2 x double> @test_mm_blend_pd(<2 x double> %a0, <2 x double> %a1) {
; SSE-LABEL: test_mm_blend_pd:
; SSE:       # %bb.0:
; SSE-NEXT:    blendps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_blend_pd:
; AVX:       # %bb.0:
; AVX-NEXT:    vblendps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; AVX-NEXT:    ret{{[l|q]}}
  %res = shufflevector <2 x double> %a0, <2 x double> %a1, <2 x i32> <i32 0, i32 3>
  ret <2 x double> %res
}

define <4 x float> @test_mm_blend_ps(<4 x float> %a0, <4 x float> %a1) {
; SSE-LABEL: test_mm_blend_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    blendps {{.*#+}} xmm0 = xmm0[0],xmm1[1,2],xmm0[3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_blend_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vblendps {{.*#+}} xmm0 = xmm0[0],xmm1[1,2],xmm0[3]
; AVX-NEXT:    ret{{[l|q]}}
  %res = shufflevector <4 x float> %a0, <4 x float> %a1, <4 x i32> <i32 0, i32 5, i32 6, i32 3>
  ret <4 x float> %res
}

define <2 x i64> @test_mm_blendv_epi8(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) {
; SSE-LABEL: test_mm_blendv_epi8:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa %xmm0, %xmm3
; SSE-NEXT:    movaps %xmm2, %xmm0
; SSE-NEXT:    pblendvb %xmm0, %xmm1, %xmm3
; SSE-NEXT:    movdqa %xmm3, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_blendv_epi8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %arg2 = bitcast <2 x i64> %a2 to <16 x i8>
  %call = call <16 x i8> @llvm.x86.sse41.pblendvb(<16 x i8> %arg0, <16 x i8> %arg1, <16 x i8> %arg2)
  %res = bitcast <16 x i8> %call to <2 x i64>
  ret <2 x i64> %res
}
declare <16 x i8> @llvm.x86.sse41.pblendvb(<16 x i8>, <16 x i8>, <16 x i8>) nounwind readnone

define <2 x double> @test_mm_blendv_pd(<2 x double> %a0, <2 x double> %a1, <2 x double> %a2) {
; SSE-LABEL: test_mm_blendv_pd:
; SSE:       # %bb.0:
; SSE-NEXT:    movapd %xmm0, %xmm3
; SSE-NEXT:    movaps %xmm2, %xmm0
; SSE-NEXT:    blendvpd %xmm0, %xmm1, %xmm3
; SSE-NEXT:    movapd %xmm3, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_blendv_pd:
; AVX:       # %bb.0:
; AVX-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.blendvpd(<2 x double> %a0, <2 x double> %a1, <2 x double> %a2)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.blendvpd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone

define <4 x float> @test_mm_blendv_ps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2) {
; SSE-LABEL: test_mm_blendv_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps %xmm0, %xmm3
; SSE-NEXT:    movaps %xmm2, %xmm0
; SSE-NEXT:    blendvps %xmm0, %xmm1, %xmm3
; SSE-NEXT:    movaps %xmm3, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_blendv_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vblendvps %xmm2, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.blendvps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.blendvps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone

define <2 x double> @test_mm_ceil_pd(<2 x double> %a0) {
; SSE-LABEL: test_mm_ceil_pd:
; SSE:       # %bb.0:
; SSE-NEXT:    roundpd $2, %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_ceil_pd:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundpd $2, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %a0, i32 2)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.round.pd(<2 x double>, i32) nounwind readnone

define <4 x float> @test_mm_ceil_ps(<4 x float> %a0) {
; SSE-LABEL: test_mm_ceil_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    roundps $2, %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_ceil_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundps $2, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %a0, i32 2)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.round.ps(<4 x float>, i32) nounwind readnone

define <2 x double> @test_mm_ceil_sd(<2 x double> %a0, <2 x double> %a1) {
; SSE-LABEL: test_mm_ceil_sd:
; SSE:       # %bb.0:
; SSE-NEXT:    roundsd $2, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_ceil_sd:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundsd $2, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.round.sd(<2 x double> %a0, <2 x double> %a1, i32 2)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.round.sd(<2 x double>, <2 x double>, i32) nounwind readnone

define <4 x float> @test_mm_ceil_ss(<4 x float> %a0, <4 x float> %a1) {
; SSE-LABEL: test_mm_ceil_ss:
; SSE:       # %bb.0:
; SSE-NEXT:    roundss $2, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_ceil_ss:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundss $2, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.round.ss(<4 x float> %a0, <4 x float> %a1, i32 2)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.round.ss(<4 x float>, <4 x float>, i32) nounwind readnone

define <2 x i64> @test_mm_cmpeq_epi64(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_cmpeq_epi64:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqq %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: test_mm_cmpeq_epi64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpcmpeqq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: test_mm_cmpeq_epi64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpcmpeqq %xmm1, %xmm0, %k0
; AVX512-NEXT:    vpmovm2q %k0, %xmm0
; AVX512-NEXT:    ret{{[l|q]}}
  %cmp = icmp eq <2 x i64> %a0, %a1
  %res = sext <2 x i1> %cmp to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_cvtepi8_epi16(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepi8_epi16:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovsxbw %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepi8_epi16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovsxbw %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %ext0 = shufflevector <16 x i8> %arg0, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %sext = sext <8 x i8> %ext0 to <8 x i16>
  %res = bitcast <8 x i16> %sext to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_cvtepi8_epi32(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepi8_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovsxbd %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepi8_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovsxbd %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %ext0 = shufflevector <16 x i8> %arg0, <16 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %sext = sext <4 x i8> %ext0 to <4 x i32>
  %res = bitcast <4 x i32> %sext to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_cvtepi8_epi64(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepi8_epi64:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovsxbq %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepi8_epi64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovsxbq %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %ext0 = shufflevector <16 x i8> %arg0, <16 x i8> undef, <2 x i32> <i32 0, i32 1>
  %sext = sext <2 x i8> %ext0 to <2 x i64>
  ret <2 x i64> %sext
}

define <2 x i64> @test_mm_cvtepi16_epi32(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepi16_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovsxwd %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepi16_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovsxwd %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %ext0 = shufflevector <8 x i16> %arg0, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %sext = sext <4 x i16> %ext0 to <4 x i32>
  %res = bitcast <4 x i32> %sext to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_cvtepi16_epi64(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepi16_epi64:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovsxwq %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepi16_epi64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovsxwq %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %ext0 = shufflevector <8 x i16> %arg0, <8 x i16> undef, <2 x i32> <i32 0, i32 1>
  %sext = sext <2 x i16> %ext0 to <2 x i64>
  ret <2 x i64> %sext
}

define <2 x i64> @test_mm_cvtepi32_epi64(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepi32_epi64:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovsxdq %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepi32_epi64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovsxdq %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %ext0 = shufflevector <4 x i32> %arg0, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %sext = sext <2 x i32> %ext0 to <2 x i64>
  ret <2 x i64> %sext
}

define <2 x i64> @test_mm_cvtepu8_epi16(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepu8_epi16:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepu8_epi16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %ext0 = shufflevector <16 x i8> %arg0, <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %sext = zext <8 x i8> %ext0 to <8 x i16>
  %res = bitcast <8 x i16> %sext to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_cvtepu8_epi32(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepu8_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepu8_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxbd {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %ext0 = shufflevector <16 x i8> %arg0, <16 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %sext = zext <4 x i8> %ext0 to <4 x i32>
  %res = bitcast <4 x i32> %sext to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_cvtepu8_epi64(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepu8_epi64:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepu8_epi64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxbq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,zero,zero,zero,zero,xmm0[1],zero,zero,zero,zero,zero,zero,zero
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %ext0 = shufflevector <16 x i8> %arg0, <16 x i8> undef, <2 x i32> <i32 0, i32 1>
  %sext = zext <2 x i8> %ext0 to <2 x i64>
  ret <2 x i64> %sext
}

define <2 x i64> @test_mm_cvtepu16_epi32(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepu16_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepu16_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxwd {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %ext0 = shufflevector <8 x i16> %arg0, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %sext = zext <4 x i16> %ext0 to <4 x i32>
  %res = bitcast <4 x i32> %sext to <2 x i64>
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_cvtepu16_epi64(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepu16_epi64:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepu16_epi64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxwq {{.*#+}} xmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %ext0 = shufflevector <8 x i16> %arg0, <8 x i16> undef, <2 x i32> <i32 0, i32 1>
  %sext = zext <2 x i16> %ext0 to <2 x i64>
  ret <2 x i64> %sext
}

define <2 x i64> @test_mm_cvtepu32_epi64(<2 x i64> %a0) {
; SSE-LABEL: test_mm_cvtepu32_epi64:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_cvtepu32_epi64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %ext0 = shufflevector <4 x i32> %arg0, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %sext = zext <2 x i32> %ext0 to <2 x i64>
  ret <2 x i64> %sext
}

define <2 x double> @test_mm_dp_pd(<2 x double> %a0, <2 x double> %a1) {
; SSE-LABEL: test_mm_dp_pd:
; SSE:       # %bb.0:
; SSE-NEXT:    dppd $7, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_dp_pd:
; AVX:       # %bb.0:
; AVX-NEXT:    vdppd $7, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.dppd(<2 x double> %a0, <2 x double> %a1, i8 7)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.dppd(<2 x double>, <2 x double>, i8) nounwind readnone

define <4 x float> @test_mm_dp_ps(<4 x float> %a0, <4 x float> %a1) {
; SSE-LABEL: test_mm_dp_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    dpps $7, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_dp_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vdpps $7, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.dpps(<4 x float> %a0, <4 x float> %a1, i8 7)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.dpps(<4 x float>, <4 x float>, i8) nounwind readnone

define i32 @test_mm_extract_epi8(<2 x i64> %a0) {
; SSE-LABEL: test_mm_extract_epi8:
; SSE:       # %bb.0:
; SSE-NEXT:    pextrb $1, %xmm0, %eax
; SSE-NEXT:    movzbl %al, %eax
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_extract_epi8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpextrb $1, %xmm0, %eax
; AVX-NEXT:    movzbl %al, %eax
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %ext = extractelement <16 x i8> %arg0, i32 1
  %res = zext i8 %ext to i32
  ret i32 %res
}

define i32 @test_mm_extract_epi32(<2 x i64> %a0) {
; SSE-LABEL: test_mm_extract_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    extractps $1, %xmm0, %eax
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_extract_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vextractps $1, %xmm0, %eax
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %ext = extractelement <4 x i32> %arg0, i32 1
  ret i32 %ext
}

define i64 @test_mm_extract_epi64(<2 x i64> %a0) {
; X86-SSE-LABEL: test_mm_extract_epi64:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    extractps $2, %xmm0, %eax
; X86-SSE-NEXT:    extractps $3, %xmm0, %edx
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test_mm_extract_epi64:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vextractps $2, %xmm0, %eax
; X86-AVX-NEXT:    vextractps $3, %xmm0, %edx
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_mm_extract_epi64:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    pextrq $1, %xmm0, %rax
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_mm_extract_epi64:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vpextrq $1, %xmm0, %rax
; X64-AVX-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %ext = extractelement <2 x i64> %a0, i32 1
  ret i64 %ext
}

define i32 @test_mm_extract_ps(<4 x float> %a0) {
; SSE-LABEL: test_mm_extract_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    movshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE-NEXT:    movd %xmm0, %eax
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_extract_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovshdup {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    ret{{[l|q]}}
  %ext = extractelement <4 x float> %a0, i32 1
  %bc = bitcast float %ext to i32
  ret i32 %bc
}

define <2 x double> @test_mm_floor_pd(<2 x double> %a0) {
; SSE-LABEL: test_mm_floor_pd:
; SSE:       # %bb.0:
; SSE-NEXT:    roundpd $1, %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_floor_pd:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundpd $1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %a0, i32 1)
  ret <2 x double> %res
}

define <4 x float> @test_mm_floor_ps(<4 x float> %a0) {
; SSE-LABEL: test_mm_floor_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    roundps $1, %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_floor_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundps $1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %a0, i32 1)
  ret <4 x float> %res
}

define <2 x double> @test_mm_floor_sd(<2 x double> %a0, <2 x double> %a1) {
; SSE-LABEL: test_mm_floor_sd:
; SSE:       # %bb.0:
; SSE-NEXT:    roundsd $1, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_floor_sd:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundsd $1, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.round.sd(<2 x double> %a0, <2 x double> %a1, i32 1)
  ret <2 x double> %res
}

define <4 x float> @test_mm_floor_ss(<4 x float> %a0, <4 x float> %a1) {
; SSE-LABEL: test_mm_floor_ss:
; SSE:       # %bb.0:
; SSE-NEXT:    roundss $1, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_floor_ss:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundss $1, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.round.ss(<4 x float> %a0, <4 x float> %a1, i32 1)
  ret <4 x float> %res
}

define <2 x i64> @test_mm_insert_epi8(<2 x i64> %a0, i8 %a1) {
; X86-SSE-LABEL: test_mm_insert_epi8:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    pinsrb $1, %eax, %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test_mm_insert_epi8:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    vpinsrb $1, %eax, %xmm0, %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_mm_insert_epi8:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movzbl %dil, %eax
; X64-SSE-NEXT:    pinsrb $1, %eax, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_mm_insert_epi8:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    movzbl %dil, %eax
; X64-AVX-NEXT:    vpinsrb $1, %eax, %xmm0, %xmm0
; X64-AVX-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = insertelement <16 x i8> %arg0, i8 %a1,i32 1
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_insert_epi32(<2 x i64> %a0, i32 %a1) {
; X86-SSE-LABEL: test_mm_insert_epi32:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    pinsrd $1, {{[0-9]+}}(%esp), %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test_mm_insert_epi32:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vpinsrd $1, {{[0-9]+}}(%esp), %xmm0, %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_mm_insert_epi32:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    pinsrd $1, %edi, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_mm_insert_epi32:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vpinsrd $1, %edi, %xmm0, %xmm0
; X64-AVX-NEXT:    retq
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %res = insertelement <4 x i32> %arg0, i32 %a1,i32 1
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_insert_epi64(<2 x i64> %a0, i64 %a1) {
; X86-SSE-LABEL: test_mm_insert_epi64:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    pinsrd $2, {{[0-9]+}}(%esp), %xmm0
; X86-SSE-NEXT:    pinsrd $3, {{[0-9]+}}(%esp), %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test_mm_insert_epi64:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    vpinsrd $2, {{[0-9]+}}(%esp), %xmm0, %xmm0
; X86-AVX-NEXT:    vpinsrd $3, {{[0-9]+}}(%esp), %xmm0, %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_mm_insert_epi64:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    pinsrq $1, %rdi, %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_mm_insert_epi64:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vpinsrq $1, %rdi, %xmm0, %xmm0
; X64-AVX-NEXT:    retq
  %res = insertelement <2 x i64> %a0, i64 %a1,i32 1
  ret <2 x i64> %res
}

define <4 x float> @test_mm_insert_ps(<4 x float> %a0, <4 x float> %a1) {
; SSE-LABEL: test_mm_insert_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    insertps {{.*#+}} xmm0 = xmm1[0],xmm0[1],zero,xmm0[3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_insert_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vinsertps {{.*#+}} xmm0 = xmm1[0],xmm0[1],zero,xmm0[3]
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.insertps(<4 x float> %a0, <4 x float> %a1, i8 4)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.insertps(<4 x float>, <4 x float>, i8) nounwind readnone

define <2 x i64> @test_mm_max_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_max_epi8:
; SSE:       # %bb.0:
; SSE-NEXT:    pmaxsb %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_max_epi8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %cmp = icmp sgt <16 x i8> %arg0, %arg1
  %sel = select <16 x i1> %cmp, <16 x i8> %arg0, <16 x i8> %arg1
  %bc = bitcast <16 x i8> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_max_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_max_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    pmaxsd %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_max_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %cmp = icmp sgt <4 x i32> %arg0, %arg1
  %sel = select <4 x i1> %cmp, <4 x i32> %arg0, <4 x i32> %arg1
  %bc = bitcast <4 x i32> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_max_epu16(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_max_epu16:
; SSE:       # %bb.0:
; SSE-NEXT:    pmaxuw %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_max_epu16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %cmp = icmp ugt <8 x i16> %arg0, %arg1
  %sel = select <8 x i1> %cmp, <8 x i16> %arg0, <8 x i16> %arg1
  %bc = bitcast <8 x i16> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_max_epu32(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_max_epu32:
; SSE:       # %bb.0:
; SSE-NEXT:    pmaxud %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_max_epu32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %cmp = icmp ugt <4 x i32> %arg0, %arg1
  %sel = select <4 x i1> %cmp, <4 x i32> %arg0, <4 x i32> %arg1
  %bc = bitcast <4 x i32> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_min_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_min_epi8:
; SSE:       # %bb.0:
; SSE-NEXT:    pminsb %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_min_epi8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpminsb %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %cmp = icmp slt <16 x i8> %arg0, %arg1
  %sel = select <16 x i1> %cmp, <16 x i8> %arg0, <16 x i8> %arg1
  %bc = bitcast <16 x i8> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_min_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_min_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    pminsd %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_min_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpminsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %cmp = icmp slt <4 x i32> %arg0, %arg1
  %sel = select <4 x i1> %cmp, <4 x i32> %arg0, <4 x i32> %arg1
  %bc = bitcast <4 x i32> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_min_epu16(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_min_epu16:
; SSE:       # %bb.0:
; SSE-NEXT:    pminuw %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_min_epu16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpminuw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %cmp = icmp ult <8 x i16> %arg0, %arg1
  %sel = select <8 x i1> %cmp, <8 x i16> %arg0, <8 x i16> %arg1
  %bc = bitcast <8 x i16> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_min_epu32(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_min_epu32:
; SSE:       # %bb.0:
; SSE-NEXT:    pminud %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_min_epu32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpminud %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %cmp = icmp ult <4 x i32> %arg0, %arg1
  %sel = select <4 x i1> %cmp, <4 x i32> %arg0, <4 x i32> %arg1
  %bc = bitcast <4 x i32> %sel to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_minpos_epu16(<2 x i64> %a0) {
; SSE-LABEL: test_mm_minpos_epu16:
; SSE:       # %bb.0:
; SSE-NEXT:    phminposuw %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_minpos_epu16:
; AVX:       # %bb.0:
; AVX-NEXT:    vphminposuw %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.sse41.phminposuw(<8 x i16> %arg0)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.sse41.phminposuw(<8 x i16>) nounwind readnone

define <2 x i64> @test_mm_mpsadbw_epu8(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_mpsadbw_epu8:
; SSE:       # %bb.0:
; SSE-NEXT:    mpsadbw $1, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_mpsadbw_epu8:
; AVX:       # %bb.0:
; AVX-NEXT:    vmpsadbw $1, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %res = call <8 x i16> @llvm.x86.sse41.mpsadbw(<16 x i8> %arg0, <16 x i8> %arg1, i8 1)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.sse41.mpsadbw(<16 x i8>, <16 x i8>, i8) nounwind readnone

define <2 x i64> @test_mm_mul_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_mul_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa %xmm0, %xmm2
; SSE-NEXT:    psllq $32, %xmm2
; SSE-NEXT:    psrad $31, %xmm2
; SSE-NEXT:    pblendw {{.*#+}} xmm2 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    psllq $32, %xmm0
; SSE-NEXT:    psrad $31, %xmm0
; SSE-NEXT:    pblendw {{.*#+}} xmm0 = xmm1[0,1],xmm0[2,3],xmm1[4,5],xmm0[6,7]
; SSE-NEXT:    pmuldq %xmm0, %xmm2
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX1-LABEL: test_mm_mul_epi32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpsllq $32, %xmm0, %xmm2
; AVX1-NEXT:    vpsrad $31, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    vpsllq $32, %xmm1, %xmm2
; AVX1-NEXT:    vpsrad $31, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3],xmm1[4,5],xmm2[6,7]
; AVX1-NEXT:    vpmuldq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    ret{{[l|q]}}
;
; AVX512-LABEL: test_mm_mul_epi32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpsllq $32, %xmm0, %xmm0
; AVX512-NEXT:    vpsraq $32, %xmm0, %xmm0
; AVX512-NEXT:    vpsllq $32, %xmm1, %xmm1
; AVX512-NEXT:    vpsraq $32, %xmm1, %xmm1
; AVX512-NEXT:    vpmullq %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    ret{{[l|q]}}
  %A = shl <2 x i64> %a0, <i64 32, i64 32>
  %A1 = ashr exact <2 x i64> %A, <i64 32, i64 32>
  %B = shl <2 x i64> %a1, <i64 32, i64 32>
  %B1 = ashr exact <2 x i64> %B, <i64 32, i64 32>
  %res = mul nsw <2 x i64> %A1, %B1
  ret <2 x i64> %res
}

define <2 x i64> @test_mm_mullo_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_mullo_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    pmulld %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_mullo_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = mul <4 x i32> %arg0, %arg1
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}

define <2 x i64> @test_mm_packus_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_packus_epi32:
; SSE:       # %bb.0:
; SSE-NEXT:    packusdw %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_packus_epi32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpackusdw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <8 x i16> @llvm.x86.sse41.packusdw(<4 x i32> %arg0, <4 x i32> %arg1)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.sse41.packusdw(<4 x i32>, <4 x i32>) nounwind readnone

define <2 x double> @test_mm_round_pd(<2 x double> %a0) {
; SSE-LABEL: test_mm_round_pd:
; SSE:       # %bb.0:
; SSE-NEXT:    roundpd $4, %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_round_pd:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundpd $4, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %a0, i32 4)
  ret <2 x double> %res
}

define <4 x float> @test_mm_round_ps(<4 x float> %a0) {
; SSE-LABEL: test_mm_round_ps:
; SSE:       # %bb.0:
; SSE-NEXT:    roundps $4, %xmm0, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_round_ps:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundps $4, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %a0, i32 4)
  ret <4 x float> %res
}

define <2 x double> @test_mm_round_sd(<2 x double> %a0, <2 x double> %a1) {
; SSE-LABEL: test_mm_round_sd:
; SSE:       # %bb.0:
; SSE-NEXT:    roundsd $4, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_round_sd:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundsd $4, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.sse41.round.sd(<2 x double> %a0, <2 x double> %a1, i32 4)
  ret <2 x double> %res
}

define <4 x float> @test_mm_round_ss(<4 x float> %a0, <4 x float> %a1) {
; SSE-LABEL: test_mm_round_ss:
; SSE:       # %bb.0:
; SSE-NEXT:    roundss $4, %xmm1, %xmm0
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_round_ss:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundss $4, %xmm1, %xmm0, %xmm0
; AVX-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.sse41.round.ss(<4 x float> %a0, <4 x float> %a1, i32 4)
  ret <4 x float> %res
}

define <2 x i64> @test_mm_stream_load_si128(<2 x i64>* %a0) {
; X86-SSE-LABEL: test_mm_stream_load_si128:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SSE-NEXT:    movntdqa (%eax), %xmm0
; X86-SSE-NEXT:    retl
;
; X86-AVX-LABEL: test_mm_stream_load_si128:
; X86-AVX:       # %bb.0:
; X86-AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-AVX-NEXT:    vmovntdqa (%eax), %xmm0
; X86-AVX-NEXT:    retl
;
; X64-SSE-LABEL: test_mm_stream_load_si128:
; X64-SSE:       # %bb.0:
; X64-SSE-NEXT:    movntdqa (%rdi), %xmm0
; X64-SSE-NEXT:    retq
;
; X64-AVX-LABEL: test_mm_stream_load_si128:
; X64-AVX:       # %bb.0:
; X64-AVX-NEXT:    vmovntdqa (%rdi), %xmm0
; X64-AVX-NEXT:    retq
  %arg0 = bitcast <2 x i64>* %a0 to i8*
  %res = call <2 x i64> @llvm.x86.sse41.movntdqa(i8* %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.sse41.movntdqa(i8*) nounwind readnone

define i32 @test_mm_test_all_ones(<2 x i64> %a0) {
; SSE-LABEL: test_mm_test_all_ones:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    ptest %xmm1, %xmm0
; SSE-NEXT:    setb %al
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_test_all_ones:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpeqd %xmm1, %xmm1, %xmm1
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %xmm1, %xmm0
; AVX-NEXT:    setb %al
; AVX-NEXT:    ret{{[l|q]}}
  %res = call i32 @llvm.x86.sse41.ptestc(<2 x i64> %a0, <2 x i64> <i64 -1, i64 -1>)
  ret i32 %res
}
declare i32 @llvm.x86.sse41.ptestc(<2 x i64>, <2 x i64>) nounwind readnone

define i32 @test_mm_test_all_zeros(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_test_all_zeros:
; SSE:       # %bb.0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    ptest %xmm1, %xmm0
; SSE-NEXT:    sete %al
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_test_all_zeros:
; AVX:       # %bb.0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %xmm1, %xmm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    ret{{[l|q]}}
  %res = call i32 @llvm.x86.sse41.ptestz(<2 x i64> %a0, <2 x i64> %a1)
  ret i32 %res
}
declare i32 @llvm.x86.sse41.ptestz(<2 x i64>, <2 x i64>) nounwind readnone

define i32 @test_mm_test_mix_ones_zeros(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_test_mix_ones_zeros:
; SSE:       # %bb.0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    ptest %xmm1, %xmm0
; SSE-NEXT:    seta %al
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_test_mix_ones_zeros:
; AVX:       # %bb.0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %xmm1, %xmm0
; AVX-NEXT:    seta %al
; AVX-NEXT:    ret{{[l|q]}}
  %res = call i32 @llvm.x86.sse41.ptestnzc(<2 x i64> %a0, <2 x i64> %a1)
  ret i32 %res
}
declare i32 @llvm.x86.sse41.ptestnzc(<2 x i64>, <2 x i64>) nounwind readnone

define i32 @test_mm_testc_si128(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_testc_si128:
; SSE:       # %bb.0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    ptest %xmm1, %xmm0
; SSE-NEXT:    setb %al
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_testc_si128:
; AVX:       # %bb.0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %xmm1, %xmm0
; AVX-NEXT:    setb %al
; AVX-NEXT:    ret{{[l|q]}}
  %res = call i32 @llvm.x86.sse41.ptestc(<2 x i64> %a0, <2 x i64> %a1)
  ret i32 %res
}

define i32 @test_mm_testnzc_si128(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_testnzc_si128:
; SSE:       # %bb.0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    ptest %xmm1, %xmm0
; SSE-NEXT:    seta %al
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_testnzc_si128:
; AVX:       # %bb.0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %xmm1, %xmm0
; AVX-NEXT:    seta %al
; AVX-NEXT:    ret{{[l|q]}}
  %res = call i32 @llvm.x86.sse41.ptestnzc(<2 x i64> %a0, <2 x i64> %a1)
  ret i32 %res
}

define i32 @test_mm_testz_si128(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_mm_testz_si128:
; SSE:       # %bb.0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    ptest %xmm1, %xmm0
; SSE-NEXT:    sete %al
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_mm_testz_si128:
; AVX:       # %bb.0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    vptest %xmm1, %xmm0
; AVX-NEXT:    sete %al
; AVX-NEXT:    ret{{[l|q]}}
  %res = call i32 @llvm.x86.sse41.ptestz(<2 x i64> %a0, <2 x i64> %a1)
  ret i32 %res
}
