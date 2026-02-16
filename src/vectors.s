; ============================================================================
; vectors.s - CPU Vector Table and IRQ Handler
; ============================================================================
; Defines the three 6502 interrupt vectors at $FFFA-$FFFF.
; The IRQ handler runs in the fixed bank (PRG_FIXED at $E000-$FFF9).
; The vector table itself is in the VECTORS segment at $FFFA-$FFFF.
; ============================================================================

.include "globals.inc"

; ============================================================================
; IRQ Handler (in fixed code bank)
; ============================================================================
; The MMC3 scanline counter triggers IRQ. For now, just acknowledge and return.
; This will be used later for split-screen effects (e.g., HUD at top).
; ============================================================================

.segment "PRG_FIXED"

.proc irq_handler
    pha
    ; Acknowledge MMC3 IRQ by writing to $E000 (disable) then $E001 (enable)
    sta $E000               ; Disable IRQ (acknowledge pending)
    ; Future: scanline effects go here
    pla
    rti
.endproc

; ============================================================================
; Vector Table (placed at $FFFA-$FFFF by the VECTORS segment)
; ============================================================================

.segment "VECTORS"

    .word nmi_handler       ; $FFFA-$FFFB: NMI vector
    .word reset_handler     ; $FFFC-$FFFD: RESET vector
    .word irq_handler       ; $FFFE-$FFFF: IRQ/BRK vector
