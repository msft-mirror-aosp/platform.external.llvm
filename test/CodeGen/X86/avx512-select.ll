; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl  | FileCheck %s

define <16 x i32> @select00(i32 %a, <16 x i32> %b) nounwind {
; CHECK-LABEL: select00:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm1, %zmm1, %zmm1
; CHECK-NEXT:    cmpl $255, %edi
; CHECK-NEXT:    je LBB0_2
; CHECK-NEXT:  ## BB#1:
; CHECK-NEXT:    vmovaps %zmm0, %zmm1
; CHECK-NEXT:  LBB0_2:
; CHECK-NEXT:    vpxord %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %cmpres = icmp eq i32 %a, 255
  %selres = select i1 %cmpres, <16 x i32> zeroinitializer, <16 x i32> %b
  %res = xor <16 x i32> %b, %selres
  ret <16 x i32> %res
}

define <8 x i64> @select01(i32 %a, <8 x i64> %b) nounwind {
; CHECK-LABEL: select01:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm1, %zmm1, %zmm1
; CHECK-NEXT:    cmpl $255, %edi
; CHECK-NEXT:    je LBB1_2
; CHECK-NEXT:  ## BB#1:
; CHECK-NEXT:    vmovaps %zmm0, %zmm1
; CHECK-NEXT:  LBB1_2:
; CHECK-NEXT:    vpxorq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %cmpres = icmp eq i32 %a, 255
  %selres = select i1 %cmpres, <8 x i64> zeroinitializer, <8 x i64> %b
  %res = xor <8 x i64> %b, %selres
  ret <8 x i64> %res
}

define float @select02(float %a, float %b, float %c, float %eps) {
; CHECK-LABEL: select02:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vcmpless %xmm0, %xmm3, %k1
; CHECK-NEXT:    vmovss %xmm2, %xmm0, %xmm1 {%k1}
; CHECK-NEXT:    vmovaps %zmm1, %zmm0
; CHECK-NEXT:    retq
  %cmp = fcmp oge float %a, %eps
  %cond = select i1 %cmp, float %c, float %b
  ret float %cond
}

define double @select03(double %a, double %b, double %c, double %eps) {
; CHECK-LABEL: select03:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vcmplesd %xmm0, %xmm3, %k1
; CHECK-NEXT:    vmovsd %xmm2, %xmm0, %xmm1 {%k1}
; CHECK-NEXT:    vmovaps %zmm1, %zmm0
; CHECK-NEXT:    retq
  %cmp = fcmp oge double %a, %eps
  %cond = select i1 %cmp, double %c, double %b
  ret double %cond
}

define <16 x double> @select04(<16 x double> %a, <16 x double> %b) {
; CHECK-LABEL: select04:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovaps %zmm3, %zmm1
; CHECK-NEXT:    retq
  %sel = select <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false>, <16 x double> %a, <16 x double> %b
  ret <16 x double> %sel
}

define i8 @select05(i8 %a.0, i8 %m) {
; CHECK-LABEL: select05:
; CHECK:       ## BB#0:
; CHECK-NEXT:    orl %esi, %edi
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %mask = bitcast i8 %m to <8 x i1>
  %a = bitcast i8 %a.0 to <8 x i1>
  %r = select <8 x i1> %mask, <8 x i1> <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>, <8 x i1> %a
  %res = bitcast <8 x i1> %r to i8
  ret i8 %res;
}

define i8 @select05_mem(<8 x i1>* %a.0, <8 x i1>* %m) {
; CHECK-LABEL: select05_mem:
; CHECK:       ## BB#0:
; CHECK-NEXT:    movzbl (%rsi), %eax
; CHECK-NEXT:    kmovw %eax, %k0
; CHECK-NEXT:    movzbl (%rdi), %eax
; CHECK-NEXT:    kmovw %eax, %k1
; CHECK-NEXT:    korw %k1, %k0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %mask = load <8 x i1> , <8 x i1>* %m
  %a = load <8 x i1> , <8 x i1>* %a.0
  %r = select <8 x i1> %mask, <8 x i1> <i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1, i1 -1>, <8 x i1> %a
  %res = bitcast <8 x i1> %r to i8
  ret i8 %res;
}

define i8 @select06(i8 %a.0, i8 %m) {
; CHECK-LABEL: select06:
; CHECK:       ## BB#0:
; CHECK-NEXT:    andl %esi, %edi
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %mask = bitcast i8 %m to <8 x i1>
  %a = bitcast i8 %a.0 to <8 x i1>
  %r = select <8 x i1> %mask, <8 x i1> %a, <8 x i1> zeroinitializer
  %res = bitcast <8 x i1> %r to i8
  ret i8 %res;
}

define i8 @select06_mem(<8 x i1>* %a.0, <8 x i1>* %m) {
; CHECK-LABEL: select06_mem:
; CHECK:       ## BB#0:
; CHECK-NEXT:    movzbl (%rsi), %eax
; CHECK-NEXT:    kmovw %eax, %k0
; CHECK-NEXT:    movzbl (%rdi), %eax
; CHECK-NEXT:    kmovw %eax, %k1
; CHECK-NEXT:    kandw %k1, %k0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %mask = load <8 x i1> , <8 x i1>* %m
  %a = load <8 x i1> , <8 x i1>* %a.0
  %r = select <8 x i1> %mask, <8 x i1> %a, <8 x i1> zeroinitializer
  %res = bitcast <8 x i1> %r to i8
  ret i8 %res;
}
define i8 @select07(i8 %a.0, i8 %b.0, i8 %m) {
; CHECK-LABEL: select07:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k0
; CHECK-NEXT:    kmovw %edi, %k1
; CHECK-NEXT:    kmovw %esi, %k2
; CHECK-NEXT:    kandw %k0, %k1, %k1
; CHECK-NEXT:    knotw %k0, %k0
; CHECK-NEXT:    kandw %k0, %k2, %k0
; CHECK-NEXT:    korw %k0, %k1, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    retq
  %mask = bitcast i8 %m to <8 x i1>
  %a = bitcast i8 %a.0 to <8 x i1>
  %b = bitcast i8 %b.0 to <8 x i1>
  %r = select <8 x i1> %mask, <8 x i1> %a, <8 x i1> %b
  %res = bitcast <8 x i1> %r to i8
  ret i8 %res;
}
