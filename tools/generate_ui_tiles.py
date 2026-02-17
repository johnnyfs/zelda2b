#!/usr/bin/env python3
"""
generate_ui_tiles.py - Generate UI widget and font CHR tiles for Zelda 2B.

This script generates ONLY UI/widget/font tiles. It does NOT generate
overworld or enemy tiles (those are handled by other agents).

Output:
  assets/chr/hud_widgets.chr  - 10 HUD widget tiles (160 bytes, NOT padded)
  assets/chr/font.chr         - Complete NES font (4096 bytes, padded to 256 tiles)
  ui_preview.html             - Self-contained HTML preview of all UI tiles

Tile format: NES 2bpp CHR - 8x8 pixels, 16 bytes per tile.
Color indices: 0=transparent/bg, 1=dark outline, 2=medium, 3=light highlight
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from png2chr import pixels_to_chr_tile


def t(rows_str):
    """Parse a compact tile string into pixel rows.
    Each character is a pixel value 0-3. '.' = 0 for readability.
    """
    rows = []
    for line in rows_str.strip().split('\n'):
        line = line.strip()
        if not line:
            continue
        row = []
        for ch in line:
            if ch == '.':
                row.append(0)
            elif ch in '0123':
                row.append(int(ch))
            # skip spaces
        if len(row) > 0:
            while len(row) < 8:
                row.append(0)
            rows.append(row[:8])
    assert len(rows) == 8, f"Expected 8 rows, got {len(rows)}"
    return rows


def empty():
    return [[0] * 8 for _ in range(8)]


# =========================================================================
# HUD WIDGET TILES ($20-$29, 10 tiles)
# =========================================================================

# $20: Heart Full - Boxy NES-style filled heart
HUD_HEART_FULL = t("""
.11.11..
13313310
13333310
13333310
.133310.
..1310..
...10...
........
""")

# $21: Heart Empty - Same shape, hollow (outline only)
HUD_HEART_EMPTY = t("""
.11.11..
1..1..10
1.....10
1.....10
.1...10.
..1.10..
...10...
........
""")

# $22: Magic Bottle Full - Potion bottle filled with blue
HUD_MAGIC_FULL = t("""
..1111..
..1331..
...11...
..1331..
.133331.
.133331.
..1331..
...11...
""")

# $23: Magic Bottle Empty - Same bottle shape, hollow
HUD_MAGIC_EMPTY = t("""
..1111..
..1..1..
...11...
..1..1..
.1....1.
.1....1.
..1..1..
...11...
""")

# $24: Item Box Frame TL (top-left corner)
HUD_BOX_TL = t("""
33333333
3.......
3.......
3.......
3.......
3.......
3.......
3.......
""")

# $25: Item Box Frame TR (top-right corner)
HUD_BOX_TR = t("""
33333333
.......3
.......3
.......3
.......3
.......3
.......3
.......3
""")

# $26: Item Box Frame BL (bottom-left corner)
HUD_BOX_BL = t("""
3.......
3.......
3.......
3.......
3.......
3.......
3.......
33333333
""")

# $27: Item Box Frame BR (bottom-right corner)
HUD_BOX_BR = t("""
.......3
.......3
.......3
.......3
.......3
.......3
.......3
33333333
""")

# $28: Button A indicator - circle with bold "A"
HUD_BTN_A = t("""
.11111..
1.....1.
1.333.1.
13...31.
13333.1.
13...31.
1.....1.
.11111..
""")

# $29: Button B indicator - circle with bold "B"
HUD_BTN_B = t("""
.11111..
1.....1.
1.333.1.
13..3.1.
1.33..1.
13..3.1.
1.333.1.
.11111..
""")

# Collect all 10 HUD widget tiles in order
HUD_WIDGET_TILES = [
    HUD_HEART_FULL,   # $20
    HUD_HEART_EMPTY,  # $21
    HUD_MAGIC_FULL,   # $22
    HUD_MAGIC_EMPTY,  # $23
    HUD_BOX_TL,       # $24
    HUD_BOX_TR,       # $25
    HUD_BOX_BL,       # $26
    HUD_BOX_BR,       # $27
    HUD_BTN_A,        # $28
    HUD_BTN_B,        # $29
]


# =========================================================================
# FONT TILES (256 tiles, padded to 4096 bytes)
# =========================================================================

# $00: Space (empty)
FONT_SPACE = empty()

# $01-$1A: A-Z uppercase letters (boxy NES style, color 3)

FONT_A = t("""
.33333..
33...33.
33...33.
3333333.
33...33.
33...33.
33...33.
........
""")

FONT_B = t("""
333333..
33...33.
33...33.
333333..
33...33.
33...33.
333333..
........
""")

FONT_C = t("""
.33333..
33...33.
33......
33......
33......
33...33.
.33333..
........
""")

FONT_D = t("""
33333...
33..33..
33...33.
33...33.
33...33.
33..33..
33333...
........
""")

FONT_E = t("""
3333333.
33......
33......
33333...
33......
33......
3333333.
........
""")

FONT_F = t("""
3333333.
33......
33......
33333...
33......
33......
33......
........
""")

FONT_G = t("""
.33333..
33...33.
33......
33.3333.
33...33.
33...33.
.33333..
........
""")

FONT_H = t("""
33...33.
33...33.
33...33.
3333333.
33...33.
33...33.
33...33.
........
""")

FONT_I = t("""
.33333..
...33...
...33...
...33...
...33...
...33...
.33333..
........
""")

FONT_J = t("""
..33333.
....33..
....33..
....33..
33..33..
33..33..
.3333...
........
""")

FONT_K = t("""
33..33..
33.33...
3333....
3333....
33.33...
33..33..
33...33.
........
""")

FONT_L = t("""
33......
33......
33......
33......
33......
33......
3333333.
........
""")

FONT_M = t("""
33...33.
333.333.
3333333.
33.3.33.
33...33.
33...33.
33...33.
........
""")

FONT_N = t("""
33...33.
333..33.
3333.33.
33.3333.
33..333.
33...33.
33...33.
........
""")

FONT_O = t("""
.33333..
33...33.
33...33.
33...33.
33...33.
33...33.
.33333..
........
""")

FONT_P = t("""
333333..
33...33.
33...33.
333333..
33......
33......
33......
........
""")

FONT_Q = t("""
.33333..
33...33.
33...33.
33...33.
33.3.33.
33..33..
.333.33.
........
""")

FONT_R = t("""
333333..
33...33.
33...33.
333333..
33.33...
33..33..
33...33.
........
""")

FONT_S = t("""
.33333..
33...33.
33......
.33333..
.....33.
33...33.
.33333..
........
""")

FONT_T = t("""
3333333.
...33...
...33...
...33...
...33...
...33...
...33...
........
""")

FONT_U = t("""
33...33.
33...33.
33...33.
33...33.
33...33.
33...33.
.33333..
........
""")

FONT_V = t("""
33...33.
33...33.
33...33.
33...33.
.33.33..
..333...
...3....
........
""")

FONT_W = t("""
33...33.
33...33.
33...33.
33.3.33.
3333333.
333.333.
33...33.
........
""")

FONT_X = t("""
33...33.
.33.33..
..333...
...3....
..333...
.33.33..
33...33.
........
""")

FONT_Y = t("""
33...33.
.33.33..
..333...
...3....
...3....
...3....
...3....
........
""")

FONT_Z = t("""
3333333.
.....33.
....33..
...33...
..33....
.33.....
3333333.
........
""")

# $1B-$24: Digits 0-9

FONT_0 = t("""
.33333..
33...33.
33..333.
33.3.33.
333..33.
33...33.
.33333..
........
""")

FONT_1 = t("""
...33...
..333...
.3.33...
...33...
...33...
...33...
.33333..
........
""")

FONT_2 = t("""
.33333..
33...33.
.....33.
...333..
..33....
.33.....
3333333.
........
""")

FONT_3 = t("""
.33333..
33...33.
.....33.
..3333..
.....33.
33...33.
.33333..
........
""")

FONT_4 = t("""
...333..
..3333..
.33.33..
33..33..
3333333.
....33..
....33..
........
""")

FONT_5 = t("""
3333333.
33......
333333..
.....33.
.....33.
33...33.
.33333..
........
""")

FONT_6 = t("""
..3333..
.33.....
33......
333333..
33...33.
33...33.
.33333..
........
""")

FONT_7 = t("""
3333333.
.....33.
....33..
...33...
..33....
..33....
..33....
........
""")

FONT_8 = t("""
.33333..
33...33.
33...33.
.33333..
33...33.
33...33.
.33333..
........
""")

FONT_9 = t("""
.33333..
33...33.
33...33.
.333333.
.....33.
....33..
.3333...
........
""")

# $25-$2F: Punctuation

# $25: ! (exclamation)
FONT_EXCL = t("""
..333...
..333...
..333...
..333...
..333...
........
..333...
........
""")

# $26: ? (question mark)
FONT_QUEST = t("""
.33333..
33...33.
.....33.
...333..
...33...
........
...33...
........
""")

# $27: . (period)
FONT_PERIOD = t("""
........
........
........
........
........
........
..33....
........
""")

# $28: , (comma)
FONT_COMMA = t("""
........
........
........
........
........
..33....
..33....
.33.....
""")

# $29: - (hyphen)
FONT_HYPHEN = t("""
........
........
........
.33333..
........
........
........
........
""")

# $2A: : (colon)
FONT_COLON = t("""
........
..33....
..33....
........
........
..33....
..33....
........
""")

# $2B: ' (apostrophe)
FONT_APOS = t("""
..33....
..33....
.33.....
........
........
........
........
........
""")

# $2C: " (double quote)
FONT_DQUOTE = t("""
.33.33..
.33.33..
.33.33..
........
........
........
........
........
""")

# $2D: ( (open paren)
FONT_LPAREN = t("""
...33...
..33....
.33.....
.33.....
.33.....
..33....
...33...
........
""")

# $2E: ) (close paren)
FONT_RPAREN = t("""
.33.....
..33....
...33...
...33...
...33...
..33....
.33.....
........
""")

# $2F: / (slash)
FONT_SLASH = t("""
.....33.
....33..
...33...
..33....
.33.....
33......
3.......
........
""")

# $30-$35: Symbols

# $30: Heart symbol (small)
FONT_HEART = t("""
........
.11.11..
1331331.
1333331.
.13331..
..131...
...1....
........
""")

# $31: Rupee symbol (small diamond)
FONT_RUPEE = t("""
...3....
..333...
.33333..
3333333.
.33333..
..333...
...3....
........
""")

# $32: Arrow right >
FONT_ARROW_R = t("""
.3......
..33....
...333..
....333.
...333..
..33....
.3......
........
""")

# $33: Arrow left <
FONT_ARROW_L = t("""
.....3..
...33...
.333....
333.....
.333....
...33...
.....3..
........
""")

# $34: Arrow up ^
FONT_ARROW_U = t("""
...3....
..333...
.33.33..
33...33.
........
........
........
........
""")

# $35: Arrow down v
FONT_ARROW_D = t("""
........
........
........
33...33.
.33.33..
..333...
...3....
........
""")


# Collect all font tiles in order
FONT_LETTERS = [
    FONT_A, FONT_B, FONT_C, FONT_D, FONT_E, FONT_F, FONT_G,
    FONT_H, FONT_I, FONT_J, FONT_K, FONT_L, FONT_M, FONT_N,
    FONT_O, FONT_P, FONT_Q, FONT_R, FONT_S, FONT_T, FONT_U,
    FONT_V, FONT_W, FONT_X, FONT_Y, FONT_Z,
]

FONT_DIGITS = [
    FONT_0, FONT_1, FONT_2, FONT_3, FONT_4,
    FONT_5, FONT_6, FONT_7, FONT_8, FONT_9,
]

FONT_PUNCTUATION = [
    FONT_EXCL, FONT_QUEST, FONT_PERIOD, FONT_COMMA, FONT_HYPHEN,
    FONT_COLON, FONT_APOS, FONT_DQUOTE, FONT_LPAREN, FONT_RPAREN,
    FONT_SLASH,
]

FONT_SYMBOLS = [
    FONT_HEART, FONT_RUPEE,
    FONT_ARROW_R, FONT_ARROW_L, FONT_ARROW_U, FONT_ARROW_D,
]


# =========================================================================
# CHR BUILD HELPERS
# =========================================================================

def build_chr(tiles):
    """Convert a list of pixel-grid tiles to CHR binary data."""
    data = bytearray()
    for tile in tiles:
        data.extend(pixels_to_chr_tile(tile))
    return bytes(data)


def pad_to_bank(data, bank_size=4096):
    """Pad CHR data to fill a full pattern table (256 tiles = 4096 bytes)."""
    if len(data) < bank_size:
        data = data + bytes(bank_size - len(data))
    return data


# =========================================================================
# HTML PREVIEW GENERATION
# =========================================================================

def tile_to_pixel_data(tile):
    """Convert an 8x8 tile (list of 8 rows of 8 ints) to a flat list of 64 values."""
    flat = []
    for row in tile:
        flat.extend(row)
    return flat


def generate_html_preview(hud_tiles, font_tiles, output_path):
    """Generate a self-contained HTML preview of all UI tiles."""

    # Convert all tiles to flat pixel arrays for JSON embedding
    hud_data = []
    hud_labels = [
        "Heart Full ($20)", "Heart Empty ($21)",
        "Magic Full ($22)", "Magic Empty ($23)",
        "Box TL ($24)", "Box TR ($25)",
        "Box BL ($26)", "Box BR ($27)",
        "Button A ($28)", "Button B ($29)",
    ]
    for tile in hud_tiles:
        hud_data.append(tile_to_pixel_data(tile))

    font_data = []
    for tile in font_tiles:
        font_data.append(tile_to_pixel_data(tile))

    # Build character map for font rendering
    char_map = {}
    # Space
    char_map[' '] = 0x00
    # A-Z
    for i in range(26):
        char_map[chr(ord('A') + i)] = 0x01 + i
    # 0-9
    for i in range(10):
        char_map[chr(ord('0') + i)] = 0x1B + i
    # Punctuation
    char_map['!'] = 0x25
    char_map['?'] = 0x26
    char_map['.'] = 0x27
    char_map[','] = 0x28
    char_map['-'] = 0x29
    char_map[':'] = 0x2A
    char_map["'"] = 0x2B
    char_map['"'] = 0x2C
    char_map['('] = 0x2D
    char_map[')'] = 0x2E
    char_map['/'] = 0x2F

    # Font labels for the grid
    font_labels = ['SPC']
    for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
        font_labels.append(c)
    for c in '0123456789':
        font_labels.append(c)
    font_labels.extend(['!', '?', '.', ',', '-', ':', "'", '"', '(', ')', '/'])
    font_labels.extend(['Heart', 'Rupee', '>', '<', '^', 'v'])
    # Fill remaining with empty labels
    while len(font_labels) < len(font_data):
        font_labels.append('')

    sample_texts = [
        "THE LEGEND OF ZELDA",
        "LINK HAS 3 HEARTS",
        "BUY FOR 50 RUPEES?",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "0123456789 !?.,:-'\"()/",
    ]

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Zelda 2B - UI Widgets &amp; Font Preview</title>
<style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{
    background: #1a1a2e;
    color: #e0e0e0;
    font-family: 'Courier New', monospace;
    padding: 20px;
}}
h1 {{
    color: #ffd700;
    text-align: center;
    margin-bottom: 10px;
    font-size: 24px;
}}
h2 {{
    color: #87ceeb;
    margin: 20px 0 10px;
    font-size: 18px;
    border-bottom: 1px solid #333;
    padding-bottom: 5px;
}}
h3 {{
    color: #aaa;
    margin: 15px 0 8px;
    font-size: 14px;
}}
.palette-controls {{
    text-align: center;
    margin: 15px 0;
    padding: 10px;
    background: #0d0d1a;
    border-radius: 8px;
}}
.palette-controls label {{
    margin-right: 15px;
    cursor: pointer;
    padding: 5px 12px;
    border: 1px solid #555;
    border-radius: 4px;
    display: inline-block;
    margin-bottom: 5px;
}}
.palette-controls label:hover {{
    border-color: #ffd700;
}}
.palette-controls input[type="radio"] {{
    margin-right: 5px;
}}
.tile-grid {{
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    margin: 10px 0;
}}
.tile-item {{
    text-align: center;
}}
.tile-item canvas {{
    border: 1px solid #333;
    image-rendering: pixelated;
    display: block;
    margin: 0 auto 4px;
}}
.tile-item .label {{
    font-size: 10px;
    color: #888;
    max-width: 60px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}}
.font-grid {{
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin: 10px 0;
}}
.font-item {{
    text-align: center;
}}
.font-item canvas {{
    border: 1px solid #222;
    image-rendering: pixelated;
    display: block;
    margin: 0 auto 2px;
}}
.font-item .label {{
    font-size: 9px;
    color: #666;
}}
.sample-text {{
    margin: 8px 0;
    padding: 8px 12px;
    background: #0d0d1a;
    border-radius: 4px;
}}
.sample-text canvas {{
    image-rendering: pixelated;
    display: block;
    margin: 4px 0;
}}
.sample-label {{
    font-size: 11px;
    color: #666;
    margin-bottom: 4px;
}}
.info {{
    font-size: 12px;
    color: #777;
    text-align: center;
    margin-top: 20px;
    padding-top: 10px;
    border-top: 1px solid #333;
}}
</style>
</head>
<body>

<h1>Zelda 2B - UI Widgets &amp; Font Preview</h1>

<div class="palette-controls">
    <strong>Palette:</strong>
    <label><input type="radio" name="palette" value="white" checked> UI White ($0F/$00/$10/$30)</label>
    <label><input type="radio" name="palette" value="green"> Overworld Green ($0F/$09/$19/$29)</label>
    <label><input type="radio" name="palette" value="red"> Red ($0F/$06/$16/$27)</label>
</div>

<h2>HUD Widgets (hud_widgets.chr - 10 tiles, 160 bytes)</h2>
<div class="tile-grid" id="hud-grid"></div>

<h2>Font (font.chr - 256 tiles, 4096 bytes)</h2>

<h3>Letters A-Z</h3>
<div class="font-grid" id="font-letters"></div>

<h3>Digits 0-9</h3>
<div class="font-grid" id="font-digits"></div>

<h3>Punctuation &amp; Symbols</h3>
<div class="font-grid" id="font-punct"></div>

<h2>Sample Text</h2>
<div id="sample-texts"></div>

<div class="info">
    Generated by generate_ui_tiles.py | NES 2bpp CHR format | 8x8 pixel tiles
</div>

<script>
// Tile data embedded as JSON
const hudTiles = {json.dumps(hud_data)};
const hudLabels = {json.dumps(hud_labels)};
const fontTiles = {json.dumps(font_data)};
const fontLabels = {json.dumps(font_labels)};
const charMap = {json.dumps(char_map)};
const sampleTexts = {json.dumps(sample_texts)};

// NES palette approximations (RGB)
const palettes = {{
    white: ['#0F0F0F', '#545454', '#A8A8A8', '#FCFCFC'],   // $0F,$00,$10,$30
    green: ['#0F0F0F', '#003800', '#00A800', '#44D800'],    // $0F,$09,$19,$29
    red:   ['#0F0F0F', '#880000', '#D80000', '#FFA347'],    // $0F,$06,$16,$27
}};

let currentPalette = 'white';

function drawTile(canvas, tileData, scale, pal) {{
    const ctx = canvas.getContext('2d');
    canvas.width = 8 * scale;
    canvas.height = 8 * scale;
    const colors = palettes[pal];
    for (let y = 0; y < 8; y++) {{
        for (let x = 0; x < 8; x++) {{
            const px = tileData[y * 8 + x];
            ctx.fillStyle = colors[px];
            ctx.fillRect(x * scale, y * scale, scale, scale);
        }}
    }}
}}

function renderHUD() {{
    const grid = document.getElementById('hud-grid');
    grid.innerHTML = '';
    for (let i = 0; i < hudTiles.length; i++) {{
        const item = document.createElement('div');
        item.className = 'tile-item';
        const canvas = document.createElement('canvas');
        drawTile(canvas, hudTiles[i], 6, currentPalette);
        const label = document.createElement('div');
        label.className = 'label';
        label.textContent = hudLabels[i];
        item.appendChild(canvas);
        item.appendChild(label);
        grid.appendChild(item);
    }}
}}

function renderFontSection(containerId, startIdx, endIdx) {{
    const grid = document.getElementById(containerId);
    grid.innerHTML = '';
    for (let i = startIdx; i < endIdx && i < fontTiles.length; i++) {{
        const item = document.createElement('div');
        item.className = 'font-item';
        const canvas = document.createElement('canvas');
        drawTile(canvas, fontTiles[i], 4, currentPalette);
        const label = document.createElement('div');
        label.className = 'label';
        label.textContent = fontLabels[i] || ('$' + i.toString(16).toUpperCase().padStart(2, '0'));
        item.appendChild(canvas);
        item.appendChild(label);
        grid.appendChild(item);
    }}
}}

function renderSampleTexts() {{
    const container = document.getElementById('sample-texts');
    container.innerHTML = '';
    const scale = 3;
    for (const text of sampleTexts) {{
        const div = document.createElement('div');
        div.className = 'sample-text';
        const labelDiv = document.createElement('div');
        labelDiv.className = 'sample-label';
        labelDiv.textContent = text;
        div.appendChild(labelDiv);

        const canvas = document.createElement('canvas');
        canvas.width = text.length * 8 * scale;
        canvas.height = 8 * scale;
        canvas.style.imageRendering = 'pixelated';
        const ctx = canvas.getContext('2d');
        const colors = palettes[currentPalette];

        for (let ci = 0; ci < text.length; ci++) {{
            const ch = text[ci].toUpperCase();
            let tileIdx = charMap[ch];
            if (tileIdx === undefined) tileIdx = 0;
            const tileData = fontTiles[tileIdx];
            if (!tileData) continue;
            for (let y = 0; y < 8; y++) {{
                for (let x = 0; x < 8; x++) {{
                    const px = tileData[y * 8 + x];
                    ctx.fillStyle = colors[px];
                    ctx.fillRect((ci * 8 + x) * scale, y * scale, scale, scale);
                }}
            }}
        }}

        div.appendChild(canvas);
        container.appendChild(div);
    }}
}}

function renderAll() {{
    renderHUD();
    // Letters: indices 1..26 (A-Z)
    renderFontSection('font-letters', 1, 27);
    // Digits: indices 27..36 (0-9)
    renderFontSection('font-digits', 27, 37);
    // Punctuation + symbols: indices 37..54
    renderFontSection('font-punct', 37, 55);
    renderSampleTexts();
}}

// Palette switching
document.querySelectorAll('input[name="palette"]').forEach(radio => {{
    radio.addEventListener('change', function() {{
        currentPalette = this.value;
        renderAll();
    }});
}});

renderAll();
</script>
</body>
</html>"""
    return html


