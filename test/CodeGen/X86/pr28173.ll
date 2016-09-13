; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mattr=+avx512f | FileCheck %s  --check-prefix=CHECK --check-prefix=KNL
; RUN: llc < %s -mattr=+avx512f,+avx512vl,+avx512bw,+avx512dq | FileCheck %s  --check-prefix=CHECK --check-prefix=SKX

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Note that the kmovs should really *not* appear in the output, this is an
; artifact of the current poor lowering. This is tracked by PR28175.

define i64 @foo64(i1 zeroext %i) #0 {
; CHECK-LABEL: foo64:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; CHECK-NEXT:    orq $-2, %rdi
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    retq
  br label %bb

bb:
  %z = zext i1 %i to i64
  %v = or i64 %z, -2
  br label %end

end:
  ret i64 %v
}

define i16 @foo16(i1 zeroext %i) #0 {
; CHECK-LABEL: foo16:
; CHECK:       # BB#0:
; CHECK-NEXT:    orl $65534, %edi # imm = 0xFFFE
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  br label %bb

bb:
  %z = zext i1 %i to i16
  %v = or i16 %z, -2
  br label %end

end:
  ret i16 %v
}

; This code is still not optimal
define i16 @foo16_1(i1 zeroext %i, i32 %j) #0 {
; KNL-LABEL: foo16_1:
; KNL:       # BB#0:
; KNL-NEXT:    kmovw %edi, %k0
; KNL-NEXT:    kmovw %k0, %eax
; KNL-NEXT:    andl $1, %eax
; KNL-NEXT:    orl $2, %eax
; KNL-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; KNL-NEXT:    retq
;
; SKX-LABEL: foo16_1:
; SKX:       # BB#0:
; SKX-NEXT:    kmovd %edi, %k0
; SKX-NEXT:    kmovw %k0, %eax
; SKX-NEXT:    andl $1, %eax
; SKX-NEXT:    orl $2, %eax
; SKX-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SKX-NEXT:    retq
  br label %bb

bb:
  %z = zext i1 %i to i16
  %v = or i16 %z, 2
  br label %end

end:
  ret i16 %v
}

define i32 @foo32(i1 zeroext %i) #0 {
; CHECK-LABEL: foo32:
; CHECK:       # BB#0:
; CHECK-NEXT:    orl $-2, %edi
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  br label %bb

bb:
  %z = zext i1 %i to i32
  %v = or i32 %z, -2
  br label %end

end:
  ret i32 %v
}

define i8 @foo8(i1 zeroext %i) #0 {
; CHECK-LABEL: foo8:
; CHECK:       # BB#0:
; CHECK-NEXT:    orb $-2, %dil
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  br label %bb

bb:
  %z = zext i1 %i to i8
  %v = or i8 %z, -2
  br label %end

end:
  ret i8 %v
}

