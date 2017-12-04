; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512vl,+gfni,+avx512bw --show-mc-encoding | FileCheck %s

declare <16 x i8> @llvm.x86.vgf2p8affineinvqb.128(<16 x i8>, <16 x i8>, i8)
define <16 x i8> @test_vgf2p8affineinvqb_128(<16 x i8> %src1, <16 x i8> %src2, <16 x i8> %passthru, i16 %mask) {
; CHECK-LABEL: test_vgf2p8affineinvqb_128:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovd %edi, %k1 ## encoding: [0xc5,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %xmm1, %xmm0, %xmm3 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0xf9,0xcf,0xd9,0x03]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %xmm1, %xmm0, %xmm4 {%k1} {z} ## encoding: [0x62,0xf3,0xfd,0x89,0xcf,0xe1,0x03]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf3,0xfd,0x09,0xcf,0xd1,0x03]
; CHECK-NEXT:    vpxor %xmm3, %xmm2, %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xe9,0xef,0xc3]
; CHECK-NEXT:    vpxor %xmm0, %xmm4, %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xd9,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i16 %mask to <16 x i1>
  %2 = call <16 x i8> @llvm.x86.vgf2p8affineinvqb.128(<16 x i8> %src1, <16 x i8> %src2, i8 3)
  %3 = select <16 x i1> %1, <16 x i8> %2, <16 x i8> zeroinitializer
  %4 = select <16 x i1> %1, <16 x i8> %2, <16 x i8> %passthru
  %5 = xor <16 x i8> %3, %4
  %6 = xor <16 x i8> %5, %2
  ret <16 x i8> %6
}

declare <32 x i8> @llvm.x86.vgf2p8affineinvqb.256(<32 x i8>, <32 x i8>, i8)
define <32 x i8> @test_vgf2p8affineinvqb_256(<32 x i8> %src1, <32 x i8> %src2, <32 x i8> %passthru, i32 %mask) {
; CHECK-LABEL: test_vgf2p8affineinvqb_256:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovd %edi, %k1 ## encoding: [0xc5,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %ymm1, %ymm0, %ymm3 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0xfd,0xcf,0xd9,0x03]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %ymm1, %ymm0, %ymm4 {%k1} {z} ## encoding: [0x62,0xf3,0xfd,0xa9,0xcf,0xe1,0x03]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf3,0xfd,0x29,0xcf,0xd1,0x03]
; CHECK-NEXT:    vpxor %ymm3, %ymm2, %ymm0 ## EVEX TO VEX Compression encoding: [0xc5,0xed,0xef,0xc3]
; CHECK-NEXT:    vpxor %ymm0, %ymm4, %ymm0 ## EVEX TO VEX Compression encoding: [0xc5,0xdd,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i32 %mask to <32 x i1>
  %2 = call <32 x i8> @llvm.x86.vgf2p8affineinvqb.256(<32 x i8> %src1, <32 x i8> %src2, i8 3)
  %3 = select <32 x i1> %1, <32 x i8> %2, <32 x i8> zeroinitializer
  %4 = select <32 x i1> %1, <32 x i8> %2, <32 x i8> %passthru
  %5 = xor <32 x i8> %3, %4
  %6 = xor <32 x i8> %5, %2
  ret <32 x i8> %6
}

