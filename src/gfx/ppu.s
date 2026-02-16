; ============================================================================
; gfx/ppu.s - PPU Utility Routines
; ============================================================================
; PPU management routines for palette loading, nametable clearing, VRAM
; string writing, and the deferred PPU write buffer system.
; Runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.segment "PRG_FIXED"

; ============================================================================
; ppu_wait_vblank - Wait for the next vblank
; ============================================================================
; Spins until bit 7 of PPUSTATUS is set (vblank flag).
; Note: For main-loop synchronization, prefer the NMI-driven nmi_ready flag.
; This is for init-time waits before NMI is enabled.
; Clobbers: A
; ============================================================================

.proc ppu_wait_vblank
@wait:
    bit PPUSTATUS
    bpl @wait
    rts
.endproc

; ============================================================================
; ppu_load_palette - Load default palette data into PPU palette RAM
; ============================================================================
; Loads all 32 bytes of palette data (4 BG + 4 sprite palettes) from
; the default_palette table into PPU $3F00-$3F1F.
; Must be called during vblank (rendering disabled or during NMI).
; Clobbers: A, X
; ============================================================================

.proc ppu_load_palette
    lda PPUSTATUS               ; Reset address latch
    lda #>PPU_PALETTES          ; High byte = $3F
    sta PPUADDR
    lda #<PPU_PALETTES          ; Low byte = $00
    sta PPUADDR

    ldx #$00
@loop:
    lda default_palette, x
    sta PPUDATA
    inx
    cpx #$20                    ; 32 bytes total
    bne @loop

    rts
.endproc

; ============================================================================
; ppu_clear_nametable - Clear nametable 0 ($2000) with tile $00
; ============================================================================
; Writes $00 to all 960 tile bytes and $00 to all 64 attribute bytes
; of nametable 0 ($2000-$23FF). Total = 1024 bytes.
; Must be called during vblank (rendering disabled).
; Clobbers: A, X, Y
; ============================================================================

.proc ppu_clear_nametable
    lda PPUSTATUS               ; Reset address latch
    lda #>PPU_NAMETABLE_0       ; $20
    sta PPUADDR
    lda #<PPU_NAMETABLE_0       ; $00
    sta PPUADDR

    ; Write 1024 bytes ($400) of $00
    ; 4 outer loops x 256 inner loops = 1024
    lda #$00
    ldy #$04                    ; Outer loop counter (4 pages)
@outer:
    ldx #$00                    ; Inner loop counter (256 bytes)
@inner:
    sta PPUDATA
    inx
    bne @inner
    dey
    bne @outer

    rts
.endproc

; ============================================================================
; ppu_write_string - Write a null-terminated string of tile indices to VRAM
; ============================================================================
; Input:
;   ptr_lo/ptr_hi = pointer to null-terminated tile data
;   PPUADDR already set to destination address before calling
; Clobbers: A, Y
; ============================================================================

.proc ppu_write_string
    ldy #$00
@loop:
    lda (ptr_lo), y
    beq @done                   ; Null terminator
    sta PPUDATA
    iny
    bne @loop                   ; Max 255 chars per call
@done:
    rts
.endproc

; ============================================================================
; ppu_buffer_write - Add a deferred VRAM write to the PPU buffer
; ============================================================================
; Queues a VRAM write to be processed during the next NMI.
; Buffer format: [addr_hi, addr_lo, length, data...]
;
; Input:
;   A     = number of data bytes (length)
;   ptr_lo/ptr_hi = pointer to data bytes
;   temp_0 = PPU address high byte
;   temp_1 = PPU address low byte
;
; Clobbers: A, X, Y
; ============================================================================

.proc ppu_buffer_write
    ; Store byte count for later
    sta temp_2

    ; Get current buffer write position
    ldx ppu_buffer_len

    ; Write PPU address (high byte first)
    lda temp_0
    sta ppu_buffer, x
    inx

    lda temp_1
    sta ppu_buffer, x
    inx

    ; Write data length
    lda temp_2
    sta ppu_buffer, x
    inx

    ; Copy data bytes from pointer
    ldy #$00
@copy:
    cpy temp_2
    beq @done
    lda (ptr_lo), y
    sta ppu_buffer, x
    inx
    iny
    bne @copy                   ; Safety: max 255

@done:
    ; Update buffer length
    stx ppu_buffer_len

    rts
.endproc
