; ============================================================================
; mmc3.s — MMC3 Bank Switching Routines
; ============================================================================
; Provides routines to switch PRG and CHR banks on the MMC3 mapper.
;
; MMC3 bank layout (PRG mode 0, our default):
;   $8000-$9FFF: Swappable 8KB PRG bank (R6)
;   $A000-$BFFF: Swappable 8KB PRG bank (R7)
;   $C000-$DFFF: Fixed to second-to-last bank (bank 30)
;   $E000-$FFFF: Fixed to last bank (bank 31)
;
; Public API:
;   mmc3_init        — Initialize MMC3 to default state
;   mmc3_set_prg_8000 — Set PRG bank at $8000 (A = bank number 0-29)
;   mmc3_set_prg_a000 — Set PRG bank at $A000 (A = bank number 0-29)
;   mmc3_set_chr_2k_0 — Set 2KB CHR bank at $0000 (A = bank number, even)
;   mmc3_set_chr_2k_1 — Set 2KB CHR bank at $0800 (A = bank number, even)
;   mmc3_set_chr_1k   — Set 1KB CHR bank (X = register 2-5, A = bank number)
;   mmc3_enable_sram   — Enable battery-backed SRAM at $6000-$7FFF
;   mmc3_set_mirroring — Set nametable mirroring (A: 0=vert, 1=horiz)
; ============================================================================

.include "mmc3.inc"
.include "globals.inc"

.export mmc3_init, mmc3_set_prg_8000, mmc3_set_prg_a000
.export mmc3_set_chr_2k_0, mmc3_set_chr_2k_1, mmc3_set_chr_1k
.export mmc3_enable_sram, mmc3_set_mirroring

.segment "PRG_FIXED_C"

; ============================================================================
; mmc3_init — Set up MMC3 to known default state
; ============================================================================
.proc mmc3_init
    ; PRG mode 0 (bit 6=0): $8000 swappable, $C000 fixed
    ; CHR mode 0 (bit 7=0): 2KB banks at $0000/$0800, 1KB at $1000-$1C00
    lda #MMC3_PRG_MODE_0 | MMC3_CHR_MODE_0
    sta mmc3_bank_select

    ; Set PRG bank 0 at $8000
    lda #MMC3_R6_PRG_8K_0
    sta MMC3_BANK_SELECT
    lda #0
    sta MMC3_BANK_DATA
    sta current_prg_bank

    ; Set PRG bank 1 at $A000
    lda #MMC3_R7_PRG_8K_1
    sta MMC3_BANK_SELECT
    lda #1
    sta MMC3_BANK_DATA

    ; Set CHR banks to identity mapping
    ; R0: 2KB CHR bank 0 at $0000
    lda #MMC3_R0_CHR_2K_0
    sta MMC3_BANK_SELECT
    lda #0
    sta MMC3_BANK_DATA

    ; R1: 2KB CHR bank 2 at $0800
    lda #MMC3_R1_CHR_2K_1
    sta MMC3_BANK_SELECT
    lda #2
    sta MMC3_BANK_DATA

    ; R2-R5: 1KB CHR banks 4-7 at $1000-$1C00
    lda #MMC3_R2_CHR_1K_0
    sta MMC3_BANK_SELECT
    lda #4
    sta MMC3_BANK_DATA

    lda #MMC3_R3_CHR_1K_1
    sta MMC3_BANK_SELECT
    lda #5
    sta MMC3_BANK_DATA

    lda #MMC3_R4_CHR_1K_2
    sta MMC3_BANK_SELECT
    lda #6
    sta MMC3_BANK_DATA

    lda #MMC3_R5_CHR_1K_3
    sta MMC3_BANK_SELECT
    lda #7
    sta MMC3_BANK_DATA

    ; Vertical mirroring (default)
    lda #MMC3_MIRROR_VERT
    sta MMC3_MIRRORING

    ; Disable scanline IRQ
    sta MMC3_IRQ_DISABLE

    ; Enable SRAM
    jmp mmc3_enable_sram
.endproc

; ============================================================================
; mmc3_set_prg_8000 — Swap 8KB PRG bank at $8000-$9FFF
; Input: A = bank number (0-29)
; ============================================================================
.proc mmc3_set_prg_8000
    pha
    lda mmc3_bank_select
    and #%11111000          ; Clear register bits
    ora #MMC3_R6_PRG_8K_0   ; Select R6
    sta MMC3_BANK_SELECT
    sta mmc3_bank_select
    pla
    sta MMC3_BANK_DATA
    sta current_prg_bank
    rts
.endproc

; ============================================================================
; mmc3_set_prg_a000 — Swap 8KB PRG bank at $A000-$BFFF
; Input: A = bank number (0-29)
; ============================================================================
.proc mmc3_set_prg_a000
    pha
    lda mmc3_bank_select
    and #%11111000
    ora #MMC3_R7_PRG_8K_1   ; Select R7
    sta MMC3_BANK_SELECT
    sta mmc3_bank_select
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; mmc3_set_chr_2k_0 — Swap 2KB CHR bank at $0000-$07FF
; Input: A = CHR bank number (must be even)
; ============================================================================
.proc mmc3_set_chr_2k_0
    pha
    lda mmc3_bank_select
    and #%11111000
    ora #MMC3_R0_CHR_2K_0
    sta MMC3_BANK_SELECT
    sta mmc3_bank_select
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; mmc3_set_chr_2k_1 — Swap 2KB CHR bank at $0800-$0FFF
; Input: A = CHR bank number (must be even)
; ============================================================================
.proc mmc3_set_chr_2k_1
    pha
    lda mmc3_bank_select
    and #%11111000
    ora #MMC3_R1_CHR_2K_1
    sta MMC3_BANK_SELECT
    sta mmc3_bank_select
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; mmc3_set_chr_1k — Swap 1KB CHR bank
; Input: X = register (2-5), A = CHR bank number
; ============================================================================
.proc mmc3_set_chr_1k
    pha
    lda mmc3_bank_select
    and #%11111000
    stx tmp0
    ora tmp0                ; OR in register number
    sta MMC3_BANK_SELECT
    sta mmc3_bank_select
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; mmc3_enable_sram — Enable battery-backed SRAM at $6000-$7FFF
; ============================================================================
.proc mmc3_enable_sram
    lda #MMC3_SRAM_ENABLE | MMC3_SRAM_WRITABLE
    sta MMC3_PRG_RAM_CTRL
    rts
.endproc

; ============================================================================
; mmc3_set_mirroring — Set nametable mirroring
; Input: A = 0 (vertical) or 1 (horizontal)
; ============================================================================
.proc mmc3_set_mirroring
    sta MMC3_MIRRORING
    rts
.endproc
