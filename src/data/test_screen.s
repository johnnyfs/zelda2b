; ============================================================================
; data/test_screen.s - Test Screen Nametable Data
; ============================================================================
.include "nes.inc"
.include "globals.inc"

BG_FLOOR = $02
BG_WALL  = $01

.segment "PRG_FIXED"

.proc load_test_screen
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR
    ldy #$00
    ldx #$00
@meta_row:
    cpx #15
    beq @nametable_done
    lda #16
    sta temp_1
@top_row:
    lda test_screen_map, y
    beq @top_floor
    lda #BG_WALL
    sta PPUDATA
    lda #BG_WALL
    sta PPUDATA
    jmp @top_next
@top_floor:
    lda #BG_FLOOR
    sta PPUDATA
    lda #BG_FLOOR
    sta PPUDATA
@top_next:
    iny
    dec temp_1
    bne @top_row
    tya
    sec
    sbc #16
    tay
    lda #16
    sta temp_1
@bot_row:
    lda test_screen_map, y
    beq @bot_floor
    lda #BG_WALL
    sta PPUDATA
    lda #BG_WALL
    sta PPUDATA
    jmp @bot_next
@bot_floor:
    lda #BG_FLOOR
    sta PPUDATA
    lda #BG_FLOOR
    sta PPUDATA
@bot_next:
    iny
    dec temp_1
    bne @bot_row
    inx
    jmp @meta_row
@nametable_done:
    lda #64
    sta temp_0
    lda #$00
@attr_loop:
    sta PPUDATA
    dec temp_0
    bne @attr_loop
    rts
.endproc

test_screen_map:
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01
    .byte $01,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01
    .byte $01,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
