; ============================================================================
; header.s - iNES 2.0 Header for Zelda 2B
; ============================================================================
; Configures the ROM for MMC3 (mapper 4) with:
;   - 256KB PRG ROM (16 x 16KB = 32 x 8KB)
;   - 256KB CHR ROM
;   - Battery-backed SRAM (8KB)
;   - Vertical mirroring (mapper can switch)
; ============================================================================

.segment "HEADER"

; ============================================================================
; iNES 2.0 Header (16 bytes)
; ============================================================================

    ; Bytes 0-3: Magic number "NES" + EOF
    .byte $4E, $45, $53, $1A   ; "NES" + $1A

    ; Byte 4: PRG ROM size (low byte, in 16KB units)
    ;   256KB / 16KB = 16
    .byte 16                    ; 16 x 16KB = 256KB PRG ROM

    ; Byte 5: CHR ROM size (low byte, in 8KB units)
    ;   256KB / 8KB = 32
    .byte 32                    ; 32 x 8KB = 256KB CHR ROM

    ; Byte 6: Flags 6
    ;   Bit 0: Mirroring (0=horizontal, 1=vertical)
    ;   Bit 1: Battery-backed PRG-RAM
    ;   Bit 2: Trainer (0=no)
    ;   Bit 3: Four-screen VRAM (0=no)
    ;   Bits 4-7: Lower nibble of mapper number
    ;   Mapper 4 = $04 -> lower nibble = $4
    .byte %01000011             ; Vertical mirror, battery, mapper low = 4

    ; Byte 7: Flags 7
    ;   Bits 0-1: Console type (0=NES)
    ;   Bit 2-3: NES 2.0 identifier (must be %10 for NES 2.0)
    ;   Bits 4-7: Upper nibble of mapper number (0 for mapper 4)
    .byte %00001000             ; NES 2.0 format, mapper high = 0

    ; Byte 8: Mapper MSB/submapper
    ;   Bits 0-3: Submapper (0)
    ;   Bits 4-7: Mapper bits 8-11 (0 for mapper 4)
    .byte $00

    ; Byte 9: PRG/CHR ROM size MSB
    ;   Bits 0-3: PRG ROM size MSB (0)
    ;   Bits 4-7: CHR ROM size MSB (0)
    .byte $00

    ; Byte 10: PRG-RAM/EEPROM size
    ;   Bits 0-3: PRG-RAM (volatile) shift count (0 = none)
    ;   Bits 4-7: PRG-NVRAM (non-volatile) shift count
    ;   8KB = 2^13, so shift count = 10 (64 << 10 = 65536? No.)
    ;   Actually: size = 64 << shift_count. 8KB = 8192. 64 << 7 = 8192. shift=7.
    .byte $70                   ; 8KB battery-backed PRG-NVRAM

    ; Byte 11: CHR-RAM/NVRAM size
    ;   No CHR-RAM (we use CHR-ROM)
    .byte $00

    ; Byte 12: CPU/PPU Timing
    ;   0 = NTSC
    .byte $00                   ; NTSC

    ; Byte 13: VS/Extended console type (0 for normal NES)
    .byte $00

    ; Byte 14: Misc ROMs (0)
    .byte $00

    ; Byte 15: Default expansion device (0)
    .byte $00
