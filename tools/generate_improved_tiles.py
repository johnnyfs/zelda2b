#!/usr/bin/env python3
"""
generate_improved_tiles.py - Generate Link's Awakening-quality BG tiles for NES CHR ROM.

Replaces the programmatically-generated placeholder tiles with carefully hand-designed
pixel art inspired by Link's Awakening (Game Boy) overworld aesthetic.

Key LA design principles applied:
- Everything has dark outlines (color 1) defining shapes
- Medium fill (color 2) for main body
- Light highlights (color 3) for depth, reflections, texture variation
- Dithered transitions rather than hard edges
- Organic, rounded shapes for natural elements
- Regular geometric patterns for man-made structures

CHR format: 16 bytes per 8x8 tile, two-bitplane NES format.
  Bytes 0-7:  low bitplane  (bit 0 of each pixel)
  Bytes 8-15: high bitplane (bit 1 of each pixel)
  Each byte = one row, MSB = leftmost pixel
  Color = (high << 1) | low: 0=bg/transparent, 1=dark, 2=mid, 3=light

Palette assignments:
  BG0 (green):  0=$0F black, 1=$09 dk green, 2=$19 med green, 3=$29 lt green
  BG1 (blue):   0=$0F black, 1=$01 dk blue,  2=$11 med blue,  3=$21 lt blue
  BG2 (brown):  0=$0F black, 1=$07 dk brown, 2=$17 med brown, 3=$27 tan
  BG3 (UI):     0=$0F black, 1=$00 dk gray,  2=$10 lt gray,   3=$30 white

Tile indices MUST match metatiles.s.
Tiles $20-$29 (HUD) are PRESERVED from existing CHR data.
"""
import sys
import os


def make_tile(rows_2bpp):
    """Convert 8 rows of 8 2-bit pixels into NES CHR 16-byte format."""
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
# Tile definitions — Link's Awakening overworld style
# Each tile is 8x8, values 0-3
# 0=bg(black/transparent), 1=dark(outlines), 2=mid(fill), 3=light(highlights)
#
# Design reference: Link's Awakening DX overworld.
# LA grass has scattered "v" blade marks on medium fill.
# LA trees have round canopies with clustered highlight dots.
# LA water has horizontal wave bands with foam crests.
# LA rocks have layered horizontal strata with shadow edges.
# ============================================================================

# $00: Empty / black
tile_empty = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
]

# ---------------------------------------------------------------------------
# GRASS TILES ($01-$03) — LA-style scattered blade dithering
# LA grass: medium-green fill with small "v" or "^" shaped blade marks
# scattered irregularly. Some pixels are light (3) as highlights,
# some dark (1) as blade tips. Creates a lively organic texture.
# ---------------------------------------------------------------------------

# $01: Grass A — primary grass with scattered blade marks
tile_grass_a = [
    [2, 2, 3, 2, 2, 2, 1, 2],
    [2, 1, 2, 2, 3, 2, 2, 2],
    [2, 2, 2, 1, 2, 2, 2, 3],
    [3, 2, 2, 2, 2, 1, 2, 2],
    [2, 2, 1, 2, 2, 2, 2, 2],
    [2, 3, 2, 2, 2, 3, 1, 2],
    [2, 2, 2, 1, 2, 2, 2, 2],
    [1, 2, 2, 2, 3, 2, 2, 1],
]

# $02: Grass B — variant with different blade positions
tile_grass_b = [
    [2, 2, 2, 2, 1, 2, 2, 3],
    [2, 3, 2, 2, 2, 2, 1, 2],
    [2, 2, 1, 2, 2, 3, 2, 2],
    [2, 2, 2, 3, 2, 2, 2, 2],
    [1, 2, 2, 2, 2, 1, 2, 2],
    [2, 2, 3, 2, 2, 2, 2, 1],
    [2, 1, 2, 2, 1, 2, 3, 2],
    [2, 2, 2, 2, 2, 2, 2, 2],
]

