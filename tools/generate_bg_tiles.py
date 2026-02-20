#!/usr/bin/env python3
"""
generate_bg_tiles.py - Generate Link's Awakening-style BG tiles for NES CHR ROM.

Creates distinct 8x8 tiles for overworld terrain in the style of Link's Awakening,
output as raw NES CHR data (16 bytes per tile, two-bitplane format).

CHR format (16 bytes per 8x8 tile):
  Bytes 0-7:  low bitplane  (bit 0 of each pixel)
  Bytes 8-15: high bitplane (bit 1 of each pixel)
  Each byte = one row, MSB = leftmost pixel
  Color = (high << 1) | low: 0=bg/transparent, 1=dark, 2=mid, 3=light

Palette mapping (BG Palette 0 - Overworld Green):
  0 = $0F Black (background)
  1 = $09 Dark green (outlines, shadows)
  2 = $19 Medium green (main fill)
  3 = $29 Light green (highlights)

Palette mapping (BG Palette 1 - Water Blue):
  0 = $0F Black
  1 = $01 Dark blue
  2 = $11 Medium blue
  3 = $21 Light blue

Palette mapping (BG Palette 2 - Dungeon Brown):
  0 = $0F Black
  1 = $07 Dark brown
  2 = $17 Medium brown
  3 = $27 Tan/light brown

Tile index assignments (must match metatiles.s):
  $00: Empty/blank (all color 0)
  $01: Grass fill A (short grass texture)
  $02: Grass fill B (alt grass texture)
  $03: Grass fill C (sparse grass)
  $04: Tree top-left
  $05: Tree top-right
  $06: Tree bottom-left
  $07: Tree bottom-right
  $08: Water TL (wave pattern)
  $09: Water TR
  $0A: Water BL
  $0B: Water BR
  $0C: Path/dirt fill A
  $0D: Path/dirt fill B
  $0E: Rock/wall top-left
  $0F: Rock/wall top-right
  $10: Rock/wall bottom-left
  $11: Rock/wall bottom-right
  $12: Stone floor TL (dungeon)
  $13: Stone floor TR
  $14: Stone floor BL
  $15: Stone floor BR
  $16: Door top-left
  $17: Door top-right
  $18: Door bottom-left
  $19: Door bottom-right
  $1A: Sand fill A
  $1B: Sand fill B
  $1C: Bush top-left
  $1D: Bush top-right
  $1E: Bush bottom-left
  $1F: Bush bottom-right
  $20-$29: HUD tiles (reserved, keep existing)
  $2A: Bridge horizontal TL
  $2B: Bridge horizontal TR
  $2C: Bridge horizontal BL
  $2D: Bridge horizontal BR
  $2E: Stone wall TL (dungeon)
  $2F: Stone wall TR
  $30: Stone wall BL
  $31: Stone wall BR
  $32: Border TL
  $33: Border TR
  $34: Border BL
  $35: Border BR
"""
import struct
import sys
import os

def make_tile(rows_2bpp):
    """Convert 8 rows of 8 2-bit pixels into NES CHR 16-byte format.
    rows_2bpp: list of 8 lists, each containing 8 values (0-3).
    Returns: 16 bytes (low plane 0-7, high plane 8-15).
    """
    low_plane = bytearray(8)
    high_plane = bytearray(8)
    for row_idx in range(8):
        lo = 0
        hi = 0
        for col_idx in range(8):
            pixel = rows_2bpp[row_idx][col_idx]
            lo_bit = pixel & 1
            hi_bit = (pixel >> 1) & 1
            lo = (lo << 1) | lo_bit
            hi = (hi << 1) | hi_bit
        low_plane[row_idx] = lo
        high_plane[row_idx] = hi
    return bytes(low_plane) + bytes(high_plane)


# ============================================================================
# Tile definitions - Link's Awakening overworld style
# Each tile is 8x8 pixels, values 0-3
# 0=bg(black), 1=dark, 2=mid, 3=light
# ============================================================================

# $00: Empty/blank
tile_empty = [
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
]

