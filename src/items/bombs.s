; ============================================================================
; items/bombs.s - B-Button Bomb System
; ============================================================================
; Manages up to MAX_BOMBS (2) active bombs using parallel arrays.
; Player places bombs with B button. After a 2-second fuse (120 frames),
; the bomb explodes, damaging nearby enemies within the blast radius.
;
; Bomb lifecycle: FUSE -> EXPLODING -> SMOKE -> INACTIVE
;
; NOTE: Breakable wall destruction requires the collision map to be in RAM
; (currently in ROM). That feature will be added when the map engine
; supports RAM-backed collision data.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"
.include "bombs.inc"
.include "audio.inc"

.segment "PRG_FIXED"

; ============================================================================
; bomb_init - Clear all bomb slots and set starting inventory
; ============================================================================
; Clobbers: A, X
; ============================================================================

.proc bomb_init
    ldx #MAX_BOMBS - 1
@loop:
    lda #BOMB_STATE_INACTIVE
    sta bomb_state, x
    lda #$00
    sta bomb_x, x
    sta bomb_y, x
    sta bomb_timer, x
    dex
    bpl @loop
    ; Start with full bomb inventory
    lda #MAX_BOMB_INVENTORY
    sta player_bombs
    rts
.endproc

; ============================================================================
; bomb_place - Place a bomb at player's position
; ============================================================================
; Called when player presses B. Checks inventory and finds a free slot.
; Places the bomb centered on the player.
;
; Returns: carry set if bomb placed, carry clear if not
; Clobbers: A, X
; ============================================================================

.proc bomb_place
    ; Check if player has bombs
    lda player_bombs
    beq @no_bomb                    ; No bombs in inventory

    ; Find a free bomb slot
    ldx #$00
@find_slot:
    lda bomb_state, x
    cmp #BOMB_STATE_INACTIVE
    beq @found
    inx
    cpx #MAX_BOMBS
    bne @find_slot
    ; No free slot
@no_bomb:
    clc
    rts

@found:
    ; Place bomb at player's feet (center of player sprite)
    lda player_x
    clc
    adc #4                          ; Center offset (16px sprite, bomb is 8px)
    sta bomb_x, x
    lda player_y
    clc
    adc #4
    sta bomb_y, x

    ; Start fuse
    lda #BOMB_STATE_FUSE
    sta bomb_state, x
    lda #BOMB_FUSE_TIME
    sta bomb_timer, x

    ; Decrement inventory
    dec player_bombs

    ; Play placement SFX
    txa
    pha
    lda #SFX_HIT                    ; Reuse hit SFX for placement (placeholder)
    ldx #SFX_CHAN_GAMEPLAY
    jsr audio_play_sfx
    pla
    tax

    sec                             ; Signal: bomb placed
    rts
.endproc

; ============================================================================
; bomb_update - Update all active bombs
; ============================================================================
; Handles fuse countdown, explosion trigger, damage check, and smoke.
; Clobbers: A, X, Y
; ============================================================================

.proc bomb_update
    ldx #$00
@loop:
    lda bomb_state, x
    cmp #BOMB_STATE_INACTIVE
    beq @next

    cmp #BOMB_STATE_FUSE
    beq @update_fuse

    cmp #BOMB_STATE_EXPLODING
    beq @update_exploding

    cmp #BOMB_STATE_SMOKE
    bne @next
    jmp @update_smoke

@update_fuse:
    dec bomb_timer, x
    bne @next                       ; Still counting down
    ; Fuse expired - EXPLODE!
    lda #BOMB_STATE_EXPLODING
    sta bomb_state, x
    lda #BOMB_EXPLODE_TIME
    sta bomb_timer, x
    ; Perform explosion effects on first frame
    txa
    pha
    ; Play explosion SFX (reuse sword swing noise burst as placeholder)
    lda #SFX_SWORD_SWING
    ldx #SFX_CHAN_GAMEPLAY
    jsr audio_play_sfx
    pla
    tax
    ; Check enemies in blast radius
    jsr bomb_check_enemies
    jmp @next

@update_exploding:
    dec bomb_timer, x
    bne @next                       ; Explosion still active
    ; Explosion done - enter smoke phase
    lda #BOMB_STATE_SMOKE
    sta bomb_state, x
    lda #BOMB_SMOKE_TIME
    sta bomb_timer, x
    jmp @next

@update_smoke:
    dec bomb_timer, x
    bne @next_far                   ; Still smoking
    ; Smoke done - deactivate
    lda #BOMB_STATE_INACTIVE
    sta bomb_state, x

@next:
    inx
    cpx #MAX_BOMBS
    bne @loop
    rts
