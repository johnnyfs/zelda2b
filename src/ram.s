; ============================================================================
; ram.s - RAM Variable Allocation
; ============================================================================
; Defines (allocates storage for) all zero-page and RAM variables
; declared in globals.inc. Only this file should define these variables;
; all other files import them via .globalzp / .global in globals.inc.
; ============================================================================

.include "globals.inc"
.include "map.inc"
.include "combat.inc"

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
player_x:           .res 1      ; Player X position (pixels, integer part)
player_y:           .res 1      ; Player Y position (pixels, integer part)
player_x_sub:       .res 1      ; Player X sub-pixel (fractional byte, 8.8 fixed)
player_y_sub:       .res 1      ; Player Y sub-pixel (fractional byte, 8.8 fixed)
player_dir:         .res 1      ; Player facing direction
player_speed:       .res 1      ; Player movement speed (legacy)
player_anim_frame:  .res 1      ; Current animation frame (0 or 1)
player_anim_timer:  .res 1      ; Animation timer countdown
player_moving:      .res 1      ; Non-zero if player moved this frame

; --- PPU state ---
ppu_ctrl_shadow:    .res 1      ; Shadow copy of PPUCTRL
ppu_mask_shadow:    .res 1      ; Shadow copy of PPUMASK
scroll_x:           .res 1      ; Horizontal scroll position
scroll_y:           .res 1      ; Vertical scroll position

; --- Sprite allocation ---
oam_offset:         .res 1      ; Next free OAM slot offset (0-255)

; --- Map engine state ---
current_screen_x:   .res 1      ; Current screen X in map grid
current_screen_y:   .res 1      ; Current screen Y in map grid
current_screen_id:  .res 1      ; Computed screen index
map_row_counter:    .res 1      ; Row counter for screen loading
map_col_counter:    .res 1      ; Column counter for screen loading

; --- MMC3 bank shadows ---
current_prg_bank_0: .res 1      ; Current PRG bank at $8000-$9FFF
current_prg_bank_1: .res 1      ; Current PRG bank at $A000-$BFFF

; --- Enemy state (parallel arrays, MAX_ENEMIES=4 slots) ---
enemy_x:            .res MAX_ENEMIES    ; X positions
enemy_y:            .res MAX_ENEMIES    ; Y positions
enemy_type:         .res MAX_ENEMIES    ; Enemy type IDs
enemy_hp:           .res MAX_ENEMIES    ; Hit points
enemy_state:        .res MAX_ENEMIES    ; State (inactive/active/hurt/dying)
enemy_dir:          .res MAX_ENEMIES    ; Facing direction
enemy_timer:        .res MAX_ENEMIES    ; General purpose timer

; --- Player combat state ---
player_state:       .res 1      ; Player action state (normal/attack)
player_attack_timer:.res 1      ; Attack animation countdown
player_hp:          .res 1      ; Current hit points
player_max_hp:      .res 1      ; Maximum hit points
player_invuln_timer:.res 1      ; Invincibility frames countdown

; --- Pickup state (parallel arrays, MAX_PICKUPS=4 slots) ---
pickup_x:           .res MAX_PICKUPS    ; X positions
pickup_y:           .res MAX_PICKUPS    ; Y positions
pickup_type:        .res MAX_PICKUPS    ; Pickup type IDs
pickup_state:       .res MAX_PICKUPS    ; State (inactive/active/spawning)
pickup_timer:       .res MAX_PICKUPS    ; Timer (spawn animation)

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
