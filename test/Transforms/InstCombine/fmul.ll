; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

; (-0.0 - X) * C => X * -C
define float @neg_constant(float %x) {
; CHECK-LABEL: @neg_constant(
; CHECK-NEXT:    [[MUL:%.*]] = fmul ninf float [[X:%.*]], -2.000000e+01
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub = fsub float -0.000000e+00, %x
  %mul = fmul ninf float %sub, 2.0e+1
  ret float %mul
}

; (0.0 - X) * C => X * -C
define float @neg_nsz_constant(float %x) {
; CHECK-LABEL: @neg_nsz_constant(
; CHECK-NEXT:    [[MUL:%.*]] = fmul nnan float [[X:%.*]], -2.000000e+01
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub = fsub nsz float 0.000000e+00, %x
  %mul = fmul nnan float %sub, 2.0e+1
  ret float %mul
}

; (-0.0 - X) * (-0.0 - Y) => X * Y
define float @neg_neg(float %x, float %y) {
; CHECK-LABEL: @neg_neg(
; CHECK-NEXT:    [[MUL:%.*]] = fmul arcp float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub float -0.000000e+00, %x
  %sub2 = fsub float -0.000000e+00, %y
  %mul = fmul arcp float %sub1, %sub2
  ret float %mul
}

; (0.0 - X) * (0.0 - Y) => X * Y
define float @neg_neg_nsz(float %x, float %y) {
; CHECK-LABEL: @neg_neg_nsz(
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub nsz float 0.000000e+00, %x
  %sub2 = fsub nsz float 0.000000e+00, %y
  %mul = fmul afn float %sub1, %sub2
  ret float %mul
}

declare void @use_f32(float)

define float @neg_neg_multi_use(float %x, float %y) {
; CHECK-LABEL: @neg_neg_multi_use(
; CHECK-NEXT:    [[NX:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[NY:%.*]] = fsub float -0.000000e+00, [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul afn float [[X]], [[Y]]
; CHECK-NEXT:    call void @use_f32(float [[NX]])
; CHECK-NEXT:    call void @use_f32(float [[NY]])
; CHECK-NEXT:    ret float [[MUL]]
;
  %nx = fsub float -0.000000e+00, %x
  %ny = fsub float -0.000000e+00, %y
  %mul = fmul afn float %nx, %ny
  call void @use_f32(float %nx)
  call void @use_f32(float %ny)
  ret float %mul
}

; (-0.0 - X) * Y => -0.0 - (X * Y)
define float @neg_sink(float %x, float %y) {
; CHECK-LABEL: @neg_sink(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fsub float -0.000000e+00, [[TMP1]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub float -0.000000e+00, %x
  %mul = fmul float %sub1, %y
  ret float %mul
}

; (0.0 - X) * Y => 0.0 - (X * Y)
define float @neg_sink_nsz(float %x, float %y) {
; CHECK-LABEL: @neg_sink_nsz(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fsub float -0.000000e+00, [[TMP1]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %sub1 = fsub nsz float 0.000000e+00, %x
  %mul = fmul float %sub1, %y
  ret float %mul
}

; "(-0.0 - X) * Y => -0.0 - (X * Y)" is disabled if expression "-0.0 - X"
; has multiple uses.
define float @neg_sink_multi_use(float %x, float %y) {
; CHECK-LABEL: @neg_sink_multi_use(
; CHECK-NEXT:    [[SUB1:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[SUB1]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul float [[MUL]], [[SUB1]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %sub1 = fsub float -0.000000e+00, %x
  %mul = fmul float %sub1, %y
  %mul2 = fmul float %mul, %sub1
  ret float %mul2
}

; Don't crash when attempting to cast a constant FMul to an instruction.
define void @test8(i32* %inout) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[LOCAL_VAR_7_0:%.*]] = phi <4 x float> [ <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, [[ENTRY:%.*]] ], [ [[TMP0:%.*]], [[FOR_BODY:%.*]] ]
; CHECK-NEXT:    br i1 undef, label [[FOR_BODY]], label [[FOR_END:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[TMP0]] = insertelement <4 x float> [[LOCAL_VAR_7_0]], float 0.000000e+00, i32 2
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %0 = load i32, i32* %inout, align 4
  %conv = uitofp i32 %0 to float
  %vecinit = insertelement <4 x float> <float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float undef>, float %conv, i32 3
  %sub = fsub <4 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, %vecinit
  %1 = shufflevector <4 x float> %sub, <4 x float> undef, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  %mul = fmul <4 x float> zeroinitializer, %1
  br label %for.cond

for.cond:                                         ; preds = %for.body, %entry
  %local_var_7.0 = phi <4 x float> [ %mul, %entry ], [ %2, %for.body ]
  br i1 undef, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = insertelement <4 x float> %local_var_7.0, float 0.000000e+00, i32 2
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; X * -1.0 => -0.0 - X
define float @test9(float %x) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[MUL:%.*]] = fsub float -0.000000e+00, [[X:%.*]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %mul = fmul float %x, -1.0
  ret float %mul
}

; PR18532
define <4 x float> @test10(<4 x float> %x) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[MUL:%.*]] = fsub arcp afn <4 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, [[X:%.*]]
; CHECK-NEXT:    ret <4 x float> [[MUL]]
;
  %mul = fmul arcp afn <4 x float> %x, <float -1.0, float -1.0, float -1.0, float -1.0>
  ret <4 x float> %mul
}

define float @test11(float %x, float %y) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[B:%.*]] = fadd fast float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[C:%.*]] = fadd fast float [[B]], 3.000000e+00
; CHECK-NEXT:    ret float [[C]]
;
  %a = fadd fast float %x, 1.0
  %b = fadd fast float %y, 2.0
  %c = fadd fast float %a, %b
  ret float %c
}

declare double @llvm.sqrt.f64(double)

; With unsafe/fast math, sqrt(X) * sqrt(X) is just X,
; but make sure another use of the sqrt is intact.
; Note that the remaining fmul is altered but is not 'fast'
; itself because it was not marked 'fast' originally.
; Thus, we have an overall fast result, but no more indication of
; 'fast'ness in the code.
define double @sqrt_squared2(double %f) {
; CHECK-LABEL: @sqrt_squared2(
; CHECK-NEXT:    [[SQRT:%.*]] = call double @llvm.sqrt.f64(double [[F:%.*]])
; CHECK-NEXT:    [[MUL2:%.*]] = fmul double [[SQRT]], [[F]]
; CHECK-NEXT:    ret double [[MUL2]]
;
  %sqrt = call double @llvm.sqrt.f64(double %f)
  %mul1 = fmul fast double %sqrt, %sqrt
  %mul2 = fmul double %mul1, %sqrt
  ret double %mul2
}

declare float @llvm.fabs.f32(float) nounwind readnone

define float @fabs_squared(float %x) {
; CHECK-LABEL: @fabs_squared(
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[X:%.*]], [[X]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %mul = fmul float %x.fabs, %x.fabs
  ret float %mul
}

define float @fabs_squared_fast(float %x) {
; CHECK-LABEL: @fabs_squared_fast(
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float [[X:%.*]], [[X]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %mul = fmul fast float %x.fabs, %x.fabs
  ret float %mul
}

define float @fabs_x_fabs(float %x, float %y) {
; CHECK-LABEL: @fabs_x_fabs(
; CHECK-NEXT:    [[X_FABS:%.*]] = call float @llvm.fabs.f32(float [[X:%.*]])
; CHECK-NEXT:    [[Y_FABS:%.*]] = call float @llvm.fabs.f32(float [[Y:%.*]])
; CHECK-NEXT:    [[MUL:%.*]] = fmul float [[X_FABS]], [[Y_FABS]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %x.fabs = call float @llvm.fabs.f32(float %x)
  %y.fabs = call float @llvm.fabs.f32(float %y)
  %mul = fmul float %x.fabs, %y.fabs
  ret float %mul
}

; (X*Y) * X => (X*X) * Y
; The transform only requires 'reassoc', but test other FMF in
; the commuted variants to make sure FMF propagates as expected.

define float @reassoc_common_operand1(float %x, float %y) {
; CHECK-LABEL: @reassoc_common_operand1(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc float [[X:%.*]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul reassoc float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %mul1 = fmul float %x, %y
  %mul2 = fmul reassoc float %mul1, %x
  ret float %mul2
}

; (Y*X) * X => (X*X) * Y

define float @reassoc_common_operand2(float %x, float %y) {
; CHECK-LABEL: @reassoc_common_operand2(
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[X:%.*]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul fast float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %mul1 = fmul float %y, %x
  %mul2 = fmul fast float %mul1, %x
  ret float %mul2
}

; X * (X*Y) => (X*X) * Y

define float @reassoc_common_operand3(float %x1, float %y) {
; CHECK-LABEL: @reassoc_common_operand3(
; CHECK-NEXT:    [[X:%.*]] = fdiv float [[X1:%.*]], 3.000000e+00
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc nnan float [[X]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul reassoc nnan float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %x = fdiv float %x1, 3.0 ; thwart complexity-based canonicalization
  %mul1 = fmul float %x, %y
  %mul2 = fmul reassoc nnan float %x, %mul1
  ret float %mul2
}

; X * (Y*X) => (X*X) * Y

define float @reassoc_common_operand4(float %x1, float %y) {
; CHECK-LABEL: @reassoc_common_operand4(
; CHECK-NEXT:    [[X:%.*]] = fdiv float [[X1:%.*]], 3.000000e+00
; CHECK-NEXT:    [[TMP1:%.*]] = fmul reassoc ninf float [[X]], [[X]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul reassoc ninf float [[TMP1]], [[Y:%.*]]
; CHECK-NEXT:    ret float [[MUL2]]
;
  %x = fdiv float %x1, 3.0 ; thwart complexity-based canonicalization
  %mul1 = fmul float %y, %x
  %mul2 = fmul reassoc ninf float %x, %mul1
  ret float %mul2
}

; No change if the first fmul has another use.

define float @reassoc_common_operand_multi_use(float %x, float %y) {
; CHECK-LABEL: @reassoc_common_operand_multi_use(
; CHECK-NEXT:    [[MUL1:%.*]] = fmul float [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[MUL2:%.*]] = fmul fast float [[MUL1]], [[X]]
; CHECK-NEXT:    call void @use_f32(float [[MUL1]])
; CHECK-NEXT:    ret float [[MUL2]]
;
  %mul1 = fmul float %x, %y
  %mul2 = fmul fast float %mul1, %x
  call void @use_f32(float %mul1)
  ret float %mul2
}

declare float @llvm.log2.f32(float)

; log2(Y * 0.5) * X = log2(Y) * X - X

define float @log2half(float %x, float %y) {
; CHECK-LABEL: @log2half(
; CHECK-NEXT:    [[LOG2:%.*]] = call fast float @llvm.log2.f32(float [[Y:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[LOG2]], [[X:%.*]]
; CHECK-NEXT:    [[MUL:%.*]] = fsub fast float [[TMP1]], [[X]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %halfy = fmul float %y, 0.5
  %log2 = call float @llvm.log2.f32(float %halfy)
  %mul = fmul fast float %log2, %x
  ret float %mul
}

define float @log2half_commute(float %x1, float %y) {
; CHECK-LABEL: @log2half_commute(
; CHECK-NEXT:    [[X:%.*]] = fdiv float [[X1:%.*]], 7.000000e+00
; CHECK-NEXT:    [[LOG2:%.*]] = call fast float @llvm.log2.f32(float [[Y:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = fmul fast float [[LOG2]], [[X]]
; CHECK-NEXT:    [[MUL:%.*]] = fsub fast float [[TMP1]], [[X]]
; CHECK-NEXT:    ret float [[MUL]]
;
  %x = fdiv float %x1, 7.0 ; thwart complexity-based canonicalization
  %halfy = fmul float %y, 0.5
  %log2 = call float @llvm.log2.f32(float %halfy)
  %mul = fmul fast float %x, %log2
  ret float %mul
}

