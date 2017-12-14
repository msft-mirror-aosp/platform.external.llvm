; RUN: llc -mtriple=x86_64-unknown-unknown < %s | FileCheck %s
; Check assembly printing of odd constants.

; CHECK: bigCst:
; CHECK-NEXT: .quad 12713950999227904
; CHECK-NEXT: .quad 26220
; CHECK-NEXT: .size bigCst, 16

@bigCst = internal constant i82 483673642326615442599424

define void @accessBig(i64* %storage) {
  %addr = bitcast i64* %storage to i82*
  %bigLoadedCst = load volatile i82, i82* @bigCst
  %tmp = add i82 %bigLoadedCst, 1
  store i82 %tmp, i82* %addr
  ret void
}