# $03: Grass C — sparser, used at edges; subtle texture
tile_grass_c = [
    [2, 2, 2, 3, 2, 2, 2, 2],
    [2, 2, 2, 2, 2, 2, 1, 2],
    [2, 1, 2, 2, 2, 2, 2, 2],
    [2, 2, 2, 2, 2, 3, 2, 2],
    [2, 2, 2, 2, 2, 2, 2, 2],
    [2, 2, 3, 2, 2, 2, 2, 1],
    [2, 2, 2, 2, 1, 2, 2, 2],
    [2, 2, 2, 2, 2, 2, 3, 2],
]

# ---------------------------------------------------------------------------
# TREE TILES ($04-$07) — LA-style rounded canopy + trunk
# LA trees: round canopy outlined in dark, filled with dithered mid/light
# clusters. Trunk is narrow and centered. The canopy has an organic wobble.
# Top tiles: leafy dome. Bottom tiles: lower leaves merging into trunk.
# ---------------------------------------------------------------------------

# $04: Tree canopy top-left
# Round shape: outline along left and top, interior dithered 2/3
tile_tree_tl = [
    [0, 0, 0, 1, 1, 1, 1, 1],
    [0, 0, 1, 3, 2, 3, 2, 3],
    [0, 1, 2, 3, 3, 2, 3, 2],
    [0, 1, 3, 2, 3, 3, 2, 3],
    [1, 2, 3, 3, 2, 3, 2, 3],
    [1, 3, 2, 3, 3, 2, 3, 2],
    [1, 2, 3, 2, 3, 3, 2, 3],
    [1, 3, 2, 3, 2, 3, 3, 2],
]

# $05: Tree canopy top-right (mirror of TL)
tile_tree_tr = [
    [1, 1, 1, 1, 1, 0, 0, 0],
    [2, 3, 2, 3, 2, 1, 0, 0],
    [3, 2, 3, 2, 3, 2, 1, 0],
    [2, 3, 2, 3, 2, 3, 1, 0],
    [3, 2, 3, 2, 3, 3, 2, 1],
    [2, 3, 2, 3, 2, 3, 2, 1],
    [3, 2, 3, 3, 2, 3, 2, 1],
    [2, 3, 3, 2, 3, 2, 3, 1],
]

# $06: Tree bottom-left — lower canopy + trunk
# Canopy tapers to trunk. Trunk is 2px wide centered at cols 4-5.
tile_tree_bl = [
    [1, 2, 3, 2, 3, 2, 3, 2],
    [0, 1, 3, 2, 3, 3, 2, 3],
    [0, 0, 1, 1, 2, 3, 2, 2],
    [0, 0, 0, 0, 1, 2, 1, 0],
    [0, 0, 0, 0, 1, 2, 1, 0],
    [0, 0, 0, 0, 1, 2, 1, 0],
    [0, 0, 0, 1, 1, 2, 1, 0],
    [2, 2, 1, 1, 2, 2, 1, 2],
]

# $07: Tree bottom-right — lower canopy + trunk
tile_tree_br = [
    [3, 2, 3, 2, 3, 2, 2, 1],
    [2, 3, 2, 3, 2, 3, 1, 0],
    [3, 2, 3, 2, 1, 1, 0, 0],
    [0, 0, 1, 2, 1, 0, 0, 0],
    [0, 0, 1, 2, 1, 0, 0, 0],
    [0, 0, 1, 2, 1, 0, 0, 0],
    [0, 0, 1, 2, 1, 1, 0, 0],
    [2, 2, 1, 2, 2, 1, 1, 2],
]

# ---------------------------------------------------------------------------
# WATER TILES ($08-$0B) — LA-style horizontal wave bands
# LA water: horizontal bands of light (foam crests) and dark (wave troughs)
# on a medium-blue fill. The bands shift phase across TL/TR/BL/BR to create
# an animated look even without CHR-swapping.
# Uses palette 1 (blue): 1=dk blue, 2=med blue, 3=lt blue
# ---------------------------------------------------------------------------

