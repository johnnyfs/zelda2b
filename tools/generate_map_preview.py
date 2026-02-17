#!/usr/bin/env python3
"""
generate_map_preview.py - Generate HTML preview of map metatiles and screens.

Reads bg_tiles.chr and renders all 16 metatiles + all 6 screens as pixel-art
in an HTML file for operator review.
"""
import os
import sys
import base64
import struct

# NES color palette (subset of the 64 standard NES colors)
# Index: NES palette value -> RGB
NES_PALETTE = {
    0x0F: (0, 0, 0),       # Black
    0x09: (0, 63, 0),      # Darker green
    0x19: (0, 120, 0),     # Dark green
    0x29: (0, 168, 0),     # Medium green
    0x01: (0, 0, 120),     # Dark blue
    0x11: (32, 56, 184),   # Medium blue
    0x21: (60, 120, 248),  # Light blue
    0x07: (68, 40, 0),     # Dark brown
    0x17: (120, 68, 0),    # Medium brown
    0x27: (172, 124, 0),   # Light brown/tan
    0x00: (84, 84, 84),    # Dark gray
    0x10: (152, 152, 152), # Light gray
    0x30: (252, 252, 252), # White
    0x38: (248, 216, 120), # Cream/yellow
    0x06: (120, 0, 0),     # Dark red
    0x16: (168, 16, 0),    # Red
    0x08: (68, 40, 0),     # Dark yellow/brown
    0x28: (216, 168, 0),   # Yellow
    0x20: (252, 252, 252), # White (alt)
}

# Palette definitions (from palettes.s)
BG_PALETTES = [
    [0x0F, 0x09, 0x19, 0x29],  # BG0: Green (grass/trees)
    [0x0F, 0x01, 0x11, 0x21],  # BG1: Blue (water)
    [0x0F, 0x07, 0x17, 0x27],  # BG2: Brown (dungeon/cave)
    [0x0F, 0x00, 0x10, 0x30],  # BG3: UI (gray/white)
]

# Metatile definitions (from metatiles.s): [TL, TR, BL, BR, attr]
METATILES = [
    [0x00, 0x00, 0x00, 0x00, 0x00],  # 0: Empty
    [0x01, 0x02, 0x03, 0x01, 0x00],  # 1: Grass light
    [0x02, 0x03, 0x01, 0x02, 0x00],  # 2: Grass dark
    [0x04, 0x05, 0x06, 0x07, 0x80],  # 3: Tree
    [0x08, 0x09, 0x0A, 0x0B, 0x81],  # 4: Water
    [0x0C, 0x0D, 0x0C, 0x0D, 0x00],  # 5: Path
    [0x0E, 0x0F, 0x10, 0x11, 0x80],  # 6: Rock wall
    [0x16, 0x17, 0x18, 0x19, 0x02],  # 7: Door
    [0x32, 0x33, 0x34, 0x35, 0x80],  # 8: Border
    [0x32, 0x32, 0x34, 0x34, 0x80],  # 9: Border L
    [0x33, 0x33, 0x35, 0x35, 0x80],  # 10: Border R
    [0x1A, 0x1B, 0x1A, 0x1B, 0x00],  # 11: Sand
    [0x1C, 0x1D, 0x1E, 0x1F, 0x80],  # 12: Bush
    [0x12, 0x13, 0x14, 0x15, 0x02],  # 13: Stone floor
    [0x2E, 0x2F, 0x30, 0x31, 0x82],  # 14: Stone wall
    [0x2A, 0x2B, 0x2C, 0x2D, 0x02],  # 15: Bridge
]

METATILE_NAMES = [
    "Empty", "Grass", "Grass2", "Tree", "Water", "Path", "Rock",
    "Door", "Border", "BorderL", "BorderR", "Sand", "Bush",
    "StoneFloor", "StoneWall", "Bridge"
]

