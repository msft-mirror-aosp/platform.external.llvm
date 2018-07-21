; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mips -mcpu=mips32 -relocation-model=pic \
; RUN:   < %s 2>&1 | FileCheck %s --check-prefix=32
; RUN: llc -mtriple=mips -mcpu=mips32 -relocation-model=pic -mattr=+micromips \
; RUN:   < %s 2>&1 | FileCheck %s --check-prefix=MM
; RUN: llc -mtriple=mips64 -mcpu=mips64 -relocation-model=pic \
; RUN:   < %s 2>&1 | FileCheck %s --check-prefix=64

@x = global i32 0
@a = global i32 0
@b = global i32 0

define void @foo() {
; 32-LABEL: foo:
; 32:       # %bb.0: # %entry
; 32-NEXT:    lui $2, %hi(_gp_disp)
; 32-NEXT:    addiu $2, $2, %lo(_gp_disp)
; 32-NEXT:    addu $1, $2, $25
; 32-NEXT:    lw $2, %got(x)($1)
; 32-NEXT:    lw $3, 0($2)
; 32-NEXT:    addiu $4, $1, %got(b)
; 32-NEXT:    addiu $1, $1, %got(a)
; 32-NEXT:    movz $4, $1, $3
; 32-NEXT:    lw $1, 0($4)
; 32-NEXT:    lw $1, 0($1)
; 32-NEXT:    jr $ra
; 32-NEXT:    sw $1, 0($2)
;
; MM-LABEL: foo:
; MM:       # %bb.0: # %entry
; MM-NEXT:    lui $2, %hi(_gp_disp)
; MM-NEXT:    addiu $2, $2, %lo(_gp_disp)
; MM-NEXT:    addu $2, $2, $25
; MM-NEXT:    lw $3, %got(x)($2)
; MM-NEXT:    lw16 $4, 0($3)
; MM-NEXT:    addiu $5, $2, %got(b)
; MM-NEXT:    addiu $1, $2, %got(a)
; MM-NEXT:    movz $5, $1, $4
; MM-NEXT:    lw16 $2, 0($5)
; MM-NEXT:    lw16 $2, 0($2)
; MM-NEXT:    sw16 $2, 0($3)
; MM-NEXT:    jrc $ra
;
; 64-LABEL: foo:
; 64:       # %bb.0: # %entry
; 64-NEXT:    lui $1, %hi(%neg(%gp_rel(foo)))
; 64-NEXT:    daddu $1, $1, $25
; 64-NEXT:    daddiu $1, $1, %lo(%neg(%gp_rel(foo)))
; 64-NEXT:    ld $2, %got_disp(x)($1)
; 64-NEXT:    lw $3, 0($2)
; 64-NEXT:    daddiu $4, $1, %got_disp(b)
; 64-NEXT:    daddiu $1, $1, %got_disp(a)
; 64-NEXT:    movz $4, $1, $3
; 64-NEXT:    ld $1, 0($4)
; 64-NEXT:    lw $1, 0($1)
; 64-NEXT:    jr $ra
; 64-NEXT:    sw $1, 0($2)
entry:
  %0 = load i32, i32* @x, align 4
  %cmp2 = icmp eq i32 %0, 0
  %1 = load i32, i32* @a, align 4
  %2 = load i32, i32* @b, align 4
  %cond = select i1 %cmp2, i32 %1, i32 %2
  store i32 %cond, i32* @x, align 4
  ret void
}
