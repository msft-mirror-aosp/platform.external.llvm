; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -mergeicmps -mtriple=x86_64-unknown-unknown -S | FileCheck %s --check-prefix=X86

%"struct.std::pair" = type { i32, i32 }

define zeroext i1 @opeq1(
; X86-LABEL: @opeq1(
; X86-NEXT:  entry:
; X86-NEXT:    [[FIRST_I:%.*]] = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* [[A:%.*]], i64 0, i32 0
; X86-NEXT:    [[FIRST1_I:%.*]] = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* [[B:%.*]], i64 0, i32 0
; X86-NEXT:    [[CSTR:%.*]] = bitcast i32* [[FIRST_I]] to i8*
; X86-NEXT:    [[CSTR1:%.*]] = bitcast i32* [[FIRST1_I]] to i8*
; X86-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* [[CSTR]], i8* [[CSTR1]], i64 8)
; X86-NEXT:    [[TMP0:%.*]] = icmp eq i32 [[MEMCMP]], 0
; X86-NEXT:    br label [[OPEQ1_EXIT:%.*]]
; X86:       opeq1.exit:
; X86-NEXT:    [[TMP1:%.*]] = phi i1 [ [[TMP0]], [[ENTRY:%.*]] ]
; X86-NEXT:    ret i1 [[TMP1]]
;
  %"struct.std::pair"* nocapture readonly dereferenceable(8) %a,
  %"struct.std::pair"* nocapture readonly dereferenceable(8) %b) local_unnamed_addr #0 {
entry:
  %first.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 0
  %0 = load i32, i32* %first.i, align 4
  %first1.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 0
  %1 = load i32, i32* %first1.i, align 4
  %cmp.i = icmp eq i32 %0, %1
  br i1 %cmp.i, label %land.rhs.i, label %opeq1.exit

land.rhs.i:
  %second.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 1
  %2 = load i32, i32* %second.i, align 4
  %second2.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 1
  %3 = load i32, i32* %second2.i, align 4
  %cmp3.i = icmp eq i32 %2, %3
  br label %opeq1.exit

opeq1.exit:
  %4 = phi i1 [ false, %entry ], [ %cmp3.i, %land.rhs.i ]
  ret i1 %4
; The entry block with zero-offset GEPs is kept, loads are removed.
; The two 4 byte loads and compares are replaced with a single 8-byte memcmp.
; The branch is now a direct branch; the other block has been removed.
; The phi is updated.
}

; Same as above, but the two blocks are in inverse order.
define zeroext i1 @opeq1_inverse(
; X86-LABEL: @opeq1_inverse(
; X86-NEXT:  land.rhs.i:
; X86-NEXT:    [[SECOND_I:%.*]] = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* [[A:%.*]], i64 0, i32 0
; X86-NEXT:    [[SECOND2_I:%.*]] = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* [[B:%.*]], i64 0, i32 0
; X86-NEXT:    [[CSTR:%.*]] = bitcast i32* [[SECOND_I]] to i8*
; X86-NEXT:    [[CSTR1:%.*]] = bitcast i32* [[SECOND2_I]] to i8*
; X86-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(i8* [[CSTR]], i8* [[CSTR1]], i64 8)
; X86-NEXT:    [[TMP0:%.*]] = icmp eq i32 [[MEMCMP]], 0
; X86-NEXT:    br label [[OPEQ1_EXIT:%.*]]
; X86:       opeq1.exit:
; X86-NEXT:    [[TMP1:%.*]] = phi i1 [ [[TMP0]], [[LAND_RHS_I:%.*]] ]
; X86-NEXT:    ret i1 [[TMP1]]
;
  %"struct.std::pair"* nocapture readonly dereferenceable(8) %a,
  %"struct.std::pair"* nocapture readonly dereferenceable(8) %b) local_unnamed_addr #0 {
entry:
  %first.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 1
  %0 = load i32, i32* %first.i, align 4
  %first1.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 1
  %1 = load i32, i32* %first1.i, align 4
  %cmp.i = icmp eq i32 %0, %1
  br i1 %cmp.i, label %land.rhs.i, label %opeq1.exit

land.rhs.i:
  %second.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %a, i64 0, i32 0
  %2 = load i32, i32* %second.i, align 4
  %second2.i = getelementptr inbounds %"struct.std::pair", %"struct.std::pair"* %b, i64 0, i32 0
  %3 = load i32, i32* %second2.i, align 4
  %cmp3.i = icmp eq i32 %2, %3
  br label %opeq1.exit

opeq1.exit:
  %4 = phi i1 [ false, %entry ], [ %cmp3.i, %land.rhs.i ]
  ret i1 %4
; The second block with zero-offset GEPs is kept, loads are removed.
; CHECK: land.rhs.i
; The two 4 byte loads and compares are replaced with a single 8-byte memcmp.
; The branch is now a direct branch; the other block has been removed.
; The phi is updated.
}