# Screen data (from map_screens.s)
SCREENS = [
    # Screen 0: Starting area - grassy field with path crossroads
    [
        3, 3, 3, 3, 3, 3, 3, 5, 5, 3, 3, 3, 3, 3, 3, 3,
        3, 1, 1, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 2, 1, 1, 2, 1, 5, 5, 1, 2, 1, 1, 2, 1, 3,
        3, 1, 1, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 1, 2, 1, 1, 1, 5, 5, 1, 1, 1, 2, 1, 1, 3,
        3, 1, 1, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 3,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        3, 1, 1, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 1, 1, 2, 1, 1, 5, 5, 1, 1, 2, 1, 1, 1, 3,
        3, 1, 2, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 2, 1, 3,
        3, 1, 1, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 1, 1, 1, 2, 1, 5, 5, 1, 2, 1, 1, 1, 1, 3,
        3, 1, 1, 2, 1, 1, 1, 5, 5, 1, 1, 1, 2, 1, 1, 3,
        3, 3, 3, 3, 3, 3, 3, 5, 5, 3, 3, 3, 3, 3, 3, 3,
    ],
    # Screen 1: Forest clearing
    [
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3,
        3, 1, 1,12,12, 1, 1, 1, 1, 1, 1,12,12, 1, 1, 3,
        3, 1,12,12,12,12, 1, 1, 1, 1,12,12,12,12, 1, 3,
        3, 1,12,12, 2,12, 1, 1, 1, 1,12, 2,12,12, 1, 3,
        3, 1, 1,12,12, 1, 1, 1, 1, 1, 1,12,12, 1, 1, 3,
        5, 5, 5, 5, 5, 5, 5, 1, 1, 5, 5, 5, 5, 5, 5, 5,
        3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 1, 3, 3, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 3,
        3, 1, 3, 3, 3, 3, 1, 1, 1, 1, 3, 3, 3, 3, 1, 3,
        3, 1, 1, 3, 3, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 3,
        3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
        3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    ],
    # Screen 2: Lake area with bridge
    [
        3, 3, 1, 1, 1, 1, 4, 4, 4, 4, 4, 1, 1, 1, 3, 3,
        3, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 3,
        1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1,
        1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1,
        1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1,
        1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1,
        5, 5,15,15,15,15, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1,
        1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1,
        1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1,
        1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1,
        1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1,
        1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1,
        3, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 3,
        3, 3, 1, 1, 1, 1, 4, 4, 4, 4, 1, 1, 1, 1, 3, 3,
    ],
    # Screen 3: Southern woods with cave entrances
    [
        3, 3, 3, 3, 3, 3, 3, 5, 5, 3, 3, 3, 3, 3, 3, 3,
        3, 1, 1, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 1, 1, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 1, 6, 6, 6, 1, 5, 5, 1, 6, 6, 6, 1, 1, 3,
        3, 1, 1, 6, 7, 6, 1, 5, 5, 1, 6, 7, 6, 1, 1, 3,
        3, 1, 1, 6,13, 6, 1, 1, 1, 1, 6,13, 6, 1, 1, 3,
        3, 1, 1, 1, 5, 5, 5, 5, 5, 5, 5, 5, 1, 1, 1, 3,
        3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
        3, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 3,
        3, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 3,
        3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3,
        3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3,
        3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    ],
    # Screen 4: Village with buildings
    [
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 3,
        3, 5,14,14,14, 5, 1, 1, 1, 1, 5,14,14,14, 5, 3,
        3, 5,14,13,14, 5, 1, 1, 1, 1, 5,14,13,14, 5, 3,
        3, 5,14, 7,14, 5, 1, 1, 1, 1, 5,14, 7,14, 5, 3,
        3, 5, 5, 5, 5, 5, 1, 1, 1, 1, 5, 5, 5, 5, 5, 3,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
        3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 3,
        3, 5,14,14,14,14,14, 5, 5,14,14,14,14,14, 5, 3,
        3, 5,14,13,13,13,14, 5, 5,14,13,13,13,14, 5, 3,
        3, 5,14,13, 7,13,14, 5, 5,14,13, 7,13,14, 5, 3,
        3, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    ],
    # Screen 5: Southern lake shore
    [
        3, 3, 1, 1, 1, 1, 4, 4, 4, 4, 1, 1, 1, 1, 3, 3,
        3, 1, 1, 1, 1, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 3,
        1, 1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 1,
        1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1,
        1,11,11, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,11,11, 1,
        1,11,11,11, 4, 4, 4, 4, 4, 4, 4, 4,11,11,11, 1,
        5, 5,11,11,11,11, 4, 4, 4, 4,11,11,11,11, 5, 5,
        1, 1,11,11,11,11,11, 4, 4,11,11,11,11,11, 1, 1,
        1, 1, 1,11,11,11,11,11,11,11,11,11,11, 1, 1, 1,
        1, 1, 1, 1,11,11,11,11,11,11,11,11, 1, 1, 1, 1,
        3, 1, 1, 1, 1,11,11,11,11,11,11, 1, 1, 1, 1, 3,
        3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3,
        3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    ],
]

SCREEN_NAMES = [
    "Screen 0: Starting Area",
    "Screen 1: Forest Clearing",
    "Screen 2: Lake + Bridge",
    "Screen 3: Cave Entrances",
    "Screen 4: Village",
    "Screen 5: Lake Shore",
]


