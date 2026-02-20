; ============================================================================
; player/player.s - Player Movement, Animation, and Rendering
; ============================================================================
.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"
.include "inventory.inc"

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
    ; --- Don't allow menu open during attack ---
    lda player_state
    cmp #PLAYER_STATE_ATTACK
    beq @skip_menu_check

    ; --- Start: open inventory ---
    lda pad1_pressed
    and #BUTTON_START
    beq @no_inventory
    jsr inventory_open
    rts
@no_inventory:

    ; --- Select: open map screen ---
    lda pad1_pressed
    and #BUTTON_SELECT
    beq @no_map
    jsr map_screen_open
    rts
@no_map:
@skip_menu_check:

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

    ; Look up base tile: use attack sprites if attacking, else walk sprites
    lda player_state
    cmp #PLAYER_STATE_ATTACK
    bne @use_walk_tiles

    ; Attack state: use attack body tile table (1 frame per direction)
    lda player_dir
    tax
    lda attack_tile_table, x
    sta ptr_lo              ; base tile index (TL)
    lda #OAM_PALETTE_0
    sta ptr_hi              ; attribute byte (no flip)
    jmp @tiles_chosen

@use_walk_tiles:
    ; Normal state: use walk tile table (2 frames per direction)
    lda player_dir
    asl
    clc
    adc player_anim_frame
    tax
    lda sprite_tile_table, x
    sta ptr_lo              ; base tile index (TL)
    lda #OAM_PALETTE_0
    sta ptr_hi              ; attribute byte (no flip)

@tiles_chosen:

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

    ; --- Draw sword sprite if attacking ---
    lda player_state
    cmp #PLAYER_STATE_ATTACK
    bne @skip_draw
    jsr draw_sword_sprite

@skip_draw:
    rts
.endproc

; ============================================================================
; draw_sword_sprite - Draw sword extending from player during attack
; ============================================================================
; Called from player_draw when player_state == PLAYER_STATE_ATTACK.
; Draws a single 8x8 sprite in the facing direction offset from the player.
; Sword flashes on alternating frames for visual pop.
; Clobbers: A, X
; ============================================================================

.proc draw_sword_sprite
    ; Flash the sword on alternating frames for visual feedback
    lda frame_counter
    and #$01
    beq @draw_it
    ; Odd frames: draw with brighter palette (alternate flash)
    ; We still draw, just swap palette for flicker effect

@draw_it:
    ldx oam_offset

    ; Determine sword position and tile based on player_dir
    lda player_dir
    cmp #DIR_UP
    beq @sword_up
    cmp #DIR_DOWN
    beq @sword_down
    cmp #DIR_LEFT
    beq @sword_left
    ; Default: DIR_RIGHT
    jmp @sword_right

@sword_up:
    ; Y position: player_y + SWORD_OFFSET_UP_Y (negative = subtract)
    lda player_y
    sec
    sbc #10                     ; 10 pixels above player top
    sta $0200, x                ; OAM Y
    inx
    lda #SWORD_TILE_VERT        ; Vertical blade tile
    sta $0200, x                ; OAM tile
    inx
    ; Attribute: palette 0 (player palette), no flip
    lda frame_counter
    and #$01
    beq @up_pal0
    lda #OAM_PALETTE_3          ; Bright flash frame
    jmp @up_attr
@up_pal0:
    lda #OAM_PALETTE_0          ; Normal frame
@up_attr:
    sta $0200, x                ; OAM attribute
    inx
    lda player_x
    clc
    adc #4                      ; Center horizontally
    sta $0200, x                ; OAM X
    inx
    jmp @done

@sword_down:
    lda player_y
    clc
    adc #16                     ; Below player bottom
    sta $0200, x
    inx
    lda #SWORD_TILE_VERT
    sta $0200, x
    inx
    lda frame_counter
    and #$01
    beq @down_pal0
    lda #(OAM_PALETTE_3 | OAM_FLIP_V)  ; Flash + flip vertical
    jmp @down_attr
@down_pal0:
    lda #(OAM_PALETTE_0 | OAM_FLIP_V)  ; Normal + flip vertical
@down_attr:
    sta $0200, x
    inx
    lda player_x
    clc
    adc #4
    sta $0200, x
    inx
    jmp @done

@sword_left:
    lda player_y
    clc
    adc #4                      ; Center vertically
    sta $0200, x
    inx
    lda #SWORD_TILE_HORIZ
    sta $0200, x
    inx
    lda frame_counter
    and #$01
    beq @left_pal0
    lda #OAM_PALETTE_3          ; Flash frame
    jmp @left_attr
@left_pal0:
    lda #OAM_PALETTE_0          ; Normal
@left_attr:
    sta $0200, x
    inx
    lda player_x
    sec
    sbc #10                     ; Left of player
    sta $0200, x
    inx
    jmp @done

@sword_right:
    lda player_y
    clc
    adc #4                      ; Center vertically
    sta $0200, x
    inx
    lda #SWORD_TILE_HORIZ
    sta $0200, x
    inx
    lda frame_counter
    and #$01
    beq @right_pal0
    lda #(OAM_PALETTE_3 | OAM_FLIP_H)  ; Flash + flip horizontal
    jmp @right_attr
@right_pal0:
    lda #(OAM_PALETTE_0 | OAM_FLIP_H)  ; Normal + flip horizontal
@right_attr:
    sta $0200, x
    inx
    lda player_x
    clc
    adc #16                     ; Right of player
    sta $0200, x
    inx

@done:
    stx oam_offset
    rts
.endproc

; ============================================================================
; Sprite tile table: base tile (TL) for each direction + animation frame.
; ============================================================================
; Source: sprite_tiles.chr (LA DX ripped via LINK_TILES.json).
;
; CHR layout (verified by pixel-level ASCII dump of actual tile data):
;   $00-$03 front-face (down)  $04-$07 front-face frame 2
;   $08-$0B back (up)          $0C-$0F back frame 2
;   $10-$13 faces LEFT         $14-$17 faces LEFT frame 2
;   $18-$1B faces RIGHT        $1C-$1F faces RIGHT frame 2
;   $20 shield_front  $21 shield_left  $2D sword_vert  $2E sword_horiz
;
; LINK_TILES.json labels ARE correct: walk_left=$10, walk_right=$18.
; PR #17 incorrectly swapped them based on a faulty pixel dump analysis.
;
; Enums: DIR_UP=0 DIR_DOWN=1 DIR_LEFT=2 DIR_RIGHT=3
; Index = (player_dir * 2) + player_anim_frame
; Draw: TL=base, TR=base+1, BL=base+2, BR=base+3
; ============================================================================
sprite_tile_table:
    .byte $08, $0C    ; DIR_UP(0)    back-facing (CHR $08/$0C)
    .byte $00, $04    ; DIR_DOWN(1)  front-facing (CHR $00/$04)
    .byte $10, $14    ; DIR_LEFT(2)  left-facing (CHR $10/$14)
    .byte $18, $1C    ; DIR_RIGHT(3) right-facing (CHR $18/$1C)

; Attack body tile table: indexed by player_dir, uses walk frame 0 body.
attack_tile_table:
    .byte $08         ; DIR_UP(0)    back-facing
    .byte $00         ; DIR_DOWN(1)  front-facing
    .byte $10         ; DIR_LEFT(2)  left-facing (CHR $10)
    .byte $18         ; DIR_RIGHT(3) right-facing (CHR $18)