# $08: Water TL — wave crests offset left
tile_water_tl = [
    [2, 3, 3, 2, 2, 2, 2, 2],
    [3, 2, 2, 2, 2, 2, 3, 3],
    [2, 2, 2, 1, 2, 2, 2, 2],
    [2, 2, 1, 1, 2, 2, 2, 2],
    [2, 2, 2, 2, 2, 3, 3, 2],
    [2, 2, 2, 2, 3, 2, 2, 2],
    [2, 2, 1, 2, 2, 2, 2, 2],
    [2, 1, 1, 2, 2, 2, 2, 3],
]

# $09: Water TR — wave crests offset right
tile_water_tr = [
    [2, 2, 2, 2, 2, 3, 3, 2],
    [2, 2, 2, 2, 3, 2, 2, 2],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [3, 3, 2, 2, 2, 2, 1, 1],
    [2, 2, 2, 2, 2, 2, 2, 2],
    [2, 3, 3, 2, 2, 2, 2, 2],
    [3, 2, 2, 2, 2, 1, 2, 2],
    [2, 2, 2, 2, 1, 1, 2, 2],
]

# $0A: Water BL — second half of wave cycle
tile_water_bl = [
    [2, 2, 2, 3, 3, 2, 2, 2],
    [2, 2, 3, 2, 2, 2, 2, 2],
    [2, 1, 2, 2, 2, 2, 2, 3],
    [1, 1, 2, 2, 2, 2, 3, 2],
    [2, 2, 2, 2, 3, 3, 2, 2],
    [2, 2, 2, 3, 2, 2, 2, 2],
    [2, 2, 2, 2, 2, 2, 1, 2],
    [2, 2, 2, 2, 2, 1, 1, 2],
]

# $0B: Water BR — completing wave pattern
tile_water_br = [
    [2, 2, 2, 2, 2, 2, 3, 3],
    [2, 2, 2, 2, 2, 3, 2, 2],
    [3, 2, 2, 1, 2, 2, 2, 2],
    [2, 2, 1, 1, 2, 2, 2, 2],
    [2, 2, 2, 2, 2, 2, 3, 3],
    [2, 2, 2, 2, 2, 3, 2, 2],
    [2, 1, 2, 2, 2, 2, 2, 2],
    [1, 1, 2, 2, 2, 2, 2, 2],
]

# ---------------------------------------------------------------------------
# PATH / DIRT TILES ($0C-$0D)
# LA paths: lighter base with scattered darker specks (pebbles/grit).
# Mostly color 3 (light) with occasional 2 (mid) spots. Very different
# from grass to clearly distinguish walkable paths.
# ---------------------------------------------------------------------------

# $0C: Path A — dirt with scattered pebbles
tile_path_a = [
    [3, 3, 2, 3, 3, 3, 3, 3],
    [3, 3, 3, 3, 3, 2, 3, 3],
    [3, 3, 3, 3, 3, 3, 3, 2],
    [2, 3, 3, 3, 3, 3, 3, 3],
    [3, 3, 3, 2, 3, 3, 3, 3],
    [3, 3, 3, 3, 3, 3, 2, 3],
    [3, 2, 3, 3, 3, 3, 3, 3],
    [3, 3, 3, 3, 2, 3, 3, 3],
]

# $0D: Path B — variant pebble placement
tile_path_b = [
    [3, 3, 3, 3, 3, 3, 2, 3],
    [3, 2, 3, 3, 3, 3, 3, 3],
    [3, 3, 3, 2, 3, 3, 3, 3],
    [3, 3, 3, 3, 3, 3, 3, 2],
    [3, 3, 2, 3, 3, 3, 3, 3],
    [3, 3, 3, 3, 3, 2, 3, 3],
    [2, 3, 3, 3, 3, 3, 3, 3],
    [3, 3, 3, 2, 3, 3, 3, 2],
]

# ---------------------------------------------------------------------------
# ROCK / CLIFF TILES ($0E-$11)
# LA rocks: layered horizontal strata with shadow on the left edge.
# Each layer has a dark line on top (shadow), mid fill, light bottom (lit face).
# The 16x16 rock metatile should read as a solid boulder with texture.
# ---------------------------------------------------------------------------

