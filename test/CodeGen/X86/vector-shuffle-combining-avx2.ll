; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=+avx2 | FileCheck %s

declare <8 x i32> @llvm.x86.avx2.permd(<8 x i32>, <8 x i32>)
declare <8 x float> @llvm.x86.avx2.permps(<8 x float>, <8 x i32>)
declare <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8>, <16 x i8>)
declare <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8>, <32 x i8>)

define <32 x i8> @combine_pshufb_pslldq(<32 x i8> %a0) {
; CHECK-LABEL: combine_pshufb_pslldq:
; CHECK:       # BB#0:
; CHECK-NEXT:    vxorps %ymm0, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %1 = tail call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %a0, <32 x i8> <i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>)
  %2 = shufflevector <32 x i8> %1, <32 x i8> zeroinitializer, <32 x i32> <i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  ret <32 x i8> %2
}

define <32 x i8> @combine_pshufb_psrldq(<32 x i8> %a0) {
; CHECK-LABEL: combine_pshufb_psrldq:
; CHECK:       # BB#0:
; CHECK-NEXT:    vxorps %ymm0, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %1 = tail call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %a0, <32 x i8> <i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128>)
  %2 = shufflevector <32 x i8> %1, <32 x i8> zeroinitializer, <32 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32>
  ret <32 x i8> %2
}

define <32 x i8> @combine_pshufb_vpermd(<8 x i32> %a) {
; CHECK-LABEL: combine_pshufb_vpermd:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,16,17,18,18]
; CHECK-NEXT:    retq
  %tmp0 = call <8 x i32> @llvm.x86.avx2.permd(<8 x i32> %a, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 4>)
  %tmp1 = bitcast <8 x i32> %tmp0 to <32 x i8>
  %tmp2 = shufflevector <32 x i8> %tmp1, <32 x i8> undef, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 30>
  ret <32 x i8> %tmp2
}

define <32 x i8> @combine_pshufb_vpermps(<8 x float> %a) {
; CHECK-LABEL: combine_pshufb_vpermps:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,16,17,18,18]
; CHECK-NEXT:    retq
  %tmp0 = call <8 x float> @llvm.x86.avx2.permps(<8 x float> %a, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 4>)
  %tmp1 = bitcast <8 x float> %tmp0 to <32 x i8>
  %tmp2 = shufflevector <32 x i8> %tmp1, <32 x i8> undef, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 30>
  ret <32 x i8> %tmp2
}

define <4 x i64> @combine_permq_pshufb(<4 x i64> %a0) {
; CHECK-LABEL: combine_permq_pshufb:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[3,2,1,0]
; CHECK-NEXT:    vpshufd {{.*#+}} ymm0 = ymm0[2,3,0,1,6,7,4,5]
; CHECK-NEXT:    retq
  %1 = shufflevector <4 x i64> %a0, <4 x i64> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %2 = bitcast <4 x i64> %1 to <32 x i8>
  %3 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %2, <32 x i8> <i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>)
  %4 = bitcast <32 x i8> %3 to <4 x i64>
  ret <4 x i64> %4
}

define <16 x i8> @combine_pshufb_as_vpbroadcastb128(<16 x i8> %a) {
; CHECK-LABEL: combine_pshufb_as_vpbroadcastb128:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpbroadcastb %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a, <16 x i8> zeroinitializer)
  ret <16 x i8> %1
}

define <32 x i8> @combine_pshufb_as_vpbroadcastb256(<2 x i64> %a) {
; CHECK-LABEL: combine_pshufb_as_vpbroadcastb256:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; CHECK-NEXT:    vpbroadcastb %xmm0, %ymm0
; CHECK-NEXT:    retq
  %1 = shufflevector <2 x i64> %a, <2 x i64> undef, <4 x i32> <i32 0, i32 undef, i32 undef, i32 undef>
  %2 = bitcast <4 x i64> %1 to <32 x i8>
  %3 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %2, <32 x i8> zeroinitializer)
  %4 = bitcast <32 x i8> %3 to <8 x i32>
  %5 = call <8 x i32> @llvm.x86.avx2.permd(<8 x i32> %4, <8 x i32> zeroinitializer)
  %6 = bitcast <8 x i32> %5 to <32 x i8>
  ret <32 x i8> %6
}

define <16 x i8> @combine_pshufb_as_vpbroadcastw128(<16 x i8> %a) {
; CHECK-LABEL: combine_pshufb_as_vpbroadcastw128:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpbroadcastw %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a, <16 x i8> <i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1>)
  ret <16 x i8> %1
}

