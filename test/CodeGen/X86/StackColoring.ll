; RUN: llc -mcpu=corei7 -no-stack-coloring=false < %s | FileCheck %s --check-prefix=YESCOLOR --check-prefix=CHECK
; RUN: llc -mcpu=corei7 -no-stack-coloring=true  < %s | FileCheck %s --check-prefix=NOCOLOR --check-prefix=CHECK

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

;CHECK-LABEL: myCall_w2:
;YESCOLOR: subq  $144, %rsp
;NOCOLOR: subq  $272, %rsp

define i32 @myCall_w2(i32 %in) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %b)
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  call void @llvm.lifetime.end(i64 -1, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
}


;CHECK-LABEL: myCall2_no_merge
;YESCOLOR: subq  $272, %rsp
;NOCOLOR: subq  $272, %rsp

define i32 @myCall2_no_merge(i32 %in, i1 %d) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %b)
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  br i1 %d, label %bb2, label %bb3
bb2:
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  call void @llvm.lifetime.end(i64 -1, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  ret i32 %t7
bb3:
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  ret i32 0
}

;CHECK-LABEL: myCall2_w2
;YESCOLOR: subq  $144, %rsp
;NOCOLOR: subq  $272, %rsp

define i32 @myCall2_w2(i32 %in, i1 %d) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %b)
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  br i1 %d, label %bb2, label %bb3
bb2:
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  call void @llvm.lifetime.end(i64 -1, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
bb3:
  ret i32 0
}

;CHECK-LABEL: myCall_w4:
;YESCOLOR: subq  $120, %rsp
;NOCOLOR: subq  $408, %rsp

define i32 @myCall_w4(i32 %in) {
entry:
  %a1 = alloca [14 x i8*], align 8
  %a2 = alloca [13 x i8*], align 8
  %a3 = alloca [12 x i8*], align 8
  %a4 = alloca [11 x i8*], align 8
  %b1 = bitcast [14 x i8*]* %a1 to i8*
  %b2 = bitcast [13 x i8*]* %a2 to i8*
  %b3 = bitcast [12 x i8*]* %a3 to i8*
  %b4 = bitcast [11 x i8*]* %a4 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %b4)
  call void @llvm.lifetime.start(i64 -1, i8* %b1)
  %t1 = call i32 @foo(i32 %in, i8* %b1)
  %t2 = call i32 @foo(i32 %in, i8* %b1)
  call void @llvm.lifetime.end(i64 -1, i8* %b1)
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t9 = call i32 @foo(i32 %in, i8* %b2)
  %t8 = call i32 @foo(i32 %in, i8* %b2)
  call void @llvm.lifetime.end(i64 -1, i8* %b2)
  call void @llvm.lifetime.start(i64 -1, i8* %b3)
  %t3 = call i32 @foo(i32 %in, i8* %b3)
  %t4 = call i32 @foo(i32 %in, i8* %b3)
  call void @llvm.lifetime.end(i64 -1, i8* %b3)
  %t11 = call i32 @foo(i32 %in, i8* %b4)
  call void @llvm.lifetime.end(i64 -1, i8* %b4)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
}

;CHECK-LABEL: myCall2_w4:
;YESCOLOR: subq  $112, %rsp
;NOCOLOR: subq  $400, %rsp

define i32 @myCall2_w4(i32 %in) {
entry:
  %a1 = alloca [14 x i8*], align 8
  %a2 = alloca [13 x i8*], align 8
  %a3 = alloca [12 x i8*], align 8
  %a4 = alloca [11 x i8*], align 8
  %b1 = bitcast [14 x i8*]* %a1 to i8*
  %b2 = bitcast [13 x i8*]* %a2 to i8*
  %b3 = bitcast [12 x i8*]* %a3 to i8*
  %b4 = bitcast [11 x i8*]* %a4 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %b1)
  %t1 = call i32 @foo(i32 %in, i8* %b1)
  %t2 = call i32 @foo(i32 %in, i8* %b1)
  call void @llvm.lifetime.end(i64 -1, i8* %b1)
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t9 = call i32 @foo(i32 %in, i8* %b2)
  %t8 = call i32 @foo(i32 %in, i8* %b2)
  call void @llvm.lifetime.end(i64 -1, i8* %b2)
  call void @llvm.lifetime.start(i64 -1, i8* %b3)
  %t3 = call i32 @foo(i32 %in, i8* %b3)
  %t4 = call i32 @foo(i32 %in, i8* %b3)
  call void @llvm.lifetime.end(i64 -1, i8* %b3)
  br i1 undef, label %bb2, label %bb3
