; ============================================================================
; gamepad.s — Controller Input Reading
; ============================================================================
; Reads the NES controller 1 and provides:
;   gamepad       — current frame button state
;   gamepad_prev  — previous frame button state
;   gamepad_press — newly pressed buttons (rising edge)
;
; Public API:
;   gamepad_read — Read controller and update all three variables
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.export gamepad_read

.segment "PRG_FIXED_C"

; ============================================================================
; gamepad_read — Read controller 1
; Call once per frame (in main loop, before game logic).
; Clobbers: A, X
; ============================================================================
.proc gamepad_read
    ; Save previous state
    lda gamepad
    sta gamepad_prev

    ; Strobe controller
    lda #$01
    sta JOY1
    lda #$00
    sta JOY1

    ; Read 8 buttons into gamepad (A, B, Select, Start, Up, Down, Left, Right)
    ldx #8
    lda #0
@loop:
    pha
    lda JOY1
    and #%00000001          ; Bit 0 = button state
    ; Shift into carry
    cmp #$01                ; C=1 if button pressed
    pla
    rol                     ; Rotate carry into bit 0
    dex
    bne @loop
    sta gamepad

    ; Calculate newly pressed buttons
    ; press = gamepad AND (NOT gamepad_prev)
    lda gamepad_prev
    eor #$FF                ; NOT
    and gamepad
    sta gamepad_press

    rts
.endproc
