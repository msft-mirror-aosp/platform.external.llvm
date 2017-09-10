; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=skx < %s | FileCheck %s

target triple = "x86_64-unknown-linux-gnu"

; This test checks the order of scatter operations after split.
; The right order is "from LSB to MSB", otherwise the semantic is broken.
; The submitted version of the test demonstrates the bug.

define void @test(i64 %x272, <16 x i32*> %x335, <16 x i32> %x270) {
; CHECK-LABEL: test:
; CHECK:       # BB#0:
; CHECK-NEXT:    vextracti64x4 $1, %zmm2, %ymm3
; CHECK-NEXT:    kxnorw %k0, %k0, %k1
; CHECK-NEXT:    kxnorw %k0, %k0, %k2
; CHECK-NEXT:    vpscatterqd %ymm3, (,%zmm1) {%k2}
; CHECK-NEXT:    vpscatterqd %ymm2, (,%zmm0) {%k1}
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  call void @llvm.masked.scatter.v16i32.v16p0i32(<16 x i32> %x270, <16 x i32*> %x335, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>)
  ret void
}
declare void @llvm.masked.scatter.v16i32.v16p0i32(<16 x i32> , <16 x i32*> , i32, <16 x i1> )
