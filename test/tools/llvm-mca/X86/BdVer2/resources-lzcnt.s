# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=bdver2 -instruction-tables < %s | FileCheck %s

lzcntw      %cx, %cx
lzcntw      (%rax), %cx

lzcntl      %eax, %ecx
lzcntl      (%rax), %ecx

lzcntq      %rax, %rcx
lzcntq      (%rax), %rcx

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  2      2     0.50                        lzcntw	%cx, %cx
# CHECK-NEXT:  2      6     0.50    *                   lzcntw	(%rax), %cx
# CHECK-NEXT:  2      2     0.50                        lzcntl	%eax, %ecx
# CHECK-NEXT:  2      6     0.50    *                   lzcntl	(%rax), %ecx
# CHECK-NEXT:  2      2     0.50                        lzcntq	%rax, %rcx
# CHECK-NEXT:  2      6     0.50    *                   lzcntq	(%rax), %rcx

# CHECK:      Resources:
# CHECK-NEXT: [0.0] - PdAGLU01
# CHECK-NEXT: [0.1] - PdAGLU01
# CHECK-NEXT: [1]   - PdBranch
# CHECK-NEXT: [2]   - PdCount
# CHECK-NEXT: [3]   - PdDiv
# CHECK-NEXT: [4]   - PdEX0
# CHECK-NEXT: [5]   - PdEX1
# CHECK-NEXT: [6]   - PdFPCVT
# CHECK-NEXT: [7.0] - PdFPFMA
# CHECK-NEXT: [7.1] - PdFPFMA
# CHECK-NEXT: [8.0] - PdFPMAL
# CHECK-NEXT: [8.1] - PdFPMAL
# CHECK-NEXT: [9]   - PdFPMMA
# CHECK-NEXT: [10]  - PdFPSTO
# CHECK-NEXT: [11]  - PdFPU0
# CHECK-NEXT: [12]  - PdFPU1
# CHECK-NEXT: [13]  - PdFPU2
# CHECK-NEXT: [14]  - PdFPU3
# CHECK-NEXT: [15]  - PdFPXBR
# CHECK-NEXT: [16.0] - PdLoad
# CHECK-NEXT: [16.1] - PdLoad
# CHECK-NEXT: [17]  - PdMul
# CHECK-NEXT: [18]  - PdStore

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]
# CHECK-NEXT: 1.50   1.50    -      -      -     3.00   3.00    -      -      -      -      -      -      -      -      -      -      -      -     1.50   1.50    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     lzcntw	%cx, %cx
# CHECK-NEXT: 0.50   0.50    -      -      -     0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     0.50   0.50    -      -     lzcntw	(%rax), %cx
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     lzcntl	%eax, %ecx
# CHECK-NEXT: 0.50   0.50    -      -      -     0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     0.50   0.50    -      -     lzcntl	(%rax), %ecx
# CHECK-NEXT:  -      -      -      -      -     0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     lzcntq	%rax, %rcx
# CHECK-NEXT: 0.50   0.50    -      -      -     0.50   0.50    -      -      -      -      -      -      -      -      -      -      -      -     0.50   0.50    -      -     lzcntq	(%rax), %rcx
