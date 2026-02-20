; ============================================================================
; nmi.s — NMI (Vblank) Interrupt Handler
; ============================================================================
; Runs every vblank (~60Hz NTSC). Does time-critical PPU work:
;   1. OAM DMA (copy shadow OAM to PPU)
;   2. Flush PPU write buffer
;   3. Set scroll position
;   4. Write shadow PPUCTRL/PPUMASK
;   5. Signal main loop (nmi_ready = 1)
;   6. Increment frame counter
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.import ppu_buf_flush

.export nmi, irq

.segment "PRG_FIXED"

; ============================================================================
; nmi — NMI handler
; ============================================================================
.proc nmi
    ; Save registers
    pha
    txa
    pha
    tya
    pha

    ; --- 1. OAM DMA ---
    ; Copy 256 bytes from $0200 to PPU OAM
    lda #$00
    sta OAMADDR             ; Start at OAM address 0
    lda #>OAM_BUF           ; High byte of $0200 = $02
    sta OAMDMA              ; Triggers DMA (takes ~513 CPU cycles)

    ; --- 2. Flush PPU buffer ---
    jsr ppu_buf_flush

    ; --- 3. Set scroll position ---
    bit PPUSTATUS           ; Reset address latch
    lda scroll_x
    sta PPUSCROLL
    lda scroll_y
    sta PPUSCROLL

    ; --- 4. Write shadow PPU registers ---
    lda nmi_ctrl
    sta PPUCTRL
    lda nmi_mask
    sta PPUMASK

    ; --- 5. Signal main loop ---
    lda #1
    sta nmi_ready

    ; --- 6. Increment frame counter ---
    inc frame_counter

    ; Restore registers
    pla
    tay
    pla
    tax
    pla
    rti
.endproc

; ============================================================================
; irq — IRQ handler
; ============================================================================
; MMC3 scanline counter IRQ. For now, just acknowledge and return.
; Will be used for mid-screen scroll splits (status bar, etc.) later.
; ============================================================================
.proc irq
    pha
    ; Acknowledge MMC3 IRQ by writing to $E000 (disable) then $E001 (enable)
    ; For now we just disable
    lda #0
    sta $E000               ; Acknowledge IRQ
    pla
    rti
.endproc