# $01: Grass fill A - LA-style short grass with scattered blades
tile_grass_a = [
    [2,2,3,2,2,2,2,3],
    [2,3,2,2,3,2,2,2],
    [2,2,2,2,2,2,3,2],
    [3,2,2,3,2,2,2,2],
    [2,2,2,2,2,3,2,2],
    [2,3,2,2,2,2,2,3],
    [2,2,2,3,2,2,2,2],
    [2,2,2,2,2,2,3,2],
]

# $02: Grass fill B - variation with different blade positions
tile_grass_b = [
    [2,2,2,2,3,2,2,2],
    [2,2,3,2,2,2,3,2],
    [3,2,2,2,2,2,2,2],
    [2,2,2,2,3,2,2,3],
    [2,3,2,2,2,2,2,2],
    [2,2,2,3,2,3,2,2],
    [2,2,2,2,2,2,2,2],
    [2,3,2,2,2,2,3,2],
]

# $03: Grass fill C - sparse grass, more subtle
tile_grass_c = [
    [2,2,2,2,2,2,2,2],
    [2,2,2,3,2,2,2,2],
    [2,2,2,2,2,2,2,2],
    [2,2,2,2,2,2,2,2],
    [2,2,2,2,2,3,2,2],
    [2,2,2,2,2,2,2,2],
    [2,2,3,2,2,2,2,2],
    [2,2,2,2,2,2,2,2],
]

# $04: Tree top-left - LA-style round canopy
tile_tree_tl = [
    [0,0,1,1,1,2,2,2],
    [0,1,2,3,2,3,2,2],
    [1,2,3,2,3,2,3,2],
    [1,2,2,3,2,3,2,3],
    [1,3,2,3,2,2,3,2],
    [1,2,3,2,3,2,2,3],
    [1,2,2,3,2,3,2,2],
    [0,1,2,2,3,2,3,2],
]

# $05: Tree top-right
tile_tree_tr = [
    [2,2,1,1,1,0,0,0],
    [3,2,3,2,3,1,0,0],
    [2,3,2,3,2,3,1,0],
    [3,2,3,2,3,2,1,0],
    [2,3,2,3,2,3,1,0],
    [3,2,2,3,2,2,1,0],
    [2,3,2,2,3,2,1,0],
    [2,3,2,3,2,1,0,0],
]

# $06: Tree bottom-left - trunk visible
tile_tree_bl = [
    [0,1,2,3,2,3,2,2],
    [0,0,1,2,3,2,2,3],
    [0,0,0,1,1,2,2,2],
    [0,0,0,0,1,2,1,0],
    [0,0,0,0,1,2,1,0],
    [0,0,0,0,1,2,1,0],
    [0,0,0,0,1,2,1,0],
    [0,0,0,1,1,2,1,0],
]

# $07: Tree bottom-right
tile_tree_br = [
    [3,2,3,2,2,1,0,0],
    [2,2,3,2,1,0,0,0],
    [2,2,1,1,0,0,0,0],
    [0,1,2,1,0,0,0,0],
    [0,1,2,1,0,0,0,0],
    [0,1,2,1,0,0,0,0],
    [0,1,2,1,0,0,0,0],
    [0,1,2,1,1,0,0,0],
]

# $08: Water TL - LA-style animated wave pattern (frame 1)
tile_water_tl = [
    [2,2,3,3,2,2,2,2],
    [2,3,3,2,2,2,2,3],
    [3,3,2,2,2,2,3,3],
    [3,2,2,2,2,3,3,2],
    [2,2,2,2,3,3,2,2],
    [2,2,2,3,3,2,2,2],
    [2,2,3,3,2,2,2,2],
    [2,3,3,2,2,2,2,3],
]

# $09: Water TR
tile_water_tr = [
    [3,3,2,2,2,2,3,3],
    [3,2,2,2,2,3,3,2],
    [2,2,2,2,3,3,2,2],
    [2,2,2,3,3,2,2,2],
    [2,2,3,3,2,2,2,2],
    [2,3,3,2,2,2,2,3],
    [3,3,2,2,2,2,3,3],
    [3,2,2,2,2,3,3,2],
]

# $0A: Water BL
tile_water_bl = [
    [3,3,2,2,2,2,3,3],
    [3,2,2,2,2,3,3,2],
    [2,2,2,2,3,3,2,2],
    [2,2,2,3,3,2,2,2],
    [2,2,3,3,2,2,2,2],
    [2,3,3,2,2,2,2,3],
    [3,3,2,2,2,2,3,3],
    [3,2,2,2,2,3,3,2],
]

