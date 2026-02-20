#!/usr/bin/env python3
"""
generate_sprite_tiles.py - Generate sprite-side CHR tiles for Zelda 2B.

This script generates sprite pattern table tiles (PPU $1000-$1FFF) for:
  - Octorok enemy: 4-direction walk cycle (16 tiles at $30-$3F)
  - Item pickups: heart, rupee, bomb, key (8 tiles at $24-$2B)
  - NPC old man: front/side facing (8 tiles at $40-$47)

Also regenerates existing tile assignments to keep them consistent:
  - Blank at $00
  - Enemy placeholder at $21-$23 (kept for backward compat)
  - Sword at $2D-$2E

All tiles are written into sprite_tiles.chr at their correct byte offsets.
Link sprites at $01-$1F are preserved from the existing file.

Output:
  assets/chr/sprite_tiles.chr  - 4096 bytes (256 tiles, full sprite pattern table)
  sprite_preview.html          - Self-contained HTML preview

NES CHR format: 8x8 pixels, 2bpp, 16 bytes/tile.
Color indices: 0=transparent, 1=dark outline, 2=medium, 3=light highlight
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
        if len(row) > 0:
            while len(row) < 8:
                row.append(0)
            rows.append(row[:8])
    assert len(rows) == 8, f"Expected 8 rows, got {len(rows)}"
    return rows


def empty():
    return [[0] * 8 for _ in range(8)]


# =========================================================================
# EXISTING TILES (regenerated here for consistency)
# =========================================================================

# $21-$23: Legacy Octorok placeholder (3 tiles used by current enemy_draw)
# These use ENEMY_TILE_BASE=$21, referencing $21,$22,$23,$24
# But we're now assigning $24+ to items, so we keep $21-$23 only
ENEMY_LEGACY_TL = t("""
..1111..
.122221.
12233221
12232221
12222221
12233221
.122221.
.112211.
""")

ENEMY_LEGACY_TR = t("""
..1111..
.122221.
12233221
12222321
12222221
12233221
.122221.
.112211.
""")

ENEMY_LEGACY_BL = t("""
.112211.
.122221.
12222221
12233221
.122221.
..1221..
.12..21.
.1....1.
""")

# $2D: Sword vertical
SWORD_VERT = t("""
...33...
...33...
...33...
...33...
...33...
..3333..
..1331..
...11...
""")

# $2E: Sword horizontal
SWORD_HORIZ = t("""
........
........
..1.....
.33333..
.33333..
..1.....
........
........
""")


# =========================================================================
# ITEM PICKUP SPRITES ($24-$2B, 8 tiles)
# Items shown as 2-tile wide pairs (TL + TR side by side for 16x8)
# Each pair forms one item when drawn with 2 OAM sprites
# =========================================================================

# $24: Heart pickup TL - chunky LA-style heart left half
ITEM_HEART_TL = t("""
........
.11.....
1331....
13331...
13331...
.1331...
..131...
...1....
""")

# $25: Heart pickup TR - right half
ITEM_HEART_TR = t("""
........
.....11.
....1331
...13331
...13331
...1331.
...131..
....1...
""")

# $26: Rupee TL - green diamond left half, Link's Awakening style
ITEM_RUPEE_TL = t("""
...11...
..1221..
.122221.
12222210
12233210
.123310.
..1310..
...10...
""")

# $27: Rupee TR - right half (mirrored complement)
ITEM_RUPEE_TR = t("""
...11...
..1221..
.122221.
01222221
01332221
.013321.
..0131..
...01...
""")

# $28: Bomb TL - round bomb body left half, LA-style
ITEM_BOMB_TL = t("""
.....13.
...111..
..12221.
.1222221
.1222221
.1222221
..12221.
...111..
""")

# $29: Bomb TR - right half with fuse
ITEM_BOMB_TR = t("""
31......
..111...
.12221..
1222221.
1222221.
1222221.
.12221..
..111...
""")

# $2A: Key TL - small key top, ornate head
ITEM_KEY_TL = t("""
..1111..
.122221.
12233221
12233221
.122221.
..1111..
...11...
...11...
""")

# $2B: Key TR - shaft and teeth
ITEM_KEY_TR = t("""
........
........
........
........
........
........
..11....
..11.11.
""")


# =========================================================================
# OCTOROK ENEMY SPRITES ($30-$3F, 16 tiles)
# 4 directions x 4 tiles (TL, TR, BL, BR) = 16 tiles
# Walk animation achieved by H-flipping the BL/BR tiles via OAM
# Style: Link's Awakening overworld Octorok - round body, stubby legs
# =========================================================================

# --- Down (facing camera) ---
# $30: Down TL - left side of round body with left eye
OCTOROK_DOWN_TL = t("""
..1111..
.122221.
12233210
12232210
12222210
12222210
.122210.
..11110.
""")

# $31: Down TR - right side with right eye and mouth tube
OCTOROK_DOWN_TR = t("""
..1111..
.122221.
01222221
01222321
01222221
01222221
.012221.
.011110.
""")

# $32: Down BL - left legs
OCTOROK_DOWN_BL = t("""
.112210.
.122210.
12222210
12222210
.122210.
..11210.
..12.10.
..1..10.
""")

# $33: Down BR - right legs
OCTOROK_DOWN_BR = t("""
.012211.
.012221.
01222221
01222221
.012221.
.01211..
.01.21..
.01..1..
""")

# --- Up (back turned) ---
# $34: Up TL
OCTOROK_UP_TL = t("""
..1111..
.122221.
12222210
12222210
12222210
12222210
.122210.
..11110.
""")

# $35: Up TR
OCTOROK_UP_TR = t("""
..1111..
.122221.
01222221
01222221
01222221
01222221
.012221.
.011110.
""")

# $36: Up BL
OCTOROK_UP_BL = t("""
.112210.
.122210.
12222210
12222210
.122210.
..11210.
..12.10.
..1..10.
""")

# $37: Up BR
OCTOROK_UP_BR = t("""
.012211.
.012221.
01222221
01222221
.012221.
.01211..
.01.21..
.01..1..
""")

# --- Right (side view, facing right) ---
# $38: Right TL - body left side
OCTOROK_RIGHT_TL = t("""
..1111..
.122221.
12222221
12233221
12233221
12222221
.122221.
..1111..
""")

# $39: Right TR - body right + spout
OCTOROK_RIGHT_TR = t("""
........
..111...
.12221..
122221..
1222111.
12222221
.1222210
..111100
""")

# $3A: Right BL - legs
OCTOROK_RIGHT_BL = t("""
..1221..
.12..21.
.1....1.
........
........
........
........
........
""")

# $3B: Right BR - legs
OCTOROK_RIGHT_BR = t("""
.1221...
12..21..
1....1..
........
........
........
........
........
""")

# --- Left (side view, facing left, explicit tiles for clarity) ---
# $3C: Left TL - spout + body left
OCTOROK_LEFT_TL = t("""
........
...111..
..12221.
..122221
.1112221
12222221
.0122221
..001111
""")

# $3D: Left TR - body right side
OCTOROK_LEFT_TR = t("""
..1111..
.122221.
12222221
12233221
12233221
12222221
.122221.
..1111..
""")

# $3E: Left BL - legs
OCTOROK_LEFT_BL = t("""
...1221.
..12..21
..1....1
........
........
........
........
........
""")

# $3F: Left BR - legs
OCTOROK_LEFT_BR = t("""
..1221..
.12..21.
.1....1.
........
........
........
........
........
""")


# =========================================================================
# NPC OLD MAN SPRITES ($40-$47, 8 tiles)
# Link's Awakening style - robed elder with beard
# Front facing (2x2) + Side facing right (2x2)
# Side-facing left achieved via OAM H-flip
# =========================================================================

# --- Front facing ---
# $40: Front TL - head left with beard
NPC_OLDMAN_FRONT_TL = t("""
..1111..
.133331.
13333310
13332210
.132210.
.112210.
.122210.
.122210.
""")

# $41: Front TR - head right with beard
NPC_OLDMAN_FRONT_TR = t("""
..1111..
.133331.
01333331
01223331
.012231.
.012211.
.012221.
.012221.
""")

# $42: Front BL - robe left + staff
NPC_OLDMAN_FRONT_BL = t("""
12222210
12222210
12222210
12222210
.122210.
..1221..
..12.1..
..1..1..
""")

# $43: Front BR - robe right
NPC_OLDMAN_FRONT_BR = t("""
01222221
01222221
01222221
01222221
.012221.
..1221..
..1.21..
..1..1..
""")

# --- Side facing right ---
# $44: Side TL - head side view
NPC_OLDMAN_SIDE_TL = t("""
..1111..
.133331.
13333310
13333310
13332210
.132210.
.122210.
.122210.
""")

# $45: Side TR - profile right + beard
NPC_OLDMAN_SIDE_TR = t("""
.11111..
.13331..
01333310
01333.10
.133310.
..13310.
..12210.
..12210.
""")

# $46: Side BL - robe left
NPC_OLDMAN_SIDE_BL = t("""
.122210.
12222210
12222210
12222210
.122210.
..1221..
..12.1..
..1..1..
""")

# $47: Side BR - robe right + staff
NPC_OLDMAN_SIDE_BR = t("""
..12210.
.1222210
.1222210
.1222210
..12210.
..1221..
..1.21..
..1..1..
""")


# =========================================================================
# BUILD THE FULL SPRITE TILE MAP
# =========================================================================

SPRITE_TILES = {}

# $00: blank
SPRITE_TILES[0x00] = empty()

# $21-$23: Legacy Octorok placeholder (backward compat)
SPRITE_TILES[0x21] = ENEMY_LEGACY_TL
SPRITE_TILES[0x22] = ENEMY_LEGACY_TR
SPRITE_TILES[0x23] = ENEMY_LEGACY_BL

# $24-$2B: Item pickups
SPRITE_TILES[0x24] = ITEM_HEART_TL
SPRITE_TILES[0x25] = ITEM_HEART_TR
SPRITE_TILES[0x26] = ITEM_RUPEE_TL
SPRITE_TILES[0x27] = ITEM_RUPEE_TR
SPRITE_TILES[0x28] = ITEM_BOMB_TL
SPRITE_TILES[0x29] = ITEM_BOMB_TR
SPRITE_TILES[0x2A] = ITEM_KEY_TL
SPRITE_TILES[0x2B] = ITEM_KEY_TR

# $2D-$2E: Sword
SPRITE_TILES[0x2D] = SWORD_VERT
SPRITE_TILES[0x2E] = SWORD_HORIZ

# $30-$3F: Octorok 4-direction sprites
SPRITE_TILES[0x30] = OCTOROK_DOWN_TL
SPRITE_TILES[0x31] = OCTOROK_DOWN_TR
SPRITE_TILES[0x32] = OCTOROK_DOWN_BL
SPRITE_TILES[0x33] = OCTOROK_DOWN_BR
SPRITE_TILES[0x34] = OCTOROK_UP_TL
SPRITE_TILES[0x35] = OCTOROK_UP_TR
SPRITE_TILES[0x36] = OCTOROK_UP_BL
SPRITE_TILES[0x37] = OCTOROK_UP_BR
SPRITE_TILES[0x38] = OCTOROK_RIGHT_TL
SPRITE_TILES[0x39] = OCTOROK_RIGHT_TR
SPRITE_TILES[0x3A] = OCTOROK_RIGHT_BL
SPRITE_TILES[0x3B] = OCTOROK_RIGHT_BR
SPRITE_TILES[0x3C] = OCTOROK_LEFT_TL
SPRITE_TILES[0x3D] = OCTOROK_LEFT_TR
SPRITE_TILES[0x3E] = OCTOROK_LEFT_BL
SPRITE_TILES[0x3F] = OCTOROK_LEFT_BR

# $40-$47: NPC Old Man
SPRITE_TILES[0x40] = NPC_OLDMAN_FRONT_TL
SPRITE_TILES[0x41] = NPC_OLDMAN_FRONT_TR
SPRITE_TILES[0x42] = NPC_OLDMAN_FRONT_BL
SPRITE_TILES[0x43] = NPC_OLDMAN_FRONT_BR
SPRITE_TILES[0x44] = NPC_OLDMAN_SIDE_TL
SPRITE_TILES[0x45] = NPC_OLDMAN_SIDE_TR
SPRITE_TILES[0x46] = NPC_OLDMAN_SIDE_BL
SPRITE_TILES[0x47] = NPC_OLDMAN_SIDE_BR


# =========================================================================
# CHR BUILD
# =========================================================================

def build_sprite_chr():
    """Build the full 4096-byte sprite pattern table.

    Reads existing sprite_tiles.chr to preserve Link sprites ($01-$1F),
    then overwrites the tile ranges we define.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.join(script_dir, "..")
    chr_path = os.path.join(project_dir, "assets", "chr", "sprite_tiles.chr")

    # Start with existing data to preserve Link sprites
    if os.path.exists(chr_path):
        with open(chr_path, 'rb') as f:
            data = bytearray(f.read())
        if len(data) < 4096:
            data.extend(bytes(4096 - len(data)))
        print(f"  Loaded existing sprite_tiles.chr ({len(data)} bytes)")
    else:
        data = bytearray(4096)
        print("  Creating new sprite_tiles.chr (4096 bytes)")

    # Overwrite tiles we define
    tiles_written = 0
    for tile_idx, tile_pixels in SPRITE_TILES.items():
        offset = tile_idx * 16
        chr_bytes = pixels_to_chr_tile(tile_pixels)
        data[offset:offset + 16] = chr_bytes
        tiles_written += 1

    return bytes(data[:4096]), tiles_written


