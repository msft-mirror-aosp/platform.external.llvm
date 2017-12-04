; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mcpu=skx | FileCheck %s

@ac = external local_unnamed_addr global [20 x i8], align 16
@ai3 = external local_unnamed_addr global [20 x i32], align 16

; Function Attrs: norecurse nounwind uwtable
define void @main() {
; CHECK-LABEL: main:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movzbl ac+{{.*}}(%rip), %eax
; CHECK-NEXT:    vmovd %eax, %xmm0
; CHECK-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; CHECK-NEXT:    vpsubq %ymm0, %ymm1, %ymm0
; CHECK-NEXT:    vpmovqd %ymm0, ai3+{{.*}}(%rip)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
entry:
  %wide.masked.load66 = call <4 x i8> @llvm.masked.load.v4i8.p0v4i8(<4 x i8>* bitcast (i8* getelementptr inbounds ([20 x i8], [20 x i8]* @ac, i64 0, i64 4) to <4 x i8>*), i32 1, <4 x i1> <i1 true, i1 false, i1 false, i1 false>, <4 x i8> undef)
  %0 = zext <4 x i8> %wide.masked.load66 to <4 x i64>
  %1 = sub <4 x i64> zeroinitializer, %0
  %predphi = shufflevector <4 x i64> %1, <4 x i64> undef, <4 x i32> <i32 0, i32 5, i32 6, i32 7>
  %2 = trunc <4 x i64> %predphi to <4 x i32>
  %3 = add <4 x i32> zeroinitializer, %2
  store <4 x i32> %3, <4 x i32>* bitcast (i32* getelementptr inbounds ([20 x i32], [20 x i32]* @ai3, i64 0, i64 4) to <4 x i32>*), align 16
  ret void
}

; Function Attrs: argmemonly nounwind readonly
declare <4 x i8> @llvm.masked.load.v4i8.p0v4i8(<4 x i8>*, i32, <4 x i1>, <4 x i8>)
