; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown -mattr=+sse2,-sse4.1 | FileCheck %s

define <4 x float> @test1(float %a) nounwind {
; CHECK-LABEL: test1:
; CHECK:       # BB#0:
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    retl
  %tmp = insertelement <4 x float> zeroinitializer, float %a, i32 0
  %tmp5 = insertelement <4 x float> %tmp, float 0.000000e+00, i32 1
  %tmp6 = insertelement <4 x float> %tmp5, float 0.000000e+00, i32 2
  %tmp7 = insertelement <4 x float> %tmp6, float 0.000000e+00, i32 3
  ret <4 x float> %tmp7
}

define <2 x i64> @test(i32 %a) nounwind {
; CHECK-LABEL: test:
; CHECK:       # BB#0:
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    retl
  %tmp = insertelement <4 x i32> zeroinitializer, i32 %a, i32 0
  %tmp6 = insertelement <4 x i32> %tmp, i32 0, i32 1
  %tmp8 = insertelement <4 x i32> %tmp6, i32 0, i32 2
  %tmp10 = insertelement <4 x i32> %tmp8, i32 0, i32 3
  %tmp19 = bitcast <4 x i32> %tmp10 to <2 x i64>
  ret <2 x i64> %tmp19
}
