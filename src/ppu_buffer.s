; ============================================================================
; ppu_buffer.s — PPU Write Buffer System
; ============================================================================
; Queue PPU writes during game logic, flush them during NMI (vblank).
; This ensures all PPU writes happen in the safe vblank window.
;
; Buffer format: parallel arrays of (addr_hi, addr_lo, data).
; Max 32 writes per frame (well within vblank budget).
;
; Public API:
;   ppu_buf_reset  — Clear the buffer (call at start of frame)
;   ppu_buf_put    — Queue one byte: A=data, X=addr_hi, Y=addr_lo
;   ppu_buf_flush  — Write all queued bytes to PPU (called by NMI)
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.export ppu_buf_reset, ppu_buf_put, ppu_buf_flush

.segment "PRG_FIXED_C"

; ============================================================================
; ppu_buf_reset — Clear the PPU write buffer
; ============================================================================
.proc ppu_buf_reset
    lda #0
    sta ppu_buf_len
    rts
.endproc

; ============================================================================
; ppu_buf_put — Queue a single PPU write
; Input: A = data byte, X = PPU address high, Y = PPU address low
; Clobbers: nothing (saves/restores as needed)
; ============================================================================
.proc ppu_buf_put
    pha                     ; Save data byte
    ; Get current buffer index
    stx tmp0                ; Save addr_hi temporarily
    ldx ppu_buf_len
    ; Store address high
    lda tmp0
    sta ppu_buf_hi, x
    ; Store address low
    tya
    sta ppu_buf_lo, x
    ; Store data
    pla                     ; Recover data byte
    sta ppu_buf_data, x
    ; Increment length
    inc ppu_buf_len
    rts
.endproc

; ============================================================================
; ppu_buf_flush — Write all buffered bytes to PPU
; Called during NMI. Assumes PPU rendering is in vblank.
; Clobbers: A, X, Y
; ============================================================================
.proc ppu_buf_flush
    ldx ppu_buf_len
    beq @done               ; Nothing to flush

    ldx #0
@loop:
    cpx ppu_buf_len
    beq @finish

    ; Set PPU address
    bit PPUSTATUS           ; Reset address latch
    lda ppu_buf_hi, x
    sta PPUADDR
    lda ppu_buf_lo, x
    sta PPUADDR

    ; Write data
    lda ppu_buf_data, x
    sta PPUDATA

    inx
    jmp @loop

@finish:
    ; Clear buffer
    lda #0
    sta ppu_buf_len
@done:
    rts
.endproc
