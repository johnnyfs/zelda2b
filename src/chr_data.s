; ============================================================================
; chr_data.s — Programmer Art CHR Tiles
; ============================================================================
; Generates simple placeholder tiles for the tech demo.
; Each NES tile is 16 bytes: 8 bytes bitplane 0 + 8 bytes bitplane 1.
; Pixel color = bit from plane 0 + (bit from plane 1 << 1), giving 0-3.
;
; Tile $00: All color 0 (transparent/black)
; Tile $01: All color 3 (white - solid block)
; Tile $02: All color 1 (green - grass)
; Tile $03: All color 2 (brown - wall)
; Tile $04: All color 1 + pattern (blue - water)
; Tile $05: Checkerboard color 1/2 (path)
; Tile $06: All color 2 (gray - floor)
; Tile $07: All color 3 (dark green - tree)
; Tile $10: Player-like shape (color 1+3)
; ============================================================================

.segment "CHR_PADDING"

; ============================================================================
; Background tiles (Pattern Table 0: $0000-$0FFF)
; ============================================================================

; --- Tile $00: Empty (all color 0) ---
    .byte $00, $00, $00, $00, $00, $00, $00, $00  ; Plane 0
    .byte $00, $00, $00, $00, $00, $00, $00, $00  ; Plane 1

; --- Tile $01: Solid color 3 (white block) ---
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF  ; Plane 0
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF  ; Plane 1

; --- Tile $02: Solid color 1 (for grass) ---
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF  ; Plane 0
    .byte $00, $00, $00, $00, $00, $00, $00, $00  ; Plane 1

; --- Tile $03: Solid color 2 (for wall/rock) ---
    .byte $00, $00, $00, $00, $00, $00, $00, $00  ; Plane 0
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF  ; Plane 1

; --- Tile $04: Wavy color 1 (water) ---
    .byte $FF, $FF, $DB, $FF, $FF, $DB, $FF, $FF  ; Plane 0 (wavy pattern)
    .byte $00, $00, $00, $00, $00, $00, $00, $00  ; Plane 1

; --- Tile $05: Checkerboard color 1/2 (path) ---
    .byte $AA, $55, $AA, $55, $AA, $55, $AA, $55  ; Plane 0
    .byte $55, $AA, $55, $AA, $55, $AA, $55, $AA  ; Plane 1

; --- Tile $06: Solid color 2 + border (floor) ---
    .byte $FF, $81, $81, $81, $81, $81, $81, $FF  ; Plane 0 (border)
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF  ; Plane 1

; --- Tile $07: Cross pattern color 3 (tree) ---
    .byte $18, $3C, $7E, $FF, $FF, $7E, $3C, $18  ; Plane 0 (diamond)
    .byte $18, $3C, $7E, $FF, $FF, $7E, $3C, $18  ; Plane 1

; Pad remaining BG tiles ($08-$FF) with empty
.repeat 248
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
.endrepeat

; ============================================================================
; Sprite tiles (Pattern Table 1: $1000-$1FFF)
; ============================================================================

; --- Sprite Tile $00: Empty ---
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

; --- Sprite Tile $01: Player body (facing down) ---
; A simple humanoid shape:
;   ..XXXX..  = $3C
;   .XXXXXX.  = $7E
;   .XXXXXX.  = $7E
;   ..XXXX..  = $3C  (head)
;   .XXXXXX.  = $7E
;   ..XXXX..  = $3C
;   ..X..X..  = $24
;   ..X..X..  = $24  (legs)
    .byte $3C, $7E, $7E, $3C, $7E, $3C, $24, $24  ; Plane 0
    .byte $3C, $7E, $7E, $3C, $7E, $3C, $24, $24  ; Plane 1

; --- Sprite Tile $02: Player body (facing up) ---
    .byte $3C, $7E, $42, $3C, $7E, $3C, $24, $24  ; Plane 0
    .byte $3C, $7E, $7E, $3C, $7E, $3C, $24, $24  ; Plane 1

; --- Sprite Tile $03: Player body (facing right) ---
    .byte $3C, $7E, $7C, $3C, $7E, $3C, $28, $28  ; Plane 0
    .byte $3C, $7E, $7C, $3C, $7E, $3C, $28, $28  ; Plane 1

; --- Sprite Tile $04: Sword (horizontal) ---
    .byte $00, $00, $00, $FF, $FF, $00, $00, $00  ; Plane 0
    .byte $00, $00, $00, $FF, $FF, $00, $00, $00  ; Plane 1

; --- Sprite Tile $05: Sword (vertical) ---
    .byte $18, $18, $18, $18, $18, $18, $18, $18  ; Plane 0
    .byte $18, $18, $18, $18, $18, $18, $18, $18  ; Plane 1

; --- Sprite Tile $06: Heart (pickup/HUD) ---
    .byte $00, $66, $FF, $FF, $FF, $7E, $3C, $18  ; Plane 0
    .byte $00, $66, $FF, $FF, $FF, $7E, $3C, $18  ; Plane 1

; --- Sprite Tile $07: Generic enemy (blob) ---
    .byte $3C, $7E, $DB, $FF, $DB, $66, $7E, $3C  ; Plane 0
    .byte $3C, $7E, $DB, $FF, $DB, $66, $7E, $3C  ; Plane 1

; Pad remaining sprite tiles ($08-$FF) with empty
.repeat 248
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
.endrepeat
