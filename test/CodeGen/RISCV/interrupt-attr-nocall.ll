; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple riscv32-unknown-elf -o - %s \
; RUN: 2>&1 | FileCheck %s -check-prefix CHECK-RV32
; RUN: llc -mtriple riscv32-unknown-elf -mattr=+f -o - %s \
; RUN: 2>&1 | FileCheck %s -check-prefix CHECK-RV32-F
; RUN: llc -mtriple riscv32-unknown-elf -mattr=+f,+d -o - %s \
; RUN: 2>&1 | FileCheck %s -check-prefix CHECK-RV32-FD
;
; TODO: Add RV64 tests when we can lower global addresses.

; Checking all registers that are used are being saved.
; This includes Caller (arguments and temps) and
; Callee saved registers.
;
; extern int a, b, c;
; __attribute__((interrupt)) void foo_no_call(void) {
;   c = a + b;
; }
;

@a = external global i32
@b = external global i32
@c = external global i32

define void @foo_i32() #0 {
; CHECK-RV32-LABEL: foo_i32:
; CHECK-RV32:       # %bb.0:
; CHECK-RV32-NEXT:    addi sp, sp, -16
; CHECK-RV32-NEXT:    sw a0, 12(sp)
; CHECK-RV32-NEXT:    sw a1, 8(sp)
; CHECK-RV32-NEXT:    lui a0, %hi(a)
; CHECK-RV32-NEXT:    lw a0, %lo(a)(a0)
; CHECK-RV32-NEXT:    lui a1, %hi(b)
; CHECK-RV32-NEXT:    lw a1, %lo(b)(a1)
; CHECK-RV32-NEXT:    add a0, a1, a0
; CHECK-RV32-NEXT:    lui a1, %hi(c)
; CHECK-RV32-NEXT:    sw a0, %lo(c)(a1)
; CHECK-RV32-NEXT:    lw a1, 8(sp)
; CHECK-RV32-NEXT:    lw a0, 12(sp)
; CHECK-RV32-NEXT:    addi sp, sp, 16
; CHECK-RV32-NEXT:    mret
;
  %1 = load i32, i32* @a
  %2 = load i32, i32* @b
  %add = add nsw i32 %2, %1
  store i32 %add, i32* @c
  ret void
}

;
; Additionally check frame pointer and return address are properly saved.
;

define void @foo_fp_i32() #1 {
; CHECK-RV32-LABEL: foo_fp_i32:
; CHECK-RV32:       # %bb.0:
; CHECK-RV32-NEXT:    addi sp, sp, -16
; CHECK-RV32-NEXT:    sw ra, 12(sp)
; CHECK-RV32-NEXT:    sw s0, 8(sp)
; CHECK-RV32-NEXT:    sw a0, 4(sp)
; CHECK-RV32-NEXT:    sw a1, 0(sp)
; CHECK-RV32-NEXT:    addi s0, sp, 16
; CHECK-RV32-NEXT:    lui a0, %hi(a)
; CHECK-RV32-NEXT:    lw a0, %lo(a)(a0)
; CHECK-RV32-NEXT:    lui a1, %hi(b)
; CHECK-RV32-NEXT:    lw a1, %lo(b)(a1)
; CHECK-RV32-NEXT:    add a0, a1, a0
; CHECK-RV32-NEXT:    lui a1, %hi(c)
; CHECK-RV32-NEXT:    sw a0, %lo(c)(a1)
; CHECK-RV32-NEXT:    lw a1, 0(sp)
; CHECK-RV32-NEXT:    lw a0, 4(sp)
; CHECK-RV32-NEXT:    lw s0, 8(sp)
; CHECK-RV32-NEXT:    lw ra, 12(sp)
; CHECK-RV32-NEXT:    addi sp, sp, 16
; CHECK-RV32-NEXT:    mret
;
  %1 = load i32, i32* @a
  %2 = load i32, i32* @b
  %add = add nsw i32 %2, %1
  store i32 %add, i32* @c
  ret void
}

@e = external global float
@f = external global float
@d = external global float

define void @foo_float() #0 {
; CHECK-RV32-F-LABEL: foo_float:
; CHECK-RV32-F:       # %bb.0:
; CHECK-RV32-F-NEXT:    addi sp, sp, -16
; CHECK-RV32-F-NEXT:    sw a0, 12(sp)
; CHECK-RV32-F-NEXT:    fsw ft0, 8(sp)
; CHECK-RV32-F-NEXT:    fsw ft1, 4(sp)
; CHECK-RV32-F-NEXT:    lui a0, %hi(f)
; CHECK-RV32-F-NEXT:    flw ft0, %lo(f)(a0)
; CHECK-RV32-F-NEXT:    lui a0, %hi(e)
; CHECK-RV32-F-NEXT:    flw ft1, %lo(e)(a0)
; CHECK-RV32-F-NEXT:    fadd.s ft0, ft1, ft0
; CHECK-RV32-F-NEXT:    lui a0, %hi(d)
; CHECK-RV32-F-NEXT:    fsw ft0, %lo(d)(a0)
; CHECK-RV32-F-NEXT:    flw ft1, 4(sp)
; CHECK-RV32-F-NEXT:    flw ft0, 8(sp)
; CHECK-RV32-F-NEXT:    lw a0, 12(sp)
; CHECK-RV32-F-NEXT:    addi sp, sp, 16
; CHECK-RV32-F-NEXT:    mret
;
  %1 = load float, float* @e
  %2 = load float, float* @f
  %add = fadd float %1, %2
  store float %add, float* @d
  ret void
}

