; ============================================================================
; npc/shop.s - Zelda 1-Style Shop System
; ============================================================================
; Shop = a cave room screen with a shopkeeper NPC behind a counter and
; 3 items on the floor. Player walks freely (normal gameplay).
; Press A near an item to buy it. Items disappear when purchased.
; Runs during GAME_STATE_GAMEPLAY on shop screens.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "shop.inc"
.include "combat.inc"
.include "bombs.inc"
.include "hud.inc"

.segment "PRG_FIXED"

; ============================================================================
; shop_init - Initialize shop state at game start
; ============================================================================
.proc shop_init
    lda #STARTING_RUPEES
    sta player_rupees_lo
    lda #$00
    sta player_rupees_hi
    sta shop_active
    sta shop_id
    sta shop_items_bought
    rts
.endproc

; ============================================================================
; shop_enter - Activate shop for current screen
; ============================================================================
; Input: A = shop_id
.proc shop_enter
    sta shop_id
    lda #$01
    sta shop_active
    lda #$00
    sta shop_items_bought
    jsr shop_draw_prices
    rts
.endproc

; ============================================================================
; shop_update - Per-frame shop interaction check
; ============================================================================
.proc shop_update
    lda shop_active
    beq @done
    lda pad1_pressed
    and #BUTTON_A
    beq @done

    ; Check proximity to each item
    lda shop_items_bought
    and #$01
    bne @check_item1
    lda #SHOP_ITEM0_X
    sta temp_0
    lda #SHOP_ITEMS_Y
    sta temp_1
    jsr check_proximity
    bcs @try_buy_0

@check_item1:
    lda shop_items_bought
    and #$02
    bne @check_item2
    lda #SHOP_ITEM1_X
    sta temp_0
    lda #SHOP_ITEMS_Y
    sta temp_1
    jsr check_proximity
    bcs @try_buy_1

@check_item2:
    lda shop_items_bought
    and #$04
    bne @done
    lda #SHOP_ITEM2_X
    sta temp_0
    lda #SHOP_ITEMS_Y
    sta temp_1
    jsr check_proximity
    bcs @try_buy_2

@done:
    rts

@try_buy_0:
    lda #$00
    jmp do_purchase
@try_buy_1:
    lda #$01
    jmp do_purchase
@try_buy_2:
    lda #$02
    jmp do_purchase
.endproc

; ============================================================================
; check_proximity
; ============================================================================
.proc check_proximity
    lda player_x
    sec
    sbc temp_0
    bpl @x_pos
    eor #$FF
    clc
    adc #$01
@x_pos:
    cmp #SHOP_ITEM_RANGE
    bcs @far
    lda player_y
    sec
    sbc temp_1
    bpl @y_pos
    eor #$FF
    clc
    adc #$01
@y_pos:
    cmp #SHOP_ITEM_RANGE
    bcs @far
    sec
    rts
@far:
    clc
    rts
.endproc

; ============================================================================
; do_purchase
; ============================================================================
.proc do_purchase
    sta temp_3
    lda shop_id
    asl a
    asl a
    asl a
    clc
    adc shop_id
    sta temp_2
    lda temp_3
    asl a
    clc
    adc temp_3
    clc
    adc temp_2
    tax

    lda shop_data_table, x
    pha
    inx
    lda shop_data_table, x
    sta temp_0
    inx
    lda shop_data_table, x
    sta temp_1

    lda player_rupees_hi
    cmp temp_1
    bcc @cant_afford
    bne @can_afford
    lda player_rupees_lo
    cmp temp_0
    bcc @cant_afford

@can_afford:
    lda player_rupees_lo
    sec
    sbc temp_0
    sta player_rupees_lo
    lda player_rupees_hi
    sbc temp_1
    sta player_rupees_hi

    lda temp_3
    tax
    lda #$01
@shift:
    cpx #$00
    beq @set
    asl a
    dex
    jmp @shift
@set:
    ora shop_items_bought
    sta shop_items_bought

    pla
    jsr grant_item
    lda #$02
    jsr audio_play_sfx
    lda #$01
    sta hud_dirty
    rts

@cant_afford:
    pla
    lda #$01
    jsr audio_play_sfx
    rts
.endproc

; ============================================================================
; grant_item
; ============================================================================
.proc grant_item
    cmp #ITEM_BOMB
    bne @not_bomb
    lda player_bombs
    clc
    adc #5
    cmp #99
    bcc @ok
    lda #99
@ok:
    sta player_bombs
    rts
@not_bomb:
    cmp #ITEM_POTION
    bne @not_potion
    lda player_max_hp
    sta player_hp
    rts
@not_potion:
    rts
.endproc

; ============================================================================
; shop_draw_items - Draw shopkeeper + item sprites to OAM
; ============================================================================
.proc shop_draw_items
    lda shop_active
    bne @active
    rts