# $0B: Water BR
tile_water_br = [
    [2,2,2,2,3,3,2,2],
    [2,2,2,3,3,2,2,2],
    [2,2,3,3,2,2,2,2],
    [2,3,3,2,2,2,2,3],
    [3,3,2,2,2,2,3,3],
    [3,2,2,2,2,3,3,2],
    [2,2,2,2,3,3,2,2],
    [2,2,2,3,3,2,2,2],
]

# $0C: Path/dirt fill A - flat sandy path
tile_path_a = [
    [3,3,3,3,3,3,3,3],
    [3,3,3,2,3,3,3,3],
    [3,3,3,3,3,3,2,3],
    [3,2,3,3,3,3,3,3],
    [3,3,3,3,3,3,3,3],
    [3,3,3,3,2,3,3,3],
    [3,3,2,3,3,3,3,3],
    [3,3,3,3,3,3,3,2],
]

# $0D: Path/dirt fill B - slight variation
tile_path_b = [
    [3,3,3,3,3,2,3,3],
    [3,3,3,3,3,3,3,3],
    [3,2,3,3,3,3,3,3],
    [3,3,3,3,3,3,2,3],
    [3,3,3,2,3,3,3,3],
    [3,3,3,3,3,3,3,3],
    [3,3,3,3,3,2,3,3],
    [3,2,3,3,3,3,3,3],
]

# $0E: Rock/wall top-left - LA-style rough stone
tile_rock_tl = [
    [1,1,1,1,1,1,1,1],
    [1,2,2,3,2,2,3,2],
    [1,2,3,3,3,2,2,2],
    [1,3,3,2,3,3,2,3],
    [1,2,3,3,2,3,3,2],
    [1,3,2,2,3,2,3,3],
    [1,2,3,3,3,3,2,2],
    [1,2,2,3,2,3,3,2],
]

# $0F: Rock/wall top-right
tile_rock_tr = [
    [1,1,1,1,1,1,1,1],
    [3,2,2,3,2,3,2,1],
    [2,3,3,2,3,2,3,1],
    [3,2,3,3,2,3,2,1],
    [2,3,2,3,3,2,3,1],
    [3,2,3,2,2,3,2,1],
    [2,3,2,3,3,2,3,1],
    [3,2,3,2,3,3,2,1],
]

# $10: Rock/wall bottom-left
tile_rock_bl = [
    [1,3,3,2,3,2,2,3],
    [1,2,2,3,2,3,3,2],
    [1,3,2,3,3,2,2,3],
    [1,2,3,2,2,3,3,2],
    [1,3,2,3,3,2,2,3],
    [1,2,3,2,2,3,2,2],
    [1,2,2,3,3,2,3,3],
    [1,1,1,1,1,1,1,1],
]

# $11: Rock/wall bottom-right
tile_rock_br = [
    [2,3,3,2,3,2,3,1],
    [3,2,2,3,2,3,2,1],
    [2,3,3,2,3,2,3,1],
    [3,2,3,3,2,3,2,1],
    [2,3,2,2,3,2,3,1],
    [3,2,3,3,2,3,2,1],
    [2,3,2,2,3,2,3,1],
    [1,1,1,1,1,1,1,1],
]

# $12: Stone floor TL (dungeon) - smooth brick pattern
tile_stone_tl = [
    [1,1,1,1,1,1,1,1],
    [2,2,2,2,3,2,2,2],
    [2,2,2,2,3,2,2,2],
    [2,2,2,2,3,2,2,2],
    [1,1,1,1,1,1,1,1],
    [2,2,3,2,2,2,2,3],
    [2,2,3,2,2,2,2,3],
    [2,2,3,2,2,2,2,3],
]

# $13: Stone floor TR
tile_stone_tr = [
    [1,1,1,1,1,1,1,1],
    [2,3,2,2,2,2,3,2],
    [2,3,2,2,2,2,3,2],
    [2,3,2,2,2,2,3,2],
    [1,1,1,1,1,1,1,1],
    [2,2,2,3,2,2,2,2],
    [2,2,2,3,2,2,2,2],
    [2,2,2,3,2,2,2,2],
]

