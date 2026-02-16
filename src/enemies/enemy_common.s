; ============================================================================
; enemies/enemy_common.s - Enemy Slot System
; ============================================================================
; Manages up to MAX_ENEMIES (4) enemies using parallel arrays.
; Provides init, update dispatch, draw, and screen spawn routines.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"

.segment "PRG_FIXED"

; ============================================================================
; enemy_init - Clear all enemy slots
; ============================================================================
; Sets all enemy states to INACTIVE, zeroes arrays.
; Clobbers: A, X
; ============================================================================

.proc enemy_init
    ldx #MAX_ENEMIES - 1
@loop:
    lda #ENEMY_STATE_INACTIVE
    sta enemy_state, x
    lda #ENEMY_NONE
    sta enemy_type, x
    lda #$00
    sta enemy_x, x
    sta enemy_y, x
    sta enemy_hp, x
    sta enemy_dir, x
    sta enemy_timer, x
    dex
    bpl @loop
    rts
.endproc

; ============================================================================
; enemy_update - Update all active enemies
; ============================================================================
; Iterates through all slots. For each active enemy, dispatches to the
; appropriate AI routine based on type. Handles hurt/dying state timers.
; Clobbers: A, X, Y
; ============================================================================

.proc enemy_update
    ldx #$00                    ; Start with slot 0
@loop:
    lda enemy_state, x
    cmp #ENEMY_STATE_INACTIVE
    beq @next                   ; Skip inactive slots

    cmp #ENEMY_STATE_DYING
    beq @update_dying

    cmp #ENEMY_STATE_HURT
    beq @update_hurt

    ; ENEMY_STATE_ACTIVE - dispatch AI by type
    lda enemy_type, x
    cmp #ENEMY_OCTOROK
    beq @ai_octorok
    ; Add more enemy types here
    jmp @next

@ai_octorok:
    ; Save X (slot index) on stack - AI routine may clobber it
    txa
    pha
    jsr enemy_ai_octorok
    pla
    tax
    jmp @next

@update_hurt:
    dec enemy_timer, x
    bne @next                   ; Still in hurt frames
    ; Hurt timer expired - return to active
    lda #ENEMY_STATE_ACTIVE
    sta enemy_state, x
    jmp @next

@update_dying:
    dec enemy_timer, x
    bne @next                   ; Still in death animation
    ; Death animation done - spawn pickup at enemy position, then deactivate
    lda enemy_x, x
    sta temp_2                  ; pickup X
    lda enemy_y, x
    sta temp_3                  ; pickup Y
    lda #ENEMY_STATE_INACTIVE
    sta enemy_state, x
    ; Save X, call pickup_spawn (A=type, temp_2/3=position)
    txa
    pha
    lda #PICKUP_HEART
    jsr pickup_spawn
    pla
    tax
    jmp @next

@next:
    inx
    cpx #MAX_ENEMIES
    bne @loop
    rts
.endproc

; ============================================================================
; enemy_draw - Draw sprites for all active enemies
; ============================================================================
; Each enemy is a 2x2 metatile (16x16 pixels) using 4 OAM sprites.
; Hurt enemies flash by toggling visibility on odd frames.
; Dying enemies also flash rapidly.
; Clobbers: A, X, Y
; ============================================================================

.proc enemy_draw
    ldx #$00                    ; Slot index
@loop:
    lda enemy_state, x
    cmp #ENEMY_STATE_INACTIVE
    bne @not_inactive
    jmp @next                   ; Skip inactive (far jump)
@not_inactive:

    ; Check if hurt/dying - flash effect (skip draw on odd frames)
    cmp #ENEMY_STATE_HURT
    beq @check_flash
    cmp #ENEMY_STATE_DYING
    beq @check_flash
    jmp @do_draw

@check_flash:
    ; Flash: only draw on even frames
    lda frame_counter
    and #$01
    bne @next                   ; Odd frame = invisible (flash)

