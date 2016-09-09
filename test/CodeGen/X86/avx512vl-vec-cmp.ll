; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=skx | FileCheck %s

define <4 x i64> @test256_1(<4 x i64> %x, <4 x i64> %y) nounwind {
; CHECK-LABEL: test256_1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqq %ymm1, %ymm0, %k1
; CHECK-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp eq <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %y
  ret <4 x i64> %max
}

define <4 x i64> @test256_2(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x1) nounwind {
; CHECK-LABEL: test256_2:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtq %ymm1, %ymm0, %k1
; CHECK-NEXT:    vpblendmq %ymm2, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp sgt <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x1, <4 x i64> %y
  ret <4 x i64> %max
}

define <8 x i32> @test256_3(<8 x i32> %x, <8 x i32> %y, <8 x i32> %x1) nounwind {
; CHECK-LABEL: test256_3:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled %ymm0, %ymm1, %k1
; CHECK-NEXT:    vpblendmd %ymm2, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp sge <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x1, <8 x i32> %y
  ret <8 x i32> %max
}

define <4 x i64> @test256_4(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x1) nounwind {
; CHECK-LABEL: test256_4:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpnleuq %ymm1, %ymm0, %k1
; CHECK-NEXT:    vpblendmq %ymm2, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp ugt <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x1, <4 x i64> %y
  ret <4 x i64> %max
}

