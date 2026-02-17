; ============================================================================
; metatiles.s - 16x16 Metatile Definitions
; ============================================================================
; Each metatile is 5 bytes: TL, TR, BL, BR tile indices, then attribute byte.
; Tile indices reference BG CHR pattern table ($0000-$0FFF).
;
; Attribute byte:
;   Bits 0-1: palette select (0-3)
;   Bit 7:    solid flag ($80 = solid, collision blocks movement)
;
; Tile index map (see tools/generate_bg_tiles.py):
;   $00 = empty         $0C = path A        $16 = door TL      $2A = bridge TL
;   $01 = grass A       $0D = path B        $17 = door TR      $2B = bridge TR
;   $02 = grass B       $0E = rock TL       $18 = door BL      $2C = bridge BL
;   $03 = grass C       $0F = rock TR       $19 = door BR      $2D = bridge BR
;   $04 = tree TL       $10 = rock BL       $1A = sand A       $2E = stonewall TL
;   $05 = tree TR       $11 = rock BR       $1B = sand B       $2F = stonewall TR
;   $06 = tree BL       $12 = stone fl TL   $1C = bush TL      $30 = stonewall BL
;   $07 = tree BR       $13 = stone fl TR   $1D = bush TR      $31 = stonewall BR
;   $08 = water TL      $14 = stone fl BL   $1E = bush BL      $32 = border TL
;   $09 = water TR      $15 = stone fl BR   $1F = bush BR      $33 = border TR
;   $0A = water BL                                              $34 = border BL
;   $0B = water BR                                              $35 = border BR
;
; Palette assignments:
;   0 = Green (grass/trees/bushes)
;   1 = Blue (water)
;   2 = Brown (dungeon/cave/stone)
;   3 = UI (white/gray)
; ============================================================================

.include "map.inc"
.segment "PRG_FIXED_C"

metatile_table:
    ; ID  TL    TR    BL    BR   ATTR    ; Description
    .byte $00, $00, $00, $00, $00       ; 0: Empty floor (black)
    .byte $01, $02, $03, $01, $00       ; 1: Grass light (palette 0, walkable)
    .byte $02, $03, $01, $02, $00       ; 2: Grass dark variant (palette 0, walkable)
    .byte $04, $05, $06, $07, $80       ; 3: Tree (palette 0, SOLID)
    .byte $08, $09, $0A, $0B, $81       ; 4: Water (palette 1, SOLID)
    .byte $0C, $0D, $0C, $0D, $00       ; 5: Path/dirt (palette 0, walkable)
    .byte $0E, $0F, $10, $11, $80       ; 6: Rock wall (palette 0, SOLID)
    .byte $16, $17, $18, $19, $02       ; 7: Door (palette 2, walkable)
    .byte $32, $33, $34, $35, $80       ; 8: Border (palette 0, SOLID)
    .byte $32, $32, $34, $34, $80       ; 9: Border L (palette 0, SOLID)
    .byte $33, $33, $35, $35, $80       ; 10: Border R (palette 0, SOLID)
    .byte $1A, $1B, $1A, $1B, $00       ; 11: Sand (palette 0, walkable)
    .byte $1C, $1D, $1E, $1F, $80       ; 12: Bush (palette 0, SOLID)
    .byte $12, $13, $14, $15, $02       ; 13: Stone floor (palette 2, walkable)
    .byte $2E, $2F, $30, $31, $82       ; 14: Stone wall (palette 2, SOLID)
    .byte $2A, $2B, $2C, $2D, $02       ; 15: Bridge (palette 2, walkable)