def decode_chr_tile(chr_data, tile_idx):
    """Decode NES CHR tile into 8x8 array of 2-bit pixel values."""
    offset = tile_idx * 16
    if offset + 16 > len(chr_data):
        return [[0]*8 for _ in range(8)]

    pixels = []
    for row in range(8):
        lo_byte = chr_data[offset + row]
        hi_byte = chr_data[offset + 8 + row]
        row_pixels = []
        for col in range(8):
            bit = 7 - col
            lo_bit = (lo_byte >> bit) & 1
            hi_bit = (hi_byte >> bit) & 1
            row_pixels.append((hi_bit << 1) | lo_bit)
        pixels.append(row_pixels)
    return pixels


def render_metatile_pixels(chr_data, metatile):
    """Render a 16x16 metatile to pixel array with palette colors."""
    tl_idx, tr_idx, bl_idx, br_idx, attr = metatile
    palette_idx = attr & 0x03
    palette = BG_PALETTES[palette_idx]

    tl = decode_chr_tile(chr_data, tl_idx)
    tr = decode_chr_tile(chr_data, tr_idx)
    bl = decode_chr_tile(chr_data, bl_idx)
    br = decode_chr_tile(chr_data, br_idx)

    pixels = []
    for row in range(16):
        row_pixels = []
        if row < 8:
            for col in range(16):
                if col < 8:
                    c = tl[row][col]
                else:
                    c = tr[row][col-8]
                nes_col = palette[c]
                row_pixels.append(NES_PALETTE.get(nes_col, (0,0,0)))
        else:
            for col in range(16):
                if col < 8:
                    c = bl[row-8][col]
                else:
                    c = br[row-8][col-8]
                nes_col = palette[c]
                row_pixels.append(NES_PALETTE.get(nes_col, (0,0,0)))
        pixels.append(row_pixels)
    return pixels


def pixels_to_css_grid(pixels, scale=3):
    """Convert pixel array to HTML with CSS box-shadow rendering."""
    # Use canvas-based rendering for efficiency
    width = len(pixels[0])
    height = len(pixels)

    # Build pixel data as flat array
    data = []
    for row in pixels:
        for r, g, b in row:
            data.extend([r, g, b, 255])
    return width, height, data


def generate_html(chr_data):
    """Generate complete HTML preview page."""

    html = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Zelda 2B - Map Tile Preview</title>
