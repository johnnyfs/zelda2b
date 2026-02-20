; ============================================================================
; globals.s — Global Variable Storage Allocation
; ============================================================================
; This file allocates all shared zero-page and RAM variables.
; Other modules import them via include/globals.inc.
; ============================================================================

.include "nes.inc"

; ============================================================================
; Zero-Page Variables (fast access)
; ============================================================================
.segment "ZEROPAGE"

; --- NMI / Frame Sync ---
.export nmi_ready, frame_counter, nmi_ctrl, nmi_mask, scroll_x, scroll_y
nmi_ready:      .res 1
frame_counter:  .res 1
nmi_ctrl:       .res 1      ; Shadow PPUCTRL
nmi_mask:       .res 1      ; Shadow PPUMASK
scroll_x:       .res 1
scroll_y:       .res 1

; --- Gamepad ---
.export gamepad, gamepad_prev, gamepad_press
gamepad:        .res 1
gamepad_prev:   .res 1
gamepad_press:  .res 1

; --- PPU Buffer ---
.export ppu_buf_len
ppu_buf_len:    .res 1

; --- OAM ---
.export sprite_count
sprite_count:   .res 1

; --- Game State ---
.export game_state, game_state_prev
game_state:     .res 1
game_state_prev: .res 1

; --- Temp / Scratch ---
.export tmp0, tmp1, tmp2, tmp3, ptr0, ptr0_hi, ptr1, ptr1_hi
tmp0:           .res 1
tmp1:           .res 1
tmp2:           .res 1
tmp3:           .res 1
ptr0:           .res 1
ptr0_hi:        .res 1
ptr1:           .res 1
ptr1_hi:        .res 1

; --- MMC3 ---
.export mmc3_bank_select, current_prg_bank
mmc3_bank_select: .res 1
current_prg_bank: .res 1

; ============================================================================
; RAM Variables (slower access, more space)
; ============================================================================
.segment "RAM"

; --- PPU Buffer (max 32 writes per frame) ---
PPU_BUF_MAX = 32
.export ppu_buf_hi, ppu_buf_lo, ppu_buf_data
ppu_buf_hi:     .res PPU_BUF_MAX
ppu_buf_lo:     .res PPU_BUF_MAX
ppu_buf_data:   .res PPU_BUF_MAX

; ============================================================================
; OAM Shadow Buffer (must be page-aligned at $0200)
; ============================================================================
.segment "OAM"
.export oam_buf
oam_buf:        .res 256
