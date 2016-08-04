# RUN: llvm-mc -triple mips64-unknown-linux -target-abi o32 -filetype=obj -o - %s | \
# RUN:   llvm-objdump -d -r - | FileCheck -check-prefix=ALL -check-prefix=O32 %s

# RUN: llvm-mc -triple mips64-unknown-unknown -target-abi o32 %s | \
# RUN:   FileCheck -check-prefix=ALL -check-prefix=ASM %s

# RUN: llvm-mc -triple mips64-unknown-linux -target-abi n32 -filetype=obj -o - %s | \
# RUN:   llvm-objdump -d -r - | \
# RUN:   FileCheck -check-prefix=ALL -check-prefix=NXX -check-prefix=N32 %s

# RUN: llvm-mc -triple mips64-unknown-unknown -target-abi n32 %s | \
# RUN:   FileCheck -check-prefix=ALL -check-prefix=ASM %s

# RUN: llvm-mc -triple mips64-unknown-linux %s -filetype=obj -o - | \
# RUN:   llvm-objdump -d -r - | \
# RUN:   FileCheck -check-prefix=ALL -check-prefix=NXX -check-prefix=N64 %s

# RUN: llvm-mc -triple mips64-unknown-unknown %s | \
# RUN:   FileCheck -check-prefix=ALL -check-prefix=ASM %s

        .text
        .option pic2
t1:
        .cpsetup $25, 8, __cerror
        nop
        .cpreturn
        nop

# ALL-LABEL: t1:

# O32-NOT: __cerror

# NXX-NEXT: sd       $gp, 8($sp)
# NXX-NEXT: lui      $gp, 0
# N32-NEXT: R_MIPS_HI16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_HI16  __cerror
# NXX-NEXT: addiu    $gp, $gp, 0
# N32-NEXT: R_MIPS_LO16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_LO16  __cerror
# N64-NEXT: daddu    $gp, $gp, $25

# ASM-NEXT: .cpsetup $25, 8, __cerror

# ALL-NEXT: nop

# ASM-NEXT: .cpreturn
# NXX-NEXT: ld $gp, 8($sp)

# ALL-NEXT: nop

t2:
        .cpsetup $25, $2, __cerror
        nop
        .cpreturn
        nop

# ALL-LABEL: t2:

# O32-NOT: __cerror

# NXX-NEXT: move     $2, $gp
# NXX-NEXT: lui      $gp, 0
# N32-NEXT: R_MIPS_HI16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_HI16  __cerror
# NXX-NEXT: addiu    $gp, $gp, 0
# N32-NEXT: R_MIPS_LO16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_LO16  __cerror
# N64-NEXT: daddu    $gp, $gp, $25

# ASM-NEXT: .cpsetup $25, $2, __cerror

# ALL-NEXT: nop

# ASM-NEXT: .cpreturn
# NXX-NEXT: move $gp, $2

# ALL-NEXT: nop

# .cpsetup with local labels (PR22518):

# The '1:' label isn't emitted in all cases but we still want a label to match
# so we force one here.

t3:
        nop
1:
        .cpsetup $25, $2, 1b
        nop
        sub $3, $3, $2

# ALL-LABEL: t3:
# ALL-NEXT:  nop

# O32-NEXT:   nop
# O32-NEXT:   sub $3, $3, $2

# NXX-NEXT: move     $2, $gp
# NXX-NEXT: lui      $gp, 0
# N32-NEXT: {{^ *0+}}38: R_MIPS_HI16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: {{^ *0+}}40: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_HI16 .text
# NXX-NEXT: addiu    $gp, $gp, 0
# N32-NEXT: {{^ *0+}}3c: R_MIPS_LO16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: {{^ *0+}}44: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_LO16 .text
# N64-NEXT: daddu    $gp, $gp, $25
# NXX-NEXT: nop
# NXX-NEXT: sub $3, $3, $2

# ASM: $tmp0:
# ASM-NEXT: .cpsetup $25, $2, $tmp0

# Ensure we have at least one instruction between labels so that the labels
# we're matching aren't removed.
        nop
# ALL-NEXT: nop

        .option pic0
t4:
        nop
        .cpsetup $25, 8, __cerror
        nop
        .cpreturn
        nop

# Testing that .cpsetup expands to nothing in this case
# by checking that the next instruction after the first
# nop is also a 'nop'.

# ALL-LABEL: t4:

# NXX-NEXT: nop
# NXX-NEXT: nop
# NXX-NEXT: nop

# ASM-NEXT: nop
# ASM-NEXT: .cpsetup $25, 8, __cerror
# ASM-NEXT: nop
# ASM-NEXT: .cpreturn
# ASM-NEXT: nop

# Test that we accept constant expressions.
        .option pic2
t5:
        .cpsetup $25, ((8*4) - (3*8)), __cerror
        nop

# ALL-LABEL: t5:

# O32-NOT: __cerror

# NXX-NEXT: sd       $gp, 8($sp)
# NXX-NEXT: lui      $gp, 0
# N32-NEXT: R_MIPS_HI16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_HI16  __cerror
# NXX-NEXT: addiu    $gp, $gp, 0
# N32-NEXT: R_MIPS_LO16/R_MIPS_NONE/R_MIPS_NONE __gnu_local_gp
# N64-NEXT: R_MIPS_GPREL16/R_MIPS_SUB/R_MIPS_LO16  __cerror
# N64-NEXT: daddu    $gp, $gp, $25

# ASM-NEXT: .cpsetup $25, 8, __cerror

# ALL-NEXT: nop

