; ============================================================================
; map/map_collision.s - Tile-Based Collision Detection
; ============================================================================
.include "nes.inc"
.include "globals.inc"
.include "enums.inc"

HITBOX_INSET = 2
HITBOX_SIZE  = 12

.segment "PRG_FIXED"

.proc check_collision
    ; Corner 1: Top-left
    lda temp_2
    clc
    adc #HITBOX_INSET
    lsr
    lsr
    lsr
    lsr
    sta ptr2_lo
    lda temp_3
    clc
    adc #HITBOX_INSET
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    asl
    clc
    adc ptr2_lo
    tay
    lda test_room_collision, y
    cmp #TILE_SOLID
    beq @blocked
    ; Corner 2: Top-right
    lda temp_2
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    lsr
    lsr
    lsr
    lsr
    sta ptr2_lo
    lda temp_3
    clc
    adc #HITBOX_INSET
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    asl
    clc
    adc ptr2_lo
    tay
    lda test_room_collision, y
    cmp #TILE_SOLID
    beq @blocked
    ; Corner 3: Bottom-left
    lda temp_2
    clc
    adc #HITBOX_INSET
    lsr
    lsr
    lsr
    lsr
    sta ptr2_lo
    lda temp_3
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    asl
    clc
    adc ptr2_lo
    tay
    lda test_room_collision, y
    cmp #TILE_SOLID
    beq @blocked
    ; Corner 4: Bottom-right
    lda temp_2
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    lsr
    lsr
    lsr
    lsr
    sta ptr2_lo
    lda temp_3
    clc
    adc #(HITBOX_INSET + HITBOX_SIZE - 1)
    lsr
    lsr
    lsr
    lsr
    asl
    asl
    asl
    asl
    clc
    adc ptr2_lo
    tay
    lda test_room_collision, y
    cmp #TILE_SOLID
    beq @blocked
    clc
    rts
@blocked:
    sec
    rts
.endproc

test_room_collision:
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
