; RUN: llc < %s -mcpu=corei7-avx | FileCheck %s 

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128"
target triple = "i686-apple-darwin8"

; Make sure that we are not generating a movaps because the vector is aligned to 1.
;CHECK: @foo
;CHECK: xor
;CHECK-NEXT: vmovups
;CHECK-NEXT: ret
define void @foo() {
  store <16 x i16> zeroinitializer, <16 x i16>* undef, align 1
  ret void
}
