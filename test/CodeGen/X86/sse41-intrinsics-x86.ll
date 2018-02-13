; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -disable-peephole -mtriple=i386-apple-darwin -mattr=+sse4.1 -show-mc-encoding | FileCheck %s --check-prefix=SSE41
; RUN: llc < %s -disable-peephole -mtriple=i386-apple-darwin -mattr=+avx2 -show-mc-encoding | FileCheck %s --check-prefix=VCHECK --check-prefix=AVX2
; RUN: llc < %s -disable-peephole -mtriple=i386-apple-darwin -mcpu=skx -show-mc-encoding | FileCheck %s --check-prefix=VCHECK --check-prefix=SKX

define <2 x double> @test_x86_sse41_blendvpd(<2 x double> %a0, <2 x double> %a1, <2 x double> %a2) {
; SSE41-LABEL: test_x86_sse41_blendvpd:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    movapd %xmm0, %xmm3 ## encoding: [0x66,0x0f,0x28,0xd8]
; SSE41-NEXT:    movaps %xmm2, %xmm0 ## encoding: [0x0f,0x28,0xc2]
; SSE41-NEXT:    blendvpd %xmm0, %xmm1, %xmm3 ## encoding: [0x66,0x0f,0x38,0x15,0xd9]
; SSE41-NEXT:    movapd %xmm3, %xmm0 ## encoding: [0x66,0x0f,0x28,0xc3]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_blendvpd:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    vblendvpd %xmm2, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x4b,0xc1,0x20]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call <2 x double> @llvm.x86.sse41.blendvpd(<2 x double> %a0, <2 x double> %a1, <2 x double> %a2) ; <<2 x double>> [#uses=1]
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.blendvpd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone


define <4 x float> @test_x86_sse41_blendvps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2) {
; SSE41-LABEL: test_x86_sse41_blendvps:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    movaps %xmm0, %xmm3 ## encoding: [0x0f,0x28,0xd8]
; SSE41-NEXT:    movaps %xmm2, %xmm0 ## encoding: [0x0f,0x28,0xc2]
; SSE41-NEXT:    blendvps %xmm0, %xmm1, %xmm3 ## encoding: [0x66,0x0f,0x38,0x14,0xd9]
; SSE41-NEXT:    movaps %xmm3, %xmm0 ## encoding: [0x0f,0x28,0xc3]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_blendvps:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    vblendvps %xmm2, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x4a,0xc1,0x20]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x float> @llvm.x86.sse41.blendvps(<4 x float> %a0, <4 x float> %a1, <4 x float> %a2) ; <<4 x float>> [#uses=1]
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.blendvps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone


define <2 x double> @test_x86_sse41_dppd(<2 x double> %a0, <2 x double> %a1) {
; SSE41-LABEL: test_x86_sse41_dppd:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    dppd $7, %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x41,0xc1,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_dppd:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    vdppd $7, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x41,0xc1,0x07]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call <2 x double> @llvm.x86.sse41.dppd(<2 x double> %a0, <2 x double> %a1, i8 7) ; <<2 x double>> [#uses=1]
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.dppd(<2 x double>, <2 x double>, i8) nounwind readnone


define <4 x float> @test_x86_sse41_dpps(<4 x float> %a0, <4 x float> %a1) {
; SSE41-LABEL: test_x86_sse41_dpps:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    dpps $7, %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x40,0xc1,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_dpps:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    vdpps $7, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x40,0xc1,0x07]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x float> @llvm.x86.sse41.dpps(<4 x float> %a0, <4 x float> %a1, i8 7) ; <<4 x float>> [#uses=1]
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.dpps(<4 x float>, <4 x float>, i8) nounwind readnone


define <4 x float> @test_x86_sse41_insertps(<4 x float> %a0, <4 x float> %a1) {
; SSE41-LABEL: test_x86_sse41_insertps:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    insertps $17, %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x21,0xc1,0x11]
; SSE41-NEXT:    ## xmm0 = zero,xmm1[0],xmm0[2,3]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_insertps:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vinsertps $17, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x21,0xc1,0x11]
; AVX2-NEXT:    ## xmm0 = zero,xmm1[0],xmm0[2,3]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_insertps:
; SKX:       ## %bb.0:
; SKX-NEXT:    vinsertps $17, %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0x79,0x21,0xc1,0x11]
; SKX-NEXT:    ## xmm0 = zero,xmm1[0],xmm0[2,3]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x float> @llvm.x86.sse41.insertps(<4 x float> %a0, <4 x float> %a1, i8 17) ; <<4 x float>> [#uses=1]
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.insertps(<4 x float>, <4 x float>, i8) nounwind readnone



define <8 x i16> @test_x86_sse41_mpsadbw(<16 x i8> %a0, <16 x i8> %a1) {
; SSE41-LABEL: test_x86_sse41_mpsadbw:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    mpsadbw $7, %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x42,0xc1,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_mpsadbw:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    vmpsadbw $7, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x42,0xc1,0x07]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.sse41.mpsadbw(<16 x i8> %a0, <16 x i8> %a1, i8 7) ; <<8 x i16>> [#uses=1]
  ret <8 x i16> %res
}
declare <8 x i16> @llvm.x86.sse41.mpsadbw(<16 x i8>, <16 x i8>, i8) nounwind readnone


define <8 x i16> @test_x86_sse41_packusdw(<4 x i32> %a0, <4 x i32> %a1) {
; SSE41-LABEL: test_x86_sse41_packusdw:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    packusdw %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x2b,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_packusdw:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpackusdw %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x2b,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_packusdw:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpackusdw %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x2b,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.sse41.packusdw(<4 x i32> %a0, <4 x i32> %a1) ; <<8 x i16>> [#uses=1]
  ret <8 x i16> %res
}
declare <8 x i16> @llvm.x86.sse41.packusdw(<4 x i32>, <4 x i32>) nounwind readnone


define <8 x i16> @test_x86_sse41_packusdw_fold() {
; SSE41-LABEL: test_x86_sse41_packusdw_fold:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    movaps {{.*#+}} xmm0 = [0,0,0,0,65535,65535,0,0]
; SSE41-NEXT:    ## encoding: [0x0f,0x28,0x05,A,A,A,A]
; SSE41-NEXT:    ## fixup A - offset: 3, value: LCPI7_0, kind: FK_Data_4
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_packusdw_fold:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vmovaps {{.*#+}} xmm0 = [0,0,0,0,65535,65535,0,0]
; AVX2-NEXT:    ## encoding: [0xc5,0xf8,0x28,0x05,A,A,A,A]
; AVX2-NEXT:    ## fixup A - offset: 4, value: LCPI7_0, kind: FK_Data_4
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_packusdw_fold:
; SKX:       ## %bb.0:
; SKX-NEXT:    vmovaps LCPI7_0, %xmm0 ## EVEX TO VEX Compression xmm0 = [0,0,0,0,65535,65535,0,0]
; SKX-NEXT:    ## encoding: [0xc5,0xf8,0x28,0x05,A,A,A,A]
; SKX-NEXT:    ## fixup A - offset: 4, value: LCPI7_0, kind: FK_Data_4
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.sse41.packusdw(<4 x i32> zeroinitializer, <4 x i32> <i32 65535, i32 65536, i32 -1, i32 -131072>)
  ret <8 x i16> %res
}


define <16 x i8> @test_x86_sse41_pblendvb(<16 x i8> %a0, <16 x i8> %a1, <16 x i8> %a2) {
; SSE41-LABEL: test_x86_sse41_pblendvb:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm3 ## encoding: [0x66,0x0f,0x6f,0xd8]
; SSE41-NEXT:    movaps %xmm2, %xmm0 ## encoding: [0x0f,0x28,0xc2]
; SSE41-NEXT:    pblendvb %xmm0, %xmm1, %xmm3 ## encoding: [0x66,0x0f,0x38,0x10,0xd9]
; SSE41-NEXT:    movdqa %xmm3, %xmm0 ## encoding: [0x66,0x0f,0x6f,0xc3]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_pblendvb:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    vpblendvb %xmm2, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x4c,0xc1,0x20]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call <16 x i8> @llvm.x86.sse41.pblendvb(<16 x i8> %a0, <16 x i8> %a1, <16 x i8> %a2) ; <<16 x i8>> [#uses=1]
  ret <16 x i8> %res
}
declare <16 x i8> @llvm.x86.sse41.pblendvb(<16 x i8>, <16 x i8>, <16 x i8>) nounwind readnone


define <8 x i16> @test_x86_sse41_phminposuw(<8 x i16> %a0) {
; SSE41-LABEL: test_x86_sse41_phminposuw:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    phminposuw %xmm0, %xmm0 ## encoding: [0x66,0x0f,0x38,0x41,0xc0]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_phminposuw:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    vphminposuw %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x41,0xc0]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.sse41.phminposuw(<8 x i16> %a0) ; <<8 x i16>> [#uses=1]
  ret <8 x i16> %res
}
declare <8 x i16> @llvm.x86.sse41.phminposuw(<8 x i16>) nounwind readnone


define <16 x i8> @test_x86_sse41_pmaxsb(<16 x i8> %a0, <16 x i8> %a1) {
; SSE41-LABEL: test_x86_sse41_pmaxsb:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pmaxsb %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x3c,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pmaxsb:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x3c,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pmaxsb:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmaxsb %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x3c,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <16 x i8> @llvm.x86.sse41.pmaxsb(<16 x i8> %a0, <16 x i8> %a1) ; <<16 x i8>> [#uses=1]
  ret <16 x i8> %res
}
declare <16 x i8> @llvm.x86.sse41.pmaxsb(<16 x i8>, <16 x i8>) nounwind readnone


define <4 x i32> @test_x86_sse41_pmaxsd(<4 x i32> %a0, <4 x i32> %a1) {
; SSE41-LABEL: test_x86_sse41_pmaxsd:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pmaxsd %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x3d,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pmaxsd:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x3d,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pmaxsd:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmaxsd %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x3d,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x i32> @llvm.x86.sse41.pmaxsd(<4 x i32> %a0, <4 x i32> %a1) ; <<4 x i32>> [#uses=1]
  ret <4 x i32> %res
}
declare <4 x i32> @llvm.x86.sse41.pmaxsd(<4 x i32>, <4 x i32>) nounwind readnone


define <4 x i32> @test_x86_sse41_pmaxud(<4 x i32> %a0, <4 x i32> %a1) {
; SSE41-LABEL: test_x86_sse41_pmaxud:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pmaxud %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x3f,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pmaxud:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x3f,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pmaxud:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmaxud %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x3f,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x i32> @llvm.x86.sse41.pmaxud(<4 x i32> %a0, <4 x i32> %a1) ; <<4 x i32>> [#uses=1]
  ret <4 x i32> %res
}
declare <4 x i32> @llvm.x86.sse41.pmaxud(<4 x i32>, <4 x i32>) nounwind readnone


define <8 x i16> @test_x86_sse41_pmaxuw(<8 x i16> %a0, <8 x i16> %a1) {
; SSE41-LABEL: test_x86_sse41_pmaxuw:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pmaxuw %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x3e,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pmaxuw:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x3e,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pmaxuw:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmaxuw %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x3e,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.sse41.pmaxuw(<8 x i16> %a0, <8 x i16> %a1) ; <<8 x i16>> [#uses=1]
  ret <8 x i16> %res
}
declare <8 x i16> @llvm.x86.sse41.pmaxuw(<8 x i16>, <8 x i16>) nounwind readnone


define <16 x i8> @test_x86_sse41_pminsb(<16 x i8> %a0, <16 x i8> %a1) {
; SSE41-LABEL: test_x86_sse41_pminsb:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pminsb %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x38,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pminsb:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpminsb %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x38,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pminsb:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpminsb %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x38,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <16 x i8> @llvm.x86.sse41.pminsb(<16 x i8> %a0, <16 x i8> %a1) ; <<16 x i8>> [#uses=1]
  ret <16 x i8> %res
}
declare <16 x i8> @llvm.x86.sse41.pminsb(<16 x i8>, <16 x i8>) nounwind readnone


define <4 x i32> @test_x86_sse41_pminsd(<4 x i32> %a0, <4 x i32> %a1) {
; SSE41-LABEL: test_x86_sse41_pminsd:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pminsd %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x39,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pminsd:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpminsd %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x39,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pminsd:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpminsd %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x39,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x i32> @llvm.x86.sse41.pminsd(<4 x i32> %a0, <4 x i32> %a1) ; <<4 x i32>> [#uses=1]
  ret <4 x i32> %res
}
declare <4 x i32> @llvm.x86.sse41.pminsd(<4 x i32>, <4 x i32>) nounwind readnone


define <4 x i32> @test_x86_sse41_pminud(<4 x i32> %a0, <4 x i32> %a1) {
; SSE41-LABEL: test_x86_sse41_pminud:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pminud %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x3b,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pminud:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpminud %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x3b,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pminud:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpminud %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x3b,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x i32> @llvm.x86.sse41.pminud(<4 x i32> %a0, <4 x i32> %a1) ; <<4 x i32>> [#uses=1]
  ret <4 x i32> %res
}
declare <4 x i32> @llvm.x86.sse41.pminud(<4 x i32>, <4 x i32>) nounwind readnone


define <8 x i16> @test_x86_sse41_pminuw(<8 x i16> %a0, <8 x i16> %a1) {
; SSE41-LABEL: test_x86_sse41_pminuw:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pminuw %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x3a,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pminuw:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpminuw %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x3a,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pminuw:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpminuw %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x3a,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <8 x i16> @llvm.x86.sse41.pminuw(<8 x i16> %a0, <8 x i16> %a1) ; <<8 x i16>> [#uses=1]
  ret <8 x i16> %res
}
declare <8 x i16> @llvm.x86.sse41.pminuw(<8 x i16>, <8 x i16>) nounwind readnone


define <2 x i64> @test_x86_sse41_pmuldq(<4 x i32> %a0, <4 x i32> %a1) {
; SSE41-LABEL: test_x86_sse41_pmuldq:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    pmuldq %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x28,0xc1]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_pmuldq:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vpmuldq %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x28,0xc1]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_pmuldq:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmuldq %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0x28,0xc1]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <2 x i64> @llvm.x86.sse41.pmuldq(<4 x i32> %a0, <4 x i32> %a1) ; <<2 x i64>> [#uses=1]
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.sse41.pmuldq(<4 x i32>, <4 x i32>) nounwind readnone


define i32 @test_x86_sse41_ptestc(<2 x i64> %a0, <2 x i64> %a1) {
; SSE41-LABEL: test_x86_sse41_ptestc:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    xorl %eax, %eax ## encoding: [0x31,0xc0]
; SSE41-NEXT:    ptest %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x17,0xc1]
; SSE41-NEXT:    setb %al ## encoding: [0x0f,0x92,0xc0]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_ptestc:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    xorl %eax, %eax ## encoding: [0x31,0xc0]
; VCHECK-NEXT:    vptest %xmm1, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x17,0xc1]
; VCHECK-NEXT:    setb %al ## encoding: [0x0f,0x92,0xc0]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call i32 @llvm.x86.sse41.ptestc(<2 x i64> %a0, <2 x i64> %a1) ; <i32> [#uses=1]
  ret i32 %res
}
declare i32 @llvm.x86.sse41.ptestc(<2 x i64>, <2 x i64>) nounwind readnone


define i32 @test_x86_sse41_ptestnzc(<2 x i64> %a0, <2 x i64> %a1) {
; SSE41-LABEL: test_x86_sse41_ptestnzc:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    xorl %eax, %eax ## encoding: [0x31,0xc0]
; SSE41-NEXT:    ptest %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x17,0xc1]
; SSE41-NEXT:    seta %al ## encoding: [0x0f,0x97,0xc0]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_ptestnzc:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    xorl %eax, %eax ## encoding: [0x31,0xc0]
; VCHECK-NEXT:    vptest %xmm1, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x17,0xc1]
; VCHECK-NEXT:    seta %al ## encoding: [0x0f,0x97,0xc0]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call i32 @llvm.x86.sse41.ptestnzc(<2 x i64> %a0, <2 x i64> %a1) ; <i32> [#uses=1]
  ret i32 %res
}
declare i32 @llvm.x86.sse41.ptestnzc(<2 x i64>, <2 x i64>) nounwind readnone


define i32 @test_x86_sse41_ptestz(<2 x i64> %a0, <2 x i64> %a1) {
; SSE41-LABEL: test_x86_sse41_ptestz:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    xorl %eax, %eax ## encoding: [0x31,0xc0]
; SSE41-NEXT:    ptest %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x38,0x17,0xc1]
; SSE41-NEXT:    sete %al ## encoding: [0x0f,0x94,0xc0]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; VCHECK-LABEL: test_x86_sse41_ptestz:
; VCHECK:       ## %bb.0:
; VCHECK-NEXT:    xorl %eax, %eax ## encoding: [0x31,0xc0]
; VCHECK-NEXT:    vptest %xmm1, %xmm0 ## encoding: [0xc4,0xe2,0x79,0x17,0xc1]
; VCHECK-NEXT:    sete %al ## encoding: [0x0f,0x94,0xc0]
; VCHECK-NEXT:    retl ## encoding: [0xc3]
  %res = call i32 @llvm.x86.sse41.ptestz(<2 x i64> %a0, <2 x i64> %a1) ; <i32> [#uses=1]
  ret i32 %res
}
declare i32 @llvm.x86.sse41.ptestz(<2 x i64>, <2 x i64>) nounwind readnone


define <2 x double> @test_x86_sse41_round_pd(<2 x double> %a0) {
; SSE41-LABEL: test_x86_sse41_round_pd:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    roundpd $7, %xmm0, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x09,0xc0,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_round_pd:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vroundpd $7, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x09,0xc0,0x07]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_round_pd:
; SKX:       ## %bb.0:
; SKX-NEXT:    vroundpd $7, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0x79,0x09,0xc0,0x07]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %a0, i32 7) ; <<2 x double>> [#uses=1]
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.round.pd(<2 x double>, i32) nounwind readnone


define <4 x float> @test_x86_sse41_round_ps(<4 x float> %a0) {
; SSE41-LABEL: test_x86_sse41_round_ps:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    roundps $7, %xmm0, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x08,0xc0,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_round_ps:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vroundps $7, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x08,0xc0,0x07]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_round_ps:
; SKX:       ## %bb.0:
; SKX-NEXT:    vroundps $7, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0x79,0x08,0xc0,0x07]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %a0, i32 7) ; <<4 x float>> [#uses=1]
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.round.ps(<4 x float>, i32) nounwind readnone


define <2 x double> @test_x86_sse41_round_sd(<2 x double> %a0, <2 x double> %a1) {
; SSE41-LABEL: test_x86_sse41_round_sd:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    roundsd $7, %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x0b,0xc1,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_round_sd:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vroundsd $7, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x0b,0xc1,0x07]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_round_sd:
; SKX:       ## %bb.0:
; SKX-NEXT:    vroundsd $7, %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0x79,0x0b,0xc1,0x07]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <2 x double> @llvm.x86.sse41.round.sd(<2 x double> %a0, <2 x double> %a1, i32 7) ; <<2 x double>> [#uses=1]
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.sse41.round.sd(<2 x double>, <2 x double>, i32) nounwind readnone


define <2 x double> @test_x86_sse41_round_sd_load(<2 x double> %a0, <2 x double>* %a1) {
; SSE41-LABEL: test_x86_sse41_round_sd_load:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    movl {{[0-9]+}}(%esp), %eax ## encoding: [0x8b,0x44,0x24,0x04]
; SSE41-NEXT:    roundsd $7, (%eax), %xmm0 ## encoding: [0x66,0x0f,0x3a,0x0b,0x00,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_round_sd_load:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    movl {{[0-9]+}}(%esp), %eax ## encoding: [0x8b,0x44,0x24,0x04]
; AVX2-NEXT:    vroundsd $7, (%eax), %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x0b,0x00,0x07]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_round_sd_load:
; SKX:       ## %bb.0:
; SKX-NEXT:    movl {{[0-9]+}}(%esp), %eax ## encoding: [0x8b,0x44,0x24,0x04]
; SKX-NEXT:    vroundsd $7, (%eax), %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0x79,0x0b,0x00,0x07]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %a1b = load <2 x double>, <2 x double>* %a1
  %res = call <2 x double> @llvm.x86.sse41.round.sd(<2 x double> %a0, <2 x double> %a1b, i32 7) ; <<2 x double>> [#uses=1]
  ret <2 x double> %res
}


define <4 x float> @test_x86_sse41_round_ss(<4 x float> %a0, <4 x float> %a1) {
; SSE41-LABEL: test_x86_sse41_round_ss:
; SSE41:       ## %bb.0:
; SSE41-NEXT:    roundss $7, %xmm1, %xmm0 ## encoding: [0x66,0x0f,0x3a,0x0a,0xc1,0x07]
; SSE41-NEXT:    retl ## encoding: [0xc3]
;
; AVX2-LABEL: test_x86_sse41_round_ss:
; AVX2:       ## %bb.0:
; AVX2-NEXT:    vroundss $7, %xmm1, %xmm0, %xmm0 ## encoding: [0xc4,0xe3,0x79,0x0a,0xc1,0x07]
; AVX2-NEXT:    retl ## encoding: [0xc3]
;
; SKX-LABEL: test_x86_sse41_round_ss:
; SKX:       ## %bb.0:
; SKX-NEXT:    vroundss $7, %xmm1, %xmm0, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0x79,0x0a,0xc1,0x07]
; SKX-NEXT:    retl ## encoding: [0xc3]
  %res = call <4 x float> @llvm.x86.sse41.round.ss(<4 x float> %a0, <4 x float> %a1, i32 7) ; <<4 x float>> [#uses=1]
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.sse41.round.ss(<4 x float>, <4 x float>, i32) nounwind readnone
