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
; Each metatile uses the same 8x8 tile for all 4 quadrants, producing
; a uniform 16x16 block. This gives a clear grid look per the designer's
; direction: walls = solid brick blocks, grass = uniform fill, etc.
;
; 16 metatiles defined. Tile indices reference the BG pattern table ($0000).
; Placed in PRG_FIXED_C so they're always accessible.
; ============================================================================

.include "map.inc"

.segment "PRG_FIXED_C"

; ============================================================================
; Metatile Table (16 entries x 5 bytes = 80 bytes)
; ============================================================================
; All metatiles use uniform 2x2 of the same tile for clear 16x16 blocks.

metatile_table:
    ; Metatile 0: Empty / void (palette 0) - tile $00 = blank
    .byte $00, $00, $00, $00, $00

    ; Metatile 1: Grass - light (palette 0) - tile $04 = light grass pattern
    .byte $04, $04, $04, $04, $00

    ; Metatile 2: Grass - dark (palette 0) - tile $06 = dark grass pattern
    .byte $06, $06, $06, $06, $00

    ; Metatile 3: Tree (palette 1, SOLID) - tile $08 = tree/foliage
    .byte $08, $08, $08, $08, $81

    ; Metatile 4: Water (palette 2, SOLID) - tile $0A = water waves
    .byte $0A, $0A, $0A, $0A, $82

    ; Metatile 5: Path / walkway (palette 1) - tile $0C = path/dirt
    .byte $0C, $0C, $0C, $0C, $01

    ; Metatile 6: Wall / stone (palette 1, SOLID) - tile $0E = brick wall
    .byte $0E, $0E, $0E, $0E, $81

    ; Metatile 7: Door / entrance (palette 1) - tile $10 = door/opening
    .byte $10, $10, $10, $10, $01

    ; Metatile 8: Border top (palette 1, SOLID) - tile $30
    .byte $30, $30, $30, $30, $81

    ; Metatile 9: Border left (palette 1, SOLID) - tile $32
    .byte $32, $32, $32, $32, $81

    ; Metatile 10: Border right (palette 1, SOLID) - tile $34
    .byte $34, $34, $34, $34, $81

    ; Metatile 11: Sand (palette 3) - tile $36 = sand texture
    .byte $36, $36, $36, $36, $03

    ; Metatile 12: Dense grass / bush (palette 0) - tile $38 = bush
    .byte $38, $38, $38, $38, $00

    ; Metatile 13: Stone floor (palette 1) - tile $3A = stone floor
    .byte $3A, $3A, $3A, $3A, $01

    ; Metatile 14: Stone wall (palette 1, SOLID) - tile $3C = stone wall
    .byte $3C, $3C, $3C, $3C, $81

    ; Metatile 15: Bridge (palette 3) - tile $3E = bridge planks
    .byte $3E, $3E, $3E, $3E, $03