# $0E: Rock top-left — top edge + stratified stone face
tile_rock_tl = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 3, 3, 2, 3, 3, 2, 3],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 2, 1, 1, 2, 1],
    [1, 2, 3, 3, 2, 3, 3, 2],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 2, 1, 1, 2, 1, 1],
    [1, 3, 3, 2, 3, 3, 2, 3],
]

# $0F: Rock top-right
tile_rock_tr = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [3, 2, 3, 3, 2, 3, 2, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 2, 1, 1, 2, 1, 1, 1],
    [3, 3, 2, 3, 3, 2, 3, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [2, 1, 1, 2, 1, 1, 2, 1],
    [3, 2, 3, 3, 2, 3, 3, 1],
]

# $10: Rock bottom-left
tile_rock_bl = [
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 2, 1, 1, 2, 1, 1],
    [1, 3, 3, 2, 3, 3, 2, 3],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 2, 1, 1, 2, 1],
    [1, 2, 3, 3, 2, 3, 3, 2],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# $11: Rock bottom-right
tile_rock_br = [
    [2, 2, 2, 2, 2, 2, 2, 1],
    [2, 1, 1, 2, 1, 1, 2, 1],
    [3, 2, 3, 3, 2, 3, 3, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 2, 1, 1, 2, 1, 1, 1],
    [3, 3, 2, 3, 3, 2, 3, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# ---------------------------------------------------------------------------
# STONE FLOOR TILES ($12-$15) — dungeon brick pattern
# LA dungeon floors: offset brick pattern. Each brick is ~4x3 pixels.
# Mortar lines (color 1) separate bricks. Bricks have mid fill + light spots.
# Uses palette 2 (brown): 1=dk brown, 2=med brown, 3=tan
# ---------------------------------------------------------------------------

# $12: Stone floor TL
tile_stone_tl = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 2, 3, 2, 1, 2, 3, 2],
    [2, 2, 2, 2, 1, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 2, 1, 2, 2, 3, 2],
    [2, 2, 2, 1, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 2, 3, 2, 1, 3, 2, 2],
]

# $13: Stone floor TR
tile_stone_tr = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 1, 2, 3, 2, 2, 1, 2],
    [2, 1, 2, 2, 2, 2, 1, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 2, 1, 2, 2, 3, 2, 1],
    [2, 2, 1, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [3, 2, 1, 2, 3, 2, 2, 1],
]

