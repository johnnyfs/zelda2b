; ============================================================================
; player/player.s - Player Movement, Animation, and Rendering
; ============================================================================
.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"

PLAYER_SPEED_LO     = $80
PLAYER_SPEED_HI     = $01
PLAYER_ANIM_DELAY   = 8
PLAYER_START_X      = 120
PLAYER_START_Y      = 80
SCREEN_TOP          = 16
SCREEN_BOTTOM       = 224
SCREEN_LEFT         = 8
SCREEN_RIGHT        = 240

.segment "PRG_FIXED"

.proc player_init
    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y
    lda #$00
    sta player_x_sub
    sta player_y_sub
    lda #DIR_DOWN
    sta player_dir
    lda #$00
    sta player_anim_frame
    lda #PLAYER_ANIM_DELAY
    sta player_anim_timer
    lda #$00
    sta player_moving
    rts
.endproc

.proc player_update
    lda pad1_pressed
    and #BUTTON_START
    beq @no_pause
    lda #GAME_STATE_PAUSED
    sta game_state
    rts
@no_pause:

    ; --- Combat update (checks attack input, handles sword, damage) ---
    ; Returns carry set if player is attacking (suppress movement)
    jsr combat_update
    bcc @do_movement            ; Carry clear = no attack, allow movement
    jmp @skip_movement          ; In attack state - no movement
@do_movement:

    lda #$00
    sta player_moving

    ; --- UP ---
    lda pad1_state
    and #BUTTON_UP
    beq @not_up
    lda #DIR_UP
    sta player_dir
    lda #$01
    sta player_moving
    lda player_y_sub
    sec
    sbc #PLAYER_SPEED_LO
    sta temp_0
    lda player_y
    sbc #PLAYER_SPEED_HI
    sta temp_1
    cmp #SCREEN_TOP
    bcc @not_up
    lda player_x
    sta temp_2
    lda temp_1
    sta temp_3
    jsr check_collision
    bcs @not_up
    lda temp_0
    sta player_y_sub
    lda temp_1
    sta player_y
    jmp @vert_done
@not_up:
    ; --- DOWN ---
    lda pad1_state
    and #BUTTON_DOWN
    beq @vert_done
    lda #DIR_DOWN
    sta player_dir
    lda #$01
    sta player_moving
    lda player_y_sub
    clc
    adc #PLAYER_SPEED_LO
    sta temp_0
    lda player_y
    adc #PLAYER_SPEED_HI
    sta temp_1
    cmp #SCREEN_BOTTOM
    bcs @vert_done
    lda player_x
    sta temp_2
    lda temp_1
    sta temp_3
    jsr check_collision
    bcs @vert_done
    lda temp_0
    sta player_y_sub
    lda temp_1
    sta player_y
@vert_done:

    ; --- LEFT ---
    lda pad1_state
    and #BUTTON_LEFT
    beq @not_left
    lda #DIR_LEFT
    sta player_dir
    lda #$01
    sta player_moving
    lda player_x_sub
    sec
    sbc #PLAYER_SPEED_LO
    sta temp_0
    lda player_x
    sbc #PLAYER_SPEED_HI
    sta temp_1
    cmp #SCREEN_LEFT
    bcc @not_left
    lda temp_1
    sta temp_2
    lda player_y
    sta temp_3
    jsr check_collision
    bcs @not_left
    lda temp_0
    sta player_x_sub
    lda temp_1
    sta player_x
    jmp @horiz_done
@not_left:
    ; --- RIGHT ---
    lda pad1_state
    and #BUTTON_RIGHT
    beq @horiz_done
    lda #DIR_RIGHT
    sta player_dir
    lda #$01
    sta player_moving
    lda player_x_sub
    clc
    adc #PLAYER_SPEED_LO
    sta temp_0
    lda player_x
    adc #PLAYER_SPEED_HI
    sta temp_1
    cmp #SCREEN_RIGHT
    bcs @horiz_done
    lda temp_1
    sta temp_2
    lda player_y
    sta temp_3
    jsr check_collision
    bcs @horiz_done
    lda temp_0
    sta player_x_sub
    lda temp_1
    sta player_x
@horiz_done:

@skip_movement:
    ; --- Animation ---
    lda player_moving
    beq @anim_idle
    dec player_anim_timer
    bne @anim_done
    lda player_anim_frame
    eor #$01
    sta player_anim_frame
    lda #PLAYER_ANIM_DELAY
    sta player_anim_timer
    jmp @anim_done
@anim_idle:
    lda #$00
    sta player_anim_frame
    lda #PLAYER_ANIM_DELAY
    sta player_anim_timer
@anim_done:
    jsr player_draw
    rts
.endproc

.proc player_draw
    ; --- Invincibility flash: hide player on odd frames ---
    lda player_invuln_timer
    beq @no_flash
    lda frame_counter
    and #$02                    ; Flash every 2 frames (faster than enemy flash)
    beq @no_flash               ; Zero = draw this frame
    jmp @skip_draw              ; Non-zero = skip draw (flash effect)
@no_flash:

    ; Look up base tile from direction + animation frame
    lda player_dir
    asl
    clc
    adc player_anim_frame
    tax
    lda sprite_tile_table, x
    sta ptr_lo              ; base tile index (TL)
    lda #OAM_PALETTE_0
    sta ptr_hi              ; attribute byte (no flip)

    ldx oam_offset
    ; Sprite 0: Top-left
    lda player_y
    sta $0200, x
    inx
    lda ptr_lo
    sta $0200, x
    inx
    lda ptr_hi
    sta $0200, x
    inx
    lda player_x
    sta $0200, x
    inx
    ; Sprite 1: Top-right
    lda player_y
    sta $0200, x
    inx
    lda ptr_lo
    clc
    adc #1
    sta $0200, x
    inx
    lda ptr_hi
    sta $0200, x
    inx
    lda player_x
    clc
    adc #8
    sta $0200, x
    inx
    ; Sprite 2: Bottom-left
    lda player_y
    clc
    adc #8
    sta $0200, x
    inx
    lda ptr_lo
    clc
    adc #2
    sta $0200, x
    inx
    lda ptr_hi
    sta $0200, x
    inx
    lda player_x
    sta $0200, x
    inx
    ; Sprite 3: Bottom-right
    lda player_y
    clc
    adc #8
    sta $0200, x
    inx
    lda ptr_lo
    clc
    adc #3
    sta $0200, x
    inx
    lda ptr_hi
    sta $0200, x
    inx
    lda player_x
    clc
    adc #8
    sta $0200, x
    inx
    stx oam_offset

@skip_draw:
    rts
.endproc

; Sprite tile table: base tile (TL) for each direction + animation frame.
; Tile indices from LINK_TILES.json (LA DX ripped sprites, 34 tiles).
; Each direction has 2 walk frames, 4 tiles each (TL, TR, BL, BR).
; Draw routine adds: TR=base+1, BL=base+2, BR=base+3.
sprite_tile_table:
    .byte $08, $0C    ; DIR_UP    frame 0 (walk_up_1), frame 1 (walk_up_2)
    .byte $00, $04    ; DIR_DOWN  frame 0 (walk_down_1), frame 1 (walk_down_2)
    .byte $10, $14    ; DIR_LEFT  frame 0 (walk_left_1), frame 1 (walk_left_2)
    .byte $18, $1C    ; DIR_RIGHT frame 0 (walk_right_1), frame 1 (walk_right_2)