;
; Additionally check frame pointer and return address are properly saved.
;
define void @foo_fp_float() #1 {
; CHECK-RV32-F-LABEL: foo_fp_float:
; CHECK-RV32-F:       # %bb.0:
; CHECK-RV32-F-NEXT:    addi sp, sp, -32
; CHECK-RV32-F-NEXT:    sw ra, 28(sp)
; CHECK-RV32-F-NEXT:    sw s0, 24(sp)
; CHECK-RV32-F-NEXT:    sw a0, 20(sp)
; CHECK-RV32-F-NEXT:    fsw ft0, 16(sp)
; CHECK-RV32-F-NEXT:    fsw ft1, 12(sp)
; CHECK-RV32-F-NEXT:    addi s0, sp, 32
; CHECK-RV32-F-NEXT:    lui a0, %hi(f)
; CHECK-RV32-F-NEXT:    flw ft0, %lo(f)(a0)
; CHECK-RV32-F-NEXT:    lui a0, %hi(e)
; CHECK-RV32-F-NEXT:    flw ft1, %lo(e)(a0)
; CHECK-RV32-F-NEXT:    fadd.s ft0, ft1, ft0
; CHECK-RV32-F-NEXT:    lui a0, %hi(d)
; CHECK-RV32-F-NEXT:    fsw ft0, %lo(d)(a0)
; CHECK-RV32-F-NEXT:    flw ft1, 12(sp)
; CHECK-RV32-F-NEXT:    flw ft0, 16(sp)
; CHECK-RV32-F-NEXT:    lw a0, 20(sp)
; CHECK-RV32-F-NEXT:    lw s0, 24(sp)
; CHECK-RV32-F-NEXT:    lw ra, 28(sp)
; CHECK-RV32-F-NEXT:    addi sp, sp, 32
; CHECK-RV32-F-NEXT:    mret
;
  %1 = load float, float* @e
  %2 = load float, float* @f
  %add = fadd float %1, %2
  store float %add, float* @d
  ret void
}

@h = external global double
@i = external global double
@g = external global double

define void @foo_double() #0 {
; CHECK-RV32-FD-LABEL: foo_double:
; CHECK-RV32-FD:       # %bb.0:
; CHECK-RV32-FD-NEXT:    addi sp, sp, -32
; CHECK-RV32-FD-NEXT:    sw a0, 28(sp)
; CHECK-RV32-FD-NEXT:    fsd ft0, 16(sp)
; CHECK-RV32-FD-NEXT:    fsd ft1, 8(sp)
; CHECK-RV32-FD-NEXT:    lui a0, %hi(i)
; CHECK-RV32-FD-NEXT:    fld ft0, %lo(i)(a0)
; CHECK-RV32-FD-NEXT:    lui a0, %hi(h)
; CHECK-RV32-FD-NEXT:    fld ft1, %lo(h)(a0)
; CHECK-RV32-FD-NEXT:    fadd.d ft0, ft1, ft0
; CHECK-RV32-FD-NEXT:    lui a0, %hi(g)
; CHECK-RV32-FD-NEXT:    fsd ft0, %lo(g)(a0)
; CHECK-RV32-FD-NEXT:    fld ft1, 8(sp)
; CHECK-RV32-FD-NEXT:    fld ft0, 16(sp)
; CHECK-RV32-FD-NEXT:    lw a0, 28(sp)
; CHECK-RV32-FD-NEXT:    addi sp, sp, 32
; CHECK-RV32-FD-NEXT:    mret
;
  %1 = load double, double* @h
  %2 = load double, double* @i
  %add = fadd double %1, %2
  store double %add, double* @g
  ret void
}

;
; Additionally check frame pointer and return address are properly saved.
;
define void @foo_fp_double() #1 {
; CHECK-RV32-FD-LABEL: foo_fp_double:
; CHECK-RV32-FD:       # %bb.0:
; CHECK-RV32-FD-NEXT:    addi sp, sp, -32
; CHECK-RV32-FD-NEXT:    sw ra, 28(sp)
; CHECK-RV32-FD-NEXT:    sw s0, 24(sp)
; CHECK-RV32-FD-NEXT:    sw a0, 20(sp)
; CHECK-RV32-FD-NEXT:    fsd ft0, 8(sp)
; CHECK-RV32-FD-NEXT:    fsd ft1, 0(sp)
; CHECK-RV32-FD-NEXT:    addi s0, sp, 32
; CHECK-RV32-FD-NEXT:    lui a0, %hi(i)
; CHECK-RV32-FD-NEXT:    fld ft0, %lo(i)(a0)
; CHECK-RV32-FD-NEXT:    lui a0, %hi(h)
; CHECK-RV32-FD-NEXT:    fld ft1, %lo(h)(a0)
; CHECK-RV32-FD-NEXT:    fadd.d ft0, ft1, ft0
; CHECK-RV32-FD-NEXT:    lui a0, %hi(g)
; CHECK-RV32-FD-NEXT:    fsd ft0, %lo(g)(a0)
; CHECK-RV32-FD-NEXT:    fld ft1, 0(sp)
; CHECK-RV32-FD-NEXT:    fld ft0, 8(sp)
; CHECK-RV32-FD-NEXT:    lw a0, 20(sp)
; CHECK-RV32-FD-NEXT:    lw s0, 24(sp)
; CHECK-RV32-FD-NEXT:    lw ra, 28(sp)
; CHECK-RV32-FD-NEXT:    addi sp, sp, 32
; CHECK-RV32-FD-NEXT:    mret
;
  %1 = load double, double* @h
  %2 = load double, double* @i
  %add = fadd double %1, %2
  store double %add, double* @g
  ret void
}

attributes #0 = { "interrupt"="machine" }
attributes #1 = { "interrupt"="machine" "no-frame-pointer-elim"="true" }
