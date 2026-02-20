; ============================================================================
; vectors.s — CPU Interrupt Vectors
; ============================================================================
; These 6 bytes at $FFFA-$FFFF tell the CPU where to jump on:
;   $FFFA-$FFFB = NMI (vblank)
;   $FFFC-$FFFD = RESET (power-on / reset button)
;   $FFFE-$FFFF = IRQ/BRK
; ============================================================================

.import reset, nmi, irq

.segment "VECTORS"
    .addr nmi               ; $FFFA — NMI vector
    .addr reset             ; $FFFC — Reset vector
    .addr irq               ; $FFFE — IRQ vector
