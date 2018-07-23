# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=znver1 -iterations=1500 -timeline -timeline-max-iterations=7 < %s | FileCheck %s

# The lzcnt cannot execute in parallel with the imul because there is a false
# dependency on %bx.

imul %ax, %bx
lzcnt %ax, %bx
add %cx, %bx

# CHECK:      Iterations:        1500
# CHECK-NEXT: Instructions:      4500
# CHECK-NEXT: Total Cycles:      1507
# CHECK-NEXT: Dispatch Width:    4
# CHECK-NEXT: IPC:               2.99
# CHECK-NEXT: Block RThroughput: 1.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        imulw	%ax, %bx
# CHECK-NEXT:  1      2     0.25                        lzcntw	%ax, %bx
# CHECK-NEXT:  1      1     0.25                        addw	%cx, %bx

# CHECK:      Resources:
# CHECK-NEXT: [0]   - ZnAGU0
# CHECK-NEXT: [1]   - ZnAGU1
# CHECK-NEXT: [2]   - ZnALU0
# CHECK-NEXT: [3]   - ZnALU1
# CHECK-NEXT: [4]   - ZnALU2
# CHECK-NEXT: [5]   - ZnALU3
# CHECK-NEXT: [6]   - ZnDivider
# CHECK-NEXT: [7]   - ZnFPU0
# CHECK-NEXT: [8]   - ZnFPU1
# CHECK-NEXT: [9]   - ZnFPU2
# CHECK-NEXT: [10]  - ZnFPU3
# CHECK-NEXT: [11]  - ZnMultiplier

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]
# CHECK-NEXT:  -      -     0.67   1.00   0.67   0.67    -      -      -      -      -     1.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -      -     1.00   imulw	%ax, %bx
# CHECK-NEXT:  -      -     0.33    -     0.33   0.33    -      -      -      -      -      -     lzcntw	%ax, %bx
# CHECK-NEXT:  -      -     0.33    -     0.33   0.33    -      -      -      -      -      -     addw	%cx, %bx

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeeeER    .  .   imulw	%ax, %bx
# CHECK-NEXT: [0,1]     DeeE-R    .  .   lzcntw	%ax, %bx
# CHECK-NEXT: [0,2]     D==eER    .  .   addw	%cx, %bx
# CHECK-NEXT: [1,0]     D===eeeER .  .   imulw	%ax, %bx
# CHECK-NEXT: [1,1]     .DeeE---R .  .   lzcntw	%ax, %bx
# CHECK-NEXT: [1,2]     .D==eE--R .  .   addw	%cx, %bx
# CHECK-NEXT: [2,0]     .D===eeeER.  .   imulw	%ax, %bx
# CHECK-NEXT: [2,1]     .DeeE----R.  .   lzcntw	%ax, %bx
# CHECK-NEXT: [2,2]     . D=eE---R.  .   addw	%cx, %bx
# CHECK-NEXT: [3,0]     . D===eeeER  .   imulw	%ax, %bx
# CHECK-NEXT: [3,1]     . DeeE----R  .   lzcntw	%ax, %bx
# CHECK-NEXT: [3,2]     . D==eE---R  .   addw	%cx, %bx
# CHECK-NEXT: [4,0]     .  D===eeeER .   imulw	%ax, %bx
# CHECK-NEXT: [4,1]     .  DeeE----R .   lzcntw	%ax, %bx
# CHECK-NEXT: [4,2]     .  D==eE---R .   addw	%cx, %bx
# CHECK-NEXT: [5,0]     .  D====eeeER.   imulw	%ax, %bx
# CHECK-NEXT: [5,1]     .   DeeE----R.   lzcntw	%ax, %bx
# CHECK-NEXT: [5,2]     .   D==eE---R.   addw	%cx, %bx
# CHECK-NEXT: [6,0]     .   D====eeeER   imulw	%ax, %bx
# CHECK-NEXT: [6,1]     .   DeeE-----R   lzcntw	%ax, %bx
# CHECK-NEXT: [6,2]     .    D=eE----R   addw	%cx, %bx

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     7     3.9    0.7    0.0       imulw	%ax, %bx
# CHECK-NEXT: 1.     7     1.0    1.0    3.6       lzcntw	%ax, %bx
# CHECK-NEXT: 2.     7     2.7    0.0    2.6       addw	%cx, %bx
