; ============================================================================
; map/map_collision.s - Metatile-Based Collision Detection
; ============================================================================
; Collision derived from metatile attribute byte bit 7 (METATILE_SOLID_BIT).
; Uses the same screen data and metatile table as the map renderer.
; No separate collision arrays - visual and collision are unified.
;
; Hitbox: 6x6 pixels centered at Link's feet with per-direction adjustments:
;   DOWN  - stop when toes touch wall (check y+16 edge)
;   UP    - allow ~4px into wall for false perspective (check y+8 edge)
;   LEFT  - allow ~1px overlap into wall
;   RIGHT - allow ~1px overlap into wall
;
; Input:  temp_2 = proposed X position (pixels)
;         temp_3 = proposed Y position (pixels, includes status bar offset)
;         player_dir = current direction (0=UP, 1=DOWN, 2=LEFT, 3=RIGHT)
; Output: carry set = blocked (solid metatile), carry clear = walkable
; Clobbers: A, X, Y
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"

.segment "PRG_FIXED"

; --------------------------------------------------------------------------
; Directional hitbox offsets (added to sprite origin to get corner positions)
; Sprite is 16x16. Base 6x6 box at feet: x+5..x+10, y+11..y+16
;
; Per-direction tuning:
;   UP:    shift box up so head can poke into walls (y+8..y+13)
;   DOWN:  standard feet box, stop at toes (y+11..y+16)
;   LEFT:  shift box 1px left for slight wall overlap (x+4..x+9)
;   RIGHT: shift box 1px right for slight wall overlap (x+6..x+11)
; --------------------------------------------------------------------------

; Table indexed by player_dir: [UP, DOWN, LEFT, RIGHT]
hitbox_x_left:   .byte  5,  5,  4,  6   ; left X offset
hitbox_x_right:  .byte 10, 10,  9, 11   ; right X offset
hitbox_y_top:    .byte  8, 11, 11, 11   ; top Y offset
hitbox_y_bottom: .byte 13, 16, 16, 16   ; bottom Y offset

; ============================================================================
; check_tile_solid - Check if a single pixel position is on a solid metatile
; ============================================================================
; Input:  A = pixel X, Y register = pixel Y (screen-space, includes status bar)
; Output: carry set = solid, carry clear = walkable
; Uses ptr_lo/ptr_hi as pointer into screen data, ptr2_lo/ptr2_hi as scratch
; Clobbers: A, Y
; ============================================================================

.proc check_tile_solid
    ; --- Convert pixel X to metatile column (X / 16) ---
    lsr
    lsr
    lsr
    lsr
    sta ptr2_hi             ; metatile column (0-15)

    ; --- Convert pixel Y to metatile row ---
    ; Player Y includes 16px status bar, but map grid starts at row 0 = Y 16.
    ; metatile_row = (Y - STATUS_BAR_Y_PX) / 16
    tya
    sec
    sbc #STATUS_BAR_Y_PX    ; subtract status bar height
    bcc @out_of_bounds      ; Y < status bar = out of bounds
    lsr
    lsr
    lsr
    lsr                     ; metatile row (0-13)

    ; --- Bounds check ---
    cmp #MAP_SCREEN_H
    bcs @out_of_bounds      ; row >= 14 = out of bounds

    ; --- Compute screen data offset: row * 16 + col ---
    ; row * 16 = row << 4
    asl
    asl
    asl
    asl                     ; A = row * 16
    clc
    adc ptr2_hi             ; A = row * 16 + col = offset into screen data

    ; --- Load metatile index from current screen data ---
    ; Set up pointer to current screen data
    tay                     ; Y = offset into screen data
    ldx current_screen_id
    lda screen_ptrs_lo, x
    sta ptr_lo
    lda screen_ptrs_hi, x
    sta ptr_hi
    lda (ptr_lo), y         ; A = metatile index at this grid position

    ; --- Look up metatile attribute byte ---
    ; metatile_table[index * 5 + 4] = attribute byte
    ; index * 5 = index * 4 + index
    tax                     ; X = metatile index
    asl                     ; A = index * 2
    asl                     ; A = index * 4
    stx ptr2_hi             ; save original index
    clc
    adc ptr2_hi             ; A = index * 5
    clc
    adc #4                  ; A = index * 5 + 4 (attribute byte offset)
    tay
    lda metatile_table, y   ; A = attribute byte

    ; --- Check solid bit (bit 7) ---
    and #METATILE_SOLID_BIT
    beq @walkable
    sec                     ; solid
    rts

@walkable:
    clc                     ; walkable
    rts

@out_of_bounds:
    sec                     ; treat out-of-bounds as solid
    rts
.endproc

; ============================================================================
; check_collision - Directional 4-corner hitbox collision check
; ============================================================================
; Checks all 4 corners of a 6x6 feet-centered hitbox against metatile solidity.
; Hitbox shape varies by player_dir for Zelda-style false perspective feel:
;   - Walking DOWN: toes stop at wall edge
;   - Walking UP: head pokes ~4px into wall (top-down illusion)
;   - Walking L/R: ~1px overlap allowed
;
; Input:  temp_2 = proposed X, temp_3 = proposed Y, player_dir = direction
; Output: carry set = blocked, carry clear = walkable
; Clobbers: A, X, Y
; ============================================================================

.proc check_collision
    ; Load direction index for table lookups
    ldx player_dir

    ; --- Corner 1: Top-left ---
    lda temp_2
    clc
    adc hitbox_x_left, x
    pha                     ; save X coord on stack
    lda temp_3
    clc
    adc hitbox_y_top, x
    tay                     ; Y = top Y pixel
    pla                     ; A = left X pixel
    jsr check_tile_solid
    bcs @blocked

    ; --- Corner 2: Top-right ---
    ldx player_dir
    lda temp_2
    clc
    adc hitbox_x_right, x
    pha
    lda temp_3
    clc
    adc hitbox_y_top, x
    tay
    pla
    jsr check_tile_solid
    bcs @blocked

    ; --- Corner 3: Bottom-left ---
    ldx player_dir
    lda temp_2
    clc
    adc hitbox_x_left, x
    pha
    lda temp_3
    clc
    adc hitbox_y_bottom, x
    tay
    pla
    jsr check_tile_solid
    bcs @blocked

    ; --- Corner 4: Bottom-right ---
    ldx player_dir
    lda temp_2
    clc
    adc hitbox_x_right, x
    pha
    lda temp_3
    clc
    adc hitbox_y_bottom, x
    tay
    pla
    jsr check_tile_solid
    bcs @blocked

    ; All corners clear
    clc
    rts

@blocked:
    sec
    rts
.endproc