<style>
body { background: #1a1a2e; color: #eee; font-family: 'Courier New', monospace; margin: 20px; }
h1 { color: #29a329; text-align: center; }
h2 { color: #21c0ff; border-bottom: 1px solid #333; padding-bottom: 5px; }
h3 { color: #d4a017; }
.section { margin: 20px 0; }
.metatile-grid { display: flex; flex-wrap: wrap; gap: 10px; }
.metatile-card {
    background: #222; border: 1px solid #444; padding: 8px; border-radius: 4px;
    text-align: center; width: 100px;
}
.metatile-card .label { font-size: 10px; margin-top: 4px; color: #888; }
.metatile-card .solid { color: #ff4444; font-weight: bold; }
.metatile-card .walkable { color: #44ff44; }
.screen-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; max-width: 1200px; }
.screen-card { background: #222; border: 1px solid #444; padding: 10px; border-radius: 4px; }
.screen-card h3 { margin: 5px 0; font-size: 14px; }
canvas { image-rendering: pixelated; image-rendering: crisp-edges; }
.palette-info { display: flex; gap: 20px; margin: 10px 0; }
.palette { display: flex; align-items: center; gap: 5px; }
.color-swatch { width: 20px; height: 20px; border: 1px solid #555; display: inline-block; }
.info { background: #1a2a1a; border: 1px solid #2a4a2a; padding: 10px; border-radius: 4px; margin: 10px 0; }
</style>
</head>
<body>
<h1>Zelda 2B - Map Tile Preview</h1>
<div class="info">
<strong>Map Artist: BG Tile Overhaul</strong><br>
44 distinct tiles replacing identical placeholders. Each metatile is now visually unique 16x16 blocks.<br>
Tiles sourced from Link's Awakening style pixel art patterns. ROM builds clean at 524KB.
</div>

<h2>Palettes</h2>
<div class="palette-info">
"""

    palette_names = ["BG0: Green (Overworld)", "BG1: Blue (Water)", "BG2: Brown (Dungeon)", "BG3: Gray (UI)"]
    for i, (name, pal) in enumerate(zip(palette_names, BG_PALETTES)):
        html += f'<div class="palette"><strong>{name}:</strong> '
        for j, c in enumerate(pal):
            r, g, b = NES_PALETTE.get(c, (0,0,0))
            html += f'<span class="color-swatch" style="background:rgb({r},{g},{b})" title="${c:02X} = ({r},{g},{b})"></span>'
        html += '</div>\n'

    html += """</div>

<h2>Metatiles (16x16 each)</h2>
<div class="metatile-grid">
"""

    # Render each metatile
    for mt_idx, (mt, name) in enumerate(zip(METATILES, METATILE_NAMES)):
        pixels = render_metatile_pixels(chr_data, mt)
        solid = (mt[4] & 0x80) != 0
        pal_idx = mt[4] & 0x03

        # Encode pixel data for canvas
        pixel_flat = []
        for row in pixels:
            for r, g, b in row:
                pixel_flat.extend([r, g, b, 255])

        b64 = base64.b64encode(bytes(pixel_flat)).decode()

        solid_class = "solid" if solid else "walkable"
        solid_text = "SOLID" if solid else "walk"

        html += f'''<div class="metatile-card">
<canvas id="mt{mt_idx}" width="16" height="16" style="width:64px;height:64px;"></canvas>
<div class="label">{mt_idx}: {name}</div>
<div class="{solid_class}">{solid_text} P{pal_idx}</div>
</div>
'''

    html += """</div>

<h2>Screen Maps (16x14 metatiles = 256x224 px)</h2>
<div class="screen-grid">
"""

    # Render each screen
    for scr_idx, (screen, name) in enumerate(zip(SCREENS, SCREEN_NAMES)):
        # Render full screen (16*16 x 14*16 = 256x224 pixels)
        screen_pixels = []
        for mt_row in range(14):
            for pixel_row in range(16):
                row_pixels = []
                for mt_col in range(16):
                    mt_id = screen[mt_row * 16 + mt_col]
                    mt = METATILES[mt_id]
                    tile_pixels = render_metatile_pixels(chr_data, mt)
                    row_pixels.extend(tile_pixels[pixel_row])
                screen_pixels.append(row_pixels)

        html += f'''<div class="screen-card">
<h3>{name}</h3>
<canvas id="scr{scr_idx}" width="256" height="224" style="width:384px;height:336px;"></canvas>
</div>
'''

    html += """</div>

<script>
// Metatile pixel data
const metatileData = {
"""

    # Emit metatile pixel data
    for mt_idx, mt in enumerate(METATILES):
        pixels = render_metatile_pixels(chr_data, mt)
        pixel_flat = []
        for row in pixels:
            for r, g, b in row:
                pixel_flat.extend([r, g, b, 255])
        html += f'  {mt_idx}: new Uint8ClampedArray({pixel_flat}),\n'

    html += "};\n\n"

    # Draw metatiles
    html += """
// Draw metatiles
for (const [idx, data] of Object.entries(metatileData)) {
    const canvas = document.getElementById('mt' + idx);
    if (canvas) {
        const ctx = canvas.getContext('2d');
        const imgData = new ImageData(data, 16, 16);
        ctx.putImageData(imgData, 0, 0);
    }
}
"""

    # Screen pixel data
    html += "\n// Screen data\nconst screenData = {\n"
    for scr_idx, (screen, name) in enumerate(zip(SCREENS, SCREEN_NAMES)):
        screen_pixels = []
        for mt_row in range(14):
            for pixel_row in range(16):
                for mt_col in range(16):
                    mt_id = screen[mt_row * 16 + mt_col]
                    mt = METATILES[mt_id]
                    tile_pixels = render_metatile_pixels(chr_data, mt)
                    for r, g, b in tile_pixels[pixel_row]:
                        screen_pixels.extend([r, g, b, 255])

        # Chunk the data into smaller pieces to avoid giant literals
        html += f'  {scr_idx}: new Uint8ClampedArray(['
        # Write in chunks
        chunk_size = 1000
        for i in range(0, len(screen_pixels), chunk_size):
            chunk = screen_pixels[i:i+chunk_size]
            html += ','.join(str(x) for x in chunk)
            if i + chunk_size < len(screen_pixels):
                html += ','
        html += ']),\n'

    html += """};\n
// Draw screens
for (const [idx, data] of Object.entries(screenData)) {
    const canvas = document.getElementById('scr' + idx);
    if (canvas) {
        const ctx = canvas.getContext('2d');
        const imgData = new ImageData(data, 256, 224);
        ctx.putImageData(imgData, 0, 0);
    }
}
</script>
</body>
</html>"""

    return html


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    chr_path = os.path.join(project_dir, 'assets', 'chr', 'bg_tiles.chr')

    with open(chr_path, 'rb') as f:
        chr_data = f.read()

    print(f"Read {len(chr_data)} bytes from {chr_path}")

    html = generate_html(chr_data)

    # Write to workspace root for operator_prompt
    output_path = os.path.join(project_dir, 'map_preview.html')
    with open(output_path, 'w') as f:
        f.write(html)

    print(f"Written preview to {output_path}")
    print(f"HTML size: {len(html)} bytes")

    return 0


if __name__ == '__main__':
    sys.exit(main())
