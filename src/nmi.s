; ============================================================================
; nmi.s - NMI (Non-Maskable Interrupt) Handler
; ============================================================================
; Called every vblank (~60 Hz on NTSC). Performs time-critical PPU updates:
;   1. OAM DMA transfer
;   2. Buffered VRAM writes (future)
;   3. Set scroll position
;   4. Audio update (stub)
;   5. Signal main loop
; This code runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.segment "PRG_FIXED"

; ============================================================================
; NMI Handler
; ============================================================================

.proc nmi_handler
    ; --- Save registers ---
    pha
    txa
    pha
    tya
    pha

    ; --- OAM DMA transfer ---
    ; Copy the 256-byte OAM shadow buffer from $0200 to PPU OAM.
    ; Write $02 (high byte of $0200) to $4014 to trigger DMA.
    lda #$00
    sta OAMADDR             ; Start at OAM address 0
    lda #$02                ; High byte of source address ($0200)
    sta OAMDMA              ; Triggers 256-byte DMA transfer (takes ~513 cycles)

    ; --- Process PPU write buffer (deferred VRAM writes) ---
    ; Check if there are any buffered writes to process
    lda ppu_buffer_len
    beq @no_buffer_writes

    ; Buffer format: [addr_hi, addr_lo, length, data..., ...]
    ; Process each entry
    ldx #$00                ; Buffer read index
@buffer_loop:
    cpx ppu_buffer_len
    bcs @buffer_done

    ; Read PPU address (high byte first)
    lda ppu_buffer, x
    sta PPUADDR
    inx
    lda ppu_buffer, x
    sta PPUADDR
    inx

    ; Read data length
    lda ppu_buffer, x
    inx
    tay                     ; Y = byte count

@data_loop:
    lda ppu_buffer, x
    sta PPUDATA
    inx
    dey
    bne @data_loop

    jmp @buffer_loop

@buffer_done:
    ; Clear the buffer
    lda #$00
    sta ppu_buffer_len

@no_buffer_writes:

    ; --- Set scroll position ---
    ; Must be done after all VRAM writes since writes change the address.
    lda PPUSTATUS           ; Reset PPU address latch
    lda scroll_x
    sta PPUSCROLL
    lda scroll_y
    sta PPUSCROLL

    ; --- Restore PPUCTRL (sets nametable bits for scroll) ---
    lda ppu_ctrl_shadow
    sta PPUCTRL

    ; --- Audio update ---
    jsr audio_update        ; Update FamiStudio sound engine every frame

    ; --- Increment NMI counter ---
    inc nmi_counter

    ; --- Signal main loop that vblank occurred ---
    lda #$01
    sta nmi_ready

    ; --- Restore registers ---
    pla
    tay
    pla
    tax
    pla

    rti
.endproc
