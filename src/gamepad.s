; ============================================================================
; gamepad.s - NES Controller Reading
; ============================================================================
; Reads both controllers, stores current state, previous state, and
; computes newly-pressed buttons (just-pressed detection).
; Runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.segment "PRG_FIXED"

; ============================================================================
; read_gamepads - Read both controllers
; ============================================================================
; Reads controller state via the standard strobe protocol.
; Updates: pad1_state, pad1_prev, pad1_pressed, pad2_state, pad2_prev, pad2_pressed
; Clobbers: A, X
; ============================================================================

.proc read_gamepads
    ; --- Save previous frame's state ---
    lda pad1_state
    sta pad1_prev
    lda pad2_state
    sta pad2_prev

    ; --- Strobe controllers ---
    ; Write 1 then 0 to $4016 to latch current button state
    lda #$01
    sta JOYPAD1
    lda #$00
    sta JOYPAD1

    ; --- Read controller 1 (8 buttons) ---
    ; Standard read: each read of $4016 returns one button in bit 0.
    ; Read order: A, B, Select, Start, Up, Down, Left, Right
    ; We read twice per button to handle DPCM conflict (standard technique).
    ldx #$08
    lda #$00
    sta pad1_state
@read_pad1:
    lda JOYPAD1
    lsr a                   ; Bit 0 -> carry
    rol pad1_state          ; Rotate carry into result
    dex
    bne @read_pad1

    ; --- Read controller 2 (8 buttons) ---
    ldx #$08
    lda #$00
    sta pad2_state
@read_pad2:
    lda JOYPAD2
    lsr a                   ; Bit 0 -> carry
    rol pad2_state          ; Rotate carry into result
    dex
    bne @read_pad2

    ; --- Compute just-pressed (buttons that are down now but weren't before) ---
    ; pressed = current AND (NOT previous) = current AND (current XOR previous)
    ; This gives us buttons that transitioned from 0 to 1 this frame.
    lda pad1_state
    eor pad1_prev           ; Bits that changed
    and pad1_state          ; Only keep bits that are currently pressed
    sta pad1_pressed

    lda pad2_state
    eor pad2_prev
    and pad2_state
    sta pad2_pressed

    rts
.endproc
