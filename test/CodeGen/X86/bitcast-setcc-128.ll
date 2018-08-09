; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX12,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX12,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefixes=AVX512 --check-prefixes=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefixes=AVX512 --check-prefixes=AVX512BW

define i8 @v8i16(<8 x i16> %a, <8 x i16> %b) {
; SSE2-SSSE3-LABEL: v8i16:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v8i16:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX12-NEXT:    vpmovmskb %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v8i16:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX512F-NEXT:    vpmovsxwd %xmm0, %ymm0
; AVX512F-NEXT:    vptestmd %ymm0, %ymm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v8i16:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpcmpgtw %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <8 x i16> %a, %b
  %res = bitcast <8 x i1> %x to i8
  ret i8 %res
}

define i4 @v4i32(<4 x i32> %a, <4 x i32> %b) {
; SSE2-SSSE3-LABEL: v4i32:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    movmskps %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v4i32:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vmovmskps %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v4i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpcmpgtd %xmm1, %xmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v4i32:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpcmpgtd %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <4 x i32> %a, %b
  %res = bitcast <4 x i1> %x to i4
  ret i4 %res
}

define i4 @v4f32(<4 x float> %a, <4 x float> %b) {
; SSE2-SSSE3-LABEL: v4f32:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    cmpltps %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    movmskps %xmm1, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v4f32:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vcmpltps %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    vmovmskps %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v4f32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vcmpltps %xmm0, %xmm1, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v4f32:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vcmpltps %xmm0, %xmm1, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = fcmp ogt <4 x float> %a, %b
  %res = bitcast <4 x i1> %x to i4
  ret i4 %res
}

define i16 @v16i8(<16 x i8> %a, <16 x i8> %b) {
; SSE2-SSSE3-LABEL: v16i8:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pcmpgtb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v16i8:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vpmovmskb %xmm0, %eax
; AVX12-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v16i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm0
; AVX512F-NEXT:    vpmovsxbd %xmm0, %zmm0
; AVX512F-NEXT:    vptestmd %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v16i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpcmpgtb %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <16 x i8> %a, %b
  %res = bitcast <16 x i1> %x to i16
  ret i16 %res
}