# $14: Stone floor BL
tile_stone_bl = [
    [2, 2, 2, 2, 1, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 2, 1, 2, 2, 3, 2],
    [2, 2, 2, 1, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 2, 3, 2, 1, 2, 3, 2],
    [2, 2, 2, 2, 1, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# $15: Stone floor BR
tile_stone_br = [
    [3, 2, 1, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 2, 1, 2, 2, 3, 2, 1],
    [2, 2, 1, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 1, 2, 3, 2, 2, 1, 2],
    [2, 1, 2, 2, 2, 2, 1, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# ---------------------------------------------------------------------------
# DOOR TILES ($16-$19) — cave entrance
# LA cave entrances: dark recessed opening framed by stone.
# Frame is palette 2 (brown). Interior is black (0). Frame has detail.
# ---------------------------------------------------------------------------

# $16: Door top-left — stone lintel + dark opening
tile_door_tl = [
    [1, 1, 1, 1, 2, 3, 2, 2],
    [1, 2, 3, 1, 0, 0, 0, 0],
    [1, 2, 2, 1, 0, 0, 0, 0],
    [1, 3, 2, 1, 0, 0, 0, 0],
    [1, 2, 2, 1, 0, 0, 0, 0],
    [1, 2, 3, 1, 0, 0, 0, 0],
    [1, 2, 2, 1, 0, 0, 0, 0],
    [1, 3, 2, 1, 0, 0, 0, 0],
]

# $17: Door top-right
tile_door_tr = [
    [2, 2, 3, 2, 1, 1, 1, 1],
    [0, 0, 0, 0, 1, 3, 2, 1],
    [0, 0, 0, 0, 1, 2, 2, 1],
    [0, 0, 0, 0, 1, 2, 3, 1],
    [0, 0, 0, 0, 1, 2, 2, 1],
    [0, 0, 0, 0, 1, 3, 2, 1],
    [0, 0, 0, 0, 1, 2, 2, 1],
    [0, 0, 0, 0, 1, 2, 3, 1],
]

# $18: Door bottom-left
tile_door_bl = [
    [1, 2, 3, 1, 0, 0, 0, 0],
    [1, 2, 2, 1, 0, 0, 0, 0],
    [1, 3, 2, 1, 0, 0, 0, 0],
    [1, 2, 2, 1, 0, 0, 0, 0],
    [1, 2, 3, 1, 0, 0, 0, 0],
    [1, 2, 2, 1, 0, 0, 0, 0],
    [1, 3, 2, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# $19: Door bottom-right
tile_door_br = [
    [0, 0, 0, 0, 1, 3, 2, 1],
    [0, 0, 0, 0, 1, 2, 2, 1],
    [0, 0, 0, 0, 1, 2, 3, 1],
    [0, 0, 0, 0, 1, 2, 2, 1],
    [0, 0, 0, 0, 1, 3, 2, 1],
    [0, 0, 0, 0, 1, 2, 2, 1],
    [0, 0, 0, 0, 1, 2, 3, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# ---------------------------------------------------------------------------
# SAND TILES ($1A-$1B) — beach / desert
# LA sand: very light base with sparse mid-tone specks (darker pebbles).
# Uses palette 0 (green) but reads as sandy because it's mostly color 3.
# ---------------------------------------------------------------------------

# $1A: Sand A — light with sparse specks
tile_sand_a = [
    [3, 3, 3, 2, 3, 3, 3, 3],
    [3, 3, 3, 3, 3, 3, 2, 3],
    [3, 2, 3, 3, 3, 3, 3, 3],
    [3, 3, 3, 3, 2, 3, 3, 3],
    [3, 3, 3, 3, 3, 3, 3, 2],
    [3, 3, 2, 3, 3, 3, 3, 3],
    [3, 3, 3, 3, 3, 2, 3, 3],
    [2, 3, 3, 3, 3, 3, 3, 3],
]

# $1B: Sand B — variant specks
tile_sand_b = [
    [3, 3, 3, 3, 3, 2, 3, 3],
    [3, 2, 3, 3, 3, 3, 3, 3],
    [3, 3, 3, 3, 3, 3, 3, 2],
    [3, 3, 3, 2, 3, 3, 3, 3],
    [2, 3, 3, 3, 3, 3, 2, 3],
    [3, 3, 3, 3, 3, 3, 3, 3],
    [3, 3, 2, 3, 3, 3, 3, 3],
    [3, 3, 3, 3, 2, 3, 3, 2],
]

# ---------------------------------------------------------------------------
# BUSH TILES ($1C-$1F) — LA-style round cuttable bush
# LA bushes: compact, round, darker than trees. Dense dithered fill.
# Slightly smaller than trees — sits more compactly. Outlined with dark.
# The interior uses more color 2 than trees (denser look).
# ---------------------------------------------------------------------------

# $1C: Bush top-left — round compact shape
tile_bush_tl = [
    [0, 0, 0, 1, 1, 1, 1, 1],
    [0, 0, 1, 2, 3, 2, 3, 2],
    [0, 1, 2, 3, 2, 2, 3, 2],
    [1, 2, 3, 2, 2, 3, 2, 2],
    [1, 2, 2, 3, 2, 2, 2, 3],
    [1, 3, 2, 2, 2, 3, 2, 2],
    [1, 2, 2, 3, 2, 2, 3, 2],
    [1, 2, 3, 2, 2, 3, 2, 2],
]

# $1D: Bush top-right
tile_bush_tr = [
    [1, 1, 1, 1, 1, 0, 0, 0],
    [2, 3, 2, 3, 2, 1, 0, 0],
    [2, 2, 3, 2, 3, 2, 1, 0],
    [3, 2, 2, 3, 2, 2, 2, 1],
    [2, 2, 3, 2, 2, 3, 2, 1],
    [2, 3, 2, 2, 3, 2, 2, 1],
    [3, 2, 2, 3, 2, 2, 3, 1],
    [2, 2, 3, 2, 2, 3, 2, 1],
]

# $1E: Bush bottom-left
tile_bush_bl = [
    [1, 3, 2, 2, 3, 2, 2, 3],
    [1, 2, 3, 2, 2, 3, 2, 2],
    [1, 2, 2, 3, 2, 2, 3, 2],
    [1, 3, 2, 2, 3, 2, 2, 2],
    [0, 1, 2, 3, 2, 2, 3, 2],
    [0, 1, 2, 2, 3, 2, 2, 3],
    [0, 0, 1, 1, 2, 2, 3, 2],
    [0, 0, 0, 0, 1, 1, 1, 1],
]

# $1F: Bush bottom-right
tile_bush_br = [
    [2, 2, 3, 2, 2, 3, 2, 1],
    [3, 2, 2, 3, 2, 2, 3, 1],
    [2, 3, 2, 2, 3, 2, 2, 1],
    [2, 2, 3, 2, 2, 3, 2, 1],
    [3, 2, 2, 3, 2, 2, 1, 0],
    [2, 3, 2, 2, 3, 1, 1, 0],
    [2, 2, 3, 2, 1, 1, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0],
]

# ---------------------------------------------------------------------------
# BRIDGE TILES ($2A-$2D) — wooden plank bridge
# LA bridges: horizontal wooden planks with nail/plank lines.
# Uses palette 2 (brown): 1=dk brown outlines, 2=wood fill, 3=lit highlights.
# Clear plank lines running horizontally.
# ---------------------------------------------------------------------------

# $2A: Bridge TL — top rail + planks
tile_bridge_tl = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 3, 2, 3, 2, 3, 2, 3],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 3, 2, 3, 2, 3, 2],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 3, 2, 3, 2, 3, 2, 3],
]

# $2B: Bridge TR
tile_bridge_tr = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 2, 3, 2, 3, 2, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [3, 2, 3, 2, 3, 2, 3, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 2, 3, 2, 3, 2, 1],
]

# $2C: Bridge BL — planks + bottom rail
tile_bridge_bl = [
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 3, 2, 3, 2, 3, 2],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 3, 2, 3, 2, 3, 2, 3],
    [1, 2, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# $2D: Bridge BR
tile_bridge_br = [
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [3, 2, 3, 2, 3, 2, 3, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 2, 3, 2, 3, 2, 1],
    [2, 2, 2, 2, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# ---------------------------------------------------------------------------
# STONE WALL TILES ($2E-$31) — dungeon / town wall blocks
# LA dungeon walls: brick bond pattern (running bond), dark mortar lines.
# Each brick ~4px wide, 3px tall. Offset by half on alternating rows.
# Uses palette 2 (brown).
# ---------------------------------------------------------------------------

# $2E: Stone wall TL — top-left of a wall block
tile_stonewall_tl = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 3, 2, 1, 2, 3, 2],
    [1, 2, 2, 2, 1, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 1, 2, 2, 3, 1, 2],
    [2, 2, 1, 2, 2, 2, 1, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 3, 2, 1, 2, 3, 2],
]

# $2F: Stone wall TR
tile_stonewall_tr = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 3, 2, 1, 3, 2, 1],
    [1, 2, 2, 2, 1, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 1, 2, 3, 2, 1, 1],
    [2, 2, 1, 2, 2, 2, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 3, 2, 1, 2, 3, 2, 1],
]

# $30: Stone wall BL
tile_stonewall_bl = [
    [1, 2, 2, 2, 1, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 1, 2, 2, 3, 1, 2],
    [2, 2, 1, 2, 2, 2, 1, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 2, 3, 2, 1, 2, 3, 2],
    [1, 2, 2, 2, 1, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# $31: Stone wall BR
tile_stonewall_br = [
    [1, 2, 2, 2, 1, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 3, 1, 2, 3, 2, 1, 1],
    [2, 2, 1, 2, 2, 2, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 3, 2, 1, 2, 3, 2, 1],
    [1, 2, 2, 1, 2, 2, 2, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# ---------------------------------------------------------------------------
# BORDER TILES ($32-$35) — screen border / thick wall edge
# LA borders: thick outer wall with inner bevel. Dark outer edge,
# medium body, light inner highlight. Creates a frame around the play area.
# ---------------------------------------------------------------------------

# $32: Border TL — top-left corner of frame
tile_border_tl = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 2, 2, 2, 2, 2, 2],
    [1, 1, 2, 3, 3, 3, 3, 3],
    [1, 1, 2, 3, 2, 2, 2, 2],
    [1, 1, 2, 3, 2, 2, 2, 2],
    [1, 1, 2, 3, 2, 2, 2, 2],
    [1, 1, 2, 3, 2, 2, 2, 2],
]

# $33: Border TR — top-right corner
tile_border_tr = [
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [2, 2, 2, 2, 2, 2, 1, 1],
    [3, 3, 3, 3, 3, 2, 1, 1],
    [2, 2, 2, 2, 3, 2, 1, 1],
    [2, 2, 2, 2, 3, 2, 1, 1],
    [2, 2, 2, 2, 3, 2, 1, 1],
    [2, 2, 2, 2, 3, 2, 1, 1],
]

# $34: Border BL — bottom-left corner
tile_border_bl = [
    [1, 1, 2, 3, 2, 2, 2, 2],
    [1, 1, 2, 3, 2, 2, 2, 2],
    [1, 1, 2, 3, 2, 2, 2, 2],
    [1, 1, 2, 3, 2, 2, 2, 2],
    [1, 1, 2, 3, 3, 3, 3, 3],
    [1, 1, 2, 2, 2, 2, 2, 2],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
]

# $35: Border BR — bottom-right corner
tile_border_br = [
    [2, 2, 2, 2, 3, 2, 1, 1],
    [2, 2, 2, 2, 3, 2, 1, 1],
    [2, 2, 2, 2, 3, 2, 1, 1],
    [2, 2, 2, 2, 3, 2, 1, 1],
    [3, 3, 3, 3, 3, 2, 1, 1],
    [2, 2, 2, 2, 2, 2, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1],
]


# ============================================================================
# Build and output
# ============================================================================

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    output_path = os.path.join(project_root, 'assets', 'chr', 'bg_tiles.chr')

    # Read existing CHR data to preserve HUD tiles ($20-$29)
    existing_chr = None
    if os.path.exists(output_path):
        with open(output_path, 'rb') as f:
            existing_chr = f.read()

    # Tiles $00-$1F (32 tiles)
    tiles_00_1f = [
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

    # Convert $00-$1F to CHR
    chr_data = bytearray()
    for tile in tiles_00_1f:
        chr_data.extend(make_tile(tile))

    # Preserve HUD tiles $20-$29 (10 tiles = 160 bytes at offset 0x200)
    if existing_chr and len(existing_chr) >= 0x2A0:
        chr_data.extend(existing_chr[0x200:0x2A0])
    else:
        chr_data.extend(b'\x00' * 160)

    # Tiles $2A-$35 (12 tiles)
    tiles_2a_35 = [
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

    for tile in tiles_2a_35:
        chr_data.extend(make_tile(tile))

    # Pad to 4096 bytes (256 tiles total)
    while len(chr_data) < 4096:
        chr_data.extend(b'\x00' * 16)
    chr_data = chr_data[:4096]

    with open(output_path, 'wb') as f:
        f.write(chr_data)

    print(f"Written {len(chr_data)} bytes to {output_path}")
    print(f"Tiles $00-$1F: {len(tiles_00_1f)} improved terrain tiles")
    print(f"Tiles $20-$29: HUD tiles (preserved from existing)")
    print(f"Tiles $2A-$35: {len(tiles_2a_35)} structure tiles")
    print(f"Tiles $36-$FF: zero-padded")
    return 0


if __name__ == '__main__':
    sys.exit(main())