# $14: Stone floor BL
tile_stone_bl = [
    [1,1,1,1,1,1,1,1],
    [2,2,2,3,2,2,2,2],
    [2,2,2,3,2,2,2,2],
    [2,2,2,3,2,2,2,2],
    [1,1,1,1,1,1,1,1],
    [2,2,2,2,2,3,2,2],
    [2,2,2,2,2,3,2,2],
    [2,2,2,2,2,3,2,2],
]

# $15: Stone floor BR
tile_stone_br = [
    [1,1,1,1,1,1,1,1],
    [3,2,2,2,2,3,2,2],
    [3,2,2,2,2,3,2,2],
    [3,2,2,2,2,3,2,2],
    [1,1,1,1,1,1,1,1],
    [2,2,3,2,2,2,2,3],
    [2,2,3,2,2,2,2,3],
    [2,2,3,2,2,2,2,3],
]

# $16: Door top-left - dark opening with frame
tile_door_tl = [
    [1,1,1,1,1,2,2,2],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
]

# $17: Door top-right
tile_door_tr = [
    [2,2,1,1,1,1,1,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
]

# $18: Door bottom-left
tile_door_bl = [
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,3,3,1,0,0,0,0],
    [1,1,1,1,1,1,1,1],
]

# $19: Door bottom-right
tile_door_br = [
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [0,0,0,0,1,3,3,1],
    [1,1,1,1,1,1,1,1],
]

# $1A: Sand fill A - dotted sand texture
tile_sand_a = [
    [3,3,3,2,3,3,3,3],
    [3,3,3,3,3,3,3,2],
    [3,2,3,3,3,3,3,3],
    [3,3,3,3,3,2,3,3],
    [3,3,3,3,3,3,3,3],
    [3,3,2,3,3,3,3,3],
    [3,3,3,3,3,3,2,3],
    [3,3,3,3,2,3,3,3],
]

# $1B: Sand fill B
tile_sand_b = [
    [3,3,3,3,3,3,3,3],
    [3,3,2,3,3,3,3,3],
    [3,3,3,3,3,2,3,3],
    [3,3,3,3,3,3,3,3],
    [2,3,3,3,3,3,3,3],
    [3,3,3,3,2,3,3,3],
    [3,3,3,3,3,3,3,2],
    [3,2,3,3,3,3,3,3],
]

# $1C: Bush top-left - dense rounded bush
tile_bush_tl = [
    [0,0,1,1,1,2,2,2],
    [0,1,2,2,3,2,3,2],
    [1,2,3,2,2,3,2,3],
    [1,2,2,3,2,3,2,2],
    [1,3,2,2,3,2,3,2],
    [1,2,3,2,2,3,2,3],
    [1,2,2,3,2,2,3,2],
    [1,2,3,2,3,2,2,3],
]

# $1D: Bush top-right
tile_bush_tr = [
    [2,2,2,1,1,1,0,0],
    [3,2,3,2,2,2,1,0],
    [2,3,2,3,2,3,2,1],
    [3,2,3,2,3,2,2,1],
    [2,3,2,3,2,2,3,1],
    [3,2,3,2,3,2,2,1],
    [2,3,2,3,2,3,2,1],
    [3,2,2,3,2,3,2,1],
]

# $1E: Bush bottom-left
tile_bush_bl = [
    [1,3,2,3,2,3,2,2],
    [1,2,3,2,3,2,3,2],
    [1,2,2,3,2,3,2,3],
    [1,3,2,2,3,2,3,2],
    [0,1,3,2,3,2,2,3],
    [0,1,2,3,2,3,2,2],
    [0,0,1,1,2,2,3,2],
    [0,0,0,1,1,1,1,1],
]

# $1F: Bush bottom-right
tile_bush_br = [
    [3,2,3,2,3,2,2,1],
    [2,3,2,3,2,3,2,1],
    [3,2,3,2,3,2,2,1],
    [2,3,2,3,2,2,3,1],
    [3,2,2,3,2,3,1,0],
    [2,3,2,2,3,1,1,0],
    [2,3,2,2,1,1,0,0],
    [1,1,1,1,1,0,0,0],
]

# $20-$29: HUD tiles - preserve existing (will be overwritten from existing chr data)

