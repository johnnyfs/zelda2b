; ============================================================================
; init.s — Hardware Initialization + Boot
; ============================================================================
; Standard NES boot sequence:
;   1. Disable IRQ, set stack pointer
;   2. Disable PPU rendering + NMI
;   3. Wait two vblanks (PPU warmup)
;   4. Clear RAM
;   5. Jump to main_init then main_loop
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.import main_init, main_loop

.export reset

.segment "PRG_FIXED"

; ============================================================================
; reset — Entry point after power-on / reset
; ============================================================================
.proc reset
    sei                     ; Disable IRQs
    cld                     ; Clear decimal mode (not used on NES, but safe)

    ; Disable PPU
    lda #$00
    sta PPUCTRL             ; Disable NMI
    sta PPUMASK             ; Disable rendering

    ; Disable DMC IRQs
    sta $4010

    ; Set up stack
    ldx #$FF
    txs

    ; --- First vblank wait (PPU warmup) ---
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; --- Clear all RAM ($0000-$07FF) ---
    lda #$00
    ldx #$00
@clear_ram:
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne @clear_ram

    ; --- Second vblank wait ---
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; --- Initialize game systems and enter main loop ---
    jsr main_init
    jmp main_loop           ; Never returns
.endproc
