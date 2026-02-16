; ============================================================================
; metatiles.s - Metatile Definitions
; ============================================================================
; Each metatile is 5 bytes:
;   Byte 0: Top-left tile index (CHR)
;   Byte 1: Top-right tile index (CHR)
;   Byte 2: Bottom-left tile index (CHR)
;   Byte 3: Bottom-right tile index (CHR)
;   Byte 4: Attribute byte
;            bits 0-1: palette (0-3)
;            bit 7:    solid flag (1 = solid/impassable)
;
; 16 metatiles defined. Tile indices reference the BG pattern table ($0000).
; Placed in PRG_FIXED_C so they're always accessible.
; ============================================================================

.include "map.inc"

.segment "PRG_FIXED_C"

; ============================================================================
; Metatile Table (16 entries x 5 bytes = 80 bytes)
; ============================================================================

metatile_table:
    ; Metatile 0: Empty / void (palette 0)
    .byte $00, $00, $00, $00, $00

    ; Metatile 1: Grass - light (palette 0)
    .byte $04, $05, $14, $15, $00

    ; Metatile 2: Grass - dark (palette 0)
    .byte $06, $07, $16, $17, $00

    ; Metatile 3: Tree (palette 1, SOLID)
    .byte $08, $09, $18, $19, $81

    ; Metatile 4: Water (palette 2, SOLID)
    .byte $0A, $0B, $1A, $1B, $82

    ; Metatile 5: Path / walkway (palette 1)
    .byte $0C, $0D, $1C, $1D, $01

    ; Metatile 6: Wall / stone (palette 1, SOLID)
    .byte $0E, $0F, $1E, $1F, $81

    ; Metatile 7: Door / entrance (palette 1)
    .byte $10, $11, $20, $21, $01

    ; Metatile 8: Border top (palette 1, SOLID)
    .byte $30, $31, $40, $41, $81

    ; Metatile 9: Border left (palette 1, SOLID)
    .byte $32, $33, $42, $43, $81

    ; Metatile 10: Border right (palette 1, SOLID)
    .byte $34, $35, $44, $45, $81

    ; Metatile 11: Sand (palette 3)
    .byte $36, $37, $46, $47, $03

    ; Metatile 12: Dense grass / bush (palette 0)
    .byte $38, $39, $48, $49, $00

    ; Metatile 13: Stone floor (palette 1)
    .byte $3A, $3B, $4A, $4B, $01

    ; Metatile 14: Stone wall (palette 1, SOLID)
    .byte $3C, $3D, $4C, $4D, $81

    ; Metatile 15: Bridge (palette 3)
    .byte $3E, $3F, $4E, $4F, $03