@active:

    ; Shopkeeper (2x2 metatile)
    lda #(SHOPKEEPER_Y - 1)
    sta temp_0
    lda #SHOPKEEPER_TILE
    sta temp_1
    lda #OAM_PALETTE_2
    sta temp_2
    lda #SHOPKEEPER_X
    sta temp_3
    jsr alloc_sprite

    lda #(SHOPKEEPER_Y - 1)
    sta temp_0
    lda #(SHOPKEEPER_TILE + 1)
    sta temp_1
    lda #OAM_PALETTE_2
    sta temp_2
    lda #(SHOPKEEPER_X + 8)
    sta temp_3
    jsr alloc_sprite

    lda #(SHOPKEEPER_Y + 7)
    sta temp_0
    lda #(SHOPKEEPER_TILE + 2)
    sta temp_1
    lda #OAM_PALETTE_2
    sta temp_2
    lda #SHOPKEEPER_X
    sta temp_3
    jsr alloc_sprite

    lda #(SHOPKEEPER_Y + 7)
    sta temp_0
    lda #(SHOPKEEPER_TILE + 3)
    sta temp_1
    lda #OAM_PALETTE_2
    sta temp_2
    lda #(SHOPKEEPER_X + 8)
    sta temp_3
    jsr alloc_sprite

    ; Item 0
    lda shop_items_bought
    and #$01
    bne @skip0
    lda #(SHOP_ITEMS_Y - 1)
    sta temp_0
    lda #SHOP_TILE_BOMB
    sta temp_1
    lda #OAM_PALETTE_1
    sta temp_2
    lda #SHOP_ITEM0_X
    sta temp_3
    jsr alloc_sprite
@skip0:

    ; Item 1
    lda shop_items_bought
    and #$02
    bne @skip1
    lda #(SHOP_ITEMS_Y - 1)
    sta temp_0
    lda #SHOP_TILE_SHIELD
    sta temp_1
    lda #OAM_PALETTE_1
    sta temp_2
    lda #SHOP_ITEM1_X
    sta temp_3
    jsr alloc_sprite
@skip1:

    ; Item 2
    lda shop_items_bought
    and #$04
    bne @skip2
    lda #(SHOP_ITEMS_Y - 1)
    sta temp_0
    lda #SHOP_TILE_POTION
    sta temp_1
    lda #OAM_PALETTE_1
    sta temp_2
    lda #SHOP_ITEM2_X
    sta temp_3
    jsr alloc_sprite
@skip2:

@done:
    rts
.endproc

; ============================================================================
; shop_draw_prices - Write price text to nametable (rendering off)
; ============================================================================
.proc shop_draw_prices
    lda shop_id
    asl a
    asl a
    asl a
    clc
    adc shop_id
    tax

    ; "BUY SOMETHIN" at row 3, col 10
    lda PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$6A
    sta PPUADDR
    lda #$41
    sta PPUDATA
    lda #$54
    sta PPUDATA
    lda #$58
    sta PPUDATA
    lda #FONT_TILE_BLANK
    sta PPUDATA
    lda #$52
    sta PPUDATA
    lda #$4E
    sta PPUDATA
    lda #$4C
    sta PPUDATA
    lda #$44
    sta PPUDATA
    lda #$53
    sta PPUDATA
    lda #$47
    sta PPUDATA
    lda #$48
    sta PPUDATA
    lda #$4D
    sta PPUDATA

    ; Item 0 price at row 14, col 5
    inx
    lda shop_data_table, x
    sta temp_0
    inx
    inx
    stx temp_2

    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$C5
    sta PPUADDR
    lda temp_0
    jsr write_price_digits

    ; Item 1 price at row 14, col 15
    ldx temp_2
    inx
    lda shop_data_table, x
    sta temp_0
    inx
    inx
    stx temp_2

    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$CF
    sta PPUADDR
    lda temp_0
    jsr write_price_digits

    ; Item 2 price at row 14, col 25
    ldx temp_2
    inx
    lda shop_data_table, x
    sta temp_0

    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$D9
    sta PPUADDR
    lda temp_0
    jsr write_price_digits

    rts
.endproc

; ============================================================================
; write_price_digits
; ============================================================================
.proc write_price_digits
    sta ptr_lo
    lda #$00
    sta ptr_hi
@hundreds:
    lda ptr_lo
    cmp #100
    bcc @tens
    sec
    sbc #100
    sta ptr_lo
    inc ptr_hi
    jmp @hundreds
@tens:
    lda ptr_hi
    beq @skip_h
    clc
    adc #FONT_TILE_0
    sta PPUDATA
    jmp @do_tens
@skip_h:
    lda #FONT_TILE_BLANK
    sta PPUDATA
@do_tens:
    lda #$00
    sta ptr_hi
@tens_loop:
    lda ptr_lo
    cmp #10
    bcc @ones
    sec
    sbc #10
    sta ptr_lo
    inc ptr_hi
    jmp @tens_loop
@ones:
    lda ptr_hi
    clc
    adc #FONT_TILE_0
    sta PPUDATA
    lda ptr_lo
    clc
    adc #FONT_TILE_0
    sta PPUDATA
    rts
.endproc