define i2 @v2i8(<2 x i8> %a, <2 x i8> %b) {
; SSE2-SSSE3-LABEL: v2i8:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    psllq $56, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    psrad $31, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,3,2,3]
; SSE2-SSSE3-NEXT:    psrad $24, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,3,2,3]
; SSE2-SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE2-SSSE3-NEXT:    psllq $56, %xmm1
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    psrad $31, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,3,2,3]
; SSE2-SSSE3-NEXT:    psrad $24, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,3,2,3]
; SSE2-SSSE3-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-SSSE3-NEXT:    pxor %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pxor %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    movmskpd %xmm1, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v2i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpsllq $56, %xmm1, %xmm1
; AVX1-NEXT:    vpsrad $31, %xmm1, %xmm2
; AVX1-NEXT:    vpsrad $24, %xmm1, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3],xmm1[4,5],xmm2[6,7]
; AVX1-NEXT:    vpsllq $56, %xmm0, %xmm0
; AVX1-NEXT:    vpsrad $31, %xmm0, %xmm2
; AVX1-NEXT:    vpsrad $24, %xmm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovmskpd %xmm0, %eax
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v2i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsllq $56, %xmm1, %xmm1
; AVX2-NEXT:    vpsrad $31, %xmm1, %xmm2
; AVX2-NEXT:    vpsrad $24, %xmm1, %xmm1
; AVX2-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; AVX2-NEXT:    vpblendd {{.*#+}} xmm1 = xmm1[0],xmm2[1],xmm1[2],xmm2[3]
; AVX2-NEXT:    vpsllq $56, %xmm0, %xmm0
; AVX2-NEXT:    vpsrad $31, %xmm0, %xmm2
; AVX2-NEXT:    vpsrad $24, %xmm0, %xmm0
; AVX2-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX2-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX2-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vmovmskpd %xmm0, %eax
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v2i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpsllq $56, %xmm1, %xmm1
; AVX512F-NEXT:    vpsraq $56, %xmm1, %xmm1
; AVX512F-NEXT:    vpsllq $56, %xmm0, %xmm0
; AVX512F-NEXT:    vpsraq $56, %xmm0, %xmm0
; AVX512F-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v2i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpsllq $56, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsraq $56, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsllq $56, %xmm0, %xmm0
; AVX512BW-NEXT:    vpsraq $56, %xmm0, %xmm0
; AVX512BW-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <2 x i8> %a, %b
  %res = bitcast <2 x i1> %x to i2
  ret i2 %res
}

define i2 @v2i16(<2 x i16> %a, <2 x i16> %b) {
; SSE2-SSSE3-LABEL: v2i16:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    psllq $48, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    psrad $31, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,3,2,3]
; SSE2-SSSE3-NEXT:    psrad $16, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,3,2,3]
; SSE2-SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; SSE2-SSSE3-NEXT:    psllq $48, %xmm1
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    psrad $31, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,3,2,3]
; SSE2-SSSE3-NEXT:    psrad $16, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,3,2,3]
; SSE2-SSSE3-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-SSSE3-NEXT:    pxor %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pxor %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    movmskpd %xmm1, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v2i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpsllq $48, %xmm1, %xmm1
; AVX1-NEXT:    vpsrad $31, %xmm1, %xmm2
; AVX1-NEXT:    vpsrad $16, %xmm1, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3],xmm1[4,5],xmm2[6,7]
; AVX1-NEXT:    vpsllq $48, %xmm0, %xmm0
; AVX1-NEXT:    vpsrad $31, %xmm0, %xmm2
; AVX1-NEXT:    vpsrad $16, %xmm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovmskpd %xmm0, %eax
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v2i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsllq $48, %xmm1, %xmm1
; AVX2-NEXT:    vpsrad $31, %xmm1, %xmm2
; AVX2-NEXT:    vpsrad $16, %xmm1, %xmm1
; AVX2-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; AVX2-NEXT:    vpblendd {{.*#+}} xmm1 = xmm1[0],xmm2[1],xmm1[2],xmm2[3]
; AVX2-NEXT:    vpsllq $48, %xmm0, %xmm0
; AVX2-NEXT:    vpsrad $31, %xmm0, %xmm2
; AVX2-NEXT:    vpsrad $16, %xmm0, %xmm0
; AVX2-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; AVX2-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX2-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vmovmskpd %xmm0, %eax
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v2i16:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpsllq $48, %xmm1, %xmm1
; AVX512F-NEXT:    vpsraq $48, %xmm1, %xmm1
; AVX512F-NEXT:    vpsllq $48, %xmm0, %xmm0
; AVX512F-NEXT:    vpsraq $48, %xmm0, %xmm0
; AVX512F-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v2i16:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpsllq $48, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsraq $48, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsllq $48, %xmm0, %xmm0
; AVX512BW-NEXT:    vpsraq $48, %xmm0, %xmm0
; AVX512BW-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <2 x i16> %a, %b
  %res = bitcast <2 x i1> %x to i2
  ret i2 %res
}

define i2 @v2i32(<2 x i32> %a, <2 x i32> %b) {
; SSE2-SSSE3-LABEL: v2i32:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    psllq $32, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,3,2,3]
; SSE2-SSSE3-NEXT:    psrad $31, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,3,2,3]
; SSE2-SSSE3-NEXT:    punpckldq {{.*#+}} xmm2 = xmm2[0],xmm0[0],xmm2[1],xmm0[1]
; SSE2-SSSE3-NEXT:    psllq $32, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[1,3,2,3]
; SSE2-SSSE3-NEXT:    psrad $31, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,3,2,3]
; SSE2-SSSE3-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [2147483648,0,2147483648,0]
; SSE2-SSSE3-NEXT:    pxor %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pxor %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    movdqa %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm1[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    movmskpd %xmm1, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v2i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpsllq $32, %xmm1, %xmm2
; AVX1-NEXT:    vpsrad $31, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm2[2,3],xmm1[4,5],xmm2[6,7]
; AVX1-NEXT:    vpsllq $32, %xmm0, %xmm2
; AVX1-NEXT:    vpsrad $31, %xmm2, %xmm2
; AVX1-NEXT:    vpblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vmovmskpd %xmm0, %eax
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v2i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsllq $32, %xmm1, %xmm2
; AVX2-NEXT:    vpsrad $31, %xmm2, %xmm2
; AVX2-NEXT:    vpblendd {{.*#+}} xmm1 = xmm1[0],xmm2[1],xmm1[2],xmm2[3]
; AVX2-NEXT:    vpsllq $32, %xmm0, %xmm2
; AVX2-NEXT:    vpsrad $31, %xmm2, %xmm2
; AVX2-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0],xmm2[1],xmm0[2],xmm2[3]
; AVX2-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vmovmskpd %xmm0, %eax
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v2i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpsllq $32, %xmm1, %xmm1
; AVX512F-NEXT:    vpsraq $32, %xmm1, %xmm1
; AVX512F-NEXT:    vpsllq $32, %xmm0, %xmm0
; AVX512F-NEXT:    vpsraq $32, %xmm0, %xmm0
; AVX512F-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v2i32:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpsllq $32, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsraq $32, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsllq $32, %xmm0, %xmm0
; AVX512BW-NEXT:    vpsraq $32, %xmm0, %xmm0
; AVX512BW-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <2 x i32> %a, %b
  %res = bitcast <2 x i1> %x to i2
  ret i2 %res
}

define i2 @v2i64(<2 x i64> %a, <2 x i64> %b) {
; SSE2-SSSE3-LABEL: v2i64:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,0,2147483648,0]
; SSE2-SSSE3-NEXT:    pxor %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pxor %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    movmskpd %xmm1, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v2i64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vmovmskpd %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v2i64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v2i64:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpcmpgtq %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <2 x i64> %a, %b
  %res = bitcast <2 x i1> %x to i2
  ret i2 %res
}

define i2 @v2f64(<2 x double> %a, <2 x double> %b) {
; SSE2-SSSE3-LABEL: v2f64:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    cmpltpd %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    movmskpd %xmm1, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v2f64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vcmpltpd %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    vmovmskpd %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v2f64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vcmpltpd %xmm0, %xmm1, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v2f64:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vcmpltpd %xmm0, %xmm1, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = fcmp ogt <2 x double> %a, %b
  %res = bitcast <2 x i1> %x to i2
  ret i2 %res
}

define i4 @v4i8(<4 x i8> %a, <4 x i8> %b) {
; SSE2-SSSE3-LABEL: v4i8:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pslld $24, %xmm1
; SSE2-SSSE3-NEXT:    psrad $24, %xmm1
; SSE2-SSSE3-NEXT:    pslld $24, %xmm0
; SSE2-SSSE3-NEXT:    psrad $24, %xmm0
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    movmskps %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v4i8:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpslld $24, %xmm1, %xmm1
; AVX12-NEXT:    vpsrad $24, %xmm1, %xmm1
; AVX12-NEXT:    vpslld $24, %xmm0, %xmm0
; AVX12-NEXT:    vpsrad $24, %xmm0, %xmm0
; AVX12-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vmovmskps %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v4i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpslld $24, %xmm1, %xmm1
; AVX512F-NEXT:    vpsrad $24, %xmm1, %xmm1
; AVX512F-NEXT:    vpslld $24, %xmm0, %xmm0
; AVX512F-NEXT:    vpsrad $24, %xmm0, %xmm0
; AVX512F-NEXT:    vpcmpgtd %xmm1, %xmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v4i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpslld $24, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsrad $24, %xmm1, %xmm1
; AVX512BW-NEXT:    vpslld $24, %xmm0, %xmm0
; AVX512BW-NEXT:    vpsrad $24, %xmm0, %xmm0
; AVX512BW-NEXT:    vpcmpgtd %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <4 x i8> %a, %b
  %res = bitcast <4 x i1> %x to i4
  ret i4 %res
}

define i4 @v4i16(<4 x i16> %a, <4 x i16> %b) {
; SSE2-SSSE3-LABEL: v4i16:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pslld $16, %xmm1
; SSE2-SSSE3-NEXT:    psrad $16, %xmm1
; SSE2-SSSE3-NEXT:    pslld $16, %xmm0
; SSE2-SSSE3-NEXT:    psrad $16, %xmm0
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    movmskps %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v4i16:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpslld $16, %xmm1, %xmm1
; AVX12-NEXT:    vpsrad $16, %xmm1, %xmm1
; AVX12-NEXT:    vpslld $16, %xmm0, %xmm0
; AVX12-NEXT:    vpsrad $16, %xmm0, %xmm0
; AVX12-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vmovmskps %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v4i16:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpslld $16, %xmm1, %xmm1
; AVX512F-NEXT:    vpsrad $16, %xmm1, %xmm1
; AVX512F-NEXT:    vpslld $16, %xmm0, %xmm0
; AVX512F-NEXT:    vpsrad $16, %xmm0, %xmm0
; AVX512F-NEXT:    vpcmpgtd %xmm1, %xmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v4i16:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpslld $16, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsrad $16, %xmm1, %xmm1
; AVX512BW-NEXT:    vpslld $16, %xmm0, %xmm0
; AVX512BW-NEXT:    vpsrad $16, %xmm0, %xmm0
; AVX512BW-NEXT:    vpcmpgtd %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <4 x i16> %a, %b
  %res = bitcast <4 x i1> %x to i4
  ret i4 %res
}

define i8 @v8i8(<8 x i8> %a, <8 x i8> %b) {
; SSE2-SSSE3-LABEL: v8i8:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    psllw $8, %xmm1
; SSE2-SSSE3-NEXT:    psraw $8, %xmm1
; SSE2-SSSE3-NEXT:    psllw $8, %xmm0
; SSE2-SSSE3-NEXT:    psraw $8, %xmm0
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v8i8:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpsllw $8, %xmm1, %xmm1
; AVX12-NEXT:    vpsraw $8, %xmm1, %xmm1
; AVX12-NEXT:    vpsllw $8, %xmm0, %xmm0
; AVX12-NEXT:    vpsraw $8, %xmm0, %xmm0
; AVX12-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX12-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX12-NEXT:    vpmovmskb %xmm0, %eax
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v8i8:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vpsllw $8, %xmm1, %xmm1
; AVX512F-NEXT:    vpsraw $8, %xmm1, %xmm1
; AVX512F-NEXT:    vpsllw $8, %xmm0, %xmm0
; AVX512F-NEXT:    vpsraw $8, %xmm0, %xmm0
; AVX512F-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX512F-NEXT:    vpmovsxwd %xmm0, %ymm0
; AVX512F-NEXT:    vptestmd %ymm0, %ymm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: def $al killed $al killed $eax
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v8i8:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vpsllw $8, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsraw $8, %xmm1, %xmm1
; AVX512BW-NEXT:    vpsllw $8, %xmm0, %xmm0
; AVX512BW-NEXT:    vpsraw $8, %xmm0, %xmm0
; AVX512BW-NEXT:    vpcmpgtw %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: def $al killed $al killed $eax
; AVX512BW-NEXT:    retq
  %x = icmp sgt <8 x i8> %a, %b
  %res = bitcast <8 x i1> %x to i8
  ret i8 %res
}

define i64 @v16i8_widened_with_zeroes(<16 x i8> %a, <16 x i8> %b) {
; SSE2-SSSE3-LABEL: v16i8_widened_with_zeroes:
; SSE2-SSSE3:       # %bb.0: # %entry
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v16i8_widened_with_zeroes:
; AVX1:       # %bb.0: # %entry
; AVX1-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v16i8_widened_with_zeroes:
; AVX2:       # %bb.0: # %entry
; AVX2-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %ymm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v16i8_widened_with_zeroes:
; AVX512F:       # %bb.0: # %entry
; AVX512F-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX512F-NEXT:    vpmovsxbd %xmm0, %zmm0
; AVX512F-NEXT:    vptestmd %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    movzwl %ax, %eax
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v16i8_widened_with_zeroes:
; AVX512BW:       # %bb.0: # %entry
; AVX512BW-NEXT:    vpcmpeqb %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kmovq %k0, %rax
; AVX512BW-NEXT:    retq
entry:
  %c = icmp eq <16 x i8> %a, %b
  %d = shufflevector <16 x i1> %c, <16 x i1> zeroinitializer, <64 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %e = bitcast <64 x i1> %d to i64
  ret i64 %e
}

define i64 @v16i8_widened_with_ones(<16 x i8> %a, <16 x i8> %b) {
; SSE2-SSSE3-LABEL: v16i8_widened_with_ones:
; SSE2-SSSE3:       # %bb.0: # %entry
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-SSSE3-NEXT:    orl $-65536, %ecx # imm = 0xFFFF0000
; SSE2-SSSE3-NEXT:    movabsq $-4294967296, %rax # imm = 0xFFFFFFFF00000000
; SSE2-SSSE3-NEXT:    orq %rcx, %rax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v16i8_widened_with_ones:
; AVX1:       # %bb.0: # %entry
; AVX1-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsllw $7, %xmm0, %xmm0
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpgtb %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %ecx
; AVX1-NEXT:    orl $-65536, %ecx # imm = 0xFFFF0000
; AVX1-NEXT:    movabsq $-4294967296, %rax # imm = 0xFFFFFFFF00000000
; AVX1-NEXT:    orq %rcx, %rax
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v16i8_widened_with_ones:
; AVX2:       # %bb.0: # %entry
; AVX2-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vinserti128 $1, {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpsllw $7, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpmovmskb %ymm0, %ecx
; AVX2-NEXT:    movabsq $-4294967296, %rax # imm = 0xFFFFFFFF00000000
; AVX2-NEXT:    orq %rcx, %rax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v16i8_widened_with_ones:
; AVX512F:       # %bb.0: # %entry
; AVX512F-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX512F-NEXT:    vpmovsxbd %xmm0, %zmm0
; AVX512F-NEXT:    vptestmd %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %ecx
; AVX512F-NEXT:    orl $-65536, %ecx # imm = 0xFFFF0000
; AVX512F-NEXT:    movabsq $-4294967296, %rax # imm = 0xFFFFFFFF00000000
; AVX512F-NEXT:    orq %rcx, %rax
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v16i8_widened_with_ones:
; AVX512BW:       # %bb.0: # %entry
; AVX512BW-NEXT:    vpcmpeqb %xmm1, %xmm0, %k0
; AVX512BW-NEXT:    kxnorw %k0, %k0, %k1
; AVX512BW-NEXT:    kunpckwd %k0, %k1, %k0
; AVX512BW-NEXT:    kxnord %k0, %k0, %k1
; AVX512BW-NEXT:    kunpckdq %k0, %k1, %k0
; AVX512BW-NEXT:    kmovq %k0, %rax
; AVX512BW-NEXT:    retq
entry:
  %c = icmp eq <16 x i8> %a, %b
  %d = shufflevector <16 x i1> %c, <16 x i1> <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>, <64 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %e = bitcast <64 x i1> %d to i64
  ret i64 %e
}
