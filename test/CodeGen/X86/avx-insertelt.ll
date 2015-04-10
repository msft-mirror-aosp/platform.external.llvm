; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx  | FileCheck %s --check-prefix=ALL --check-prefix=AVX
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX2

define <8 x float> @insert_f32(<8 x float> %y, float %f, <8 x float> %x) {
; ALL-LABEL: insert_f32:
; ALL:         vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1,2,3,4,5,6,7]
; ALL-NEXT:    retq
  %i0 = insertelement <8 x float> %y, float %f, i32 0
  ret <8 x float> %i0
}

define <4 x double> @insert_f64(<4 x double> %y, double %f, <4 x double> %x) {
; ALL-LABEL: insert_f64:
; ALL:         vblendpd {{.*#+}} ymm0 = ymm1[0],ymm0[1,2,3]
; ALL-NEXT:    retq
  %i0 = insertelement <4 x double> %y, double %f, i32 0
  ret <4 x double> %i0
}

define <32 x i8> @insert_i8(<32 x i8> %y, i8 %f, <32 x i8> %x) {
; AVX-LABEL: insert_i8:
; AVX:       # BB#0:
; AVX-NEXT:    vpinsrb $0, %edi, %xmm0, %xmm1
; AVX-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX-NEXT:    retq
;
; AVX2-LABEL: insert_i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpinsrb $0, %edi, %xmm0, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    retq
  %i0 = insertelement <32 x i8> %y, i8 %f, i32 0
  ret <32 x i8> %i0
}

define <16 x i16> @insert_i16(<16 x i16> %y, i16 %f, <16 x i16> %x) {
; AVX-LABEL: insert_i16:
; AVX:       # BB#0:
; AVX-NEXT:    vpinsrw $0, %edi, %xmm0, %xmm1
; AVX-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX-NEXT:    retq
;
; AVX2-LABEL: insert_i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpinsrw $0, %edi, %xmm0, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    retq
  %i0 = insertelement <16 x i16> %y, i16 %f, i32 0
  ret <16 x i16> %i0
}

define <8 x i32> @insert_i32(<8 x i32> %y, i32 %f, <8 x i32> %x) {
; AVX-LABEL: insert_i32:
; AVX:       # BB#0:
; AVX-NEXT:    vpinsrd $0, %edi, %xmm0, %xmm1
; AVX-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX-NEXT:    retq
;
; AVX2-LABEL: insert_i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0],ymm0[1,2,3,4,5,6,7]
; AVX2-NEXT:    retq
  %i0 = insertelement <8 x i32> %y, i32 %f, i32 0
  ret <8 x i32> %i0
}

define <4 x i64> @insert_i64(<4 x i64> %y, i64 %f, <4 x i64> %x) {
; AVX-LABEL: insert_i64:
; AVX:       # BB#0:
; AVX-NEXT:    vpinsrq $0, %rdi, %xmm0, %xmm1
; AVX-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX-NEXT:    retq
;
; AVX2-LABEL: insert_i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpinsrq $0, %rdi, %xmm0, %xmm1
; AVX2-NEXT:    vpblendd {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX2-NEXT:    retq
  %i0 = insertelement <4 x i64> %y, i64 %f, i32 0
  ret <4 x i64> %i0
}

