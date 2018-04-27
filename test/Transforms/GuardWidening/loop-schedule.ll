; RUN: opt -S -licm -loop-guard-widening -licm -debug-pass=Structure < %s 2>&1   | FileCheck %s

; Main point of this test is to check the scheduling -- there should be
; no analysis passes needed between LICM and LoopGuardWidening

; TODO: Because guard widdening currently requires post-dom, we end up
; breaking the loop pass manager to compute it.  Need to either make all
; loop passes preserve postdom (hard) or make it optional in guard widdening
; CHECK: Loop Pass Manager
; CHECK:   Loop Invariant Code Motion
; CHECK: Post-Dominator Tree Construction
; CHECK: Loop Pass Manager
; CHECK:   Widen guards (within a single loop, as a loop pass)
; CHECK:   Loop Invariant Code Motion

declare void @llvm.experimental.guard(i1,...)

define void @iter(i32 %a, i32 %b, i1* %c_p) {
; CHECK-LABEL @iter
; CHECK:  %cond_0 = icmp ult i32 %a, 10
; CHECK:  %cond_1 = icmp ult i32 %b, 10
; CHECK:  %wide.chk = and i1 %cond_0, %cond_1
; CHECK:  call void (i1, ...) @llvm.experimental.guard(i1 %wide.chk) [ "deopt"() ]

entry:
  %cond_0 = icmp ult i32 %a, 10
  call void (i1, ...) @llvm.experimental.guard(i1 %cond_0) [ "deopt"() ]
  br label %loop

loop:                                             ; preds = %loop.preheader, %loop
  %cond_1 = icmp ult i32 %b, 10
  call void (i1, ...) @llvm.experimental.guard(i1 %cond_1) [ "deopt"() ]
  %cnd = load i1, i1* %c_p
  br i1 %cnd, label %loop, label %leave.loopexit

leave.loopexit:                                   ; preds = %loop
  br label %leave

leave:                                            ; preds = %leave.loopexit, %entry
  ret void
}