@next_far:
    jmp @next
.endproc

; ============================================================================
; bomb_check_enemies - Damage enemies within blast radius
; ============================================================================
; Input: X = bomb slot index
; Checks each active enemy against blast radius using AABB distance.
; Clobbers: A, Y (X preserved)
; ============================================================================

.proc bomb_check_enemies
    ; Save bomb position in temps
    lda bomb_x, x
    sta temp_2                      ; bomb X
    lda bomb_y, x
    sta temp_3                      ; bomb Y

    ; Save bomb slot index
    txa
    pha

    ldy #$00                        ; Enemy slot index
@enemy_loop:
    lda enemy_state, y
    cmp #ENEMY_STATE_ACTIVE
    beq @check_distance
    cmp #ENEMY_STATE_HURT
    beq @check_distance
    jmp @next_enemy                 ; Skip inactive/dying enemies

@check_distance:
    ; Check X distance: |bomb_x - enemy_x| < BOMB_ENEMY_HIT_DIST
    lda temp_2
    sec
    sbc enemy_x, y
    bpl @ex_pos
    eor #$FF
    clc
    adc #$01
@ex_pos:
    cmp #BOMB_ENEMY_HIT_DIST
    bcs @next_enemy                 ; Too far in X

    ; Check Y distance: |bomb_y - enemy_y| < BOMB_ENEMY_HIT_DIST
    lda temp_3
    sec
    sbc enemy_y, y
    bpl @ey_pos
    eor #$FF
    clc
    adc #$01
@ey_pos:
    cmp #BOMB_ENEMY_HIT_DIST
    bcs @next_enemy                 ; Too far in Y

    ; --- Enemy in blast radius! ---
    ; Apply BOMB_DAMAGE to this enemy
    ; We need X = enemy index for accessing enemy arrays
    sty temp_0                      ; Save enemy loop index in temp

    ; Decrease enemy HP by BOMB_DAMAGE
    lda enemy_hp, y
    sec
    sbc #BOMB_DAMAGE
    bcs @no_underflow               ; No underflow
    lda #$00                        ; Clamp to zero
@no_underflow:
    sta enemy_hp, y
    beq @enemy_dies

    ; Enemy survives - enter hurt state
    lda #ENEMY_STATE_HURT
    sta enemy_state, y
    lda #ENEMY_HURT_TIME
    sta enemy_timer, y
    jmp @damage_done

@enemy_dies:
    ; Enemy killed by bomb
    lda #ENEMY_STATE_DYING
    sta enemy_state, y
    lda #ENEMY_DEATH_TIME
    sta enemy_timer, y

@damage_done:
    ldy temp_0                      ; Restore enemy loop index

@next_enemy:
    iny
    cpy #MAX_ENEMIES
    bne @enemy_loop

    ; Restore bomb slot index
    pla
    tax
    rts
.endproc

; ============================================================================
; bomb_draw - Draw all active bomb/explosion sprites
; ============================================================================
; FUSE state: draw 8x8 bomb sprite, flash fuse spark in last 30 frames
; EXPLODING state: draw 2x2 explosion metatile (flashing)
; SMOKE state: draw faded 2x2 smoke (every other frame)
; Clobbers: A, X, Y
; ============================================================================

.proc bomb_draw
    ldx #$00
@loop:
    lda bomb_state, x
    cmp #BOMB_STATE_INACTIVE
    bne @not_inactive
    jmp @next
@not_inactive:

    cmp #BOMB_STATE_FUSE
    bne @not_fuse
    jmp @draw_fuse
@not_fuse:

    cmp #BOMB_STATE_EXPLODING
    bne @not_exploding
    jmp @draw_explosion
@not_exploding:

    cmp #BOMB_STATE_SMOKE
    bne @to_next
    jmp @draw_smoke
@to_next:
    jmp @next

; --- Draw bomb during fuse countdown ---
@draw_fuse:
    txa
    pha

    ldy oam_offset

    ; Draw bomb body (single 8x8 sprite)
    lda bomb_y, x
    sta $0200, y
    iny
    lda #BOMB_TILE
    sta $0200, y
    iny
    lda #OAM_PALETTE_1              ; Enemy/bomb palette
    sta $0200, y
    iny
    lda bomb_x, x
    sta $0200, y
    iny

    ; Draw fuse spark when timer < 30 (last half second, flashing)
    lda bomb_timer, x
    cmp #30
    bcs @no_fuse_spark              ; Timer >= 30, no spark yet
    ; Flash the spark on even frames
    lda frame_counter
    and #$02
    bne @no_fuse_spark

    ; Fuse spark sprite (above and right of bomb)
    lda bomb_y, x
    sec
    sbc #6                          ; Spark above bomb
    sta $0200, y
    iny
    lda #BOMB_FUSE_TILE
    sta $0200, y
    iny
    lda #OAM_PALETTE_3              ; Bright palette for spark
    sta $0200, y
    iny
    lda bomb_x, x
    clc
    adc #4                          ; Spark offset right
    sta $0200, y
    iny

