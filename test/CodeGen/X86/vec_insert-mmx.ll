; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-darwin -mattr=+mmx,+sse2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-darwin -mattr=+mmx,+sse4.1 | FileCheck %s --check-prefix=X64

; This is not an MMX operation; promoted to XMM.
define x86_mmx @t0(i32 %A) nounwind {
; X32-LABEL: t0:
; X32:       ## BB#0:
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,0,1,1]
; X32-NEXT:    movq %xmm0, (%esp)
; X32-NEXT:    movq (%esp), %mm0
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: t0:
; X64:       ## BB#0:
; X64-NEXT:    ## kill: %EDI<def> %EDI<kill> %RDI<def>
; X64-NEXT:    movd %rdi, %xmm0
; X64-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7]
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X64-NEXT:    retq
  %tmp3 = insertelement <2 x i32> < i32 0, i32 undef >, i32 %A, i32 1
  %tmp4 = bitcast <2 x i32> %tmp3 to x86_mmx
  ret x86_mmx %tmp4
}

define <8 x i8> @t1(i8 zeroext %x) nounwind {
; X32-LABEL: t1:
; X32:       ## BB#0:
; X32-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32-NEXT:    retl
;
; X64-LABEL: t1:
; X64:       ## BB#0:
; X64-NEXT:    movd %edi, %xmm0
; X64-NEXT:    retq
  %r = insertelement <8 x i8> undef, i8 %x, i32 0
  ret <8 x i8> %r
}

; PR2574
define <2 x float> @t2(<2 x float> %a0) {
; X32-LABEL: t2:
; X32:       ## BB#0:
; X32-NEXT:    xorps %xmm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: t2:
; X64:       ## BB#0:
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    retq
  %v1 = insertelement <2 x float> %a0, float 0.000000e+00, i32 0
  %v2 = insertelement <2 x float> %v1, float 0.000000e+00, i32 1
  ret <2 x float> %v2
}

@g0 = external global i16
@g1 = external global <4 x i16>

; PR2562
define void @t3() {
; X32-LABEL: t3:
; X32:       ## BB#0:
; X32-NEXT:    movl L_g0$non_lazy_ptr, %eax
; X32-NEXT:    movl L_g1$non_lazy_ptr, %ecx
; X32-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X32-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; X32-NEXT:    movzwl (%eax), %eax
; X32-NEXT:    movd %eax, %xmm1
; X32-NEXT:    movss {{.*#+}} xmm0 = xmm1[0],xmm0[1,2,3]
; X32-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; X32-NEXT:    pshufhw {{.*#+}} xmm0 = xmm0[0,1,2,3,4,6,6,7]
; X32-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X32-NEXT:    movq %xmm0, (%ecx)
; X32-NEXT:    retl
;
; X64-LABEL: t3:
; X64:       ## BB#0:
; X64-NEXT:    movq _g0@{{.*}}(%rip), %rax
; X64-NEXT:    movq _g1@{{.*}}(%rip), %rcx
; X64-NEXT:    pmovzxwd {{.*#+}} xmm0 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero
; X64-NEXT:    movzwl (%rax), %eax
; X64-NEXT:    pinsrd $0, %eax, %xmm0
; X64-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; X64-NEXT:    movq %xmm0, (%rcx)
; X64-NEXT:    retq
  load i16, i16* @g0
  load <4 x i16>, <4 x i16>* @g1
  insertelement <4 x i16> %2, i16 %1, i32 0
  store <4 x i16> %3, <4 x i16>* @g1
  ret void
}
