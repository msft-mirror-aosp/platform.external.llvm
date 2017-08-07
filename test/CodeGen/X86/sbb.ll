; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

; Vary the operand sizes for extra coverage, but the transform should be identical in all cases.

; (X == 0) ? 0 : -1 --> (X == 0) - 1

define i8 @i8_select_0_or_neg1(i8 %x) {
; CHECK-LABEL: i8_select_0_or_neg1:
; CHECK:       # BB#0:
; CHECK-NEXT:    negb %dil
; CHECK-NEXT:    sbbb %al, %al
; CHECK-NEXT:    retq
  %cmp = icmp eq i8 %x, 0
  %sel = select i1 %cmp, i8 0, i8 -1
  ret i8 %sel
}

; (X == 0) ? 0 : -1 --> (X == 0) - 1

define i16 @i16_select_0_or_neg1_as_math(i16 %x) {
; CHECK-LABEL: i16_select_0_or_neg1_as_math:
; CHECK:       # BB#0:
; CHECK-NEXT:    negw %di
; CHECK-NEXT:    sbbw %ax, %ax
; CHECK-NEXT:    retq
  %cmp = icmp eq i16 %x, 0
  %ext = zext i1 %cmp to i16
  %add = add i16 %ext, -1
  ret i16 %add
}

; (X != 0) ? -1 : 0 --> 0 - (X != 0)

define i32 @i32_select_0_or_neg1_commuted(i32 %x) {
; CHECK-LABEL: i32_select_0_or_neg1_commuted:
; CHECK:       # BB#0:
; CHECK-NEXT:    negl %edi
; CHECK-NEXT:    sbbl %eax, %eax
; CHECK-NEXT:    retq
  %cmp = icmp ne i32 %x, 0
  %sel = select i1 %cmp, i32 -1, i32 0
  ret i32 %sel
}

; (X != 0) ? -1 : 0 --> 0 - (X != 0)

define i64 @i64_select_0_or_neg1_commuted_as_math(i64 %x) {
; CHECK-LABEL: i64_select_0_or_neg1_commuted_as_math:
; CHECK:       # BB#0:
; CHECK-NEXT:    negq %rdi
; CHECK-NEXT:    sbbq %rax, %rax
; CHECK-NEXT:    retq
  %cmp = icmp ne i64 %x, 0
  %ext = zext i1 %cmp to i64
  %sub = sub i64 0, %ext
  ret i64 %sub
}

; (X == 0) ? -1 : 0 --> 0 - (X == 0)

define i64 @i64_select_neg1_or_0(i64 %x) {
; CHECK-LABEL: i64_select_neg1_or_0:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpq $1, %rdi
; CHECK-NEXT:    sbbq %rax, %rax
; CHECK-NEXT:    retq
  %cmp = icmp eq i64 %x, 0
  %sel = select i1 %cmp, i64 -1, i64 0
  ret i64 %sel
}

; (X == 0) ? -1 : 0 --> 0 - (X == 0)

define i32 @i32_select_neg1_or_0_as_math(i32 %x) {
; CHECK-LABEL: i32_select_neg1_or_0_as_math:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl $1, %edi
; CHECK-NEXT:    sbbl %eax, %eax
; CHECK-NEXT:    retq
  %cmp = icmp eq i32 %x, 0
  %ext = zext i1 %cmp to i32
  %sub = sub i32 0, %ext
  ret i32 %sub
}

; (X != 0) ? 0 : -1 --> (X != 0) - 1

define i16 @i16_select_neg1_or_0_commuted(i16 %x) {
; CHECK-LABEL: i16_select_neg1_or_0_commuted:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpw $1, %di
; CHECK-NEXT:    sbbw %ax, %ax
; CHECK-NEXT:    retq
  %cmp = icmp ne i16 %x, 0
  %sel = select i1 %cmp, i16 0, i16 -1
  ret i16 %sel
}

; (X != 0) ? 0 : -1 --> (X != 0) - 1

define i8 @i8_select_neg1_or_0_commuted_as_math(i8 %x) {
; CHECK-LABEL: i8_select_neg1_or_0_commuted_as_math:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpb $1, %dil
; CHECK-NEXT:    sbbb %al, %al
; CHECK-NEXT:    retq
  %cmp = icmp ne i8 %x, 0
  %ext = zext i1 %cmp to i8
  %add = add i8 %ext, -1
  ret i8 %add
}

; (X <u Y) ? -1 : 0  --> cmp, sbb

