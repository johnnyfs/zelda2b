; ============================================================================
; data/palettes.s - Palette Data (Region-Varied)
; ============================================================================
; NES palette values are indices into the NES master palette (0-$3F).
; Each palette set = 32 bytes: 4 BG palettes + 4 sprite palettes.
; BG palettes share index 0 as universal background color.
; Sprite palette index 0 = transparent.
;
; Region palette strategy (operator-approved):
;   BG0 (ground):  Classic Green (start area) / Warm Green (wilderness)
;   BG1 (water):   Teal (lakes/palace) / Deep Blue (ocean) / Purple-Blue (east)
;   BG2 (stone):   Varies per cave/dungeon
;   BG3 (UI):      Warm UI ($0F/$07/$27/$38) - all regions
;   SP0 (Link):    Green Tunic - all regions
;   SP1 (enemies): Red / Blue / Purple - varies by enemy type & region
;   SP2 (items):   Multi-purpose blue/white - all regions
;   SP3 (effects): Yellow/white - all regions
;
; Color reference:
;   $0F = Black          $30 = White         $10 = Light gray
;   $00 = Dark gray      $20 = White
;   $29 = Green          $19 = Dark green    $09 = Darker green
;   $2A = Bright green   $1A = Med green     $0A = Deep green
;   $27 = Orange/brown   $17 = Brown         $07 = Dark brown
;   $21 = Cyan/blue      $11 = Blue          $01 = Dark blue
;   $2C = Teal           $1C = Dark teal     $0C = Deep teal
;   $22 = Lavender       $12 = Purple-blue   $02 = Dark indigo
;   $16 = Red/brown      $06 = Dark red      $04 = Dark purple
;   $14 = Purple          $24 = Light purple
;   $38 = Cream/yellow   $28 = Yellow        $18 = Dark yellow
; ============================================================================

.include "globals.inc"

.export default_palette
.export palette_region_start, palette_region_wilderness
.export palette_region_ocean, palette_region_east
.export palette_dungeon_warm, palette_dungeon_cool, palette_dungeon_blue
.export sprite_palette_common

.segment "PRG_FIXED"

; ============================================================================
; REGION: Starting Area (west overworld, near sleeping Zelda palace)
; Classic Green ground + Teal water + Warm Stone + Warm UI
; ============================================================================
default_palette:
palette_region_start:
    ; --- Background palettes ---
    ; BG0: Classic Green (grass/ground)
    .byte $0F, $09, $19, $29
    ; BG1: Teal water (lakes, opening palace moat)
    .byte $0F, $0C, $1C, $2C
    ; BG2: Warm stone (caves, buildings)
    .byte $0F, $07, $17, $27
    ; BG3: Warm UI
    .byte $0F, $07, $27, $38

    ; --- Sprite palettes (shared across all overworld regions) ---
sprite_palette_common:
    ; SP0: Player (Link - green tunic, skin)
    .byte $0F, $19, $29, $38
    ; SP1: Enemies (red - default)
    .byte $0F, $06, $16, $27
    ; SP2: Items/NPCs (blue + cyan + white)
    .byte $0F, $12, $21, $30
    ; SP3: Effects/projectiles (yellow/white)
    .byte $0F, $18, $28, $30

; ============================================================================
; REGION: Wilderness (right half overworld, past the water)
; Warm Green ground + Purple-Blue water + Warm Stone + Warm UI
; ============================================================================
palette_region_wilderness:
    ; BG0: Warm Green (yellowed darks, lush)
    .byte $0F, $08, $19, $2A
    ; BG1: Purple-Blue water (mysterious eastern lakes)
    .byte $0F, $02, $12, $22
    ; BG2: Warm stone
    .byte $0F, $07, $17, $27
    ; BG3: Warm UI
    .byte $0F, $07, $27, $38

; ============================================================================
; REGION: Ocean crossing (between west and east halves)
; Classic Green ground + Deep Blue ocean + Warm Stone + Warm UI
; ============================================================================
palette_region_ocean:
    ; BG0: Classic Green (coastal)
    .byte $0F, $09, $19, $29
    ; BG1: Deep Blue (ocean)
    .byte $0F, $01, $11, $21
    ; BG2: Warm stone (docks/bridges)
    .byte $0F, $07, $17, $27
    ; BG3: Warm UI
    .byte $0F, $07, $27, $38

; ============================================================================
; REGION: Eastern overworld
; Warm Green + Purple-Blue + varies
; ============================================================================
palette_region_east:
    ; BG0: Warm Green
    .byte $0F, $08, $19, $2A
    ; BG1: Purple-Blue water
    .byte $0F, $02, $12, $22
    ; BG2: Cool stone (eastern caves are different)
    .byte $0F, $00, $10, $20
    ; BG3: Warm UI
    .byte $0F, $07, $27, $38

; ============================================================================
; DUNGEON PALETTE SETS (BG only - sprites stay the same)
; Each is 16 bytes (4 BG palettes). Sprite palettes loaded separately.
; ============================================================================

; Warm dungeon (brown stone - palaces 1-3)
palette_dungeon_warm:
    ; BG0: Dungeon floor (brown)
    .byte $0F, $07, $17, $27
    ; BG1: Dungeon accent (blue doors/water)
    .byte $0F, $01, $11, $21
    ; BG2: Dungeon walls (darker brown)
    .byte $0F, $07, $17, $37
    ; BG3: Warm UI
    .byte $0F, $07, $27, $38

; Cool dungeon (gray stone - palaces 4-5)
palette_dungeon_cool:
    ; BG0: Gray floor
    .byte $0F, $00, $10, $20
    ; BG1: Ice/water blue
    .byte $0F, $0C, $1C, $2C
    ; BG2: Gray walls
    .byte $0F, $00, $10, $3D
    ; BG3: Warm UI
    .byte $0F, $07, $27, $38

; Blue dungeon (Death Mountain / final palace)
palette_dungeon_blue:
    ; BG0: Dark blue floor
    .byte $0F, $01, $11, $21
    ; BG1: Purple accent
    .byte $0F, $04, $14, $24
    ; BG2: Blue-gray walls
    .byte $0F, $0C, $1C, $2C
    ; BG3: Warm UI
    .byte $0F, $07, $27, $38