define <8 x i32> @test256_5(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; CHECK-LABEL: test256_5:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqd (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp eq <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_5b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; CHECK-LABEL: test256_5b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqd (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp eq <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_6(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test256_6:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtd (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp sgt <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_6b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test256_6b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtd (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp slt <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_7(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test256_7:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp sle <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_7b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test256_7b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp sge <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_8(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test256_8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleud (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp ule <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_8b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test256_8b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleud (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp uge <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_9(<8 x i32> %x, <8 x i32> %y, <8 x i32> %x1, <8 x i32> %y1) nounwind {
; CHECK-LABEL: test256_9:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqd %ymm1, %ymm0, %k1
; CHECK-NEXT:    vpcmpeqd %ymm3, %ymm2, %k1 {%k1}
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp eq <8 x i32> %x1, %y1
  %mask0 = icmp eq <8 x i32> %x, %y
  %mask = select <8 x i1> %mask0, <8 x i1> %mask1, <8 x i1> zeroinitializer
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %y
  ret <8 x i32> %max
}

define <4 x i64> @test256_10(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x1, <4 x i64> %y1) nounwind {
; CHECK-LABEL: test256_10:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleq %ymm1, %ymm0, %k1
; CHECK-NEXT:    vpcmpleq %ymm2, %ymm3, %k1 {%k1}
; CHECK-NEXT:    vpblendmq %ymm0, %ymm2, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <4 x i64> %x1, %y1
  %mask0 = icmp sle <4 x i64> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <4 x i64> @test256_11(<4 x i64> %x, <4 x i64>* %y.ptr, <4 x i64> %x1, <4 x i64> %y1) nounwind {
; CHECK-LABEL: test256_11:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtq %ymm2, %ymm1, %k1
; CHECK-NEXT:    vpcmpgtq (%rdi), %ymm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sgt <4 x i64> %x1, %y1
  %y = load <4 x i64>, <4 x i64>* %y.ptr, align 4
  %mask0 = icmp sgt <4 x i64> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <8 x i32> @test256_12(<8 x i32> %x, <8 x i32>* %y.ptr, <8 x i32> %x1, <8 x i32> %y1) nounwind {
; CHECK-LABEL: test256_12:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled %ymm1, %ymm2, %k1
; CHECK-NEXT:    vpcmpleud (%rdi), %ymm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <8 x i32> %x1, %y1
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask0 = icmp ule <8 x i32> %x, %y
  %mask = select <8 x i1> %mask0, <8 x i1> %mask1, <8 x i1> zeroinitializer
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <4 x i64> @test256_13(<4 x i64> %x, <4 x i64> %x1, i64* %yb.ptr) nounwind {
; CHECK-LABEL: test256_13:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqq (%rdi){1to4}, %ymm0, %k1
; CHECK-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <4 x i64> undef, i64 %yb, i32 0
  %y = shufflevector <4 x i64> %y.0, <4 x i64> undef, <4 x i32> zeroinitializer
  %mask = icmp eq <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <8 x i32> @test256_14(<8 x i32> %x, i32* %yb.ptr, <8 x i32> %x1) nounwind {
; CHECK-LABEL: test256_14:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled (%rdi){1to8}, %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <8 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <8 x i32> %y.0, <8 x i32> undef, <8 x i32> zeroinitializer
  %mask = icmp sle <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_15(<8 x i32> %x, i32* %yb.ptr, <8 x i32> %x1, <8 x i32> %y1) nounwind {
; CHECK-LABEL: test256_15:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled %ymm1, %ymm2, %k1
; CHECK-NEXT:    vpcmpgtd (%rdi){1to8}, %ymm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <8 x i32> %x1, %y1
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <8 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <8 x i32> %y.0, <8 x i32> undef, <8 x i32> zeroinitializer
  %mask0 = icmp sgt <8 x i32> %x, %y
  %mask = select <8 x i1> %mask0, <8 x i1> %mask1, <8 x i1> zeroinitializer
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <4 x i64> @test256_16(<4 x i64> %x, i64* %yb.ptr, <4 x i64> %x1, <4 x i64> %y1) nounwind {
; CHECK-LABEL: test256_16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleq %ymm1, %ymm2, %k1
; CHECK-NEXT:    vpcmpgtq (%rdi){1to4}, %ymm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <4 x i64> %x1, %y1
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <4 x i64> undef, i64 %yb, i32 0
  %y = shufflevector <4 x i64> %y.0, <4 x i64> undef, <4 x i32> zeroinitializer
  %mask0 = icmp sgt <4 x i64> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <8 x i32> @test256_17(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; CHECK-LABEL: test256_17:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpneqd (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp ne <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_18(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; CHECK-LABEL: test256_18:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpneqd (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp ne <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_19(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; CHECK-LABEL: test256_19:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpnltud (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp uge <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_20(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; CHECK-LABEL: test256_20:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleud (%rdi), %ymm0, %k1
; CHECK-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp uge <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <2 x i64> @test128_1(<2 x i64> %x, <2 x i64> %y) nounwind {
; CHECK-LABEL: test128_1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqq %xmm1, %xmm0, %k1
; CHECK-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp eq <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %y
  ret <2 x i64> %max
}

define <2 x i64> @test128_2(<2 x i64> %x, <2 x i64> %y, <2 x i64> %x1) nounwind {
; CHECK-LABEL: test128_2:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtq %xmm1, %xmm0, %k1
; CHECK-NEXT:    vpblendmq %xmm2, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp sgt <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x1, <2 x i64> %y
  ret <2 x i64> %max
}

define <4 x i32> @test128_3(<4 x i32> %x, <4 x i32> %y, <4 x i32> %x1) nounwind {
; CHECK-LABEL: test128_3:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled %xmm0, %xmm1, %k1
; CHECK-NEXT:    vpblendmd %xmm2, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp sge <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x1, <4 x i32> %y
  ret <4 x i32> %max
}

define <2 x i64> @test128_4(<2 x i64> %x, <2 x i64> %y, <2 x i64> %x1) nounwind {
; CHECK-LABEL: test128_4:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpnleuq %xmm1, %xmm0, %k1
; CHECK-NEXT:    vpblendmq %xmm2, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp ugt <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x1, <2 x i64> %y
  ret <2 x i64> %max
}

define <4 x i32> @test128_5(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %yp) nounwind {
; CHECK-LABEL: test128_5:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqd (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %yp, align 4
  %mask = icmp eq <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_5b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %yp) nounwind {
; CHECK-LABEL: test128_5b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqd (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %yp, align 4
  %mask = icmp eq <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_6(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_6:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtd (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp sgt <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_6b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_6b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtd (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp slt <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_7(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_7:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp sle <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_7b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_7b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp sge <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_8(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleud (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp ule <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_8b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_8b:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleud (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp uge <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_9(<4 x i32> %x, <4 x i32> %y, <4 x i32> %x1, <4 x i32> %y1) nounwind {
; CHECK-LABEL: test128_9:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqd %xmm1, %xmm0, %k1
; CHECK-NEXT:    vpcmpeqd %xmm3, %xmm2, %k1 {%k1}
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp eq <4 x i32> %x1, %y1
  %mask0 = icmp eq <4 x i32> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %y
  ret <4 x i32> %max
}

define <2 x i64> @test128_10(<2 x i64> %x, <2 x i64> %y, <2 x i64> %x1, <2 x i64> %y1) nounwind {
; CHECK-LABEL: test128_10:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleq %xmm1, %xmm0, %k1
; CHECK-NEXT:    vpcmpleq %xmm2, %xmm3, %k1 {%k1}
; CHECK-NEXT:    vpblendmq %xmm0, %xmm2, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <2 x i64> %x1, %y1
  %mask0 = icmp sle <2 x i64> %x, %y
  %mask = select <2 x i1> %mask0, <2 x i1> %mask1, <2 x i1> zeroinitializer
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <2 x i64> @test128_11(<2 x i64> %x, <2 x i64>* %y.ptr, <2 x i64> %x1, <2 x i64> %y1) nounwind {
; CHECK-LABEL: test128_11:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpgtq %xmm2, %xmm1, %k1
; CHECK-NEXT:    vpcmpgtq (%rdi), %xmm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sgt <2 x i64> %x1, %y1
  %y = load <2 x i64>, <2 x i64>* %y.ptr, align 4
  %mask0 = icmp sgt <2 x i64> %x, %y
  %mask = select <2 x i1> %mask0, <2 x i1> %mask1, <2 x i1> zeroinitializer
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <4 x i32> @test128_12(<4 x i32> %x, <4 x i32>* %y.ptr, <4 x i32> %x1, <4 x i32> %y1) nounwind {
; CHECK-LABEL: test128_12:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled %xmm1, %xmm2, %k1
; CHECK-NEXT:    vpcmpleud (%rdi), %xmm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <4 x i32> %x1, %y1
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask0 = icmp ule <4 x i32> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <2 x i64> @test128_13(<2 x i64> %x, <2 x i64> %x1, i64* %yb.ptr) nounwind {
; CHECK-LABEL: test128_13:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpeqq (%rdi){1to2}, %xmm0, %k1
; CHECK-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <2 x i64> undef, i64 %yb, i32 0
  %y = insertelement <2 x i64> %y.0, i64 %yb, i32 1
  %mask = icmp eq <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <4 x i32> @test128_14(<4 x i32> %x, i32* %yb.ptr, <4 x i32> %x1) nounwind {
; CHECK-LABEL: test128_14:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled (%rdi){1to4}, %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <4 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <4 x i32> %y.0, <4 x i32> undef, <4 x i32> zeroinitializer
  %mask = icmp sle <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_15(<4 x i32> %x, i32* %yb.ptr, <4 x i32> %x1, <4 x i32> %y1) nounwind {
; CHECK-LABEL: test128_15:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpled %xmm1, %xmm2, %k1
; CHECK-NEXT:    vpcmpgtd (%rdi){1to4}, %xmm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <4 x i32> %x1, %y1
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <4 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <4 x i32> %y.0, <4 x i32> undef, <4 x i32> zeroinitializer
  %mask0 = icmp sgt <4 x i32> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <2 x i64> @test128_16(<2 x i64> %x, i64* %yb.ptr, <2 x i64> %x1, <2 x i64> %y1) nounwind {
; CHECK-LABEL: test128_16:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleq %xmm1, %xmm2, %k1
; CHECK-NEXT:    vpcmpgtq (%rdi){1to2}, %xmm0, %k1 {%k1}
; CHECK-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %mask1 = icmp sge <2 x i64> %x1, %y1
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <2 x i64> undef, i64 %yb, i32 0
  %y = insertelement <2 x i64> %y.0, i64 %yb, i32 1
  %mask0 = icmp sgt <2 x i64> %x, %y
  %mask = select <2 x i1> %mask0, <2 x i1> %mask1, <2 x i1> zeroinitializer
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <4 x i32> @test128_17(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_17:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpneqd (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp ne <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_18(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_18:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpneqd (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp ne <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_19(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_19:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpnltud (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp uge <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_20(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; CHECK-LABEL: test128_20:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpcmpleud (%rdi), %xmm0, %k1
; CHECK-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; CHECK-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp uge <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}
