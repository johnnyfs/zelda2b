; ============================================================================
; sprites.s — OAM Shadow Buffer Management
; ============================================================================
; Manages the 256-byte OAM shadow buffer at $0200.
; Each sprite is 4 bytes: Y, Tile, Attributes, X.
; Max 64 sprites per frame.
;
; Public API:
;   sprite_clear — Hide all sprites (set Y=$FF)
;   sprite_put   — Add one sprite to OAM buffer
;                  Input: A=tile, X=x_pos, Y=y_pos
;                         tmp0=attributes
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.export sprite_clear, sprite_put

.segment "PRG_FIXED_C"

; ============================================================================
; sprite_clear — Move all 64 sprites offscreen (Y = $FF)
; Call at the start of each frame before drawing sprites.
; Clobbers: A, X
; ============================================================================
.proc sprite_clear
    lda #$FF
    ldx #0
@loop:
    sta oam_buf, x          ; Y position = $FF (offscreen)
    inx
    inx
    inx
    inx                     ; Skip 4 bytes per sprite
    bne @loop               ; 256 bytes = 64 sprites
    lda #0
    sta sprite_count
    rts
.endproc

; ============================================================================
; sprite_put — Add one sprite to the OAM buffer
; Input:
;   A   = tile index
;   X   = X position
;   Y   = Y position
;   tmp0 = attributes (palette, flip, priority)
; Output:
;   sprite_count incremented
; Clobbers: A, preserves X/Y
; ============================================================================
.proc sprite_put
    ; Save tile index
    sta tmp1

    ; Calculate OAM offset = sprite_count * 4
    lda sprite_count
    cmp #64
    bcs @full               ; No room for more sprites

    asl                     ; * 2
    asl                     ; * 4
    stx tmp2                ; Save X pos
    tax                     ; X = OAM offset

    ; Write 4 OAM bytes
    tya                     ; A = Y position
    sta oam_buf, x          ; Byte 0: Y
    lda tmp1
    sta oam_buf+1, x        ; Byte 1: Tile
    lda tmp0
    sta oam_buf+2, x        ; Byte 2: Attributes
    lda tmp2
    sta oam_buf+3, x        ; Byte 3: X

    inc sprite_count

    ldx tmp2                ; Restore X
    rts

@full:
    ldx tmp2
    rts
.endproc