bb2:
  call void @llvm.lifetime.start(i64 -1, i8* %b4)
  %t11 = call i32 @foo(i32 %in, i8* %b4)
  call void @llvm.lifetime.end(i64 -1, i8* %b4)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
bb3:
  ret i32 0
}


;CHECK-LABEL: myCall2_noend:
;YESCOLOR: subq  $144, %rsp
;NOCOLOR: subq  $272, %rsp


define i32 @myCall2_noend(i32 %in, i1 %d) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %b)
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  br i1 %d, label %bb2, label %bb3
bb2:
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
bb3:
  ret i32 0
}

;CHECK-LABEL: myCall2_noend2:
;YESCOLOR: subq  $144, %rsp
;NOCOLOR: subq  $272, %rsp
define i32 @myCall2_noend2(i32 %in, i1 %d) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %b)
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  br i1 %d, label %bb2, label %bb3
bb2:
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
bb3:
  ret i32 0
}


;CHECK-LABEL: myCall2_nostart:
;YESCOLOR: subq  $272, %rsp
;NOCOLOR: subq  $272, %rsp
define i32 @myCall2_nostart(i32 %in, i1 %d) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  br i1 %d, label %bb2, label %bb3
bb2:
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
bb3:
  ret i32 0
}

; Adopt the test from Transforms/Inline/array_merge.ll'
;CHECK-LABEL: array_merge:
;YESCOLOR: subq  $808, %rsp
;NOCOLOR: subq  $1608, %rsp
define void @array_merge() nounwind ssp {
entry:
  %A.i1 = alloca [100 x i32], align 4
  %B.i2 = alloca [100 x i32], align 4
  %A.i = alloca [100 x i32], align 4
  %B.i = alloca [100 x i32], align 4
  %0 = bitcast [100 x i32]* %A.i to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %0) nounwind
  %1 = bitcast [100 x i32]* %B.i to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %1) nounwind
  call void @bar([100 x i32]* %A.i, [100 x i32]* %B.i) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %0) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %1) nounwind
  %2 = bitcast [100 x i32]* %A.i1 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %2) nounwind
  %3 = bitcast [100 x i32]* %B.i2 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %3) nounwind
  call void @bar([100 x i32]* %A.i1, [100 x i32]* %B.i2) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %2) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %3) nounwind
  ret void
}

;CHECK-LABEL: func_phi_lifetime:
;YESCOLOR: subq  $272, %rsp
;NOCOLOR: subq  $272, %rsp
define i32 @func_phi_lifetime(i32 %in, i1 %d) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  br i1 %d, label %bb0, label %bb1

bb0:
  %I1 = bitcast [17 x i8*]* %a to i8*
  br label %bb2

bb1:
  %I2 = bitcast [16 x i8*]* %a2 to i8*
  br label %bb2

bb2:
  %split = phi i8* [ %I1, %bb0 ], [ %I2, %bb1 ]
  call void @llvm.lifetime.start(i64 -1, i8* %split)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  call void @llvm.lifetime.end(i64 -1, i8* %split)
  ret i32 %t7
bb3:
  ret i32 0
}


;CHECK-LABEL: multi_region_bb:
define void @multi_region_bb() nounwind ssp {
entry:
  %A.i1 = alloca [100 x i32], align 4
  %B.i2 = alloca [100 x i32], align 4
  %A.i = alloca [100 x i32], align 4
  %B.i = alloca [100 x i32], align 4
  %0 = bitcast [100 x i32]* %A.i to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %0) nounwind ; <---- start #1
  %1 = bitcast [100 x i32]* %B.i to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %1) nounwind
  call void @bar([100 x i32]* %A.i, [100 x i32]* %B.i) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %0) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %1) nounwind
  %2 = bitcast [100 x i32]* %A.i1 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %2) nounwind
  %3 = bitcast [100 x i32]* %B.i2 to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %3) nounwind
  call void @llvm.lifetime.start(i64 -1, i8* %0) nounwind  ; <---- start #2
  call void @bar([100 x i32]* %A.i1, [100 x i32]* %B.i2) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %2) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %0) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %3) nounwind
  ret void
}
;YESCOLOR: subq  $272, %rsp
;NOCOLOR: subq  $272, %rsp

define i32 @myCall_end_before_begin(i32 %in, i1 %d) {
entry:
  %a = alloca [17 x i8*], align 8
  %a2 = alloca [16 x i8*], align 8
  %b = bitcast [17 x i8*]* %a to i8*
  %b2 = bitcast [16 x i8*]* %a2 to i8*
  %t1 = call i32 @foo(i32 %in, i8* %b)
  %t2 = call i32 @foo(i32 %in, i8* %b)
  call void @llvm.lifetime.end(i64 -1, i8* %b)
  call void @llvm.lifetime.start(i64 -1, i8* %b)
  br i1 %d, label %bb2, label %bb3
bb2:
  call void @llvm.lifetime.start(i64 -1, i8* %b2)
  %t3 = call i32 @foo(i32 %in, i8* %b2)
  %t4 = call i32 @foo(i32 %in, i8* %b2)
  %t5 = add i32 %t1, %t2
  %t6 = add i32 %t3, %t4
  %t7 = add i32 %t5, %t6
  ret i32 %t7
bb3:
  ret i32 0
}


