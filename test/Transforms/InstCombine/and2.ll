; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

; PR1738
define i1 @test1(double %X, double %Y) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[TMP1:%.*]] = fcmp ord double %Y, %X
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %tmp9 = fcmp ord double %X, 0.000000e+00
  %tmp13 = fcmp ord double %Y, 0.000000e+00
  %bothcond = and i1 %tmp13, %tmp9
  ret i1 %bothcond
}

define i1 @test2(i1 %X, i1 %Y) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[B:%.*]] = and i1 %X, %Y
; CHECK-NEXT:    ret i1 [[B]]
;
  %a = and i1 %X, %Y
  %b = and i1 %a, %X
  ret i1 %b
}

define i32 @test3(i32 %X, i32 %Y) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[B:%.*]] = and i32 %X, %Y
; CHECK-NEXT:    ret i32 [[B]]
;
  %a = and i32 %X, %Y
  %b = and i32 %Y, %a
  ret i32 %b
}

; Make sure we don't go into an infinite loop with this test
define <4 x i32> @test5(<4 x i32> %A) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[TMP1:%.*]] = xor <4 x i32> %A, <i32 1, i32 2, i32 3, i32 4>
; CHECK-NEXT:    [[TMP2:%.*]] = and <4 x i32> [[TMP1]], <i32 1, i32 2, i32 3, i32 4>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %1 = xor <4 x i32> %A, <i32 1, i32 2, i32 3, i32 4>
  %2 = and <4 x i32> <i32 1, i32 2, i32 3, i32 4>, %1
  ret <4 x i32> %2
}

; Check that we combine "if x!=0 && x!=-1" into "if x+1u>1"
define i32 @test6(i64 %x) nounwind {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[X_OFF:%.*]] = add i64 %x, 1
; CHECK-NEXT:    [[X_CMP:%.*]] = icmp ugt i64 [[X_OFF]], 1
; CHECK-NEXT:    [[LAND_EXT:%.*]] = zext i1 [[X_CMP]] to i32
; CHECK-NEXT:    ret i32 [[LAND_EXT]]
;
  %cmp1 = icmp ne i64 %x, -1
  %not.cmp = icmp ne i64 %x, 0
  %.cmp1 = and i1 %cmp1, %not.cmp
  %land.ext = zext i1 %.cmp1 to i32
  ret i32 %land.ext
}

define i1 @test7(i32 %i, i1 %b) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i32 %i, 0
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[TMP1]], %b
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp1 = icmp slt i32 %i, 1
  %cmp2 = icmp sgt i32 %i, -1
  %and1 = and i1 %cmp1, %b
  %and2 = and i1 %and1, %cmp2
  ret i1 %and2
}

define i1 @test8(i32 %i) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[I_OFF:%.*]] = add i32 %i, -1
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[I_OFF]], 13
; CHECK-NEXT:    ret i1 [[TMP1]]
;
  %cmp1 = icmp ne i32 %i, 0
  %cmp2 = icmp ult i32 %i, 14
  %cond = and i1 %cmp1, %cmp2
  ret i1 %cond
}

; FIXME: Vectors should fold too.
define <2 x i1> @test8vec(<2 x i32> %i) {
; CHECK-LABEL: @test8vec(
; CHECK-NEXT:    [[CMP1:%.*]] = icmp ne <2 x i32> %i, zeroinitializer
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ult <2 x i32> %i, <i32 14, i32 14>
; CHECK-NEXT:    [[COND:%.*]] = and <2 x i1> [[CMP1]], [[CMP2]]
; CHECK-NEXT:    ret <2 x i1> [[COND]]
;
  %cmp1 = icmp ne <2 x i32> %i, zeroinitializer
  %cmp2 = icmp ult <2 x i32> %i, <i32 14, i32 14>
  %cond = and <2 x i1> %cmp1, %cmp2
  ret <2 x i1> %cond
}

; combine -x & 1 into x & 1
define i64 @test9(i64 %x) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[AND:%.*]] = and i64 %x, 1
; CHECK-NEXT:    ret i64 [[AND]]
;
  %sub = sub nsw i64 0, %x
  %and = and i64 %sub, 1
  ret i64 %and
}

define i64 @test10(i64 %x) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[AND:%.*]] = and i64 %x, 1
; CHECK-NEXT:    [[ADD:%.*]] = sub i64 [[AND]], %x
; CHECK-NEXT:    ret i64 [[ADD]]
;
  %sub = sub nsw i64 0, %x
  %and = and i64 %sub, 1
  %add = add i64 %sub, %and
  ret i64 %add
}

; The add in this test is unnecessary because the LSBs of the RHS are 0 and we only consume those bits.
define i32 @test11(i32 %a, i32 %b) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[X:%.*]] = shl i32 [[A:%.*]], 8
; CHECK-NEXT:    [[Y:%.*]] = add i32 [[X]], [[B:%.*]]
; CHECK-NEXT:    [[Z:%.*]] = and i32 [[Y]], 128
; CHECK-NEXT:    [[W:%.*]] = mul i32 [[Z]], [[X]]
; CHECK-NEXT:    ret i32 [[W]]
;
  %x = shl i32 %a, 8
  %y = add i32 %x, %b
  %z = and i32 %y, 128
  %w = mul i32 %z, %x ; to keep the shift from being removed
  ret i32 %w
}

; The add in this test is unnecessary because the LSBs of the RHS are 0 and we only consume those bits.
define i32 @test12(i32 %a, i32 %b) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[X:%.*]] = shl i32 [[A:%.*]], 8
; CHECK-NEXT:    [[Y:%.*]] = add i32 [[X]], [[B:%.*]]
; CHECK-NEXT:    [[Z:%.*]] = and i32 [[Y]], 128
; CHECK-NEXT:    [[W:%.*]] = mul i32 [[Z]], [[X]]
; CHECK-NEXT:    ret i32 [[W]]
;
  %x = shl i32 %a, 8
  %y = add i32 %b, %x
  %z = and i32 %y, 128
  %w = mul i32 %z, %x ; to keep the shift from being removed
  ret i32 %w
}

; The sub in this test is unnecessary because the LSBs of the RHS are 0 and we only consume those bits.
define i32 @test13(i32 %a, i32 %b) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    [[X:%.*]] = shl i32 [[A:%.*]], 8
; CHECK-NEXT:    [[Y:%.*]] = sub i32 [[B:%.*]], [[X]]
; CHECK-NEXT:    [[Z:%.*]] = and i32 [[Y]], 128
; CHECK-NEXT:    [[W:%.*]] = mul i32 [[Z]], [[X]]
; CHECK-NEXT:    ret i32 [[W]]
;
  %x = shl i32 %a, 8
  %y = sub i32 %b, %x
  %z = and i32 %y, 128
  %w = mul i32 %z, %x ; to keep the shift from being removed
  ret i32 %w
}

; The sub in this test cannot be removed because we need to keep the negation of %b
define i32 @test14(i32 %a, i32 %b) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:    [[X:%.*]] = shl i32 [[A:%.*]], 8
; CHECK-NEXT:    [[Y:%.*]] = sub i32 [[X]], [[B:%.*]]
; CHECK-NEXT:    [[Z:%.*]] = and i32 [[Y]], 128
; CHECK-NEXT:    [[W:%.*]] = mul i32 [[Z]], [[X]]
; CHECK-NEXT:    ret i32 [[W]]
;
  %x = shl i32 %a, 8
  %y = sub i32 %x, %b
  %z = and i32 %y, 128
  %w = mul i32 %z, %x ; to keep the shift from being removed
  ret i32 %w
}
