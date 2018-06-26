; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

define i47 @shl_by_0(i47 %A) {
; CHECK-LABEL: @shl_by_0(
; CHECK-NEXT:    ret i47 [[A:%.*]]
;
  %B = shl i47 %A, 0
  ret i47 %B
}

define i41 @shl_0(i41 %X) {
; CHECK-LABEL: @shl_0(
; CHECK-NEXT:    ret i41 0
;
  %B = shl i41 0, %X
  ret i41 %B
}

define <2 x i41> @shl_0_vec_undef_elt(<2 x i41> %X) {
; CHECK-LABEL: @shl_0_vec_undef_elt(
; CHECK-NEXT:    ret <2 x i41> zeroinitializer
;
  %B = shl <2 x i41> <i41 0, i41 undef>, %X
  ret <2 x i41> %B
}

define i41 @ashr_by_0(i41 %A) {
; CHECK-LABEL: @ashr_by_0(
; CHECK-NEXT:    ret i41 [[A:%.*]]
;
  %B = ashr i41 %A, 0
  ret i41 %B
}

define i39 @ashr_0(i39 %X) {
; CHECK-LABEL: @ashr_0(
; CHECK-NEXT:    ret i39 0
;
  %B = ashr i39 0, %X
  ret i39 %B
}

define <2 x i141> @ashr_0_vec_undef_elt(<2 x i141> %X) {
; CHECK-LABEL: @ashr_0_vec_undef_elt(
; CHECK-NEXT:    ret <2 x i141> zeroinitializer
;
  %B = shl <2 x i141> <i141 undef, i141 0>, %X
  ret <2 x i141> %B
}

define i55 @lshr_by_bitwidth(i55 %A) {
; CHECK-LABEL: @lshr_by_bitwidth(
; CHECK-NEXT:    ret i55 undef
;
  %B = lshr i55 %A, 55
  ret i55 %B
}

define i32 @shl_by_bitwidth(i32 %A) {
; CHECK-LABEL: @shl_by_bitwidth(
; CHECK-NEXT:    ret i32 undef
;
  %B = shl i32 %A, 32
  ret i32 %B
}

define <4 x i32> @lshr_by_bitwidth_splat(<4 x i32> %A) {
; CHECK-LABEL: @lshr_by_bitwidth_splat(
; CHECK-NEXT:    ret <4 x i32> undef
;
  %B = lshr <4 x i32> %A, <i32 32, i32 32, i32 32, i32 32>     ;; shift all bits out
  ret <4 x i32> %B
}

define <4 x i32> @lshr_by_0_splat(<4 x i32> %A) {
; CHECK-LABEL: @lshr_by_0_splat(
; CHECK-NEXT:    ret <4 x i32> [[A:%.*]]
;
  %B = lshr <4 x i32> %A, zeroinitializer
  ret <4 x i32> %B
}

define <4 x i32> @shl_by_bitwidth_splat(<4 x i32> %A) {
; CHECK-LABEL: @shl_by_bitwidth_splat(
; CHECK-NEXT:    ret <4 x i32> undef
;
  %B = shl <4 x i32> %A, <i32 32, i32 32, i32 32, i32 32>     ;; shift all bits out
  ret <4 x i32> %B
}

define i32 @ashr_undef() {
; CHECK-LABEL: @ashr_undef(
; CHECK-NEXT:    ret i32 0
;
  %B = ashr i32 undef, 2  ;; top two bits must be equal, so not undef
  ret i32 %B
}

define i32 @ashr_undef_variable_shift_amount(i32 %A) {
; CHECK-LABEL: @ashr_undef_variable_shift_amount(
; CHECK-NEXT:    ret i32 0
;
  %B = ashr i32 undef, %A  ;; top %A bits must be equal, so not undef
  ret i32 %B
}

define i32 @ashr_all_ones(i32 %A) {
; CHECK-LABEL: @ashr_all_ones(
; CHECK-NEXT:    ret i32 -1
;
  %B = ashr i32 -1, %A
  ret i32 %B
}

define <3 x i8> @ashr_all_ones_vec_with_undef_elts(<3 x i8> %x, <3 x i8> %y) {
; CHECK-LABEL: @ashr_all_ones_vec_with_undef_elts(
; CHECK-NEXT:    ret <3 x i8> <i8 -1, i8 -1, i8 -1>
;
  %sh = ashr <3 x i8> <i8 undef, i8 -1, i8 undef>, %y
  ret <3 x i8> %sh
}

define i8 @lshr_by_sext_bool(i1 %x, i8 %y) {
; CHECK-LABEL: @lshr_by_sext_bool(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[X:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = lshr i8 [[Y:%.*]], [[S]]
; CHECK-NEXT:    ret i8 [[R]]
;
  %s = sext i1 %x to i8
  %r = lshr i8 %y, %s
  ret i8 %r
}

define <2 x i8> @lshr_by_sext_bool_vec(<2 x i1> %x, <2 x i8> %y) {
; CHECK-LABEL: @lshr_by_sext_bool_vec(
; CHECK-NEXT:    [[S:%.*]] = sext <2 x i1> [[X:%.*]] to <2 x i8>
; CHECK-NEXT:    [[R:%.*]] = lshr <2 x i8> [[Y:%.*]], [[S]]
; CHECK-NEXT:    ret <2 x i8> [[R]]
;
  %s = sext <2 x i1> %x to <2 x i8>
  %r = lshr <2 x i8> %y, %s
  ret <2 x i8> %r
}

define i8 @ashr_by_sext_bool(i1 %x, i8 %y) {
; CHECK-LABEL: @ashr_by_sext_bool(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[X:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = ashr i8 [[Y:%.*]], [[S]]
; CHECK-NEXT:    ret i8 [[R]]
;
  %s = sext i1 %x to i8
  %r = ashr i8 %y, %s
  ret i8 %r
}

define <2 x i8> @ashr_by_sext_bool_vec(<2 x i1> %x, <2 x i8> %y) {
; CHECK-LABEL: @ashr_by_sext_bool_vec(
; CHECK-NEXT:    [[S:%.*]] = sext <2 x i1> [[X:%.*]] to <2 x i8>
; CHECK-NEXT:    [[R:%.*]] = ashr <2 x i8> [[Y:%.*]], [[S]]
; CHECK-NEXT:    ret <2 x i8> [[R]]
;
  %s = sext <2 x i1> %x to <2 x i8>
  %r = ashr <2 x i8> %y, %s
  ret <2 x i8> %r
}

define i8 @shl_by_sext_bool(i1 %x, i8 %y) {
; CHECK-LABEL: @shl_by_sext_bool(
; CHECK-NEXT:    [[S:%.*]] = sext i1 [[X:%.*]] to i8
; CHECK-NEXT:    [[R:%.*]] = shl i8 [[Y:%.*]], [[S]]
; CHECK-NEXT:    ret i8 [[R]]
;
  %s = sext i1 %x to i8
  %r = shl i8 %y, %s
  ret i8 %r
}

define <2 x i8> @shl_by_sext_bool_vec(<2 x i1> %x, <2 x i8> %y) {
; CHECK-LABEL: @shl_by_sext_bool_vec(
; CHECK-NEXT:    [[S:%.*]] = sext <2 x i1> [[X:%.*]] to <2 x i8>
; CHECK-NEXT:    [[R:%.*]] = shl <2 x i8> [[Y:%.*]], [[S]]
; CHECK-NEXT:    ret <2 x i8> [[R]]
;
  %s = sext <2 x i1> %x to <2 x i8>
  %r = shl <2 x i8> %y, %s
  ret <2 x i8> %r
}

