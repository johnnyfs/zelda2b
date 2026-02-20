; ============================================================================
; mmc3.inc — MMC3 (Mapper 4) Register Constants
; ============================================================================
; TxROM / MMC3 mapper registers for bank switching, mirroring, and IRQ.
; ============================================================================

; --- MMC3 Registers ---
MMC3_BANK_SELECT    = $8000     ; Bank select (write)
MMC3_BANK_DATA      = $8001     ; Bank data (write)
MMC3_MIRRORING      = $A000     ; Mirroring (write): 0=vertical, 1=horizontal
MMC3_PRG_RAM_CTRL   = $A001     ; PRG RAM protect (write)
MMC3_IRQ_LATCH      = $C000     ; IRQ latch value (write)
MMC3_IRQ_RELOAD     = $C001     ; IRQ reload (write)
MMC3_IRQ_DISABLE    = $E000     ; IRQ disable + acknowledge (write)
MMC3_IRQ_ENABLE     = $E001     ; IRQ enable (write)

; --- Bank Select Register Bits ---
; Bits 0-2: register to update (R0-R7)
; Bit 6: PRG ROM bank mode (0=$8000 swappable, 1=$C000 swappable)
; Bit 7: CHR ROM bank mode (0=two 2KB banks at $0000, 1=two 2KB banks at $1000)
MMC3_R0_CHR_2K_0    = 0         ; R0: 2KB CHR bank at $0000 (or $1000)
MMC3_R1_CHR_2K_1    = 1         ; R1: 2KB CHR bank at $0800 (or $1800)
MMC3_R2_CHR_1K_0    = 2         ; R2: 1KB CHR bank at $1000 (or $0000)
MMC3_R3_CHR_1K_1    = 3         ; R3: 1KB CHR bank at $1400 (or $0400)
MMC3_R4_CHR_1K_2    = 4         ; R4: 1KB CHR bank at $1800 (or $0800)
MMC3_R5_CHR_1K_3    = 5         ; R5: 1KB CHR bank at $1C00 (or $0C00)
MMC3_R6_PRG_8K_0    = 6         ; R6: 8KB PRG bank at $8000 (or $C000)
MMC3_R7_PRG_8K_1    = 7         ; R7: 8KB PRG bank at $A000

; --- PRG RAM Protect ---
MMC3_SRAM_ENABLE    = %10000000 ; Enable SRAM at $6000-$7FFF
MMC3_SRAM_WRITABLE  = %01000000 ; Allow writes to SRAM (0=write-protect)
; For battery-backed save: set both bits = $C0

; --- Mirroring ---
MMC3_MIRROR_VERT    = 0
MMC3_MIRROR_HORIZ   = 1

; --- PRG Bank Mode ---
; Mode 0 (bit 6 = 0): $8000-$9FFF swappable, $C000-$DFFF fixed to second-to-last bank
; Mode 1 (bit 6 = 1): $C000-$DFFF swappable, $8000-$9FFF fixed to second-to-last bank
; We use Mode 0 (default): $8000 swappable, $C000 fixed (bank 30), $E000 fixed (bank 31)
MMC3_PRG_MODE_0     = %00000000
MMC3_PRG_MODE_1     = %01000000

; --- CHR Bank Mode ---
; Mode 0 (bit 7 = 0): 2KB banks at $0000/$0800, 1KB banks at $1000-$1C00
; Mode 1 (bit 7 = 1): 2KB banks at $1000/$1800, 1KB banks at $0000-$0C00
MMC3_CHR_MODE_0     = %00000000
MMC3_CHR_MODE_1     = %10000000