@do_draw:
    ; Save slot index
    txa
    pha

    ; Get enemy position into temps for sprite allocation
    ; We'll draw a 2x2 metatile using the same pattern as player_draw
    ldy oam_offset

    ; Sprite 0: Top-left
    lda enemy_y, x
    sta $0200, y
    iny
    lda #ENEMY_TILE_BASE        ; TL tile
    sta $0200, y
    iny
    lda #OAM_PALETTE_1          ; Enemy palette (red)
    sta $0200, y
    iny
    lda enemy_x, x
    sta $0200, y
    iny

    ; Sprite 1: Top-right
    lda enemy_y, x
    sta $0200, y
    iny
    lda #(ENEMY_TILE_BASE + 1)  ; TR tile
    sta $0200, y
    iny
    lda #OAM_PALETTE_1
    sta $0200, y
    iny
    lda enemy_x, x
    clc
    adc #8
    sta $0200, y
    iny

    ; Sprite 2: Bottom-left
    lda enemy_y, x
    clc
    adc #8
    sta $0200, y
    iny
    lda #(ENEMY_TILE_BASE + 2)  ; BL tile
    sta $0200, y
    iny
    lda #OAM_PALETTE_1
    sta $0200, y
    iny
    lda enemy_x, x
    sta $0200, y
    iny

    ; Sprite 3: Bottom-right
    lda enemy_y, x
    clc
    adc #8
    sta $0200, y
    iny
    lda #(ENEMY_TILE_BASE + 3)  ; BR tile
    sta $0200, y
    iny
    lda #OAM_PALETTE_1
    sta $0200, y
    iny
    lda enemy_x, x
    clc
    adc #8
    sta $0200, y
    iny

    ; Update oam_offset
    sty oam_offset

    pla
    tax
@next:
    inx
    cpx #MAX_ENEMIES
    beq @done
    jmp @loop
@done:
    rts
.endproc

; ============================================================================
; enemy_spawn_screen - Spawn enemies for the current test screen
; ============================================================================
; Hardcodes 3 Octorok enemies at fixed positions for testing.
; Called after loading a screen. Clears existing enemies first.
; Clobbers: A, X
; ============================================================================

.proc enemy_spawn_screen
    ; Clear all slots first
    jsr enemy_init

    ; Spawn Octorok 0 at (80, 64)
    ldx #$00
    lda #80
    sta enemy_x, x
    lda #64
    sta enemy_y, x
    lda #ENEMY_OCTOROK
    sta enemy_type, x
    lda #OCTOROK_HP
    sta enemy_hp, x
    lda #ENEMY_STATE_ACTIVE
    sta enemy_state, x
    lda #DIR_DOWN
    sta enemy_dir, x
    lda #ENEMY_WANDER_TIME
    sta enemy_timer, x

    ; Spawn Octorok 1 at (160, 96)
    ldx #$01
    lda #160
    sta enemy_x, x
    lda #96
    sta enemy_y, x
    lda #ENEMY_OCTOROK
    sta enemy_type, x
    lda #OCTOROK_HP
    sta enemy_hp, x
    lda #ENEMY_STATE_ACTIVE
    sta enemy_state, x
    lda #DIR_LEFT
    sta enemy_dir, x
    lda #ENEMY_WANDER_TIME
    sta enemy_timer, x

    ; Spawn Octorok 2 at (120, 160)
    ldx #$02
    lda #120
    sta enemy_x, x
    lda #160
    sta enemy_y, x
    lda #ENEMY_OCTOROK
    sta enemy_type, x
    lda #OCTOROK_HP
    sta enemy_hp, x
    lda #ENEMY_STATE_ACTIVE
    sta enemy_state, x
    lda #DIR_RIGHT
    sta enemy_dir, x
    lda #ENEMY_WANDER_TIME
    sta enemy_timer, x

    rts
.endproc
