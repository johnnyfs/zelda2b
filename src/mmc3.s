; ============================================================================
; mmc3.s - MMC3 (Mapper 4) Bank Switching Routines
; ============================================================================
; Provides callable routines for switching PRG and CHR banks.
; All routines update shadow variables so current bank state is always known.
; Runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "mmc3.inc"
.include "globals.inc"

.segment "PRG_FIXED"

; ============================================================================
; init_mmc3 - Initialize MMC3 mapper to a known state
; ============================================================================
; Sets PRG mode 0 ($8000 swappable, $C000 fixed), CHR mode 0,
; maps PRG bank 0 to $8000, PRG bank 1 to $A000,
; enables PRG-RAM, sets vertical mirroring, and configures initial CHR.
; ============================================================================

.proc init_mmc3
    ; Set PRG bank 0 at $8000-$9FFF
    lda #MMC3_REG_PRG_0 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    lda #$00
    sta MMC3_BANK_DATA
    sta current_prg_bank_0

    ; Set PRG bank 1 at $A000-$BFFF
    lda #MMC3_REG_PRG_1 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    lda #$01
    sta MMC3_BANK_DATA
    sta current_prg_bank_1

    ; Set CHR 2KB bank 0 at $0000-$07FF (BG tiles)
    lda #MMC3_REG_CHR_2K_0 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    lda #$00                    ; CHR bank 0 (first 2KB)
    sta MMC3_BANK_DATA

    ; Set CHR 2KB bank 1 at $0800-$0FFF (more BG tiles)
    lda #MMC3_REG_CHR_2K_1 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    lda #$02                    ; CHR bank 2 (second 2KB)
    sta MMC3_BANK_DATA

    ; Set CHR 1KB banks at $1000-$1FFF (sprite tiles)
    lda #MMC3_REG_CHR_1K_0 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    lda #$08                    ; CHR bank 8
    sta MMC3_BANK_DATA

    lda #MMC3_REG_CHR_1K_1 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    lda #$09
    sta MMC3_BANK_DATA

    lda #MMC3_REG_CHR_1K_2 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    lda #$0A
    sta MMC3_BANK_DATA

    lda #MMC3_REG_CHR_1K_3 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    lda #$0B
    sta MMC3_BANK_DATA

    ; Set vertical mirroring
    lda #MMC3_MIRROR_VERTICAL
    sta MMC3_MIRRORING

    ; Enable PRG-RAM (for save data)
    lda #MMC3_PRGRAM_ENABLE
    sta MMC3_PRG_RAM_CTRL

    ; Disable IRQ initially
    sta MMC3_IRQ_DISABLE

    rts
.endproc

; ============================================================================
; switch_prg_bank_0 - Switch 8KB PRG bank at $8000-$9FFF
; ============================================================================
; Input: A = bank number (0-62)
; Clobbers: A (preserves X, Y)
; ============================================================================

.proc switch_prg_bank_0
    pha
    ; Select PRG bank register 6 (PRG mode 0)
    lda #MMC3_REG_PRG_0 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    sta current_prg_bank_0
    rts
.endproc

; ============================================================================
; switch_prg_bank_1 - Switch 8KB PRG bank at $A000-$BFFF
; ============================================================================
; Input: A = bank number (0-62)
; Clobbers: A (preserves X, Y)
; ============================================================================

.proc switch_prg_bank_1
    pha
    lda #MMC3_REG_PRG_1 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    sta current_prg_bank_1
    rts
.endproc

; ============================================================================
; switch_chr_2k_0 - Switch 2KB CHR bank at $0000-$07FF
; ============================================================================
; Input: A = CHR bank number (even, 0-254)
; Clobbers: A (preserves X, Y)
; ============================================================================

.proc switch_chr_2k_0
    pha
    lda #MMC3_REG_CHR_2K_0 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; switch_chr_2k_1 - Switch 2KB CHR bank at $0800-$0FFF
; ============================================================================
; Input: A = CHR bank number (even, 0-254)
; Clobbers: A (preserves X, Y)
; ============================================================================

.proc switch_chr_2k_1
    pha
    lda #MMC3_REG_CHR_2K_1 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; switch_chr_1k_0 - Switch 1KB CHR bank at $1000-$13FF
; ============================================================================
; Input: A = CHR bank number (0-255)
; Clobbers: A (preserves X, Y)
; ============================================================================

.proc switch_chr_1k_0
    pha
    lda #MMC3_REG_CHR_1K_0 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; switch_chr_1k_1 - Switch 1KB CHR bank at $1400-$17FF
; ============================================================================

.proc switch_chr_1k_1
    pha
    lda #MMC3_REG_CHR_1K_1 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; switch_chr_1k_2 - Switch 1KB CHR bank at $1800-$1BFF
; ============================================================================

.proc switch_chr_1k_2
    pha
    lda #MMC3_REG_CHR_1K_2 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; switch_chr_1k_3 - Switch 1KB CHR bank at $1C00-$1FFF
; ============================================================================

.proc switch_chr_1k_3
    pha
    lda #MMC3_REG_CHR_1K_3 | MMC3_CHR_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
    rts
.endproc

; ============================================================================
; set_mirroring - Set nametable mirroring mode
; ============================================================================
; Input: A = 0 for vertical, 1 for horizontal
; Clobbers: A (preserves X, Y)
; ============================================================================

.proc set_mirroring
    sta MMC3_MIRRORING
    rts
.endproc