; Regression test for PR15707.  %buf1 and %buf2 should not be merged
; in this test case.
;CHECK-LABEL: myCall_pr15707:
;YESCOLOR: subq $200008, %rsp
;NOCOLOR: subq $200008, %rsp
define void @myCall_pr15707() {
  %buf1 = alloca i8, i32 100000, align 16
  %buf2 = alloca i8, i32 100000, align 16

  call void @llvm.lifetime.start(i64 -1, i8* %buf1)
  call void @llvm.lifetime.end(i64 -1, i8* %buf1)

  call void @llvm.lifetime.start(i64 -1, i8* %buf1)
  call void @llvm.lifetime.start(i64 -1, i8* %buf2)
  %result1 = call i32 @foo(i32 0, i8* %buf1)
  %result2 = call i32 @foo(i32 0, i8* %buf2)
  ret void
}


; Check that we don't assert and crash even when there are allocas
; outside the declared lifetime regions.
;CHECK-LABEL: bad_range:
define void @bad_range() nounwind ssp {
entry:
  %A.i1 = alloca [100 x i32], align 4
  %B.i2 = alloca [100 x i32], align 4
  %A.i = alloca [100 x i32], align 4
  %B.i = alloca [100 x i32], align 4
  %0 = bitcast [100 x i32]* %A.i to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %0) nounwind
  %1 = bitcast [100 x i32]* %B.i to i8*
  call void @llvm.lifetime.start(i64 -1, i8* %1) nounwind
  call void @bar([100 x i32]* %A.i, [100 x i32]* %B.i) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %0) nounwind
  call void @llvm.lifetime.end(i64 -1, i8* %1) nounwind
  br label %block2

block2:
  ; I am used outside the marked lifetime.
  call void @bar([100 x i32]* %A.i, [100 x i32]* %B.i) nounwind
  ret void
}


; Check that we don't assert and crash even when there are usages
; of allocas which do not read or write outside the declared lifetime regions.
;CHECK-LABEL: shady_range:

%struct.Klass = type { i32, i32 }

define i32 @shady_range(i32 %argc, i8** nocapture %argv) uwtable {
  %a.i = alloca [4 x %struct.Klass], align 16
  %b.i = alloca [4 x %struct.Klass], align 16
  %a8 = bitcast [4 x %struct.Klass]* %a.i to i8*
  %b8 = bitcast [4 x %struct.Klass]* %b.i to i8*
  ; I am used outside the lifetime zone below:
  %z2 = getelementptr inbounds [4 x %struct.Klass], [4 x %struct.Klass]* %a.i, i64 0, i64 0, i32 0
  call void @llvm.lifetime.start(i64 -1, i8* %a8)
  call void @llvm.lifetime.start(i64 -1, i8* %b8)
  %z3 = load i32, i32* %z2, align 16
  %r = call i32 @foo(i32 %z3, i8* %a8)
  %r2 = call i32 @foo(i32 %z3, i8* %b8)
  call void @llvm.lifetime.end(i64 -1, i8* %a8)
  call void @llvm.lifetime.end(i64 -1, i8* %b8)
  ret i32 9
}

; In this case 'itar1' and 'itar2' can't be overlapped if we treat
; lifetime.start as the beginning of the lifetime, but we can
; overlap if we consider first use of the slot as lifetime
; start. See llvm bug 25776.

;CHECK-LABEL: ifthen_twoslots:
;YESCOLOR: subq  $536, %rsp
;NOCOLOR: subq  $1048, %rsp

