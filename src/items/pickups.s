; ============================================================================
; items/pickups.s - Collectible Pickup System
; ============================================================================
; Manages up to MAX_PICKUPS (4) ground pickups using parallel arrays.
; Pickups are spawned when enemies die and collected on player contact.
; Currently supports heart pickups that restore 1 HP.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"
.include "audio.inc"

.segment "PRG_FIXED"

; ============================================================================
; pickup_init - Clear all pickup slots
; ============================================================================
; Clobbers: A, X
; ============================================================================

.proc pickup_init
    ldx #MAX_PICKUPS - 1
@loop:
    lda #PICKUP_STATE_INACTIVE
    sta pickup_state, x
    lda #PICKUP_NONE
    sta pickup_type, x
    lda #$00
    sta pickup_x, x
    sta pickup_y, x
    sta pickup_timer, x
    dex
    bpl @loop
    rts
.endproc

; ============================================================================
; pickup_spawn - Spawn a pickup at a given position
; ============================================================================
; Input:
;   A      = pickup type (PICKUP_HEART, etc.)
;   temp_2 = X position
;   temp_3 = Y position
;
; Finds first inactive slot and fills it. If all slots full, does nothing.
; Clobbers: A, X
; ============================================================================

.proc pickup_spawn
    ; Save type in temp_0
    sta temp_0

    ; Find first inactive slot
    ldx #$00
@find_slot:
    lda pickup_state, x
    cmp #PICKUP_STATE_INACTIVE
    beq @found
    inx
    cpx #MAX_PICKUPS
    bne @find_slot
    rts                         ; No free slot, silently fail

@found:
    lda temp_2
    sta pickup_x, x
    lda temp_3
    sta pickup_y, x
    lda temp_0
    sta pickup_type, x
    lda #PICKUP_STATE_SPAWNING
    sta pickup_state, x
    lda #PICKUP_SPAWN_TIME
    sta pickup_timer, x
    rts
.endproc

; ============================================================================
; pickup_update - Update all active pickups
; ============================================================================
; Handles spawn animation timer and player collection check.
; Clobbers: A, X
; ============================================================================

.proc pickup_update
    ldx #$00
@loop:
    lda pickup_state, x
    cmp #PICKUP_STATE_INACTIVE
    beq @next

    cmp #PICKUP_STATE_SPAWNING
    beq @update_spawning

    ; PICKUP_STATE_ACTIVE - check player collection
    jsr check_collect
    jmp @next

@update_spawning:
    dec pickup_timer, x
    bne @next
    ; Spawn animation done - become active
    lda #PICKUP_STATE_ACTIVE
    sta pickup_state, x

@next:
    inx
    cpx #MAX_PICKUPS
    bne @loop
    rts
.endproc

; ============================================================================
; check_collect - Check if player overlaps this pickup
; ============================================================================
; Input: X = pickup slot index
; If overlapping, applies pickup effect and deactivates slot.
; Clobbers: A (X preserved)
; ============================================================================

.proc check_collect
    ; AABB overlap: |player_x - pickup_x| < PICKUP_COLLECT_DIST
    ;             AND |player_y - pickup_y| < PICKUP_COLLECT_DIST

    ; Check X distance
    lda player_x
    sec
    sbc pickup_x, x
    bpl @x_pos
    eor #$FF
    clc
    adc #$01
@x_pos:
    cmp #PICKUP_COLLECT_DIST
    bcs @no_collect

    ; Check Y distance
    lda player_y
    sec
    sbc pickup_y, x
    bpl @y_pos
    eor #$FF
    clc
    adc #$01
@y_pos:
    cmp #PICKUP_COLLECT_DIST
    bcs @no_collect

    ; --- COLLECTED! ---
    ; Apply effect based on type
    lda pickup_type, x
    cmp #PICKUP_HEART
    beq @collect_heart
    ; Future: other pickup types here
    jmp @deactivate

@collect_heart:
    ; Restore 1 HP (capped at max)
    lda player_hp
    cmp player_max_hp
    bcs @deactivate             ; Already at max HP, still collect but no heal
    inc player_hp

@deactivate:
    ; Deactivate slot
    lda #PICKUP_STATE_INACTIVE
    sta pickup_state, x

    ; Play pickup SFX
    txa
    pha
    lda #SFX_PICKUP
    ldx #SFX_CHAN_GAMEPLAY
    jsr audio_play_sfx
    pla
    tax

@no_collect:
    rts
.endproc

; ============================================================================
; pickup_draw - Draw all active pickup sprites
; ============================================================================
; Each pickup is a single 8x8 sprite (small collectible).
; Spawning pickups bob/flash. Active pickups are steady.
; Clobbers: A, X, Y
; ============================================================================

.proc pickup_draw
    ldx #$00
@loop:
    lda pickup_state, x
    cmp #PICKUP_STATE_INACTIVE
    beq @next

    ; Spawning pickups flash
    cmp #PICKUP_STATE_SPAWNING
    bne @do_draw
    lda frame_counter
    and #$01
    bne @next                   ; Flash: skip odd frames

@do_draw:
    ; Write one OAM sprite entry
    ldy oam_offset

    ; Y position
    lda pickup_y, x
    sta $0200, y
    iny

    ; Tile index based on type
    lda pickup_type, x
    cmp #PICKUP_HEART
    bne @default_tile
    lda #PICKUP_HEART_TILE
    jmp @write_tile
@default_tile:
    lda #PICKUP_HEART_TILE      ; Fallback
@write_tile:
    sta $0200, y
    iny

    ; Attributes: items palette (palette 2 = blue/items)
    lda #OAM_PALETTE_2
    sta $0200, y
    iny

    ; X position
    lda pickup_x, x
    sta $0200, y
    iny

    sty oam_offset

@next:
    inx
    cpx #MAX_PICKUPS
    bne @loop
    rts
.endproc
