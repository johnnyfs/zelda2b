; ============================================================================
; player/player_combat.s - Player Combat: Sword Attack and Damage
; ============================================================================
; Handles sword attack on A button, sword-vs-enemy collision,
; enemy-vs-player contact damage, and invincibility frames.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"
.include "bombs.inc"
.include "audio.inc"

; Overlap threshold for AABB collision (in pixels)
; Two 16x16 sprites overlap if their centers are within 14px
OVERLAP_THRESHOLD   = 14

.segment "PRG_FIXED"

; ============================================================================
; combat_init - Initialize player combat state
; ============================================================================
; Called once at game start from reset handler.
; Clobbers: A
; ============================================================================

.proc combat_init
    lda #PLAYER_STATE_NORMAL
    sta player_state
    lda #$00
    sta player_attack_timer
    sta player_invuln_timer
    lda #PLAYER_MAX_HP
    sta player_hp
    sta player_max_hp
    rts
.endproc

; ============================================================================
; combat_update - Main combat logic per frame
; ============================================================================
; Called from player_update. Handles:
; 1. Sword attack initiation (A button)
; 2. Attack timer countdown
; 3. Sword hitbox vs enemy collision
; 4. Player invincibility timer
; 5. Enemy contact damage
;
; Returns: carry set if player is in attack state (suppress movement)
; Clobbers: A, X, Y
; ============================================================================

.proc combat_update
    ; --- Decrement invuln timer if active ---
    lda player_invuln_timer
    beq @no_invuln_tick
    dec player_invuln_timer
@no_invuln_tick:

    ; --- Check current player state ---
    lda player_state
    cmp #PLAYER_STATE_ATTACK
    beq @in_attack

    ; --- NORMAL state: check for A button press ---
    lda pad1_pressed
    and #BUTTON_A
    beq @no_attack

    ; Start attack
    lda #PLAYER_STATE_ATTACK
    sta player_state
    lda #ATTACK_DURATION
    sta player_attack_timer

    ; Play sword swing SFX
    lda #SFX_SWORD_SWING
    ldx #SFX_CHAN_GAMEPLAY
    jsr audio_play_sfx

    ; Check sword hitbox immediately on first frame
    jsr check_sword_vs_enemies

    sec                         ; Signal: player is attacking (no movement)
    rts

@no_attack:
    ; --- Check for B button press (place bomb) ---
    lda pad1_pressed
    and #BUTTON_B
    beq @no_bomb
    jsr bomb_place              ; Places bomb if inventory > 0 and slot free
@no_bomb:

    ; Not attacking - check enemy contact damage
    jsr check_player_damage
    clc                         ; Signal: normal movement allowed
    rts

@in_attack:
    ; --- ATTACK state: count down timer ---
    dec player_attack_timer
    bne @attack_continue

    ; Attack finished - return to normal
    lda #PLAYER_STATE_NORMAL
    sta player_state
    ; Check enemy contact now that attack is over
    jsr check_player_damage
    clc                         ; Movement allowed again
    rts

@attack_continue:
    ; Still attacking - check sword collision each frame
    jsr check_sword_vs_enemies
    sec                         ; No movement during attack
    rts
.endproc

; ============================================================================
; check_sword_vs_enemies - Test sword hitbox against all enemy positions
; ============================================================================
; Computes sword hitbox from player position + facing direction, then tests
; overlap with each active enemy.
;
; Sword hitbox: 16px ahead of player center in facing direction,
; SWORD_HITBOX_W x SWORD_HITBOX_H sized.
;
; Clobbers: A, X, Y
; ============================================================================

.proc check_sword_vs_enemies
    ; Compute sword hitbox center based on player direction
    ; Player center: (player_x + 8, player_y + 8)
    ; Sword extends SWORD_REACH pixels in facing direction

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
    ; Sword box: x = player_x, y = player_y - SWORD_REACH
    lda player_x
    sta temp_2                  ; sword_x
    lda player_y
    sec
    sbc #SWORD_REACH
    sta temp_3                  ; sword_y
    jmp @check_enemies

@sword_down:
    lda player_x
    sta temp_2
    lda player_y
    clc
    adc #SWORD_REACH
    sta temp_3
    jmp @check_enemies

@sword_left:
    lda player_x
    sec
    sbc #SWORD_REACH
    sta temp_2
    lda player_y
    sta temp_3
    jmp @check_enemies

@sword_right:
    lda player_x
    clc
    adc #SWORD_REACH
    sta temp_2
    lda player_y
    sta temp_3