declare <64 x i8> @llvm.x86.vgf2p8affineinvqb.512(<64 x i8>, <64 x i8>, i8)
define <64 x i8> @test_vgf2p8affineinvqb_512(<64 x i8> %src1, <64 x i8> %src2, <64 x i8> %passthru, i64 %mask) {
; CHECK-LABEL: test_vgf2p8affineinvqb_512:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovq %rdi, %k1 ## encoding: [0xc4,0xe1,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %zmm1, %zmm0, %zmm3 ## encoding: [0x62,0xf3,0xfd,0x48,0xcf,0xd9,0x03]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %zmm1, %zmm0, %zmm4 {%k1} {z} ## encoding: [0x62,0xf3,0xfd,0xc9,0xcf,0xe1,0x03]
; CHECK-NEXT:    vgf2p8affineinvqb $3, %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf3,0xfd,0x49,0xcf,0xd1,0x03]
; CHECK-NEXT:    vpxorq %zmm3, %zmm2, %zmm0 ## encoding: [0x62,0xf1,0xed,0x48,0xef,0xc3]
; CHECK-NEXT:    vpxorq %zmm0, %zmm4, %zmm0 ## encoding: [0x62,0xf1,0xdd,0x48,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i64 %mask to <64 x i1>
  %2 = call <64 x i8> @llvm.x86.vgf2p8affineinvqb.512(<64 x i8> %src1, <64 x i8> %src2, i8 3)
  %3 = select <64 x i1> %1, <64 x i8> %2, <64 x i8> zeroinitializer
  %4 = select <64 x i1> %1, <64 x i8> %2, <64 x i8> %passthru
  %5 = xor <64 x i8> %3, %4
  %6 = xor <64 x i8> %5, %2
  ret <64 x i8> %6
}

declare <16 x i8> @llvm.x86.vgf2p8affineqb.128(<16 x i8>, <16 x i8>, i8)
define <16 x i8> @test_vgf2p8affineqb_128(<16 x i8> %src1, <16 x i8> %src2, <16 x i8> %passthru, i16 %mask) {
; CHECK-LABEL: test_vgf2p8affineqb_128:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovd %edi, %k1 ## encoding: [0xc5,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8affineqb $3, %xmm1, %xmm0, %xmm3 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0xf9,0xce,0xd9,0x03]
; CHECK-NEXT:    vgf2p8affineqb $3, %xmm1, %xmm0, %xmm4 {%k1} {z} ## encoding: [0x62,0xf3,0xfd,0x89,0xce,0xe1,0x03]
; CHECK-NEXT:    vgf2p8affineqb $3, %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf3,0xfd,0x09,0xce,0xd1,0x03]
; CHECK-NEXT:    vpxor %xmm3, %xmm2, %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xe9,0xef,0xc3]
; CHECK-NEXT:    vpxor %xmm0, %xmm4, %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xd9,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i16 %mask to <16 x i1>
  %2 = call <16 x i8> @llvm.x86.vgf2p8affineqb.128(<16 x i8> %src1, <16 x i8> %src2, i8 3)
  %3 = select <16 x i1> %1, <16 x i8> %2, <16 x i8> zeroinitializer
  %4 = select <16 x i1> %1, <16 x i8> %2, <16 x i8> %passthru
  %5 = xor <16 x i8> %3, %4
  %6 = xor <16 x i8> %5, %2
  ret <16 x i8> %6
}

declare <32 x i8> @llvm.x86.vgf2p8affineqb.256(<32 x i8>, <32 x i8>, i8)
define <32 x i8> @test_vgf2p8affineqb_256(<32 x i8> %src1, <32 x i8> %src2, <32 x i8> %passthru, i32 %mask) {
; CHECK-LABEL: test_vgf2p8affineqb_256:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovd %edi, %k1 ## encoding: [0xc5,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8affineqb $3, %ymm1, %ymm0, %ymm3 ## EVEX TO VEX Compression encoding: [0xc4,0xe3,0xfd,0xce,0xd9,0x03]
; CHECK-NEXT:    vgf2p8affineqb $3, %ymm1, %ymm0, %ymm4 {%k1} {z} ## encoding: [0x62,0xf3,0xfd,0xa9,0xce,0xe1,0x03]
; CHECK-NEXT:    vgf2p8affineqb $3, %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf3,0xfd,0x29,0xce,0xd1,0x03]
; CHECK-NEXT:    vpxor %ymm3, %ymm2, %ymm0 ## EVEX TO VEX Compression encoding: [0xc5,0xed,0xef,0xc3]
; CHECK-NEXT:    vpxor %ymm0, %ymm4, %ymm0 ## EVEX TO VEX Compression encoding: [0xc5,0xdd,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i32 %mask to <32 x i1>
  %2 = call <32 x i8> @llvm.x86.vgf2p8affineqb.256(<32 x i8> %src1, <32 x i8> %src2, i8 3)
  %3 = select <32 x i1> %1, <32 x i8> %2, <32 x i8> zeroinitializer
  %4 = select <32 x i1> %1, <32 x i8> %2, <32 x i8> %passthru
  %5 = xor <32 x i8> %3, %4
  %6 = xor <32 x i8> %5, %2
  ret <32 x i8> %6
}