define i32 @ifthen_twoslots(i32 %x) #0 {
entry:
  %retval = alloca i32, align 4
  %x.addr = alloca i32, align 4
  %itar1 = alloca [128 x i32], align 16
  %itar2 = alloca [128 x i32], align 16
  %cleanup.dest.slot = alloca i32
  store i32 %x, i32* %x.addr, align 4
  %itar1_start_8 = bitcast [128 x i32]* %itar1 to i8*
  call void @llvm.lifetime.start(i64 512, i8* %itar1_start_8) #3
  %itar2_start_8 = bitcast [128 x i32]* %itar2 to i8*
  call void @llvm.lifetime.start(i64 512, i8* %itar2_start_8) #3
  %xval = load i32, i32* %x.addr, align 4
  %and = and i32 %xval, 1
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %arraydecay = getelementptr inbounds [128 x i32], [128 x i32]* %itar1, i32 0, i32 0
  call void @inita(i32* %arraydecay)
  store i32 1, i32* %retval, align 4
  store i32 1, i32* %cleanup.dest.slot, align 4
  %itar2_end_8 = bitcast [128 x i32]* %itar2 to i8*
  call void @llvm.lifetime.end(i64 512, i8* %itar2_end_8) #3
  %itar1_end_8 = bitcast [128 x i32]* %itar1 to i8*
  call void @llvm.lifetime.end(i64 512, i8* %itar1_end_8) #3
  br label %cleanup

if.else:                                          ; preds = %entry
  %arraydecay1 = getelementptr inbounds [128 x i32], [128 x i32]* %itar2, i32 0, i32 0
  call void @inita(i32* %arraydecay1)
  store i32 0, i32* %retval, align 4
  store i32 1, i32* %cleanup.dest.slot, align 4
  %itar2_end2_8 = bitcast [128 x i32]* %itar2 to i8*
  call void @llvm.lifetime.end(i64 512, i8* %itar2_end2_8) #3
  %itar1_end2_8 = bitcast [128 x i32]* %itar1 to i8*
  call void @llvm.lifetime.end(i64 512, i8* %itar1_end2_8) #3
  br label %cleanup

cleanup:                                          ; preds = %if.else, %if.then
  %final_retval = load i32,
 i32* %retval, align 4
  ret i32 %final_retval
}

; This function is intended to test the case where you
; have a reference to a stack slot that lies outside of
; the START/END lifetime markers-- the flow analysis
; should catch this and build the lifetime based on the
; markers only.

;CHECK-LABEL: while_loop:
;YESCOLOR: subq  $1032, %rsp
;NOCOLOR: subq  $1544, %rsp

define i32 @while_loop(i32 %x) #0 {
entry:
  %b1 = alloca [128 x i32], align 16
  %b2 = alloca [128 x i32], align 16
  %b3 = alloca [128 x i32], align 16
  %tmp = bitcast [128 x i32]* %b1 to i8*
  call void @llvm.lifetime.start(i64 512, i8* %tmp) #3
  %tmp1 = bitcast [128 x i32]* %b2 to i8*
  call void @llvm.lifetime.start(i64 512, i8* %tmp1) #3
  %and = and i32 %x, 1
  %tobool = icmp eq i32 %and, 0
  br i1 %tobool, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  %arraydecay = getelementptr inbounds [128 x i32], [128 x i32]* %b2, i64 0, i64 0
  call void @inita(i32* %arraydecay) #3
  br label %if.end

if.else:                                          ; preds = %entry
  %arraydecay1 = getelementptr inbounds [128 x i32], [128 x i32]* %b1, i64 0, i64 0
  call void @inita(i32* %arraydecay1) #3
  %arraydecay3 = getelementptr inbounds [128 x i32], [128 x i32]* %b3, i64 0, i64 0
  call void @inita(i32* %arraydecay3) #3
  %tobool25 = icmp eq i32 %x, 0
  br i1 %tobool25, label %if.end, label %while.body.lr.ph

while.body.lr.ph:                                 ; preds = %if.else
  %tmp2 = bitcast [128 x i32]* %b3 to i8*
  br label %while.body

while.body:                                       ; preds = %while.body.lr.ph, %while.body
  %x.addr.06 = phi i32 [ %x, %while.body.lr.ph ], [ %dec, %while.body ]
  %dec = add nsw i32 %x.addr.06, -1
  call void @llvm.lifetime.start(i64 512, i8* %tmp2) #3
  call void @inita(i32* %arraydecay3) #3
  call void @llvm.lifetime.end(i64 512, i8* %tmp2) #3
  %tobool2 = icmp eq i32 %dec, 0
  br i1 %tobool2, label %if.end.loopexit, label %while.body

if.end.loopexit:                                  ; preds = %while.body
  br label %if.end

if.end:                                           ; preds = %if.end.loopexit, %if.else, %if.then
  call void @llvm.lifetime.end(i64 512, i8* %tmp1) #3
  call void @llvm.lifetime.end(i64 512, i8* %tmp) #3
  ret i32 0
}

declare void @inita(i32*) #2

declare void @bar([100 x i32]* , [100 x i32]*) nounwind

declare void @llvm.lifetime.start(i64, i8* nocapture) nounwind

declare void @llvm.lifetime.end(i64, i8* nocapture) nounwind

declare i32 @foo(i32, i8*)