# =========================================================================
# HTML PREVIEW
# =========================================================================

def tile_to_flat(tile):
    """8x8 tile -> flat list of 64 values."""
    flat = []
    for row in tile:
        flat.extend(row)
    return flat


def generate_sprite_preview(output_path):
    """Generate a self-contained HTML preview of all sprite tiles."""

    # Collect tile data for JSON embedding
    all_tile_data = {}
    for idx, tile_pixels in SPRITE_TILES.items():
        all_tile_data[str(idx)] = tile_to_flat(tile_pixels)

    # Define metatile compositions for assembled preview
    metatile_defs = [
        ("Octorok Down", [0x30, 0x31, 0x32, 0x33], "2x2"),
        ("Octorok Up", [0x34, 0x35, 0x36, 0x37], "2x2"),
        ("Octorok Right", [0x38, 0x39, 0x3A, 0x3B], "2x2"),
        ("Octorok Left", [0x3C, 0x3D, 0x3E, 0x3F], "2x2"),
        ("Old Man Front", [0x40, 0x41, 0x42, 0x43], "2x2"),
        ("Old Man Side", [0x44, 0x45, 0x46, 0x47], "2x2"),
        ("Heart", [0x24, 0x25], "1x2"),
        ("Rupee", [0x26, 0x27], "1x2"),
        ("Bomb", [0x28, 0x29], "1x2"),
        ("Key", [0x2A, 0x2B], "1x2"),
    ]

    # Individual tile sections
    tile_sections = [
        ("Item Pickups ($24-$2B)", [
            (0x24, "Heart TL"), (0x25, "Heart TR"),
            (0x26, "Rupee TL"), (0x27, "Rupee TR"),
            (0x28, "Bomb TL"), (0x29, "Bomb TR"),
            (0x2A, "Key TL"), (0x2B, "Key TR"),
        ]),
        ("Octorok Down ($30-$33)", [
            (0x30, "TL"), (0x31, "TR"), (0x32, "BL"), (0x33, "BR"),
        ]),
        ("Octorok Up ($34-$37)", [
            (0x34, "TL"), (0x35, "TR"), (0x36, "BL"), (0x37, "BR"),
        ]),
        ("Octorok Right ($38-$3B)", [
            (0x38, "TL"), (0x39, "TR"), (0x3A, "BL"), (0x3B, "BR"),
        ]),
        ("Octorok Left ($3C-$3F)", [
            (0x3C, "TL"), (0x3D, "TR"), (0x3E, "BL"), (0x3F, "BR"),
        ]),
        ("NPC Front ($40-$43)", [
            (0x40, "TL"), (0x41, "TR"), (0x42, "BL"), (0x43, "BR"),
        ]),
        ("NPC Side ($44-$47)", [
            (0x44, "TL"), (0x45, "TR"), (0x46, "BL"), (0x47, "BR"),
        ]),
        ("Weapons ($2D-$2E)", [
            (0x2D, "Sword V"), (0x2E, "Sword H"),
        ]),
        ("Legacy ($21-$23)", [
            (0x21, "Octo TL"), (0x22, "Octo TR"), (0x23, "Octo BL"),
        ]),
    ]

    # Build section data for JS
    sections_js = []
    for sect_name, sect_items in tile_sections:
        tiles = []
        labels = []
        for idx, label in sect_items:
            tiles.append(tile_to_flat(SPRITE_TILES[idx]))
            labels.append(f"{label} (${idx:02X})")
        sections_js.append({"name": sect_name, "tiles": tiles, "labels": labels})

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Zelda 2B - Sprite Tiles Preview</title>
<style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{
    background: #1a1a2e;
    color: #e0e0e0;
    font-family: 'Courier New', monospace;
    padding: 20px;
    max-width: 900px;
    margin: 0 auto;
}}
h1 {{ color: #ffd700; text-align: center; margin-bottom: 8px; font-size: 22px; }}
.subtitle {{ text-align: center; color: #888; font-size: 11px; margin-bottom: 15px; }}
h2 {{ color: #87ceeb; margin: 18px 0 8px; font-size: 16px; border-bottom: 1px solid #333; padding-bottom: 4px; }}
h3 {{ color: #aaa; margin: 12px 0 6px; font-size: 13px; }}
.pal-ctrl {{
    text-align: center; margin: 12px 0; padding: 8px;
    background: #0d0d1a; border-radius: 6px;
}}
.pal-ctrl label {{
    margin: 0 8px; cursor: pointer; padding: 4px 10px;
    border: 1px solid #555; border-radius: 4px; display: inline-block;
    font-size: 12px; margin-bottom: 4px;
}}
.pal-ctrl label:hover {{ border-color: #ffd700; }}
.meta-grid {{ display: flex; flex-wrap: wrap; gap: 18px; margin: 10px 0; }}
.meta-item {{ text-align: center; }}
.meta-item canvas {{
    border: 1px solid #555; image-rendering: pixelated;
    display: block; margin: 0 auto 4px; background: #000;
}}
.meta-item .lbl {{ font-size: 11px; color: #aaa; }}
.tile-grid {{ display: flex; flex-wrap: wrap; gap: 6px; margin: 8px 0; }}
.tile-item {{ text-align: center; }}
.tile-item canvas {{
    border: 1px solid #333; image-rendering: pixelated;
    display: block; margin: 0 auto 2px;
}}
.tile-item .lbl {{ font-size: 9px; color: #666; max-width: 70px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }}
.info {{ font-size: 11px; color: #666; text-align: center; margin-top: 18px; padding-top: 8px; border-top: 1px solid #333; }}
</style>
</head>
<body>

<h1>Zelda 2B - Sprite Tiles Preview</h1>
<p class="subtitle">Sprite pattern table ($1000-$1FFF) | Octorok, Items, NPC Old Man</p>

<div class="pal-ctrl">
    <strong>Palette:</strong>
    <label><input type="radio" name="pal" value="enemy" checked> Enemy Red</label>
    <label><input type="radio" name="pal" value="link"> Link Green</label>
    <label><input type="radio" name="pal" value="item"> Item Blue</label>
    <label><input type="radio" name="pal" value="npc"> NPC Brown</label>
    <label><input type="radio" name="pal" value="white"> White</label>
</div>

<h2>Assembled Metatiles (16x16)</h2>
<div class="meta-grid" id="meta-grid"></div>

<h2>Individual 8x8 Tiles</h2>
<div id="sections"></div>

<div class="info">
    generate_sprite_tiles.py | NES 2bpp CHR | 8x8 tiles<br>
    Octorok: $30-$3F (16 tiles) | Items: $24-$2B (8 tiles) | NPC: $40-$47 (8 tiles)
</div>

<script>
const allTiles = {json.dumps(all_tile_data)};
const metatileDefs = {json.dumps([(n, ids, t) for n, ids, t in metatile_defs])};
const sections = {json.dumps(sections_js)};

const pals = {{
    enemy: ['#0F0F0F', '#880000', '#D80000', '#FCFCFC'],
    link:  ['#0F0F0F', '#004400', '#00A800', '#FCFCFC'],
    item:  ['#0F0F0F', '#0000A8', '#3838D8', '#FCFCFC'],
    npc:   ['#0F0F0F', '#5C3800', '#AC7C00', '#FCFCFC'],
    white: ['#0F0F0F', '#545454', '#A8A8A8', '#FCFCFC'],
}};
let curPal = 'enemy';

function drawTile(ctx, data, ox, oy, sc) {{
    const c = pals[curPal];
    for (let y = 0; y < 8; y++) {{
        for (let x = 0; x < 8; x++) {{
            const v = data[y * 8 + x];
            ctx.fillStyle = v === 0 ? (((ox/8+oy/8+x+y) % 2 === 0) ? '#1a1a2e' : '#222240') : c[v];
            ctx.fillRect((ox + x) * sc, (oy + y) * sc, sc, sc);
        }}
    }}
}}

function renderMeta() {{
    const g = document.getElementById('meta-grid');
    g.innerHTML = '';
    const sc = 4;
    for (const [name, ids, type] of metatileDefs) {{
        const item = document.createElement('div');
        item.className = 'meta-item';
        const cv = document.createElement('canvas');
        const is2x2 = type === '2x2';
        cv.width = 16 * sc;
        cv.height = (is2x2 ? 16 : 8) * sc;
        const ctx = cv.getContext('2d');
        if (is2x2 && ids.length === 4) {{
            drawTile(ctx, allTiles[ids[0]], 0, 0, sc);
            drawTile(ctx, allTiles[ids[1]], 8, 0, sc);
            drawTile(ctx, allTiles[ids[2]], 0, 8, sc);
            drawTile(ctx, allTiles[ids[3]], 8, 8, sc);
        }} else {{
            drawTile(ctx, allTiles[ids[0]], 0, 0, sc);
            drawTile(ctx, allTiles[ids[1]], 8, 0, sc);
        }}
        const lbl = document.createElement('div');
        lbl.className = 'lbl';
        lbl.textContent = name;
        item.appendChild(cv);
        item.appendChild(lbl);
        g.appendChild(item);
    }}
}}

function renderSections() {{
    const cont = document.getElementById('sections');
    cont.innerHTML = '';
    for (const sect of sections) {{
        const h3 = document.createElement('h3');
        h3.textContent = sect.name;
        cont.appendChild(h3);
        const grid = document.createElement('div');
        grid.className = 'tile-grid';
        for (let i = 0; i < sect.tiles.length; i++) {{
            const item = document.createElement('div');
            item.className = 'tile-item';
            const cv = document.createElement('canvas');
            cv.width = 40; cv.height = 40;
            const ctx = cv.getContext('2d');
            drawTile(ctx, sect.tiles[i], 0, 0, 5);
            const lbl = document.createElement('div');
            lbl.className = 'lbl';
            lbl.textContent = sect.labels[i];
            item.appendChild(cv);
            item.appendChild(lbl);
            grid.appendChild(item);
        }}
        cont.appendChild(grid);
    }}
}}

function renderAll() {{ renderMeta(); renderSections(); }}

document.querySelectorAll('input[name="pal"]').forEach(r => {{
    r.addEventListener('change', function() {{ curPal = this.value; renderAll(); }});
}});
renderAll();
</script>
</body>
</html>"""

    with open(output_path, 'w') as f:
        f.write(html)


# =========================================================================
# MAIN
# =========================================================================

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.join(script_dir, "..")
    chr_dir = os.path.join(project_dir, "assets", "chr")
    os.makedirs(chr_dir, exist_ok=True)

    print("Generating sprite tiles...")

    # Build sprite CHR
    chr_data, tiles_written = build_sprite_chr()
    chr_path = os.path.join(chr_dir, "sprite_tiles.chr")
    with open(chr_path, 'wb') as f:
        f.write(chr_data)
    print(f"  Wrote {tiles_written} tiles -> {chr_path} ({len(chr_data)} bytes)")

    # Generate HTML preview
    preview_path = os.path.join(project_dir, "sprite_preview.html")
    generate_sprite_preview(preview_path)
    print(f"  HTML Preview -> {preview_path}")

    # Summary
    print("\nTile map:")
    print("  $00      : blank")
    print("  $01-$1F  : Link sprites (preserved from existing)")
    print("  $21-$23  : Legacy Octorok placeholder (3 tiles)")
    print("  $24-$2B  : Item pickups: Heart, Rupee, Bomb, Key (8 tiles)")
    print("  $2D-$2E  : Sword vert/horiz (2 tiles)")
    print("  $30-$3F  : Octorok 4-direction sprites (16 tiles)")
    print("  $40-$47  : NPC Old Man front/side (8 tiles)")
    print(f"\nTotal tiles defined: {tiles_written}")


if __name__ == "__main__":
    main()
