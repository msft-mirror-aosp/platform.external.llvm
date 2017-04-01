; RUN: llc < %s -debug-pass=Structure -stop-after=loop-reduce -o /dev/null 2>&1 | FileCheck %s -check-prefix=STOP-AFTER
; STOP-AFTER: -loop-reduce
; STOP-AFTER: Dominator Tree Construction
; STOP-AFTER: Loop Strength Reduction
; STOP-AFTER-NEXT: MIR Printing Pass

; RUN: llc < %s -debug-pass=Structure -stop-before=loop-reduce -o /dev/null 2>&1 | FileCheck %s -check-prefix=STOP-BEFORE
; STOP-BEFORE-NOT: -loop-reduce
; STOP-BEFORE: Dominator Tree Construction
; STOP-BEFORE-NOT: Loop Strength Reduction

; RUN: llc < %s -debug-pass=Structure -start-after=loop-reduce -o /dev/null 2>&1 | FileCheck %s -check-prefix=START-AFTER
; START-AFTER: -machine-branch-prob -pre-isel-intrinsic-lowering
; START-AFTER: FunctionPass Manager
; START-AFTER-NEXT: Lower Garbage Collection Instructions

; RUN: llc < %s -debug-pass=Structure -start-before=loop-reduce -o /dev/null 2>&1 | FileCheck %s -check-prefix=START-BEFORE
; START-BEFORE: -machine-branch-prob -pre-isel-intrinsic-lowering
; START-BEFORE: FunctionPass Manager
; START-BEFORE: Loop Strength Reduction
; START-BEFORE-NEXT: Lower Garbage Collection Instructions

; RUN: not llc < %s -start-before=nonexistent -o /dev/null 2>&1 | FileCheck %s -check-prefix=NONEXISTENT-START-BEFORE
; RUN: not llc < %s -stop-before=nonexistent -o /dev/null 2>&1 | FileCheck %s -check-prefix=NONEXISTENT-STOP-BEFORE
; RUN: not llc < %s -start-after=nonexistent -o /dev/null 2>&1 | FileCheck %s -check-prefix=NONEXISTENT-START-AFTER
; RUN: not llc < %s -stop-after=nonexistent -o /dev/null 2>&1 | FileCheck %s -check-prefix=NONEXISTENT-STOP-AFTER
; NONEXISTENT-START-BEFORE: "nonexistent" pass is not registered.
; NONEXISTENT-STOP-BEFORE: "nonexistent" pass is not registered.
; NONEXISTENT-START-AFTER: "nonexistent" pass is not registered.
; NONEXISTENT-STOP-AFTER: "nonexistent" pass is not registered.

; RUN: not llc < %s -start-before=loop-reduce -start-after=loop-reduce -o /dev/null 2>&1 | FileCheck %s -check-prefix=DOUBLE-START
; RUN: not llc < %s -stop-before=loop-reduce -stop-after=loop-reduce -o /dev/null 2>&1 | FileCheck %s -check-prefix=DOUBLE-STOP
; DOUBLE-START: -start-before and -start-after specified!
; DOUBLE-STOP: -stop-before and -stop-after specified!
