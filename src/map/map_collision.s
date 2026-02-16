; ============================================================================
; map/map_collision.s - Metatile-Based Collision Detection
; ============================================================================
; Collision derived from metatile attribute byte bit 7 (METATILE_SOLID_BIT).
; Uses the same screen data and metatile table as the map renderer.
; No separate collision arrays - visual and collision are unified.
;
; Input:  temp_2 = proposed X position (pixels)
;         temp_3 = proposed Y position (pixels, includes status bar offset)
; Output: carry set = blocked (solid metatile), carry clear = walkable
; Clobbers: A, Y
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"

HITBOX_INSET = 2
HITBOX_SIZE  = 12

.segment "PRG_FIXED"

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
; check_collision - 4-corner hitbox collision check
; ============================================================================
; Checks all 4 corners of the player hitbox against metatile solidity.
; Input:  temp_2 = proposed X, temp_3 = proposed Y
; Output: carry set = blocked, carry clear = walkable
; Clobbers: A, X, Y
; ============================================================================

.proc check_collision
    ; --- Corner 1: Top-left ---
    lda temp_2
    clc
    adc #HITBOX_INSET
    ldy temp_3
    iny                     ; +1 for inset (simplified from HITBOX_INSET for Y)
    iny
    jsr check_tile_solid
    bcs @blocked

    ; --- Corner 2: Top-right ---
    lda temp_2
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    ldy temp_3
    iny
    iny
    jsr check_tile_solid
    bcs @blocked

    ; --- Corner 3: Bottom-left ---
    lda temp_2
    clc
    adc #HITBOX_INSET
    ldy temp_3
    tya
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    tay
    lda temp_2
    clc
    adc #HITBOX_INSET
    jsr check_tile_solid
    bcs @blocked

    ; --- Corner 4: Bottom-right ---
    lda temp_2
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    ldy temp_3
    tya
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    tay
    lda temp_2
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    jsr check_tile_solid
    bcs @blocked

    ; All corners clear
    clc
    rts

@blocked:
    sec
    rts
.endproc
