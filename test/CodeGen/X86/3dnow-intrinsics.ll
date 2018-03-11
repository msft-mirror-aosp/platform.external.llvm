; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+3dnow | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+3dnow | FileCheck %s --check-prefixes=CHECK,X64

define <8 x i8> @test_pavgusb(x86_mmx %a.coerce, x86_mmx %b.coerce) nounwind readnone {
; X86-LABEL: test_pavgusb:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    pavgusb %mm1, %mm0
; X86-NEXT:    movq %mm0, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: test_pavgusb:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pavgusb %mm1, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; X64-NEXT:    retq
entry:
  %0 = bitcast x86_mmx %a.coerce to <8 x i8>
  %1 = bitcast x86_mmx %b.coerce to <8 x i8>
  %2 = bitcast <8 x i8> %0 to x86_mmx
  %3 = bitcast <8 x i8> %1 to x86_mmx
  %4 = call x86_mmx @llvm.x86.3dnow.pavgusb(x86_mmx %2, x86_mmx %3)
  %5 = bitcast x86_mmx %4 to <8 x i8>
  ret <8 x i8> %5
}

declare x86_mmx @llvm.x86.3dnow.pavgusb(x86_mmx, x86_mmx) nounwind readnone

define <2 x i32> @test_pf2id(<2 x float> %a) nounwind readnone {
; X86-LABEL: test_pf2id:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    pf2id %mm1, %mm0
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    movl (%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pf2id:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm0, %mm0
; X64-NEXT:    pf2id %mm0, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = tail call x86_mmx @llvm.x86.3dnow.pf2id(x86_mmx %0)
  %2 = bitcast x86_mmx %1 to <2 x i32>
  ret <2 x i32> %2
}

declare x86_mmx @llvm.x86.3dnow.pf2id(x86_mmx) nounwind readnone

define <2 x float> @test_pfacc(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfacc:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfacc %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfacc:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfacc %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfacc(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfacc(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfadd(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfadd:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfadd %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfadd:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfadd %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfadd(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfadd(x86_mmx, x86_mmx) nounwind readnone

define <2 x i32> @test_pfcmpeq(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfcmpeq:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfcmpeq %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    movl (%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfcmpeq:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfcmpeq %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfcmpeq(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x i32>
  ret <2 x i32> %3
}

declare x86_mmx @llvm.x86.3dnow.pfcmpeq(x86_mmx, x86_mmx) nounwind readnone

define <2 x i32> @test_pfcmpge(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfcmpge:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfcmpge %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    movl (%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfcmpge:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfcmpge %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfcmpge(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x i32>
  ret <2 x i32> %3
}

declare x86_mmx @llvm.x86.3dnow.pfcmpge(x86_mmx, x86_mmx) nounwind readnone

define <2 x i32> @test_pfcmpgt(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfcmpgt:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfcmpgt %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    movl (%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfcmpgt:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfcmpgt %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfcmpgt(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x i32>
  ret <2 x i32> %3
}

declare x86_mmx @llvm.x86.3dnow.pfcmpgt(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfmax(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfmax:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfmax %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfmax:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfmax %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfmax(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfmax(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfmin(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfmin:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfmin %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfmin:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfmin %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfmin(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfmin(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfmul(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfmul:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfmul %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfmul:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfmul %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfmul(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfmul(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfrcp(<2 x float> %a) nounwind readnone {
; X86-LABEL: test_pfrcp:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    pfrcp %mm1, %mm0
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfrcp:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm0, %mm0
; X64-NEXT:    pfrcp %mm0, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = tail call x86_mmx @llvm.x86.3dnow.pfrcp(x86_mmx %0)
  %2 = bitcast x86_mmx %1 to <2 x float>
  ret <2 x float> %2
}

declare x86_mmx @llvm.x86.3dnow.pfrcp(x86_mmx) nounwind readnone

define <2 x float> @test_pfrcpit1(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfrcpit1:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfrcpit1 %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfrcpit1:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfrcpit1 %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfrcpit1(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfrcpit1(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfrcpit2(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfrcpit2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfrcpit2 %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfrcpit2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfrcpit2 %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfrcpit2(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfrcpit2(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfrsqrt(<2 x float> %a) nounwind readnone {
; X86-LABEL: test_pfrsqrt:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    pfrsqrt %mm1, %mm0
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfrsqrt:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm0, %mm0
; X64-NEXT:    pfrsqrt %mm0, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = tail call x86_mmx @llvm.x86.3dnow.pfrsqrt(x86_mmx %0)
  %2 = bitcast x86_mmx %1 to <2 x float>
  ret <2 x float> %2
}

declare x86_mmx @llvm.x86.3dnow.pfrsqrt(x86_mmx) nounwind readnone

define <2 x float> @test_pfrsqit1(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfrsqit1:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfrsqit1 %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfrsqit1:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfrsqit1 %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfrsqit1(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfrsqit1(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfsub(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfsub:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfsub %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfsub:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfsub %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfsub(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfsub(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfsubr(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfsubr:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfsubr %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfsubr:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfsubr %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnow.pfsubr(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pfsubr(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pi2fd(x86_mmx %a.coerce) nounwind readnone {
; X86-LABEL: test_pi2fd:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    pi2fd %mm0, %mm0
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pi2fd:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pi2fd %mm0, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast x86_mmx %a.coerce to <2 x i32>
  %1 = bitcast <2 x i32> %0 to x86_mmx
  %2 = call x86_mmx @llvm.x86.3dnow.pi2fd(x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnow.pi2fd(x86_mmx) nounwind readnone

define <4 x i16> @test_pmulhrw(x86_mmx %a.coerce, x86_mmx %b.coerce) nounwind readnone {
; X86-LABEL: test_pmulhrw:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    pmulhrw %mm1, %mm0
; X86-NEXT:    movq %mm0, (%eax)
; X86-NEXT:    retl $4
;
; X64-LABEL: test_pmulhrw:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pmulhrw %mm1, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    punpcklwd {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3]
; X64-NEXT:    retq
entry:
  %0 = bitcast x86_mmx %a.coerce to <4 x i16>
  %1 = bitcast x86_mmx %b.coerce to <4 x i16>
  %2 = bitcast <4 x i16> %0 to x86_mmx
  %3 = bitcast <4 x i16> %1 to x86_mmx
  %4 = call x86_mmx @llvm.x86.3dnow.pmulhrw(x86_mmx %2, x86_mmx %3)
  %5 = bitcast x86_mmx %4 to <4 x i16>
  ret <4 x i16> %5
}

declare x86_mmx @llvm.x86.3dnow.pmulhrw(x86_mmx, x86_mmx) nounwind readnone

define <2 x i32> @test_pf2iw(<2 x float> %a) nounwind readnone {
; X86-LABEL: test_pf2iw:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    pf2iw %mm1, %mm0
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    movl (%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pf2iw:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm0, %mm0
; X64-NEXT:    pf2iw %mm0, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = tail call x86_mmx @llvm.x86.3dnowa.pf2iw(x86_mmx %0)
  %2 = bitcast x86_mmx %1 to <2 x i32>
  ret <2 x i32> %2
}

declare x86_mmx @llvm.x86.3dnowa.pf2iw(x86_mmx) nounwind readnone

define <2 x float> @test_pfnacc(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfnacc:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfnacc %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfnacc:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfnacc %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnowa.pfnacc(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnowa.pfnacc(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pfpnacc(<2 x float> %a, <2 x float> %b) nounwind readnone {
; X86-LABEL: test_pfpnacc:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 20(%ebp), %mm0
; X86-NEXT:    movd 16(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm2
; X86-NEXT:    punpckldq %mm0, %mm2 # mm2 = mm2[0],mm0[0]
; X86-NEXT:    pfpnacc %mm1, %mm2
; X86-NEXT:    movq %mm2, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pfpnacc:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm1, %mm0
; X64-NEXT:    movdq2q %xmm0, %mm1
; X64-NEXT:    pfpnacc %mm0, %mm1
; X64-NEXT:    movq %mm1, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = bitcast <2 x float> %b to x86_mmx
  %2 = tail call x86_mmx @llvm.x86.3dnowa.pfpnacc(x86_mmx %0, x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnowa.pfpnacc(x86_mmx, x86_mmx) nounwind readnone

define <2 x float> @test_pi2fw(x86_mmx %a.coerce) nounwind readnone {
; X86-LABEL: test_pi2fw:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    pi2fw %mm0, %mm0
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pi2fw:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pi2fw %mm0, %mm0
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast x86_mmx %a.coerce to <2 x i32>
  %1 = bitcast <2 x i32> %0 to x86_mmx
  %2 = call x86_mmx @llvm.x86.3dnowa.pi2fw(x86_mmx %1)
  %3 = bitcast x86_mmx %2 to <2 x float>
  ret <2 x float> %3
}

declare x86_mmx @llvm.x86.3dnowa.pi2fw(x86_mmx) nounwind readnone

define <2 x float> @test_pswapdsf(<2 x float> %a) nounwind readnone {
; X86-LABEL: test_pswapdsf:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    pswapd %mm1, %mm0 # mm0 = mm1[1,0]
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    flds {{[0-9]+}}(%esp)
; X86-NEXT:    flds (%esp)
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pswapdsf:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movdq2q %xmm0, %mm0
; X64-NEXT:    pswapd %mm0, %mm0 # mm0 = mm0[1,0]
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movaps -{{[0-9]+}}(%rsp), %xmm0
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x float> %a to x86_mmx
  %1 = tail call x86_mmx @llvm.x86.3dnowa.pswapd(x86_mmx %0)
  %2 = bitcast x86_mmx %1 to <2 x float>
  ret <2 x float> %2
}

define <2 x i32> @test_pswapdsi(<2 x i32> %a) nounwind readnone {
; X86-LABEL: test_pswapdsi:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $8, %esp
; X86-NEXT:    movd 12(%ebp), %mm0
; X86-NEXT:    movd 8(%ebp), %mm1
; X86-NEXT:    punpckldq %mm0, %mm1 # mm1 = mm1[0],mm0[0]
; X86-NEXT:    pswapd %mm1, %mm0 # mm0 = mm1[1,0]
; X86-NEXT:    movq %mm0, (%esp)
; X86-NEXT:    movl (%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl %ebp, %esp
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
;
; X64-LABEL: test_pswapdsi:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X64-NEXT:    movq %xmm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    pswapd -{{[0-9]+}}(%rsp), %mm0 # mm0 = mem[1,0]
; X64-NEXT:    movq %mm0, -{{[0-9]+}}(%rsp)
; X64-NEXT:    movq {{.*#+}} xmm0 = mem[0],zero
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,1,1,3]
; X64-NEXT:    retq
entry:
  %0 = bitcast <2 x i32> %a to x86_mmx
  %1 = tail call x86_mmx @llvm.x86.3dnowa.pswapd(x86_mmx %0)
  %2 = bitcast x86_mmx %1 to <2 x i32>
  ret <2 x i32> %2
}

declare x86_mmx @llvm.x86.3dnowa.pswapd(x86_mmx) nounwind readnone
