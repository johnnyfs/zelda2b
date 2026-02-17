; ============================================================================
; data/palettes.s - Default Palette Data
; ============================================================================
; Zelda-like color palettes for backgrounds and sprites.
; 32 bytes total: 4 BG palettes + 4 sprite palettes.
; NES palette values are indices into the NES master palette (0-$3F).
;
; Color reference (common NES palette values):
;   $0F = Black          $30 = White         $10 = Light gray
;   $00 = Dark gray      $20 = White
;   $29 = Green          $19 = Dark green    $09 = Darker green
;   $27 = Orange/brown   $17 = Brown         $07 = Dark brown
;   $21 = Cyan/blue      $11 = Blue          $01 = Dark blue
;   $16 = Red/brown      $15 = Pink          $12 = Blue
;   $30 = White          $38 = Cream/yellow  $28 = Yellow
; ============================================================================

.include "globals.inc"

.segment "PRG_FIXED"

; ============================================================================
; Default palette - Zelda overworld theme
; ============================================================================
; 4 background palettes + 4 sprite palettes = 32 bytes
; Each palette: [background color, color1, color2, color3]
; The first color of each palette is the universal background color.
; ============================================================================

default_palette:
    ; --- Background palettes ---

    ; BG Palette 0: Overworld grass/ground
    ; Black bg, dark green, medium green, light green
    .byte $0F, $09, $19, $29

    ; BG Palette 1: Water/sky
    ; Black bg, dark blue, medium blue, light blue
    .byte $0F, $01, $11, $21

    ; BG Palette 2: Dungeon/cave (brown/stone)
    ; Black bg, dark brown, medium brown, tan
    .byte $0F, $07, $17, $27

    ; BG Palette 3: UI/HUD
    ; Black bg, blue (magic fill/rupee), light gray, white
    .byte $0F, $12, $10, $30

    ; --- Sprite palettes ---

    ; Sprite Palette 0: Player (Link - green tunic)
    ; Transparent, dark green, green, skin tone
    .byte $0F, $19, $29, $38

    ; Sprite Palette 1: Enemies (red theme)
    ; Transparent, dark red, red, orange
    .byte $0F, $06, $16, $27

    ; Sprite Palette 2: Items/NPCs (blue theme)
    ; Transparent, dark blue, blue, cyan
    .byte $0F, $01, $11, $21

    ; Sprite Palette 3: Effects/projectiles (yellow/white)
    ; Transparent, dark yellow, yellow, white
    .byte $0F, $08, $28, $30