define <32 x i8> @combine_pshufb_as_vpbroadcastw256(<2 x i64> %a) {
; CHECK-LABEL: combine_pshufb_as_vpbroadcastw256:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; CHECK-NEXT:    vpbroadcastw %xmm0, %ymm0
; CHECK-NEXT:    retq
  %1 = shufflevector <2 x i64> %a, <2 x i64> undef, <4 x i32> <i32 0, i32 undef, i32 undef, i32 undef>
  %2 = bitcast <4 x i64> %1 to <32 x i8>
  %3 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %2, <32 x i8> <i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1, i8 0, i8 1>)
  %4 = bitcast <32 x i8> %3 to <8 x i32>
  %5 = call <8 x i32> @llvm.x86.avx2.permd(<8 x i32> %4, <8 x i32> zeroinitializer)
  %6 = bitcast <8 x i32> %5 to <32 x i8>
  ret <32 x i8> %6
}

define <16 x i8> @combine_pshufb_as_vpbroadcastd128(<16 x i8> %a) {
; CHECK-LABEL: combine_pshufb_as_vpbroadcastd128:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpbroadcastd %xmm0, %xmm0
; CHECK-NEXT:    vpaddb {{.*}}(%rip), %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3>)
  %2 = add <16 x i8> %1, <i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3>
  ret <16 x i8> %2
}

define <8 x i32> @combine_permd_as_vpbroadcastd256(<4 x i32> %a) {
; CHECK-LABEL: combine_permd_as_vpbroadcastd256:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; CHECK-NEXT:    vpbroadcastd %xmm0, %ymm0
; CHECK-NEXT:    vpaddd {{.*}}(%rip), %ymm0, %ymm0
; CHECK-NEXT:    retq
  %1 = shufflevector <4 x i32> %a, <4 x i32> undef, <8 x i32> <i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = call <8 x i32> @llvm.x86.avx2.permd(<8 x i32> %1, <8 x i32> zeroinitializer)
  %3 = add <8 x i32> %2, <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3>
  ret <8 x i32> %3
}

define <16 x i8> @combine_pshufb_as_vpbroadcastq128(<16 x i8> %a) {
; CHECK-LABEL: combine_pshufb_as_vpbroadcastq128:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpbroadcastq %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %a, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>)
  ret <16 x i8> %1
}

define <8 x i32> @combine_permd_as_vpbroadcastq256(<4 x i32> %a) {
; CHECK-LABEL: combine_permd_as_vpbroadcastq256:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; CHECK-NEXT:    vpbroadcastq %xmm0, %ymm0
; CHECK-NEXT:    vpaddd {{.*}}(%rip), %ymm0, %ymm0
; CHECK-NEXT:    retq
  %1 = shufflevector <4 x i32> %a, <4 x i32> undef, <8 x i32> <i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = call <8 x i32> @llvm.x86.avx2.permd(<8 x i32> %1, <8 x i32> <i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1>)
  %3 = add <8 x i32> %2, <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3>
  ret <8 x i32> %3
}

define <4 x float> @combine_pshufb_as_vpbroadcastss128(<4 x float> %a) {
; CHECK-LABEL: combine_pshufb_as_vpbroadcastss128:
; CHECK:       # BB#0:
; CHECK-NEXT:    vbroadcastss %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = bitcast <4 x float> %a to <16 x i8>
  %2 = call <16 x i8> @llvm.x86.ssse3.pshuf.b.128(<16 x i8> %1, <16 x i8> <i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3, i8 0, i8 1, i8 2, i8 3>)
  %3 = bitcast <16 x i8> %2 to <4 x float>
  ret <4 x float> %3
}

define <8 x float> @combine_permd_as_vpbroadcastss256(<4 x float> %a) {
; CHECK-LABEL: combine_permd_as_vpbroadcastss256:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; CHECK-NEXT:    vbroadcastss %xmm0, %ymm0
; CHECK-NEXT:    retq
  %1 = shufflevector <4 x float> %a, <4 x float> undef, <8 x i32> <i32 0, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %2 = call <8 x float> @llvm.x86.avx2.permps(<8 x float> %1, <8 x i32> zeroinitializer)
  ret <8 x float> %2
}

