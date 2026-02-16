; ============================================================================
; map_transition.s - Screen Edge Detection and Transition
; ============================================================================
; Checks if the player has reached a screen edge and transitions to the
; adjacent screen if one exists in the map grid.
;
; This code runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"

; Screen edge thresholds (pixel coordinates)
; Map area: Y 16..239 (14 metatile rows below 16px status bar)
EDGE_LEFT   = 0
EDGE_RIGHT  = 240          ; Player X >= this = at right edge
EDGE_TOP    = 18           ; Player Y < this = at top edge (just below status bar)
EDGE_BOTTOM = 224          ; Player Y >= this = at bottom edge

; Entry positions when arriving from adjacent screen
ENTRY_FROM_LEFT   = 232    ; Arriving from left, place near right edge
ENTRY_FROM_RIGHT  = 8      ; Arriving from right, place near left edge
ENTRY_FROM_TOP    = 208    ; Arriving from top, place near bottom
ENTRY_FROM_BOTTOM = 20     ; Arriving from bottom, place just below status bar

.segment "PRG_FIXED"

; ============================================================================
; map_check_transition - Check for screen edge transition
; ============================================================================
; Call once per frame during gameplay.
; Returns: A = 1 if transition occurred, A = 0 if not
; ============================================================================

.proc map_check_transition

    ; --- Check RIGHT edge ---
    lda player_x
    cmp #EDGE_RIGHT
    bcc @not_right

    lda current_screen_x
    clc
    adc #$01
    cmp #MAP_GRID_W_CONST
    bcs @not_right

    inc current_screen_x
    jsr map_get_screen_id
    lda current_screen_id
    jsr map_load_screen
    lda #ENTRY_FROM_RIGHT
    sta player_x
    lda #$01
    rts

@not_right:

    ; --- Check LEFT edge ---
    lda player_x
    cmp #$02
    bcs @not_left

    lda current_screen_x
    beq @not_left

    dec current_screen_x
    jsr map_get_screen_id
    lda current_screen_id
    jsr map_load_screen
    lda #ENTRY_FROM_LEFT
    sta player_x
    lda #$01
    rts

@not_left:

    ; --- Check BOTTOM edge ---
    lda player_y
    cmp #EDGE_BOTTOM
    bcc @not_bottom

    lda current_screen_y
    clc
    adc #$01
    cmp #MAP_GRID_H_CONST
    bcs @not_bottom

    inc current_screen_y
    jsr map_get_screen_id
    lda current_screen_id
    jsr map_load_screen
    lda #ENTRY_FROM_BOTTOM
    sta player_y
    lda #$01
    rts

@not_bottom:

    ; --- Check TOP edge ---
    lda player_y
    cmp #EDGE_TOP
    bcs @not_top

    lda current_screen_y
    beq @not_top

    dec current_screen_y
    jsr map_get_screen_id
    lda current_screen_id
    jsr map_load_screen
    lda #ENTRY_FROM_TOP
    sta player_y
    lda #$01
    rts

@not_top:

    ; No transition
    lda #$00
    rts
.endproc