@check_enemies:
    ; temp_2 = sword hitbox X, temp_3 = sword hitbox Y
    ; Now check each enemy slot for overlap

    ldx #$00                    ; Enemy slot index
@enemy_loop:
    lda enemy_state, x
    cmp #ENEMY_STATE_ACTIVE
    bne @next_enemy             ; Only hit active enemies

    ; AABB overlap test: |sword_x - enemy_x| < OVERLAP_THRESHOLD
    ;                  AND |sword_y - enemy_y| < OVERLAP_THRESHOLD

    ; Check X overlap
    lda temp_2
    sec
    sbc enemy_x, x
    ; A = sword_x - enemy_x (signed)
    bpl @x_pos
    ; Negative: negate to get absolute value
    eor #$FF
    clc
    adc #$01
@x_pos:
    cmp #OVERLAP_THRESHOLD
    bcs @next_enemy             ; No X overlap

    ; Check Y overlap
    lda temp_3
    sec
    sbc enemy_y, x
    bpl @y_pos
    eor #$FF
    clc
    adc #$01
@y_pos:
    cmp #OVERLAP_THRESHOLD
    bcs @next_enemy             ; No Y overlap

    ; --- HIT! ---
    jsr hit_enemy               ; X = slot index

@next_enemy:
    inx
    cpx #MAX_ENEMIES
    bne @enemy_loop
    rts
.endproc

; ============================================================================
; hit_enemy - Apply damage to an enemy
; ============================================================================
; Input: X = enemy slot index
; Decreases HP. If HP reaches 0, enters DYING state.
; Otherwise enters HURT state with timer.
; Clobbers: A (X preserved)
; ============================================================================

.proc hit_enemy
    ; Play hit SFX
    txa
    pha
    lda #SFX_HIT
    ldx #SFX_CHAN_GAMEPLAY
    jsr audio_play_sfx
    pla
    tax

    ; Decrease HP
    dec enemy_hp, x
    bne @just_hurt

    ; HP = 0: enemy dies
    lda #ENEMY_STATE_DYING
    sta enemy_state, x
    lda #ENEMY_DEATH_TIME
    sta enemy_timer, x
    rts

@just_hurt:
    ; Enter hurt state (brief invulnerability + flash)
    lda #ENEMY_STATE_HURT
    sta enemy_state, x
    lda #ENEMY_HURT_TIME
    sta enemy_timer, x
    rts
.endproc

; ============================================================================
; check_player_damage - Check if player overlaps any enemy
; ============================================================================
; Tests player position against all active enemies. If overlapping and
; not invulnerable, takes DAMAGE_FROM_ENEMY and enters invuln period.
; If HP reaches 0, transitions to GAME_OVER state.
; Clobbers: A, X
; ============================================================================

.proc check_player_damage
    ; Skip if player is invulnerable
    lda player_invuln_timer
    bne @done                   ; Still invulnerable, skip checks

    ldx #$00
@loop:
    lda enemy_state, x
    cmp #ENEMY_STATE_ACTIVE
    bne @next                   ; Only active enemies deal contact damage

    ; AABB overlap: |player_x - enemy_x| < OVERLAP_THRESHOLD
    ;             AND |player_y - enemy_y| < OVERLAP_THRESHOLD

    ; Check X
    lda player_x
    sec
    sbc enemy_x, x
    bpl @px_pos
    eor #$FF
    clc
    adc #$01
@px_pos:
    cmp #OVERLAP_THRESHOLD
    bcs @next

    ; Check Y
    lda player_y
    sec
    sbc enemy_y, x
    bpl @py_pos
    eor #$FF
    clc
    adc #$01
@py_pos:
    cmp #OVERLAP_THRESHOLD
    bcs @next

    ; --- PLAYER HIT! ---
    ; Decrease HP
    lda player_hp
    sec
    sbc #DAMAGE_FROM_ENEMY
    sta player_hp
    bne @not_dead

    ; HP = 0: Game Over
    lda #$00
    sta player_hp
    lda #GAME_STATE_GAME_OVER
    sta game_state
    rts

@not_dead:
    ; Start invincibility frames
    lda #PLAYER_INVULN_TIME
    sta player_invuln_timer

    ; Play hit SFX
    txa
    pha
    lda #SFX_HIT
    ldx #SFX_CHAN_GAMEPLAY
    jsr audio_play_sfx
    pla
    tax
    rts                         ; Done - only take one hit per frame

@next:
    inx
    cpx #MAX_ENEMIES
    bne @loop
@done:
    rts
.endproc
