; ============================================================================
; macros.inc - Common Assembly Macros
; ============================================================================
; Utility macros for NES development with the MMC3 mapper.
; ============================================================================

.ifndef MACROS_INC
MACROS_INC = 1

.include "nes.inc"
.include "mmc3.inc"

; ============================================================================
; SET_PPU_ADDR - Set the PPU address for VRAM read/write
; Usage: SET_PPU_ADDR $2000
; Clobbers: A
; ============================================================================
.macro SET_PPU_ADDR addr
    lda PPUSTATUS           ; Reset address latch
    lda #>addr              ; High byte first
    sta PPUADDR
    lda #<addr              ; Low byte second
    sta PPUADDR
.endmacro

; ============================================================================
; SWITCH_PRG_BANK - Switch PRG ROM bank at $8000-$9FFF
; Usage: SWITCH_PRG_BANK bank_number
; Clobbers: A
; ============================================================================
.macro SWITCH_PRG_BANK bank_num
    lda #MMC3_REG_PRG_0 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    lda #bank_num
    sta MMC3_BANK_DATA
.endmacro

; ============================================================================
; SWITCH_PRG_BANK_1 - Switch PRG ROM bank at $A000-$BFFF
; Usage: SWITCH_PRG_BANK_1 bank_number
; Clobbers: A
; ============================================================================
.macro SWITCH_PRG_BANK_1 bank_num
    lda #MMC3_REG_PRG_1 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    lda #bank_num
    sta MMC3_BANK_DATA
.endmacro

; ============================================================================
; SWITCH_CHR_2K - Switch a 2KB CHR bank
; Usage: SWITCH_CHR_2K slot, bank_number
;   slot: 0 or 1 (which 2KB slot)
; Clobbers: A
; ============================================================================
.macro SWITCH_CHR_2K slot, bank_num
    lda #(slot) | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    lda #bank_num
    sta MMC3_BANK_DATA
.endmacro

; ============================================================================
; SWITCH_CHR_1K - Switch a 1KB CHR bank
; Usage: SWITCH_CHR_1K slot, bank_number
;   slot: 0-3 (which 1KB slot, mapped to registers 2-5)
; Clobbers: A
; ============================================================================
.macro SWITCH_CHR_1K slot, bank_num
    lda #((slot) + 2) | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    lda #bank_num
    sta MMC3_BANK_DATA
.endmacro

; ============================================================================
; PUSH_BANKS - Save current bank configuration to the stack
; Saves the shadow copies of current PRG/CHR bank selections
; Clobbers: A
; ============================================================================
.macro PUSH_BANKS
    lda current_prg_bank_0
    pha
    lda current_prg_bank_1
    pha
.endmacro

; ============================================================================
; POP_BANKS - Restore bank configuration from the stack
; Restores previously saved PRG bank selections
; Clobbers: A
; ============================================================================
.macro POP_BANKS
    ; Restore PRG bank 1 ($A000-$BFFF)
    pla
    sta current_prg_bank_1
    pha                         ; Keep on stack temporarily
    lda #MMC3_REG_PRG_1 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA

    ; Restore PRG bank 0 ($8000-$9FFF)
    pla
    sta current_prg_bank_0
    pha                         ; Keep on stack temporarily
    lda #MMC3_REG_PRG_0 | MMC3_PRG_MODE_0
    sta MMC3_BANK_SELECT
    pla
    sta MMC3_BANK_DATA
.endmacro

; ============================================================================
; VRAM_WRITE - Write a single byte to VRAM at a given address
; Usage: VRAM_WRITE addr, value
; Clobbers: A
; ============================================================================
.macro VRAM_WRITE addr, value
    SET_PPU_ADDR addr
    lda #value
    sta PPUDATA
.endmacro

; ============================================================================
; SET_SCROLL - Set PPU scroll position
; Usage: SET_SCROLL xpos, ypos
; Clobbers: A
; ============================================================================
.macro SET_SCROLL xpos, ypos
    lda #xpos
    sta PPUSCROLL
    lda #ypos
    sta PPUSCROLL
.endmacro

.endif ; MACROS_INC