declare <64 x i8> @llvm.x86.vgf2p8affineqb.512(<64 x i8>, <64 x i8>, i8)
define <64 x i8> @test_vgf2p8affineqb_512(<64 x i8> %src1, <64 x i8> %src2, <64 x i8> %passthru, i64 %mask) {
; CHECK-LABEL: test_vgf2p8affineqb_512:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovq %rdi, %k1 ## encoding: [0xc4,0xe1,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8affineqb $3, %zmm1, %zmm0, %zmm3 ## encoding: [0x62,0xf3,0xfd,0x48,0xce,0xd9,0x03]
; CHECK-NEXT:    vgf2p8affineqb $3, %zmm1, %zmm0, %zmm4 {%k1} {z} ## encoding: [0x62,0xf3,0xfd,0xc9,0xce,0xe1,0x03]
; CHECK-NEXT:    vgf2p8affineqb $3, %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf3,0xfd,0x49,0xce,0xd1,0x03]
; CHECK-NEXT:    vpxorq %zmm3, %zmm2, %zmm0 ## encoding: [0x62,0xf1,0xed,0x48,0xef,0xc3]
; CHECK-NEXT:    vpxorq %zmm0, %zmm4, %zmm0 ## encoding: [0x62,0xf1,0xdd,0x48,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i64 %mask to <64 x i1>
  %2 = call <64 x i8> @llvm.x86.vgf2p8affineqb.512(<64 x i8> %src1, <64 x i8> %src2, i8 3)
  %3 = select <64 x i1> %1, <64 x i8> %2, <64 x i8> zeroinitializer
  %4 = select <64 x i1> %1, <64 x i8> %2, <64 x i8> %passthru
  %5 = xor <64 x i8> %3, %4
  %6 = xor <64 x i8> %5, %2
  ret <64 x i8> %6
}

declare <16 x i8> @llvm.x86.vgf2p8mulb.128(<16 x i8>, <16 x i8>)
define <16 x i8> @test_vgf2p8mulb_128(<16 x i8> %src1, <16 x i8> %src2, <16 x i8> %passthru, i16 %mask) {
; CHECK-LABEL: test_vgf2p8mulb_128:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovd %edi, %k1 ## encoding: [0xc5,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8mulb %xmm1, %xmm0, %xmm3 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xcf,0xd9]
; CHECK-NEXT:    vgf2p8mulb %xmm1, %xmm0, %xmm4 {%k1} {z} ## encoding: [0x62,0xf2,0x7d,0x89,0xcf,0xe1]
; CHECK-NEXT:    vgf2p8mulb %xmm1, %xmm0, %xmm2 {%k1} ## encoding: [0x62,0xf2,0x7d,0x09,0xcf,0xd1]
; CHECK-NEXT:    vpxor %xmm3, %xmm2, %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xe9,0xef,0xc3]
; CHECK-NEXT:    vpxor %xmm0, %xmm4, %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xd9,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i16 %mask to <16 x i1>
  %2 = call <16 x i8> @llvm.x86.vgf2p8mulb.128(<16 x i8> %src1, <16 x i8> %src2)
  %3 = select <16 x i1> %1, <16 x i8> %2, <16 x i8> zeroinitializer
  %4 = select <16 x i1> %1, <16 x i8> %2, <16 x i8> %passthru
  %5 = xor <16 x i8> %3, %4
  %6 = xor <16 x i8> %5, %2
  ret <16 x i8> %6
}

