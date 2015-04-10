; RUN: llc < %s -march=x86 -mcpu=corei7 | FileCheck %s
; RUN: llc < %s -march=x86 -mcpu=core-avx-i | FileCheck %s --check-prefix=AVX

define <1 x float> @test1(<1 x double>* %p) nounwind {
; CHECK-LABEL: test1:
; CHECK:       # BB#0:
; CHECK-NEXT:    pushl %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movsd (%eax), %xmm0
; CHECK-NEXT:    cvtsd2ss %xmm0, %xmm0
; CHECK-NEXT:    movss %xmm0, (%esp)
; CHECK-NEXT:    flds (%esp)
; CHECK-NEXT:    popl %eax
; CHECK-NEXT:    retl
;
; AVX-LABEL: test1:
; AVX:       # BB#0:
; AVX-NEXT:    pushl %eax
; AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; AVX-NEXT:    vmovsd (%eax), %xmm0
; AVX-NEXT:    vcvtsd2ss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vmovss %xmm0, (%esp)
; AVX-NEXT:    flds (%esp)
; AVX-NEXT:    popl %eax
; AVX-NEXT:    retl
  %x = load <1 x double>, <1 x double>* %p
  %y = fptrunc <1 x double> %x to <1 x float>
  ret <1 x float> %y
}

define <2 x float> @test2(<2 x double>* %p) nounwind {
; CHECK-LABEL: test2:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    cvtpd2ps (%eax), %xmm0
; CHECK-NEXT:    retl
;
; AVX-LABEL: test2:
; AVX:       # BB#0:
; AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; AVX-NEXT:    vcvtpd2psx (%eax), %xmm0
; AVX-NEXT:    retl
  %x = load <2 x double>, <2 x double>* %p
  %y = fptrunc <2 x double> %x to <2 x float>
  ret <2 x float> %y
}

define <4 x float> @test3(<4 x double>* %p) nounwind {
; CHECK-LABEL: test3:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    cvtpd2ps 16(%eax), %xmm1
; CHECK-NEXT:    cvtpd2ps (%eax), %xmm0
; CHECK-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-NEXT:    retl
;
; AVX-LABEL: test3:
; AVX:       # BB#0:
; AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; AVX-NEXT:    vcvtpd2psy (%eax), %xmm0
; AVX-NEXT:    retl
  %x = load <4 x double>, <4 x double>* %p
  %y = fptrunc <4 x double> %x to <4 x float>
  ret <4 x float> %y
}

define <8 x float> @test4(<8 x double>* %p) nounwind {
; CHECK-LABEL: test4:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    cvtpd2ps 16(%eax), %xmm1
; CHECK-NEXT:    cvtpd2ps (%eax), %xmm0
; CHECK-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; CHECK-NEXT:    cvtpd2ps 48(%eax), %xmm2
; CHECK-NEXT:    cvtpd2ps 32(%eax), %xmm1
; CHECK-NEXT:    unpcklpd {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; CHECK-NEXT:    retl
;
; AVX-LABEL: test4:
; AVX:       # BB#0:
; AVX-NEXT:    movl {{[0-9]+}}(%esp), %eax
; AVX-NEXT:    vcvtpd2psy (%eax), %xmm0
; AVX-NEXT:    vcvtpd2psy 32(%eax), %xmm1
; AVX-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX-NEXT:    retl
  %x = load <8 x double>, <8 x double>* %p
  %y = fptrunc <8 x double> %x to <8 x float>
  ret <8 x float> %y
}


