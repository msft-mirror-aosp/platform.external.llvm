; RUN: llc -march=amdgcn -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=SI -check-prefix=SIVI %s
; RUN: llc -march=amdgcn -mcpu=fiji -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=SIVI -check-prefix=VI -check-prefix=GFX89 %s
; RUN: llc -march=amdgcn -mcpu=gfx900 -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck -check-prefix=GCN -check-prefix=GFX89 -check-prefix=GFX9 %s

declare half @llvm.rint.f16(half %a)
declare <2 x half> @llvm.rint.v2f16(<2 x half> %a)

; GCN-LABEL: {{^}}rint_f16
; GCN: buffer_load_ushort v[[A_F16:[0-9]+]]
; SI:  v_cvt_f32_f16_e32 v[[A_F32:[0-9]+]], v[[A_F16]]
; SI:  v_rndne_f32_e32 v[[R_F32:[0-9]+]], v[[A_F32]]
; SI:  v_cvt_f16_f32_e32 v[[R_F16:[0-9]+]], v[[R_F32]]
; GFX89: v_rndne_f16_e32 v[[R_F16:[0-9]+]], v[[A_F16]]
; GCN: buffer_store_short v[[R_F16]]
; GCN: s_endpgm
define amdgpu_kernel void @rint_f16(
    half addrspace(1)* %r,
    half addrspace(1)* %a) {
entry:
  %a.val = load half, half addrspace(1)* %a
  %r.val = call half @llvm.rint.f16(half %a.val)
  store half %r.val, half addrspace(1)* %r
  ret void
}

; GCN-LABEL: {{^}}rint_v2f16
; GCN: buffer_load_dword v[[A_V2_F16:[0-9]+]]
; SI:  v_cvt_f32_f16_e32 v[[A_F32_0:[0-9]+]], v[[A_V2_F16]]
; SI: v_lshrrev_b32_e32 v[[A_F16_1:[0-9]+]], 16, v[[A_V2_F16]]
; SI:  v_cvt_f32_f16_e32 v[[A_F32_1:[0-9]+]], v[[A_F16_1]]
; SI:  v_rndne_f32_e32 v[[R_F32_0:[0-9]+]], v[[A_F32_0]]
; SI:  v_cvt_f16_f32_e32 v[[R_F16_0:[0-9]+]], v[[R_F32_0]]
; SI:  v_rndne_f32_e32 v[[R_F32_1:[0-9]+]], v[[A_F32_1]]
; SI:  v_cvt_f16_f32_e32 v[[R_F16_1:[0-9]+]], v[[R_F32_1]]

; VI: v_lshrrev_b32_e32 v[[A_F16_1:[0-9]+]], 16, v[[A_V2_F16]]
; VI:  v_rndne_f16_e32 v[[R_F16_0:[0-9]+]], v[[A_V2_F16]]
; VI:  v_rndne_f16_e32 v[[R_F16_1:[0-9]+]], v[[A_F16_1]]

; VI: v_and_b32_e32 v[[R_F16_0]], 0xffff, v[[R_F16_0]]
; SIVI: v_lshlrev_b32_e32 v[[R_F16_HI:[0-9]+]], 16, v[[R_F16_1]]
; SIVI: v_or_b32_e32 v[[R_V2_F16:[0-9]+]], v[[R_F16_HI]], v[[R_F16_0]]

; GFX9: v_rndne_f16_e32 v[[R_F16_0:[0-9]+]], v[[A_V2_F16]]
; GFX9: v_lshrrev_b32_e32 v[[A_F16_1:[0-9]+]], 16, v[[A_V2_F16]]
; GFX9: v_rndne_f16_e32 v[[R_F16_1:[0-9]+]], v[[A_F16_1]]
; GFX9: v_pack_b32_f16 v[[R_V2_F16:[0-9]+]], v[[R_F16_0]], v[[R_F16_1]]

; GCN: buffer_store_dword v[[R_V2_F16]]
; GCN: s_endpgm
define amdgpu_kernel void @rint_v2f16(
    <2 x half> addrspace(1)* %r,
    <2 x half> addrspace(1)* %a) {
entry:
  %a.val = load <2 x half>, <2 x half> addrspace(1)* %a
  %r.val = call <2 x half> @llvm.rint.v2f16(<2 x half> %a.val)
  store <2 x half> %r.val, <2 x half> addrspace(1)* %r
  ret void
}