declare <32 x i8> @llvm.x86.vgf2p8mulb.256(<32 x i8>, <32 x i8>)
define <32 x i8> @test_vgf2p8mulb_256(<32 x i8> %src1, <32 x i8> %src2, <32 x i8> %passthru, i32 %mask) {
; CHECK-LABEL: test_vgf2p8mulb_256:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovd %edi, %k1 ## encoding: [0xc5,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8mulb %ymm1, %ymm0, %ymm3 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x7d,0xcf,0xd9]
; CHECK-NEXT:    vgf2p8mulb %ymm1, %ymm0, %ymm4 {%k1} {z} ## encoding: [0x62,0xf2,0x7d,0xa9,0xcf,0xe1]
; CHECK-NEXT:    vgf2p8mulb %ymm1, %ymm0, %ymm2 {%k1} ## encoding: [0x62,0xf2,0x7d,0x29,0xcf,0xd1]
; CHECK-NEXT:    vpxor %ymm3, %ymm2, %ymm0 ## EVEX TO VEX Compression encoding: [0xc5,0xed,0xef,0xc3]
; CHECK-NEXT:    vpxor %ymm0, %ymm4, %ymm0 ## EVEX TO VEX Compression encoding: [0xc5,0xdd,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i32 %mask to <32 x i1>
  %2 = call <32 x i8> @llvm.x86.vgf2p8mulb.256(<32 x i8> %src1, <32 x i8> %src2)
  %3 = select <32 x i1> %1, <32 x i8> %2, <32 x i8> zeroinitializer
  %4 = select <32 x i1> %1, <32 x i8> %2, <32 x i8> %passthru
  %5 = xor <32 x i8> %3, %4
  %6 = xor <32 x i8> %5, %2
  ret <32 x i8> %6
}

declare <64 x i8> @llvm.x86.vgf2p8mulb.512(<64 x i8>, <64 x i8>)
define <64 x i8> @test_vgf2p8mulb_512(<64 x i8> %src1, <64 x i8> %src2, <64 x i8> %passthru, i64 %mask) {
; CHECK-LABEL: test_vgf2p8mulb_512:
; CHECK:       ## %bb.0:
; CHECK-NEXT:    kmovq %rdi, %k1 ## encoding: [0xc4,0xe1,0xfb,0x92,0xcf]
; CHECK-NEXT:    vgf2p8mulb %zmm1, %zmm0, %zmm3 ## encoding: [0x62,0xf2,0x7d,0x48,0xcf,0xd9]
; CHECK-NEXT:    vgf2p8mulb %zmm1, %zmm0, %zmm4 {%k1} {z} ## encoding: [0x62,0xf2,0x7d,0xc9,0xcf,0xe1]
; CHECK-NEXT:    vgf2p8mulb %zmm1, %zmm0, %zmm2 {%k1} ## encoding: [0x62,0xf2,0x7d,0x49,0xcf,0xd1]
; CHECK-NEXT:    vpxorq %zmm3, %zmm2, %zmm0 ## encoding: [0x62,0xf1,0xed,0x48,0xef,0xc3]
; CHECK-NEXT:    vpxorq %zmm0, %zmm4, %zmm0 ## encoding: [0x62,0xf1,0xdd,0x48,0xef,0xc0]
; CHECK-NEXT:    retq ## encoding: [0xc3]
  %1 = bitcast i64 %mask to <64 x i1>
  %2 = call <64 x i8> @llvm.x86.vgf2p8mulb.512(<64 x i8> %src1, <64 x i8> %src2)
  %3 = select <64 x i1> %1, <64 x i8> %2, <64 x i8> zeroinitializer
  %4 = select <64 x i1> %1, <64 x i8> %2, <64 x i8> %passthru
  %5 = xor <64 x i8> %3, %4
  %6 = xor <64 x i8> %5, %2
  ret <64 x i8> %6
}