# $2A: Bridge horizontal TL - wooden plank
tile_bridge_tl = [
    [1,1,1,1,1,1,1,1],
    [2,3,2,3,2,3,2,3],
    [2,2,2,2,2,2,2,2],
    [3,2,3,2,3,2,3,2],
    [2,2,2,2,2,2,2,2],
    [2,3,2,3,2,3,2,3],
    [2,2,2,2,2,2,2,2],
    [3,2,3,2,3,2,3,2],
]

# $2B: Bridge horizontal TR
tile_bridge_tr = [
    [1,1,1,1,1,1,1,1],
    [3,2,3,2,3,2,3,2],
    [2,2,2,2,2,2,2,2],
    [2,3,2,3,2,3,2,3],
    [2,2,2,2,2,2,2,2],
    [3,2,3,2,3,2,3,2],
    [2,2,2,2,2,2,2,2],
    [2,3,2,3,2,3,2,3],
]

# $2C: Bridge horizontal BL
tile_bridge_bl = [
    [2,2,2,2,2,2,2,2],
    [2,3,2,3,2,3,2,3],
    [2,2,2,2,2,2,2,2],
    [3,2,3,2,3,2,3,2],
    [2,2,2,2,2,2,2,2],
    [2,3,2,3,2,3,2,3],
    [2,2,2,2,2,2,2,2],
    [1,1,1,1,1,1,1,1],
]

# $2D: Bridge horizontal BR
tile_bridge_br = [
    [2,2,2,2,2,2,2,2],
    [3,2,3,2,3,2,3,2],
    [2,2,2,2,2,2,2,2],
    [2,3,2,3,2,3,2,3],
    [2,2,2,2,2,2,2,2],
    [3,2,3,2,3,2,3,2],
    [2,2,2,2,2,2,2,2],
    [1,1,1,1,1,1,1,1],
]

# $2E: Stone wall TL (dungeon) - solid dark wall
tile_stonewall_tl = [
    [1,1,1,1,1,1,1,1],
    [1,2,2,2,1,2,2,2],
    [1,2,2,2,1,2,2,2],
    [1,2,2,2,1,2,2,2],
    [1,1,1,1,1,1,1,1],
    [1,2,2,1,2,2,2,1],
    [1,2,2,1,2,2,2,1],
    [1,2,2,1,2,2,2,1],
]

# $2F: Stone wall TR
tile_stonewall_tr = [
    [1,1,1,1,1,1,1,1],
    [1,2,2,2,1,2,2,1],
    [1,2,2,2,1,2,2,1],
    [1,2,2,2,1,2,2,1],
    [1,1,1,1,1,1,1,1],
    [2,2,1,2,2,2,1,1],
    [2,2,1,2,2,2,1,1],
    [2,2,1,2,2,2,1,1],
]

# $30: Stone wall BL
tile_stonewall_bl = [
    [1,1,1,1,1,1,1,1],
    [1,2,2,1,2,2,2,1],
    [1,2,2,1,2,2,2,1],
    [1,2,2,1,2,2,2,1],
    [1,1,1,1,1,1,1,1],
    [1,2,2,2,1,2,2,2],
    [1,2,2,2,1,2,2,2],
    [1,1,1,1,1,1,1,1],
]

# $31: Stone wall BR
tile_stonewall_br = [
    [1,1,1,1,1,1,1,1],
    [2,2,1,2,2,2,1,1],
    [2,2,1,2,2,2,1,1],
    [2,2,1,2,2,2,1,1],
    [1,1,1,1,1,1,1,1],
    [1,2,2,2,1,2,2,1],
    [1,2,2,2,1,2,2,1],
    [1,1,1,1,1,1,1,1],
]

# $32: Border/edge TL - thick border
tile_border_tl = [
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
    [1,1,2,2,2,2,2,2],
    [1,1,2,3,3,3,3,3],
    [1,1,2,3,2,2,2,2],
    [1,1,2,3,2,2,2,2],
    [1,1,2,3,2,2,2,2],
    [1,1,2,3,2,2,2,2],
]

# $33: Border TR
tile_border_tr = [
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
    [2,2,2,2,2,2,1,1],
    [3,3,3,3,3,2,1,1],
    [2,2,2,2,3,2,1,1],
    [2,2,2,2,3,2,1,1],
    [2,2,2,2,3,2,1,1],
    [2,2,2,2,3,2,1,1],
]

