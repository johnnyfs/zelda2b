; ============================================================================
; mmc3.inc - MMC3 (Mapper 4) Register Definitions
; ============================================================================
; Register map for the Nintendo MMC3 mapper chip
; ============================================================================

.ifndef MMC3_INC
MMC3_INC = 1

; ============================================================================
; MMC3 Registers
; ============================================================================

MMC3_BANK_SELECT    = $8000  ; Bank select (write: which register to update)
MMC3_BANK_DATA      = $8001  ; Bank data (write: value for selected register)
MMC3_MIRRORING      = $A000  ; Mirroring mode
MMC3_PRG_RAM_CTRL   = $A001  ; PRG-RAM protect
MMC3_IRQ_LATCH      = $C000  ; IRQ latch value
MMC3_IRQ_RELOAD     = $C001  ; IRQ counter reload
MMC3_IRQ_DISABLE    = $E000  ; IRQ disable (acknowledge)
MMC3_IRQ_ENABLE     = $E001  ; IRQ enable

; ============================================================================
; Bank Select Register ($8000) bit definitions
; ============================================================================
; Bits 0-2: Which bank register to update when writing to $8001
; Bit 6: PRG ROM bank mode
;   0 = $8000-$9FFF swappable, $C000-$DFFF fixed to second-to-last bank
;   1 = $C000-$DFFF swappable, $8000-$9FFF fixed to second-to-last bank
; Bit 7: CHR A12 inversion
;   0 = Two 2KB banks at $0000-$0FFF, four 1KB banks at $1000-$1FFF
;   1 = Two 2KB banks at $1000-$1FFF, four 1KB banks at $0000-$0FFF
; ============================================================================

; Bank register indices (bits 0-2 of $8000)
MMC3_REG_CHR_2K_0   = 0     ; 2KB CHR bank at $0000-$07FF (or $1000-$17FF)
MMC3_REG_CHR_2K_1   = 1     ; 2KB CHR bank at $0800-$0FFF (or $1800-$1FFF)
MMC3_REG_CHR_1K_0   = 2     ; 1KB CHR bank at $1000-$13FF (or $0000-$03FF)
MMC3_REG_CHR_1K_1   = 3     ; 1KB CHR bank at $1400-$17FF (or $0400-$07FF)
MMC3_REG_CHR_1K_2   = 4     ; 1KB CHR bank at $1800-$1BFF (or $0800-$0BFF)
MMC3_REG_CHR_1K_3   = 5     ; 1KB CHR bank at $1C00-$1FFF (or $0C00-$0FFF)
MMC3_REG_PRG_0      = 6     ; 8KB PRG bank at $8000-$9FFF (or $C000-$DFFF)
MMC3_REG_PRG_1      = 7     ; 8KB PRG bank at $A000-$BFFF

; Bank mode flags (bit 6 and 7 of $8000)
MMC3_PRG_MODE_0     = %00000000  ; $8000 swappable, $C000 fixed
MMC3_PRG_MODE_1     = %01000000  ; $C000 swappable, $8000 fixed
MMC3_CHR_MODE_0     = %00000000  ; 2KB banks at $0000, 1KB at $1000
MMC3_CHR_MODE_1     = %10000000  ; 2KB banks at $1000, 1KB at $0000

; ============================================================================
; Mirroring Register ($A000)
; ============================================================================

MMC3_MIRROR_VERTICAL    = 0  ; Vertical mirroring (horizontal arrangement)
MMC3_MIRROR_HORIZONTAL  = 1  ; Horizontal mirroring (vertical arrangement)

; ============================================================================
; PRG-RAM Protect Register ($A001)
; ============================================================================

MMC3_PRGRAM_ENABLE      = %10000000  ; Enable PRG-RAM at $6000-$7FFF
MMC3_PRGRAM_READONLY    = %01000000  ; Write-protect PRG-RAM

; ============================================================================
; PRG bank count
; ============================================================================

MMC3_PRG_BANK_COUNT     = 64   ; 512KB / 8KB = 64 banks
MMC3_CHR_BANK_COUNT     = 256  ; 256KB / 1KB = 256 banks

.endif ; MMC3_INC
