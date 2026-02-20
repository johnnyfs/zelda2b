; ============================================================================
; header.s — iNES 2.0 Header for Zelda 2B
; ============================================================================
; MMC3 (Mapper 4):
;   256KB PRG ROM (16 x 16KB units)
;   256KB CHR ROM (32 x 8KB units)
;   Battery-backed SRAM (8KB)
;   Vertical mirroring
;   NTSC
; ============================================================================

.segment "HEADER"

    ; Bytes 0-3: Magic number
    .byte $4E, $45, $53, $1A       ; "NES" + $1A

    ; Byte 4: PRG ROM size in 16KB units
    .byte 16                        ; 16 x 16KB = 256KB

    ; Byte 5: CHR ROM size in 8KB units
    .byte 32                        ; 32 x 8KB = 256KB

    ; Byte 6: Flags 6
    ;   bit 0 = vertical mirroring (1)
    ;   bit 1 = battery-backed SRAM (1)
    ;   bit 2 = no trainer (0)
    ;   bit 3 = no four-screen VRAM (0)
    ;   bits 4-7 = mapper low nibble (4 = %0100)
    .byte %01000011                 ; mapper4-lo | battery | vertical

    ; Byte 7: Flags 7
    ;   bits 0-1 = NES console (0)
    ;   bits 2-3 = NES 2.0 identifier (%10)
    ;   bits 4-7 = mapper high nibble (0)
    .byte %00001000                 ; NES 2.0 format

    ; Byte 8: Submapper / mapper MSB
    .byte $00

    ; Byte 9: PRG/CHR ROM size MSB
    .byte $00

    ; Byte 10: PRG-RAM size
    ;   bits 0-3 = volatile PRG-RAM shift (0 = none)
    ;   bits 4-7 = non-volatile (battery) shift (7 → 64 << 7 = 8KB)
    .byte $70

    ; Byte 11: CHR-RAM size (0 = none, we use CHR-ROM)
    .byte $00

    ; Byte 12: CPU/PPU timing (0 = NTSC)
    .byte $00

    ; Bytes 13-15: unused
    .byte $00, $00, $00