# $34: Border BL
tile_border_bl = [
    [1,1,2,3,2,2,2,2],
    [1,1,2,3,2,2,2,2],
    [1,1,2,3,2,2,2,2],
    [1,1,2,3,2,2,2,2],
    [1,1,2,3,3,3,3,3],
    [1,1,2,2,2,2,2,2],
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
]

# $35: Border BR
tile_border_br = [
    [2,2,2,2,3,2,1,1],
    [2,2,2,2,3,2,1,1],
    [2,2,2,2,3,2,1,1],
    [2,2,2,2,3,2,1,1],
    [3,3,3,3,3,2,1,1],
    [2,2,2,2,2,2,1,1],
    [1,1,1,1,1,1,1,1],
    [1,1,1,1,1,1,1,1],
]


def main():
    output_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                               'assets', 'chr', 'bg_tiles.chr')

    # Read existing CHR data for HUD tiles ($20-$29)
    existing_chr = None
    if os.path.exists(output_path):
        with open(output_path, 'rb') as f:
            existing_chr = f.read()

    # Build full tile list in order
    tiles = [
        tile_empty,      # $00
        tile_grass_a,    # $01
        tile_grass_b,    # $02
        tile_grass_c,    # $03
        tile_tree_tl,    # $04
        tile_tree_tr,    # $05
        tile_tree_bl,    # $06
        tile_tree_br,    # $07
        tile_water_tl,   # $08
        tile_water_tr,   # $09
        tile_water_bl,   # $0A
        tile_water_br,   # $0B
        tile_path_a,     # $0C
        tile_path_b,     # $0D
        tile_rock_tl,    # $0E
        tile_rock_tr,    # $0F
        tile_rock_bl,    # $10
        tile_rock_br,    # $11
        tile_stone_tl,   # $12
        tile_stone_tr,   # $13
        tile_stone_bl,   # $14
        tile_stone_br,   # $15
        tile_door_tl,    # $16
        tile_door_tr,    # $17
        tile_door_bl,    # $18
        tile_door_br,    # $19
        tile_sand_a,     # $1A
        tile_sand_b,     # $1B
        tile_bush_tl,    # $1C
        tile_bush_tr,    # $1D
        tile_bush_bl,    # $1E
        tile_bush_br,    # $1F
    ]

    # Convert all tiles to CHR data
    chr_data = bytearray()
    for tile in tiles:
        chr_data.extend(make_tile(tile))

    # HUD tiles $20-$29 (10 tiles = 160 bytes at offset $200)
    if existing_chr and len(existing_chr) >= 0x2A0:
        # Preserve existing HUD tiles
        chr_data.extend(existing_chr[0x200:0x2A0])
    else:
        # Fill with empty tiles
        chr_data.extend(b'\x00' * 160)

    # Tiles $2A-$35 (12 more tiles)
    extra_tiles = [
        tile_bridge_tl,    # $2A
        tile_bridge_tr,    # $2B
        tile_bridge_bl,    # $2C
        tile_bridge_br,    # $2D
        tile_stonewall_tl, # $2E
        tile_stonewall_tr, # $2F
        tile_stonewall_bl, # $30
        tile_stonewall_br, # $31
        tile_border_tl,    # $32
        tile_border_tr,    # $33
        tile_border_bl,    # $34
        tile_border_br,    # $35
    ]

    for tile in extra_tiles:
        chr_data.extend(make_tile(tile))

    # Pad to 4096 bytes (256 tiles total for 4KB CHR bank)
    while len(chr_data) < 4096:
        chr_data.extend(b'\x00' * 16)

    # Truncate if somehow over
    chr_data = chr_data[:4096]

    with open(output_path, 'wb') as f:
        f.write(chr_data)

    print(f"Written {len(chr_data)} bytes to {output_path}")
    print(f"Tiles $00-$1F: {len(tiles)} terrain tiles")
    print(f"Tiles $20-$29: HUD tiles (preserved)")
    print(f"Tiles $2A-$35: {len(extra_tiles)} additional terrain tiles")
    print(f"Tiles $36-$FF: empty (zero-filled)")

    return 0


if __name__ == '__main__':
    sys.exit(main())
