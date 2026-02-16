; ============================================================================
; enemies/enemy_types.s - Enemy AI Routines
; ============================================================================
; AI behavior for each enemy type. Called from enemy_update with X = slot.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"

; Screen boundaries for enemy movement (same as player)
ENEMY_SCREEN_TOP    = 24       ; Below status bar + margin
ENEMY_SCREEN_BOTTOM = 216      ; Above bottom edge
ENEMY_SCREEN_LEFT   = 16       ; Inside border
ENEMY_SCREEN_RIGHT  = 232      ; Inside border

.segment "PRG_FIXED"

; ============================================================================
; enemy_ai_octorok - Octorok wandering AI
; ============================================================================
; Behavior: Moves 1px/frame in current direction. Every ENEMY_WANDER_TIME
; frames, picks a new random direction. Reverses if hitting screen edge.
;
; Input: X = enemy slot index (preserved for caller)
; Clobbers: A, Y (X preserved on entry, but we use it via stack)
; ============================================================================

.proc enemy_ai_octorok
    ; X = slot index from caller (saved on stack by enemy_update)

    ; --- Wander timer ---
    dec enemy_timer, x
    bne @move                   ; Timer not expired, keep moving
    ; Timer expired: pick new direction
    lda #ENEMY_WANDER_TIME
    sta enemy_timer, x

    ; "Random" direction from frame_counter XOR'd with enemy position
    lda frame_counter
    eor enemy_x, x
    eor enemy_y, x
    and #$03                    ; 0-3 maps to DIR_UP..DIR_RIGHT
    sta enemy_dir, x

@move:
    ; --- Move in current direction ---
    lda enemy_dir, x

    cmp #DIR_UP
    beq @move_up
    cmp #DIR_DOWN
    beq @move_down
    cmp #DIR_LEFT
    beq @move_left
    cmp #DIR_RIGHT
    beq @move_right
    rts                         ; Unknown direction, bail

@move_up:
    lda enemy_y, x
    sec
    sbc #OCTOROK_SPEED
    cmp #ENEMY_SCREEN_TOP
    bcc @reverse                ; Hit top edge
    sta enemy_y, x
    rts

@move_down:
    lda enemy_y, x
    clc
    adc #OCTOROK_SPEED
    cmp #ENEMY_SCREEN_BOTTOM
    bcs @reverse                ; Hit bottom edge
    sta enemy_y, x
    rts

@move_left:
    lda enemy_x, x
    sec
    sbc #OCTOROK_SPEED
    cmp #ENEMY_SCREEN_LEFT
    bcc @reverse                ; Hit left edge
    sta enemy_x, x
    rts

@move_right:
    lda enemy_x, x
    clc
    adc #OCTOROK_SPEED
    cmp #ENEMY_SCREEN_RIGHT
    bcs @reverse                ; Hit right edge
    sta enemy_x, x
    rts

@reverse:
    ; Reverse direction: UP<->DOWN, LEFT<->RIGHT
    lda enemy_dir, x
    eor #$01                    ; Flip bit 0: UP(0)<->DOWN(1), LEFT(2)<->RIGHT(3)
    sta enemy_dir, x
    rts
.endproc