# =========================================================================
# MAIN
# =========================================================================

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.join(script_dir, "..")
    chr_dir = os.path.join(project_dir, "assets", "chr")
    os.makedirs(chr_dir, exist_ok=True)

    # --- 1. HUD Widgets (10 tiles, 160 bytes, NOT padded) ---
    hud_data = build_chr(HUD_WIDGET_TILES)
    hud_path = os.path.join(chr_dir, "hud_widgets.chr")
    with open(hud_path, 'wb') as f:
        f.write(hud_data)
    print(f"HUD Widgets: {len(HUD_WIDGET_TILES)} tiles -> {hud_path} ({len(hud_data)} bytes)")
    assert len(hud_data) == 160, f"Expected 160 bytes, got {len(hud_data)}"

    # --- 2. Font (256 tiles, padded to 4096 bytes) ---
    # Build the full font tile list in order
    font_tiles_list = [FONT_SPACE]                      # $00
    font_tiles_list.extend(FONT_LETTERS)                # $01-$1A
    font_tiles_list.extend(FONT_DIGITS)                 # $1B-$24
    font_tiles_list.extend(FONT_PUNCTUATION)            # $25-$2F
    font_tiles_list.extend(FONT_SYMBOLS)                # $30-$35
    # $36-$FF: empty/reserved
    while len(font_tiles_list) < 256:
        font_tiles_list.append(empty())

    font_data = build_chr(font_tiles_list)
    assert len(font_data) == 4096, f"Expected 4096 bytes, got {len(font_data)}"
    font_path = os.path.join(chr_dir, "font.chr")
    with open(font_path, 'wb') as f:
        f.write(font_data)
    print(f"Font: {len(font_tiles_list)} tiles -> {font_path} ({len(font_data)} bytes)")

    # --- 3. HTML Preview ---
    # For the preview, we only show the meaningful tiles (not all 256 empties)
    meaningful_count = 1 + len(FONT_LETTERS) + len(FONT_DIGITS) + len(FONT_PUNCTUATION) + len(FONT_SYMBOLS)
    preview_font = font_tiles_list[:meaningful_count]

    html = generate_html_preview(HUD_WIDGET_TILES, font_tiles_list, None)
    html_path = os.path.join(project_dir, "ui_preview.html")
    with open(html_path, 'w') as f:
        f.write(html)
    print(f"HTML Preview: {html_path}")

    print("\nDone! Output files:")
    print(f"  {hud_path}  ({len(hud_data)} bytes, {len(HUD_WIDGET_TILES)} tiles)")
    print(f"  {font_path}  ({len(font_data)} bytes, 256 tiles)")
    print(f"  {html_path}")


if __name__ == "__main__":
    main()
