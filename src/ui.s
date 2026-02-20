; ============================================================================
; ui.s — UI System (title, pause, dialog stubs)
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.export title_init, title_update
.export pause_update
.export dialog_init, dialog_update

.segment "PRG_FIXED"

.proc title_init
    ; Stub: Would draw title screen
    rts
.endproc

.proc title_update
    ; Stub: Wait for START, then transition to PLAY
    lda gamepad_press
    and #BUTTON_START
    beq :+
    lda #GAME_STATE_PLAY
    sta game_state
:   rts
.endproc

.proc pause_update
    ; Stub: Wait for START to unpause
    lda gamepad_press
    and #BUTTON_START
    beq :+
    lda #GAME_STATE_PLAY
    sta game_state
:   rts
.endproc

.proc dialog_init
    ; Stub
    rts
.endproc

.proc dialog_update
    ; Stub
    rts
.endproc