define i32 @ult_select_neg1_or_0(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: ult_select_neg1_or_0:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl %esi, %edi
; CHECK-NEXT:    sbbl %eax, %eax
; CHECK-NEXT:    retq
  %cmp = icmp ult i32 %x, %y
  %ext = sext i1 %cmp to i32
  ret i32 %ext
}

; Swap the predicate and compare operands:
; (Y >u X) ? -1 : 0  --> cmp, sbb

define i32 @ugt_select_neg1_or_0(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: ugt_select_neg1_or_0:
; CHECK:       # BB#0:
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    cmpl %edi, %esi
; CHECK-NEXT:    movl $-1, %eax
; CHECK-NEXT:    cmovbel %ecx, %eax
; CHECK-NEXT:    retq
  %cmp = icmp ugt i32 %y, %x
  %ext = sext i1 %cmp to i32
  ret i32 %ext
}

; Invert the predicate and effectively swap the select operands:
; (X >=u Y) ? 0 : -1 --> (X <u Y) ? -1 : 0 --> cmp, sbb

define i32 @uge_select_0_or_neg1(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: uge_select_0_or_neg1:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl %esi, %edi
; CHECK-NEXT:    sbbl %eax, %eax
; CHECK-NEXT:    retq
  %cmp = icmp uge i32 %x, %y
  %ext = zext i1 %cmp to i32
  %add = add i32 %ext, -1
  ret i32 %add
}

; Swap the predicate and compare operands:
; (Y <=u X) ? 0 : -1 --> (X <u Y) ? -1 : 0 --> cmp, sbb

define i32 @ule_select_0_or_neg1(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: ule_select_0_or_neg1:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl %esi, %edi
; CHECK-NEXT:    sbbl %eax, %eax
; CHECK-NEXT:    retq
  %cmp = icmp ule i32 %y, %x
  %ext = zext i1 %cmp to i32
  %add = add i32 %ext, -1
  ret i32 %add
}

; Verify that subtract with constant is the same thing.
; (X >=u Y) ? 0 : -1 --> (X <u Y) ? -1 : 0 --> cmp, sbb

define i32 @uge_select_0_or_neg1_sub(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: uge_select_0_or_neg1_sub:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpl %esi, %edi
; CHECK-NEXT:    sbbl %eax, %eax
; CHECK-NEXT:    retq
  %cmp = icmp uge i32 %x, %y
  %ext = zext i1 %cmp to i32
  %sub = sub i32 %ext, 1
  ret i32 %sub
}

; Check more sub-from-zero patterns.
; (X >u Y) ? -1 : 0  --> cmp, sbb

define i64 @ugt_select_neg1_or_0_sub(i64 %x, i64 %y) nounwind {
; CHECK-LABEL: ugt_select_neg1_or_0_sub:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpq %rdi, %rsi
; CHECK-NEXT:    sbbq %rax, %rax
; CHECK-NEXT:    retq
  %cmp = icmp ugt i64 %x, %y
  %zext = zext i1 %cmp to i64
  %sub = sub i64 0, %zext
  ret i64 %sub
}

; Swap the predicate and compare operands:
; (Y <u X) ? -1 : 0  --> cmp, sbb

define i16 @ult_select_neg1_or_0_sub(i16 %x, i16 %y) nounwind {
; CHECK-LABEL: ult_select_neg1_or_0_sub:
; CHECK:       # BB#0:
; CHECK-NEXT:    cmpw %di, %si
; CHECK-NEXT:    sbbw %ax, %ax
; CHECK-NEXT:    retq
  %cmp = icmp ult i16 %y, %x
  %zext = zext i1 %cmp to i16
  %sub = sub i16 0, %zext
  ret i16 %sub
}



; Make sure we're creating nodes with the right value types. This would crash.
; https://bugs.llvm.org/show_bug.cgi?id=33560

define void @PR33560(i8 %x, i64 %y) {
; CHECK-LABEL: PR33560:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    negb %dil
; CHECK-NEXT:    sbbq %rax, %rax
; CHECK-NEXT:    cmpq %rsi, %rax
; CHECK-NEXT:    retq
entry:
  %cmp1 = icmp eq i8 %x, 0
  %ext = zext i1 %cmp1 to i64
  %add = add i64 %ext, -1
  %cmp2 = icmp eq i64 %add, %y
  br i1 %cmp2, label %end, label %else

else:
  %tmp7 = zext i1 %cmp1 to i8
  br label %end

end:
  ret void
}

