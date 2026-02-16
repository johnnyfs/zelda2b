; ============================================================================
; ram.s - RAM Variable Allocation
; ============================================================================
; Defines (allocates storage for) all zero-page and RAM variables
; declared in globals.inc. Only this file should define these variables;
; all other files import them via .globalzp / .global in globals.inc.
; ============================================================================

.include "globals.inc"

; ============================================================================
; Zero Page Variables ($0000-$00FF)
; ============================================================================

.segment "ZEROPAGE"

; --- System state ---
nmi_ready:          .res 1      ; Flag: NMI handler sets, main loop clears
nmi_counter:        .res 1      ; Incremented every NMI (vblank counter)
game_state:         .res 1      ; Current game state (see enums.inc)
frame_counter:      .res 1      ; General purpose frame counter

; --- Temp / scratch variables ---
temp_0:             .res 1
temp_1:             .res 1
temp_2:             .res 1
temp_3:             .res 1
ptr_lo:             .res 1      ; General purpose pointer (low byte)
ptr_hi:             .res 1      ; General purpose pointer (high byte)
ptr2_lo:            .res 1      ; Second pointer (low byte)
ptr2_hi:            .res 1      ; Second pointer (high byte)

; --- Gamepad state ---
pad1_state:         .res 1      ; Controller 1: current frame buttons
pad1_prev:          .res 1      ; Controller 1: previous frame buttons
pad1_pressed:       .res 1      ; Controller 1: newly pressed this frame
pad2_state:         .res 1      ; Controller 2: current frame buttons
pad2_prev:          .res 1      ; Controller 2: previous frame buttons
pad2_pressed:       .res 1      ; Controller 2: newly pressed this frame

; --- Player state ---
player_x:           .res 1      ; Player X position (pixels)
player_y:           .res 1      ; Player Y position (pixels)
player_dir:         .res 1      ; Player facing direction
player_speed:       .res 1      ; Player movement speed
player_anim_frame:  .res 1      ; Current animation frame
player_anim_timer:  .res 1      ; Animation timer countdown

; --- PPU state ---
ppu_ctrl_shadow:    .res 1      ; Shadow copy of PPUCTRL
ppu_mask_shadow:    .res 1      ; Shadow copy of PPUMASK
scroll_x:           .res 1      ; Horizontal scroll position
scroll_y:           .res 1      ; Vertical scroll position

; --- Sprite allocation ---
oam_offset:         .res 1      ; Next free OAM slot offset (0-255)

; --- MMC3 bank shadows ---
current_prg_bank_0: .res 1      ; Current PRG bank at $8000-$9FFF
current_prg_bank_1: .res 1      ; Current PRG bank at $A000-$BFFF

; ============================================================================
; OAM Shadow Buffer ($0200-$02FF)
; ============================================================================
; The OAM buffer is used directly by address ($0200) in the code for DMA.
; We declare the segment here so the linker doesn't warn about it.

.segment "OAM"
oam_buffer:         .res 256    ; 64 sprites x 4 bytes each (accessed at $0200)

; ============================================================================
; RAM Variables ($0300-$07FF)
; ============================================================================

.segment "RAM"

; --- PPU write buffer (for deferred VRAM writes during NMI) ---
ppu_buffer:         .res 64     ; PPU write buffer (64 bytes)
ppu_buffer_len:     .res 1      ; Current length of buffered data