define <4 x double> @combine_permd_as_vpbroadcastsd256(<2 x double> %a) {
; CHECK-LABEL: combine_permd_as_vpbroadcastsd256:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<def>
; CHECK-NEXT:    vbroadcastsd %xmm0, %ymm0
; CHECK-NEXT:    retq
  %1 = shufflevector <2 x double> %a, <2 x double> undef, <4 x i32> <i32 0, i32 undef, i32 undef, i32 undef>
  %2 = bitcast <4 x double> %1 to <8 x float>
  %3 = call <8 x float> @llvm.x86.avx2.permps(<8 x float> %2, <8 x i32> <i32 0, i32 1, i32 0, i32 1, i32 0, i32 1, i32 0, i32 1>)
  %4 = bitcast <8 x float> %3 to <4 x double>
  ret <4 x double> %4
}

define <8 x i32> @combine_permd_as_permq(<8 x i32> %a) {
; CHECK-LABEL: combine_permd_as_permq:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,2,1]
; CHECK-NEXT:    retq
  %1 = call <8 x i32> @llvm.x86.avx2.permd(<8 x i32> %a, <8 x i32> <i32 0, i32 1, i32 4, i32 5, i32 4, i32 5, i32 2, i32 3>)
  ret <8 x i32> %1
}

define <8 x float> @combine_permps_as_permpd(<8 x float> %a) {
; CHECK-LABEL: combine_permps_as_permpd:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpermpd {{.*#+}} ymm0 = ymm0[3,2,0,1]
; CHECK-NEXT:    retq
  %1 = call <8 x float> @llvm.x86.avx2.permps(<8 x float> %a, <8 x i32> <i32 6, i32 7, i32 4, i32 5, i32 0, i32 1, i32 2, i32 3>)
  ret <8 x float> %1
}

define <32 x i8> @combine_pshufb_as_pslldq(<32 x i8> %a0) {
; CHECK-LABEL: combine_pshufb_as_pslldq:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpshufb {{.*#+}} ymm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,ymm0[0,1,2,3,4,5],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,ymm0[16,17,18,19,20,21]
; CHECK-NEXT:    retq
  %res0 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %a0, <32 x i8> <i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5>)
  ret <32 x i8> %res0
}

define <32 x i8> @combine_pshufb_as_psrldq(<32 x i8> %a0) {
; CHECK-LABEL: combine_pshufb_as_psrldq:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[15],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,ymm0[31],zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero
; CHECK-NEXT:    retq
  %res0 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %a0, <32 x i8> <i8 15, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 15, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128>)
  ret <32 x i8> %res0
}

define <32 x i8> @combine_pshufb_as_pshuflw(<32 x i8> %a0) {
; CHECK-LABEL: combine_pshufb_as_pshuflw:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpshuflw {{.*#+}} ymm0 = ymm0[1,0,3,2,4,5,6,7,9,8,11,10,12,13,14,15]
; CHECK-NEXT:    retq
  %res0 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %a0, <32 x i8> <i8 2, i8 3, i8 0, i8 1, i8 6, i8 7, i8 4, i8 5, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 2, i8 3, i8 0, i8 1, i8 6, i8 7, i8 4, i8 5, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>)
  ret <32 x i8> %res0
}

define <32 x i8> @combine_pshufb_as_pshufhw(<32 x i8> %a0) {
; CHECK-LABEL: combine_pshufb_as_pshufhw:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpshufhw {{.*#+}} ymm0 = ymm0[0,1,2,3,5,4,7,6,8,9,10,11,13,12,15,14]
; CHECK-NEXT:    retq
  %res0 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %a0, <32 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 10, i8 11, i8 8, i8 9, i8 14, i8 15, i8 12, i8 13, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 10, i8 11, i8 8, i8 9, i8 14, i8 15, i8 12, i8 13>)
  ret <32 x i8> %res0
}

define <32 x i8> @combine_pshufb_not_as_pshufw(<32 x i8> %a0) {
; CHECK-LABEL: combine_pshufb_not_as_pshufw:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[2,3,0,1,6,7,4,5,10,11,8,9,14,15,12,13,18,19,16,17,22,23,20,21,26,27,24,25,30,31,28,29]
; CHECK-NEXT:    retq
  %res0 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %a0, <32 x i8> <i8 2, i8 3, i8 0, i8 1, i8 6, i8 7, i8 4, i8 5, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15, i8 2, i8 3, i8 0, i8 1, i8 6, i8 7, i8 4, i8 5, i8 8, i8 9, i8 10, i8 11, i8 12, i8 13, i8 14, i8 15>)
  %res1 = call <32 x i8> @llvm.x86.avx2.pshuf.b(<32 x i8> %res0, <32 x i8> <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 10, i8 11, i8 8, i8 9, i8 14, i8 15, i8 12, i8 13, i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7, i8 10, i8 11, i8 8, i8 9, i8 14, i8 15, i8 12, i8 13>)
  ret <32 x i8> %res1
}
