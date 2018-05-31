; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

define i64 @sel_false_val_is_a_masked_shl_of_true_val1(i32 %x, i64 %y) {
; CHECK-LABEL: @sel_false_val_is_a_masked_shl_of_true_val1(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 15
; CHECK-NEXT:    [[TMP2:%.*]] = shl nuw nsw i32 [[TMP1]], 2
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[NARROW:%.*]] = select i1 [[TMP3]], i32 0, i32 [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = zext i32 [[NARROW]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = ashr i64 [[Y:%.*]], [[TMP4]]
; CHECK-NEXT:    ret i64 [[TMP5]]
;
  %1 = and i32 %x, 15
  %2 = shl nuw nsw i32 %1, 2
  %3 = zext i32 %2 to i64
  %4 = icmp eq i32 %1, 0
  %5 = ashr i64 %y, %3
  %6 = select i1 %4, i64 %y, i64 %5
  ret i64 %6
}

define i64 @sel_false_val_is_a_masked_shl_of_true_val2(i32 %x, i64 %y) {
; CHECK-LABEL: @sel_false_val_is_a_masked_shl_of_true_val2(
; CHECK-NEXT:    [[TMP1:%.*]] = shl i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], 60
; CHECK-NEXT:    [[TMP3:%.*]] = zext i32 [[TMP2]] to i64
; CHECK-NEXT:    [[TMP4:%.*]] = ashr i64 [[Y:%.*]], [[TMP3]]
; CHECK-NEXT:    ret i64 [[TMP4]]
;
  %1 = and i32 %x, 15
  %2 = shl nuw nsw i32 %1, 2
  %3 = zext i32 %2 to i64
  %4 = icmp eq i32 %2, 0
  %5 = ashr i64 %y, %3
  %6 = select i1 %4, i64 %y, i64 %5
  ret i64 %6
}

define i64 @sel_false_val_is_a_masked_lshr_of_true_val1(i32 %x, i64 %y) {
; CHECK-LABEL: @sel_false_val_is_a_masked_lshr_of_true_val1(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 60
; CHECK-NEXT:    [[TMP2:%.*]] = lshr exact i32 [[TMP1]], 2
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[NARROW:%.*]] = select i1 [[TMP3]], i32 0, i32 [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = zext i32 [[NARROW]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = ashr i64 [[Y:%.*]], [[TMP4]]
; CHECK-NEXT:    ret i64 [[TMP5]]
;
  %1 = and i32 %x, 60
  %2 = lshr i32 %1, 2
  %3 = zext i32 %2 to i64
  %4 = icmp eq i32 %1, 0
  %5 = ashr i64 %y, %3
  %6 = select i1 %4, i64 %y, i64 %5
  ret i64 %6
}

define i64 @sel_false_val_is_a_masked_lshr_of_true_val2(i32 %x, i64 %y) {
; CHECK-LABEL: @sel_false_val_is_a_masked_lshr_of_true_val2(
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], 15
; CHECK-NEXT:    [[TMP3:%.*]] = zext i32 [[TMP2]] to i64
; CHECK-NEXT:    [[TMP4:%.*]] = ashr i64 [[Y:%.*]], [[TMP3]]
; CHECK-NEXT:    ret i64 [[TMP4]]
;
  %1 = and i32 %x, 60
  %2 = lshr i32 %1, 2
  %3 = zext i32 %2 to i64
  %4 = icmp eq i32 %2, 0
  %5 = ashr i64 %y, %3
  %6 = select i1 %4, i64 %y, i64 %5
  ret i64 %6
}

define i64 @sel_false_val_is_a_masked_ashr_of_true_val1(i32 %x, i64 %y) {
; CHECK-LABEL: @sel_false_val_is_a_masked_ashr_of_true_val1(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], -2147483588
; CHECK-NEXT:    [[TMP2:%.*]] = ashr exact i32 [[TMP1]], 2
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[NARROW:%.*]] = select i1 [[TMP3]], i32 0, i32 [[TMP2]]
; CHECK-NEXT:    [[TMP4:%.*]] = zext i32 [[NARROW]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = ashr i64 [[Y:%.*]], [[TMP4]]
; CHECK-NEXT:    ret i64 [[TMP5]]
;
  %1 = and i32 %x, -2147483588
  %2 = ashr i32 %1, 2
  %3 = zext i32 %2 to i64
  %4 = icmp eq i32 %1, 0
  %5 = ashr i64 %y, %3
  %6 = select i1 %4, i64 %y, i64 %5
  ret i64 %6
}

define i64 @sel_false_val_is_a_masked_ashr_of_true_val2(i32 %x, i64 %y) {
; CHECK-LABEL: @sel_false_val_is_a_masked_ashr_of_true_val2(
; CHECK-NEXT:    [[TMP1:%.*]] = ashr i32 [[X:%.*]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], -536870897
; CHECK-NEXT:    [[TMP3:%.*]] = zext i32 [[TMP2]] to i64
; CHECK-NEXT:    [[TMP4:%.*]] = ashr i64 [[Y:%.*]], [[TMP3]]
; CHECK-NEXT:    ret i64 [[TMP4]]
;
  %1 = and i32 %x, -2147483588
  %2 = ashr i32 %1, 2
  %3 = zext i32 %2 to i64
  %4 = icmp eq i32 %2, 0
  %5 = ashr i64 %y, %3
  %6 = select i1 %4, i64 %y, i64 %5
  ret i64 %6
}