@no_fuse_spark:
    sty oam_offset

    pla
    tax
    jmp @next

; --- Draw explosion (2x2 metatile, flashing) ---
@draw_explosion:
    ; Flash rapidly during explosion
    lda frame_counter
    and #$01
    bne @to_next2                   ; Skip odd frames for intense flash

    txa
    pha

    ldy oam_offset

    ; Explosion: 4 sprites forming a 16x16 metatile centered on bomb
    ; Sprite 0: Top-left
    lda bomb_y, x
    sec
    sbc #8                          ; Explosion centered on bomb position
    sta $0200, y
    iny
    lda #EXPLOSION_TILE_BASE
    sta $0200, y
    iny
    lda #OAM_PALETTE_3              ; Bright explosion palette
    sta $0200, y
    iny
    lda bomb_x, x
    sec
    sbc #8
    sta $0200, y
    iny

    ; Sprite 1: Top-right
    lda bomb_y, x
    sec
    sbc #8
    sta $0200, y
    iny
    lda #(EXPLOSION_TILE_BASE + 1)
    sta $0200, y
    iny
    lda #OAM_PALETTE_3
    sta $0200, y
    iny
    lda bomb_x, x
    sta $0200, y
    iny

    ; Sprite 2: Bottom-left
    lda bomb_y, x
    sta $0200, y
    iny
    lda #(EXPLOSION_TILE_BASE + 2)
    sta $0200, y
    iny
    lda #OAM_PALETTE_3
    sta $0200, y
    iny
    lda bomb_x, x
    sec
    sbc #8
    sta $0200, y
    iny

    ; Sprite 3: Bottom-right
    lda bomb_y, x
    sta $0200, y
    iny
    lda #(EXPLOSION_TILE_BASE + 3)
    sta $0200, y
    iny
    lda #OAM_PALETTE_3
    sta $0200, y
    iny
    lda bomb_x, x
    sta $0200, y
    iny

    sty oam_offset

    pla
    tax
    jmp @next

@to_next2:
    jmp @next

; --- Draw smoke (faded, every other frame for fade-out effect) ---
@draw_smoke:
    ; Only draw every other frame for fading effect
    lda frame_counter
    and #$01
    bne @to_next3

    txa
    pha

    ldy oam_offset

    ; Smoke: reuse explosion tiles but behind BG, dimmer palette
    ; Sprite 0: Top-left
    lda bomb_y, x
    sec
    sbc #8
    sta $0200, y
    iny
    lda #EXPLOSION_TILE_BASE
    sta $0200, y
    iny
    lda #(OAM_PALETTE_0 | OAM_BEHIND_BG) ; Behind BG, dim palette
    sta $0200, y
    iny
    lda bomb_x, x
    sec
    sbc #8
    sta $0200, y
    iny

    ; Sprite 1: Top-right
    lda bomb_y, x
    sec
    sbc #8
    sta $0200, y
    iny
    lda #(EXPLOSION_TILE_BASE + 1)
    sta $0200, y
    iny
    lda #(OAM_PALETTE_0 | OAM_BEHIND_BG)
    sta $0200, y
    iny
    lda bomb_x, x
    sta $0200, y
    iny

    ; Sprite 2: Bottom-left
    lda bomb_y, x
    sta $0200, y
    iny
    lda #(EXPLOSION_TILE_BASE + 2)
    sta $0200, y
    iny
    lda #(OAM_PALETTE_0 | OAM_BEHIND_BG)
    sta $0200, y
    iny
    lda bomb_x, x
    sec
    sbc #8
    sta $0200, y
    iny

    ; Sprite 3: Bottom-right
    lda bomb_y, x
    sta $0200, y
    iny
    lda #(EXPLOSION_TILE_BASE + 3)
    sta $0200, y
    iny
    lda #(OAM_PALETTE_0 | OAM_BEHIND_BG)
    sta $0200, y
    iny
    lda bomb_x, x
    sta $0200, y
    iny

    sty oam_offset

    pla
    tax
    jmp @next

@to_next3:
    ; Fall through to @next

@next:
    inx
    cpx #MAX_BOMBS
    beq @done
    jmp @loop
@done:
    rts
.endproc
