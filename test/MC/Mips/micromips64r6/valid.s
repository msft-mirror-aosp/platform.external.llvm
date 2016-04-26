# RUN: llvm-mc %s -triple=mips-unknown-linux -show-encoding -mcpu=mips64r6 -mattr=micromips | FileCheck %s
a:
        .set noat
        addiur1sp $7, 4          # CHECK: addiur1sp $7, 4     # encoding: [0x6f,0x83]
        addiur2 $6, $7, -1       # CHECK: addiur2 $6, $7, -1  # encoding: [0x6f,0x7e]
        addiur2 $6, $7, 12       # CHECK: addiur2 $6, $7, 12  # encoding: [0x6f,0x76]
        addius5 $7, -2           # CHECK: addius5 $7, -2      # encoding: [0x4c,0xfc]
        addiusp -1028            # CHECK: addiusp -1028       # encoding: [0x4f,0xff]
        addiusp -1032            # CHECK: addiusp -1032       # encoding: [0x4f,0xfd]
        addiusp 1024             # CHECK: addiusp 1024        # encoding: [0x4c,0x01]
        addiusp 1028             # CHECK: addiusp 1028        # encoding: [0x4c,0x03]
        addiusp -16              # CHECK: addiusp -16         # encoding: [0x4f,0xf9]
        b 132                    # CHECK: bc16 132            # encoding: [0xcc,0x42]
        bc16 132                 # CHECK: bc16 132            # encoding: [0xcc,0x42]
        beqzc16 $6, 20           # CHECK: beqzc16 $6, 20      # encoding: [0x8f,0x0a]
        bnezc16 $6, 20           # CHECK: bnezc16 $6, 20      # encoding: [0xaf,0x0a]
        daui $3, $4, 5           # CHECK: daui $3, $4, 5      # encoding: [0xf0,0x64,0x00,0x05]
        dahi $3, 4               # CHECK: dahi $3, 4          # encoding: [0x42,0x23,0x00,0x04]
        dati $3, 4               # CHECK: dati $3, 4          # encoding: [0x42,0x03,0x00,0x04]
        dext $9, $6, 3, 7        # CHECK: dext $9, $6, 3, 7   # encoding: [0x59,0x26,0x30,0xec]
        dextm $9, $6, 3, 39      # CHECK: dextm $9, $6, 3, 39 # encoding: [0x59,0x26,0x30,0xe4]
        dextu $9, $6, 35, 7      # CHECK: dextu $9, $6, 35, 7  # encoding: [0x59,0x26,0x30,0xd4]
        dalign $4, $2, $3, 5     # CHECK: dalign $4, $2, $3, 5  # encoding: [0x58,0x43,0x25,0x1c]
        ldpc $2, 16              # CHECK: ldpc $2, 16           # encoding: [0x78,0x58,0x00,0x02]
        lw $3, 32($gp)           # CHECK: lw $3, 32($gp)        # encoding: [0x65,0x88]
        lw $3, 24($sp)           # CHECK: lw $3, 24($sp)        # encoding: [0x48,0x66]
        lw16 $4, 8($17)          # CHECK: lw16 $4, 8($17)       # encoding: [0x6a,0x12]
        lhu16 $3, 4($16)         # CHECK: lhu16 $3, 4($16)      # encoding: [0x29,0x82]
        lbu16 $3, 4($17)         # CHECK: lbu16 $3, 4($17)      # encoding: [0x09,0x94]
        lbu16 $3, -1($17)        # CHECK: lbu16 $3, -1($17)     # encoding: [0x09,0x9f]
        movep $5, $6, $2, $3     # CHECK: movep $5, $6, $2, $3  # encoding: [0x84,0x34]
        ll $2, 8($4)                    # CHECK: ll $2, 8($4)                    # encoding: [0x60,0x44,0x30,0x08]
        lwm32 $16, $17, 8($4)           # CHECK: lwm32 $16, $17, 8($4)           # encoding: [0x20,0x44,0x50,0x08]
        lwm32 $16, $17, 8($sp)          # CHECK: lwm32 $16, $17, 8($sp)          # encoding: [0x20,0x5d,0x50,0x08]
        lwm32 $16, $17, $ra, 8($4)      # CHECK: lwm32 $16, $17, $ra, 8($4)      # encoding: [0x22,0x44,0x50,0x08]
        lwm32 $16, $17, $ra, 64($sp)    # CHECK: lwm32 $16, $17, $ra, 64($sp)    # encoding: [0x22,0x5d,0x50,0x40]
        lwm32 $16, $17, $18, $19, 8($4) # CHECK: lwm32 $16, $17, $18, $19, 8($4) # encoding: [0x20,0x84,0x50,0x08]
        lwm32 $16, $17, $18, $19, $ra, 8($4)                          # CHECK: lwm32 $16, $17, $18, $19, $ra, 8($4)                          # encoding: [0x22,0x84,0x50,0x08]
        lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)      # CHECK: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)      # encoding: [0x21,0x24,0x50,0x08]
        lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # CHECK: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # encoding: [0x23,0x24,0x50,0x08]
        lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # CHECK: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # encoding: [0x23,0x24,0x50,0x08]
        rotr $2, 7                      # CHECK: rotr $2, $2, 7                  # encoding: [0x00,0x42,0x38,0xc0]
        rotr $9, $6, 7                  # CHECK: rotr $9, $6, 7                  # encoding: [0x01,0x26,0x38,0xc0]
        rotrv $9, $6, $7                # CHECK: rotrv $9, $6, $7                # encoding: [0x00,0xc7,0x48,0xd0]
        sc $2, 8($4)                    # CHECK: sc $2, 8($4)                    # encoding: [0x60,0x44,0xb0,0x08]
        swm32 $16, $17, 8($4)           # CHECK: swm32 $16, $17, 8($4)           # encoding: [0x20,0x44,0xd0,0x08]
        swm32 $16, $17, 8($sp)          # CHECK: swm32 $16, $17, 8($sp)          # encoding: [0x20,0x5d,0xd0,0x08]
        swm32 $16, $17, $ra, 8($4)      # CHECK: swm32 $16, $17, $ra, 8($4)      # encoding: [0x22,0x44,0xd0,0x08]
        swm32 $16, $17, $ra, 64($sp)    # CHECK: swm32 $16, $17, $ra, 64($sp)    # encoding: [0x22,0x5d,0xd0,0x40]
        swm32 $16, $17, $18, $19, 8($4) # CHECK: swm32 $16, $17, $18, $19, 8($4) # encoding: [0x20,0x84,0xd0,0x08]
        syscall                         # CHECK: syscall                         # encoding: [0x00,0x00,0x8b,0x7c]
        syscall 396                     # CHECK: syscall 396                     # encoding: [0x01,0x8c,0x8b,0x7c]
        ddiv $3, $4, $5          # CHECK: ddiv $3, $4, $5     # encoding: [0x58,0xa4,0x19,0x18]
        dmod $3, $4, $5          # CHECK: dmod $3, $4, $5     # encoding: [0x58,0xa4,0x19,0x58]
        ddivu $3, $4, $5         # CHECK: ddivu $3, $4, $5    # encoding: [0x58,0xa4,0x19,0x98]
        dmodu $3, $4, $5         # CHECK: dmodu $3, $4, $5    # encoding: [0x58,0xa4,0x19,0xd8]
        add.s $f3, $f4, $f5      # CHECK: add.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0x30]
        add.d $f2, $f4, $f6      # CHECK: add.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0x30]
        sub.s $f3, $f4, $f5      # CHECK: sub.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0x70]
        sub.d $f2, $f4, $f6      # CHECK: sub.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0x70]
        mul.s $f3, $f4, $f5      # CHECK: mul.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0xb0]
        mul.d $f2, $f4, $f6      # CHECK: mul.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0xb0]
        div.s $f3, $f4, $f5      # CHECK: div.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0xf0]
        div.d $f2, $f4, $f6      # CHECK: div.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0xf0]
        maddf.s $f3, $f4, $f5    # CHECK: maddf.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x19,0xb8]
        maddf.d $f3, $f4, $f5    # CHECK: maddf.d $f3, $f4, $f5 # encoding: [0x54,0xa4,0x1b,0xb8]
        msubf.s $f3, $f4, $f5    # CHECK: msubf.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x19,0xf8]
        msubf.d $f3, $f4, $f5    # CHECK: msubf.d $f3, $f4, $f5 # encoding: [0x54,0xa4,0x1b,0xf8]
        mov.s $f6, $f7           # CHECK: mov.s $f6, $f7      # encoding: [0x54,0xc7,0x00,0x7b]
        mov.d $f4, $f6           # CHECK: mov.d $f4, $f6      # encoding: [0x54,0x86,0x20,0x7b]
        neg.s $f6, $f7           # CHECK: neg.s $f6, $f7      # encoding: [0x54,0xc7,0x0b,0x7b]
        neg.d $f4, $f6           # CHECK: neg.d $f4, $f6      # encoding: [0x54,0x86,0x2b,0x7b]
        max.s $f5, $f4, $f3      # CHECK: max.s $f5, $f4, $f3      # encoding: [0x54,0x64,0x28,0x0b]
        max.d $f5, $f4, $f3      # CHECK: max.d $f5, $f4, $f3      # encoding: [0x54,0x64,0x2a,0x0b]
        maxa.s $f5, $f4, $f3     # CHECK: maxa.s $f5, $f4, $f3     # encoding: [0x54,0x64,0x28,0x2b]
        maxa.d $f5, $f4, $f3     # CHECK: maxa.d $f5, $f4, $f3     # encoding: [0x54,0x64,0x2a,0x2b]
        min.s $f5, $f4, $f3      # CHECK: min.s $f5, $f4, $f3      # encoding: [0x54,0x64,0x28,0x03]
        min.d $f5, $f4, $f3      # CHECK: min.d $f5, $f4, $f3      # encoding: [0x54,0x64,0x2a,0x03]
        mina.s $f5, $f4, $f3     # CHECK: mina.s $f5, $f4, $f3     # encoding: [0x54,0x64,0x28,0x23]
        mina.d $f5, $f4, $f3     # CHECK: mina.d $f5, $f4, $f3     # encoding: [0x54,0x64,0x2a,0x23]
        cmp.af.s $f2, $f3, $f4   # CHECK: cmp.af.s $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x05]
        cmp.af.d $f2, $f3, $f4   # CHECK: cmp.af.d $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x15]
        cmp.un.s $f2, $f3, $f4   # CHECK: cmp.un.s $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x45]
        cmp.un.d $f2, $f3, $f4   # CHECK: cmp.un.d $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x55]
        cmp.eq.s $f2, $f3, $f4   # CHECK: cmp.eq.s $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x85]
        cmp.eq.d $f2, $f3, $f4   # CHECK: cmp.eq.d $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x95]
        cmp.ueq.s $f2, $f3, $f4  # CHECK: cmp.ueq.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x10,0xc5]
        cmp.ueq.d $f2, $f3, $f4  # CHECK: cmp.ueq.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x10,0xd5]
        cmp.lt.s $f2, $f3, $f4   # CHECK: cmp.lt.s  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x05]
        cmp.lt.d $f2, $f3, $f4   # CHECK: cmp.lt.d  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x15]
        cmp.ult.s $f2, $f3, $f4  # CHECK: cmp.ult.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x45]
        cmp.ult.d $f2, $f3, $f4  # CHECK: cmp.ult.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x55]
        cmp.le.s $f2, $f3, $f4   # CHECK: cmp.le.s  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x85]
        cmp.le.d $f2, $f3, $f4   # CHECK: cmp.le.d  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x95]
        cmp.ule.s $f2, $f3, $f4  # CHECK: cmp.ule.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0xc5]
        cmp.ule.d $f2, $f3, $f4  # CHECK: cmp.ule.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0xd5]
        cmp.saf.s $f2, $f3, $f4  # CHECK: cmp.saf.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x05]
        cmp.saf.d $f2, $f3, $f4  # CHECK: cmp.saf.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x15]
        cmp.sun.s $f2, $f3, $f4  # CHECK: cmp.sun.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x45]
        cmp.sun.d $f2, $f3, $f4  # CHECK: cmp.sun.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x55]
        cmp.seq.s $f2, $f3, $f4  # CHECK: cmp.seq.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x85]
        cmp.seq.d $f2, $f3, $f4  # CHECK: cmp.seq.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x95]
        cmp.sueq.s $f2, $f3, $f4 # CHECK: cmp.sueq.s $f2, $f3, $f4 # encoding: [0x54,0x83,0x12,0xc5]
        cmp.sueq.d $f2, $f3, $f4 # CHECK: cmp.sueq.d $f2, $f3, $f4 # encoding: [0x54,0x83,0x12,0xd5]
        cmp.slt.s $f2, $f3, $f4  # CHECK: cmp.slt.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x05]
        cmp.slt.d $f2, $f3, $f4  # CHECK: cmp.slt.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x15]
        cmp.sult.s $f2, $f3, $f4 # CHECK: cmp.sult.s $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0x45]
        cmp.sult.d $f2, $f3, $f4 # CHECK: cmp.sult.d $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0x55]
        cmp.sle.s $f2, $f3, $f4  # CHECK: cmp.sle.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x85]
        cmp.sle.d $f2, $f3, $f4  # CHECK: cmp.sle.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x95]
        cmp.sule.s $f2, $f3, $f4 # CHECK: cmp.sule.s $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0xc5]
        cmp.sule.d $f2, $f3, $f4 # CHECK: cmp.sule.d $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0xd5]
        cvt.l.s $f3, $f4         # CHECK: cvt.l.s $f3, $f4         # encoding: [0x54,0x64,0x01,0x3b]
        cvt.l.d $f3, $f4         # CHECK: cvt.l.d $f3, $f4         # encoding: [0x54,0x64,0x41,0x3b]
        cvt.w.s $f3, $f4         # CHECK: cvt.w.s $f3, $f4         # encoding: [0x54,0x64,0x09,0x3b]
        cvt.w.d $f3, $f4         # CHECK: cvt.w.d $f3, $f4         # encoding: [0x54,0x64,0x49,0x3b]
        cvt.d.s $f2, $f4         # CHECK: cvt.d.s $f2, $f4         # encoding: [0x54,0x44,0x13,0x7b]
        cvt.d.w $f2, $f4         # CHECK: cvt.d.w $f2, $f4         # encoding: [0x54,0x44,0x33,0x7b]
        cvt.d.l $f2, $f4         # CHECK: cvt.d.l $f2, $f4         # encoding: [0x54,0x44,0x53,0x7b]
        cvt.s.d $f2, $f4         # CHECK: cvt.s.d $f2, $f4         # encoding: [0x54,0x44,0x1b,0x7b]
        cvt.s.w $f3, $f4         # CHECK: cvt.s.w $f3, $f4         # encoding: [0x54,0x64,0x3b,0x7b]
        cvt.s.l $f3, $f4         # CHECK: cvt.s.l $f3, $f4         # encoding: [0x54,0x64,0x5b,0x7b]
        teq $8, $9               # CHECK: teq $8, $9          # encoding: [0x01,0x28,0x00,0x3c]
        teq $5, $7, 15           # CHECK: teq $5, $7, 15      # encoding: [0x00,0xe5,0xf0,0x3c]
        tge $7, $10              # CHECK: tge $7, $10         # encoding: [0x01,0x47,0x02,0x3c]
        tge $7, $19, 15          # CHECK: tge $7, $19, 15     # encoding: [0x02,0x67,0xf2,0x3c]
        tgeu $22, $gp            # CHECK: tgeu $22, $gp       # encoding: [0x03,0x96,0x04,0x3c]
        tgeu $20, $14, 15        # CHECK: tgeu $20, $14, 15   # encoding: [0x01,0xd4,0xf4,0x3c]
        tlt $15, $13             # CHECK: tlt $15, $13        # encoding: [0x01,0xaf,0x08,0x3c]
        tlt $2, $19, 15          # CHECK: tlt $2, $19, 15     # encoding: [0x02,0x62,0xf8,0x3c]
        tltu $11, $16            # CHECK: tltu $11, $16       # encoding: [0x02,0x0b,0x0a,0x3c]
        tltu $16, $sp, 15        # CHECK: tltu $16, $sp, 15   # encoding: [0x03,0xb0,0xfa,0x3c]
        tne $6, $17              # CHECK: tne $6, $17         # encoding: [0x02,0x26,0x0c,0x3c]
        tne $7, $8, 15           # CHECK: tne $7, $8, 15      # encoding: [0x01,0x07,0xfc,0x3c]
        cachee 1, 8($5)          # CHECK: cachee 1, 8($5)     # encoding: [0x60,0x25,0xa6,0x08]
        wrpgpr $3, $4            # CHECK: wrpgpr $3, $4       # encoding: [0x00,0x64,0xf1,0x7c]
        wsbh $3, $4              # CHECK: wsbh $3, $4         # encoding: [0x00,0x64,0x7b,0x3c]
        jalr $9                  # CHECK: jalr $9             # encoding: [0x45,0x2b]
        jrc16 $9                 # CHECK: jrc16 $9            # encoding: [0x45,0x23]
        jrcaddiusp 20            # CHECK: jrcaddiusp 20       # encoding: [0x44,0xb3]
        break16 8                # CHECK: break16 8                # encoding: [0x46,0x1b]
        li16 $3, -1              # CHECK: li16 $3, -1              # encoding: [0xed,0xff]
        move16 $3, $5            # CHECK: move16 $3, $5            # encoding: [0x0c,0x65]
        sdbbp16 8                # CHECK: sdbbp16 8                # encoding: [0x46,0x3b]
        subu16 $5, $16, $3       # CHECK: subu16 $5, $16, $3       # encoding: [0x04,0x3b]
        xor16 $17, $5            # CHECK: xor16 $17, $5            # encoding: [0x44,0xd8]
        lwm $16, $17, $ra, 8($sp)   # CHECK: lwm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x22]
        lwm16 $16, $17, $ra, 8($sp) # CHECK: lwm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x22]
        sb16 $3, 4($16)          # CHECK: sb16 $3, 4($16)     # encoding: [0x89,0x84]
        sh16 $4, 8($17)          # CHECK: sh16 $4, 8($17)     # encoding: [0xaa,0x14]
        sw $4, 124($sp)          # CHECK: sw $4, 124($sp)     # encoding: [0xc8,0x9f]
        sw16 $4, 4($17)          # CHECK: sw16 $4, 4($17)     # encoding: [0xea,0x11]
        sw16 $0, 4($17)          # CHECK: sw16 $zero, 4($17)  # encoding: [0xe8,0x11]
        swm $16, $17, $ra, 8($sp)   # CHECK: swm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x2a]
        swm16 $16, $17, $ra, 8($sp) # CHECK: swm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x2a]
        recip.s $f2, $f4         # CHECK: recip.s $f2, $f4    # encoding: [0x54,0x44,0x12,0x3b]
        recip.d $f2, $f4         # CHECK: recip.d $f2, $f4    # encoding: [0x54,0x44,0x52,0x3b]
        rint.s $f2, $f4          # CHECK: rint.s $f2, $f4     # encoding: [0x54,0x82,0x00,0x20]
        rint.d $f2, $f4          # CHECK: rint.d $f2, $f4     # encoding: [0x54,0x82,0x02,0x20]
        round.l.s $f2, $f4       # CHECK: round.l.s $f2, $f4  # encoding: [0x54,0x44,0x33,0x3b]
        round.l.d $f2, $f4       # CHECK: round.l.d $f2, $f4  # encoding: [0x54,0x44,0x73,0x3b]
        round.w.s $f2, $f4       # CHECK: round.w.s $f2, $f4  # encoding: [0x54,0x44,0x3b,0x3b]
        round.w.d $f2, $f4       # CHECK: round.w.d $f2, $f4  # encoding: [0x54,0x44,0x7b,0x3b]
        sel.s $f1, $f1, $f2      # CHECK: sel.s $f1, $f1, $f2 # encoding: [0x54,0x41,0x08,0xb8]
        sel.d $f0, $f2, $f4      # CHECK: sel.d $f0, $f2, $f4 # encoding: [0x54,0x82,0x02,0xb8]
        seleqz.s $f1, $f2, $f3   # CHECK: seleqz.s $f1, $f2, $f3  # encoding: [0x54,0x62,0x08,0x38]
        seleqz.d $f2, $f4, $f8   # CHECK: seleqz.d $f2, $f4, $f8  # encoding: [0x55,0x04,0x12,0x38]
        selnez.s $f1, $f2, $f3   # CHECK: selnez.s $f1, $f2, $f3  # encoding: [0x54,0x62,0x08,0x78]
        selnez.d $f2, $f4, $f8   # CHECK: selnez.d $f2, $f4, $f8  # encoding: [0x55,0x04,0x12,0x78]
        class.s $f2, $f3         # CHECK: class.s $f2, $f3        # encoding: [0x54,0x62,0x00,0x60]
        class.d $f2, $f4         # CHECK: class.d $f2, $f4        # encoding: [0x54,0x82,0x02,0x60]
        deret                    # CHECK: deret                   # encoding: [0x00,0x00,0xe3,0x7c]
        di                       # CHECK: di                      # encoding: [0x00,0x00,0x47,0x7c]
        di $0                    # CHECK: di                      # encoding: [0x00,0x00,0x47,0x7c]
        di $15                   # CHECK: di $15                  # encoding: [0x00,0x0f,0x47,0x7c]
        ceil.l.s $f1, $f3        # CHECK: ceil.l.s $f1, $f3       # encoding: [0x54,0x23,0x13,0x3b]
        ceil.l.d $f1, $f3        # CHECK: ceil.l.d $f1, $f3       # encoding: [0x54,0x23,0x53,0x3b]
        floor.l.s $f1, $f3       # CHECK: floor.l.s $f1, $f3      # encoding: [0x54,0x23,0x03,0x3b]
        floor.l.d $f1, $f3       # CHECK: floor.l.d $f1, $f3      # encoding: [0x54,0x23,0x43,0x3b]
        tlbinv                   # CHECK: tlbinv                  # encoding: [0x00,0x00,0x43,0x7c]
        tlbinvf                  # CHECK: tlbinvf                 # encoding: [0x00,0x00,0x53,0x7c]
        dinsu $4, $2, 32, 5      # CHECK: dinsu $4, $2, 32, 5     # encoding: [0x58,0x82,0x20,0x34]
        dinsm $4, $2, 3, 5       # CHECK: dinsm $4, $2, 3, 5      # encoding: [0x58,0x82,0x38,0xc4]
        dins $4, $2, 3, 5        # CHECK: dins $4, $2, 3, 5       # encoding: [0x58,0x82,0x38,0xcc]
        mtc0 $5, $9              # CHECK: mtc0 $5, $9, 0          # encoding: [0x00,0xa9,0x02,0xfc]
        mtc0 $1, $2, 7           # CHECK: mtc0 $1, $2, 7          # encoding: [0x00,0x22,0x3a,0xfc]
        mtc1 $3, $f4             # CHECK: mtc1 $3, $f4            # encoding: [0x54,0x64,0x28,0x3b]
        mtc2 $5, $6              # CHECK: mtc2 $5, $6             # encoding: [0x00,0xa6,0x5d,0x3c]
        mthc0 $7, $8             # CHECK: mthc0 $7, $8, 0         # encoding: [0x00,0xe8,0x02,0xf4]
        mthc0 $9, $10, 1         # CHECK: mthc0 $9, $10, 1        # encoding: [0x01,0x2a,0x0a,0xf4]
        mthc1 $11, $f12          # CHECK: mthc1 $11, $f12         # encoding: [0x55,0x6c,0x38,0x3b]
        mthc2 $13, $14           # CHECK: mthc2 $13, $14          # encoding: [0x01,0xae,0x9d,0x3c]
        dmtc0 $15, $16           # CHECK: dmtc0 $15, $16, 0       # encoding: [0x59,0xf0,0x02,0xfc]
        dmtc0 $17, $18, 5        # CHECK: dmtc0 $17, $18, 5       # encoding: [0x5a,0x32,0x2a,0xfc]
        dmtc1 $19, $f20          # CHECK: dmtc1 $19, $f20         # encoding: [0x56,0x74,0x2c,0x3b]
        dmtc2 $21, $22           # CHECK: dmtc2 $21, $22          # encoding: [0x02,0xb6,0x7d,0x3c]
        dmfc0 $18, $17           # CHECK: dmfc0 $18, $17, 0       # encoding: [0x5a,0x51,0x00,0xfc]
        dmfc0 $9, $1, 1          # CHECK: dmfc0 $9, $1, 1         # encoding: [0x59,0x21,0x08,0xfc]
        dmfc1 $9, $f4            # CHECK: dmfc1 $9, $f4           # encoding: [0x55,0x24,0x24,0x3b]
        dmfc2 $14, $18           # CHECK: dmfc2 $14, $18          # encoding: [0x01,0xd2,0x6d,0x3c]
        dadd $9, $6, $7          # CHECK: dadd $9, $6, $7         # encoding: [0x58,0xe6,0x49,0x10]
        dadd $s3, $at, $ra       # CHECK: dadd $19, $1, $ra       # encoding: [0x5b,0xe1,0x99,0x10]
        daddiu $24, $2, 18079    # CHECK: daddiu $24, $2, 18079   # encoding: [0x5f,0x02,0x46,0x9f]
        daddiu $9, $6, -15001    # CHECK: daddiu $9, $6, -15001   # encoding: [0x5d,0x26,0xc5,0x67]
        daddiu $9, -15001        # CHECK: daddiu $9, $9, -15001   # encoding: [0x5d,0x29,0xc5,0x67]
        daddiu $9, $3, 8 * 4     # CHECK: daddiu $9, $3, 32       # encoding: [0x5d,0x23,0x00,0x20]
        daddiu $9, $3, (8 * 4)   # CHECK: daddiu $9, $3, 32       # encoding: [0x5d,0x23,0x00,0x20]
        daddiu $k0, $s6, -4586   # CHECK: daddiu $26, $22, -4586  # encoding: [0x5f,0x56,0xee,0x16]
        daddiu $15, $11, -5025   # CHECK: daddiu $15, $11, -5025  # encoding: [0x5d,0xeb,0xec,0x5f]
        daddiu $14, $14, 4586    # CHECK: daddiu $14, $14, 4586   # encoding: [0x5d,0xce,0x11,0xea]
        daddiu $19, $19, 26943   # CHECK: daddiu $19, $19, 26943  # encoding: [0x5e,0x73,0x69,0x3f]
        daddiu $11, $26, 31949   # CHECK: daddiu $11, $26, 31949  # encoding: [0x5d,0x7a,0x7c,0xcd]
        daddiu $sp, $sp, -32     # CHECK: daddiu $sp, $sp, -32    # encoding: [0x5f,0xbd,0xff,0xe0]
        daddu $26, $1, $11       # CHECK: daddu $26, $1, $11      # encoding: [0x59,0x61,0xd1,0x50]
        daddu $19, $1, $ra       # CHECK: daddu $19, $1, $ra      # encoding: [0x5b,0xe1,0x99,0x50]
        daddu $9, $6, $7         # CHECK: daddu $9, $6, $7        # encoding: [0x58,0xe6,0x49,0x50]
        daddu $9, $3             # CHECK: daddu $9, $9, $3        # encoding: [0x58,0x69,0x49,0x50]
        daddu $9, $6, -15001     # CHECK: daddiu $9, $6, -15001   # encoding: [0x5d,0x26,0xc5,0x67]
        daddu $9, 10             # CHECK: daddiu $9, $9, 10       # encoding: [0x5d,0x29,0x00,0x0a]
        daddu $19, 26943         # CHECK: daddiu $19, $19, 26943  # encoding: [0x5e,0x73,0x69,0x3f]
        daddu $24, $2, 18079     # CHECK: daddiu $24, $2, 18079   # encoding: [0x5f,0x02,0x46,0x9f]
        dsubu $3, 5              # CHECK: daddiu $3, $3, -5       # encoding: [0x5c,0x63,0xff,0xfb]
        dsubu $3, $4, 5          # CHECK: daddiu $3, $4, -5       # encoding: [0x5c,0x64,0xff,0xfb]
        tlbp                     # CHECK: tlbp                    # encoding: [0x00,0x00,0x03,0x7c]
        tlbr                     # CHECK: tlbr                    # encoding: [0x00,0x00,0x13,0x7c]
        tlbwi                    # CHECK: tlbwi                   # encoding: [0x00,0x00,0x23,0x7c]
        tlbwr                    # CHECK: tlbwr                   # encoding: [0x00,0x00,0x33,0x7c]
        dvp                      # CHECK: dvp $zero               # encoding: [0x00,0x00,0x19,0x7c]
        dvp $4                   # CHECK: dvp $4                  # encoding: [0x00,0x04,0x19,0x7c]
        evp                      # CHECK: evp $zero               # encoding: [0x00,0x00,0x39,0x7c]
        evp $4                   # CHECK: evp $4                  # encoding: [0x00,0x04,0x39,0x7c]
        jalrc.hb $4              # CHECK: jalrc.hb $4             # encoding: [0x03,0xe4,0x1f,0x3c]
        jalrc.hb $4, $5          # CHECK: jalrc.hb $4, $5         # encoding: [0x00,0x85,0x1f,0x3c]

1:
