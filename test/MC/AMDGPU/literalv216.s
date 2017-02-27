// RUN: llvm-mc -arch=amdgcn -mcpu=gfx901 -show-encoding %s | FileCheck -check-prefix=GFX9 %s

v_pk_add_f16 v1, 0, v2
// GFX9: v_pk_add_f16 v1, 0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x80,0x04,0x02,0x18]

v_pk_add_f16 v1, 0.0, v2
// GFX9: v_pk_add_f16 v1, 0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x80,0x04,0x02,0x18]

v_pk_add_f16 v1, v2, 0
// GFX9: v_pk_add_f16 v1, v2, 0 ; encoding: [0x01,0x00,0x8f,0xd3,0x02,0x01,0x01,0x18]

v_pk_add_f16 v1, v2, 0.0
// GFX9: v_pk_add_f16 v1, v2, 0 ; encoding: [0x01,0x00,0x8f,0xd3,0x02,0x01,0x01,0x18]

v_pk_add_f16 v1, 1.0, v2
// GFX9: v_pk_add_f16 v1, 1.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf2,0x04,0x02,0x18]

v_pk_add_f16 v1, -1.0, v2
// GFX9: v_pk_add_f16 v1, -1.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf3,0x04,0x02,0x18]

v_pk_add_f16 v1, -0.5, v2
// GFX9: v_pk_add_f16 v1, -0.5, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf1,0x04,0x02,0x18]

v_pk_add_f16 v1, 0.5, v2
// GFX9: v_pk_add_f16 v1, 0.5, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf0,0x04,0x02,0x18]

v_pk_add_f16 v1, 2.0, v2
// GFX9: v_pk_add_f16 v1, 2.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf4,0x04,0x02,0x18]

v_pk_add_f16 v1, -2.0, v2
// GFX9: v_pk_add_f16 v1, -2.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf5,0x04,0x02,0x18]

v_pk_add_f16 v1, 4.0, v2
// GFX9: v_pk_add_f16 v1, 4.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf6,0x04,0x02,0x18]

v_pk_add_f16 v1, -4.0, v2
// GFX9: v_pk_add_f16 v1, -4.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf7,0x04,0x02,0x18]

v_pk_add_f16 v1, 0.15915494, v2
// GFX9: v_pk_add_f16 v1, 0.15915494, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf8,0x04,0x02,0x18]

v_pk_add_f16 v1, -1, v2
// GFX9: v_pk_add_f16 v1, -1, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xc1,0x04,0x02,0x18]

v_pk_add_f16 v1, -2, v2
// GFX9: v_pk_add_f16 v1, -2, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xc2,0x04,0x02,0x18]

v_pk_add_f16 v1, -3, v2
// GFX9: v_pk_add_f16 v1, -3, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xc3,0x04,0x02,0x18]

v_pk_add_f16 v1, -16, v2
// GFX9: v_pk_add_f16 v1, -16, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xd0,0x04,0x02,0x18]

v_pk_add_f16 v1, 1, v2
// GFX9: v_pk_add_f16 v1, 1, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x81,0x04,0x02,0x18]

v_pk_add_f16 v1, 2, v2
// GFX9: v_pk_add_f16 v1, 2, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x82,0x04,0x02,0x18]

v_pk_add_f16 v1, 3, v2
// GFX9: v_pk_add_f16 v1, 3, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x83,0x04,0x02,0x18]

v_pk_add_f16 v1, 4, v2
// GFX9: v_pk_add_f16 v1, 4, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x84,0x04,0x02,0x18]

v_pk_add_f16 v1, 15, v2
// GFX9: v_pk_add_f16 v1, 15, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x8f,0x04,0x02,0x18]

v_pk_add_f16 v1, 16, v2
// GFX9: v_pk_add_f16 v1, 16, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x90,0x04,0x02,0x18]

v_pk_add_f16 v1, 63, v2
// GFX9: v_pk_add_f16 v1, 63, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xbf,0x04,0x02,0x18]

v_pk_add_f16 v1, 64, v2
// GFX9: v_pk_add_f16 v1, 64, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xc0,0x04,0x02,0x18]

v_pk_add_f16 v1, 0x0001, v2
// GFX9: v_pk_add_f16 v1, 1, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0x81,0x04,0x02,0x18]

v_pk_add_f16 v1, 0xffff, v2
// GFX9: v_pk_add_f16 v1, -1, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xc1,0x04,0x02,0x18]

v_pk_add_f16 v1, 0x3c00, v2
// GFX9: v_pk_add_f16 v1, 1.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf2,0x04,0x02,0x18]

v_pk_add_f16 v1, 0xbc00, v2
// GFX9: v_pk_add_f16 v1, -1.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf3,0x04,0x02,0x18]

v_pk_add_f16 v1, 0x3800, v2
// GFX9: v_pk_add_f16 v1, 0.5, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf0,0x04,0x02,0x18]

v_pk_add_f16 v1, 0xb800, v2
// GFX9: v_pk_add_f16 v1, -0.5, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf1,0x04,0x02,0x18]

v_pk_add_f16 v1, 0x4000, v2
// GFX9: v_pk_add_f16 v1, 2.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf4,0x04,0x02,0x18]

v_pk_add_f16 v1, 0xc000, v2
// GFX9: v_pk_add_f16 v1, -2.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf5,0x04,0x02,0x18]

v_pk_add_f16 v1, 0x4400, v2
// GFX9: v_pk_add_f16 v1, 4.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf6,0x04,0x02,0x18]

v_pk_add_f16 v1, 0xc400, v2
// GFX9: v_pk_add_f16 v1, -4.0, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf7,0x04,0x02,0x18]

v_pk_add_f16 v1, 0x3118, v2
// GFX9: v_pk_add_f16 v1, 0.15915494, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xf8,0x04,0x02,0x18]

v_pk_add_f16 v1, 65535, v2
// GFX9: v_pk_add_f16 v1, -1, v2 ; encoding: [0x01,0x00,0x8f,0xd3,0xc1,0x04,0x02,0x18]
