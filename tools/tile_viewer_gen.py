#!/usr/bin/env python3
"""
tile_viewer_gen.py - Generate an HTML tile viewer from CHR data.

Creates a self-contained HTML file that renders NES CHR tiles with
interactive palette selection and tile inspection.

Usage:
  python3 tile_viewer_gen.py assets/chr/bg_tiles.chr --output viewer.html
  python3 tile_viewer_gen.py assets/chr/bg_tiles.chr assets/chr/sprite_tiles.chr --output viewer.html
"""

import argparse
import base64
import json
import os
import sys


# NES master palette (NTSC, 2C02) - 64 entries as hex color strings
NES_PALETTE_HEX = [
    "#626262", "#002E98", "#1113B1", "#3A00A4", "#5C007E", "#6E0040", "#6C0700", "#561D00",
    "#333500", "#0B4800", "#005200", "#004F08", "#00404D", "#000000", "#000000", "#000000",
    "#ABABAB", "#0D57FF", "#3536FF", "#6B1CFF", "#980BD5", "#AF0D7B", "#AD2521", "#904400",
    "#646200", "#317800", "#088200", "#007F2A", "#006E82", "#000000", "#000000", "#000000",
    "#FFFFFF", "#53AEFF", "#798DFF", "#B474FF", "#E46FFF", "#F86CCF", "#F87F77", "#DD9C35",
    "#B1B50C", "#7FCA1C", "#56D445", "#40D07D", "#41C1CF", "#4E4E4E", "#000000", "#000000",
    "#FFFFFF", "#B6DBFF", "#C5CBFF", "#DAC2FF", "#F0C0FF", "#FABFEB", "#FAC7C3", "#EFD4A5",
    "#DFDE96", "#CAE79B", "#B7EBAF", "#AEEAC9", "#AFE3EA", "#B5B5B5", "#000000", "#000000",
]


def chr_to_tile_data(chr_bytes):
    """Convert CHR binary data to a list of tile pixel arrays.

    Each tile is an 8x8 array of values 0-3.
    """
    tiles = []
    num_tiles = len(chr_bytes) // 16
    for i in range(num_tiles):
        offset = i * 16
        tile = []
        for y in range(8):
            row = []
            b0 = chr_bytes[offset + y]
            b1 = chr_bytes[offset + y + 8]
            for x in range(8):
                bit = 7 - x
                p0 = (b0 >> bit) & 1
                p1 = (b1 >> bit) & 1
                row.append((p1 << 1) | p0)
            tile.append(row)
        tiles.append(tile)
    return tiles


def generate_viewer_html(chr_files, output_path):
    """Generate an HTML tile viewer for one or more CHR files."""

    # Load all CHR data
    chr_datasets = []
    for fpath in chr_files:
        name = os.path.basename(fpath).replace('.chr', '')
        with open(fpath, 'rb') as f:
            data = f.read()
        tiles = chr_to_tile_data(data)
        chr_datasets.append({
            "name": name,
            "num_tiles": len(tiles),
            "tiles": tiles,
        })

    # Serialize tile data as JSON
    datasets_json = json.dumps(chr_datasets)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>NES CHR Tile Viewer - Zelda 2B</title>
<style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{ font-family: 'Courier New', monospace; background: #1a1a2e; color: #eee; padding: 20px; }}
h1 {{ color: #e94560; margin-bottom: 10px; }}
h2 {{ color: #53aeff; margin: 15px 0 8px 0; font-size: 16px; }}

.controls {{
    background: #16213e; padding: 15px; border-radius: 8px; margin-bottom: 20px;
    display: flex; flex-wrap: wrap; gap: 15px; align-items: flex-start;
}}
.control-group {{ display: flex; flex-direction: column; gap: 5px; }}
.control-group label {{ font-size: 12px; color: #888; text-transform: uppercase; }}
.control-group select, .control-group input {{
    background: #0f3460; color: #eee; border: 1px solid #53aeff; padding: 5px 8px;
    border-radius: 4px; font-family: inherit; font-size: 13px;
}}

.palette-preview {{
    display: flex; gap: 4px; align-items: center; margin-top: 5px;
}}
.palette-swatch {{
    width: 24px; height: 24px; border: 1px solid #555; border-radius: 3px;
    cursor: pointer; position: relative;
}}
.palette-swatch:hover {{ border-color: #fff; }}
.palette-swatch .idx {{ font-size: 8px; position: absolute; bottom: 0; right: 1px; color: rgba(255,255,255,0.5); }}

.nes-color-picker {{
    display: none; position: absolute; z-index: 100; background: #16213e;
    border: 2px solid #53aeff; border-radius: 8px; padding: 10px; box-shadow: 0 4px 20px rgba(0,0,0,0.5);
}}
.nes-color-picker.active {{ display: block; }}
.nes-color-grid {{ display: grid; grid-template-columns: repeat(16, 20px); gap: 2px; }}
.nes-color-cell {{
    width: 20px; height: 20px; border: 1px solid #333; cursor: pointer; border-radius: 2px;
    font-size: 7px; display: flex; align-items: flex-end; justify-content: center; color: rgba(255,255,255,0.4);
}}
.nes-color-cell:hover {{ border-color: #fff; transform: scale(1.3); z-index: 1; }}

.tileset-container {{ margin-bottom: 25px; }}
.tile-grid-wrap {{ background: #000; padding: 2px; display: inline-block; border-radius: 4px; }}

canvas {{ image-rendering: pixelated; cursor: crosshair; }}

.tile-info {{
    background: #16213e; padding: 10px; border-radius: 8px; margin-top: 10px;
    display: flex; gap: 20px; align-items: flex-start; min-height: 80px;
}}
.tile-zoom {{ image-rendering: pixelated; border: 1px solid #53aeff; }}
.tile-details {{ font-size: 12px; line-height: 1.6; }}
.tile-details .label {{ color: #888; }}

.tab-bar {{ display: flex; gap: 5px; margin-bottom: 15px; }}
.tab-btn {{
    background: #16213e; color: #888; border: 1px solid #333; padding: 8px 16px;
    border-radius: 4px 4px 0 0; cursor: pointer; font-family: inherit; font-size: 13px;
}}
.tab-btn.active {{ background: #0f3460; color: #53aeff; border-color: #53aeff; border-bottom-color: #0f3460; }}
.tab-btn:hover {{ color: #eee; }}
</style>
</head>
<body>

<h1>NES CHR Tile Viewer</h1>
<p style="color:#888; margin-bottom:15px;">Zelda 2B Graphics Pipeline &mdash; Click tiles to inspect. Click palette swatches to change colors.</p>

<div class="controls">
    <div class="control-group">
        <label>Scale</label>
        <select id="scale">
            <option value="2">2x</option>
            <option value="3" selected>3x</option>
            <option value="4">4x</option>
            <option value="6">6x</option>
        </select>
    </div>
    <div class="control-group">
        <label>Columns</label>
        <select id="columns">
            <option value="16" selected>16 (standard)</option>
            <option value="32">32</option>
            <option value="8">8</option>
        </select>
    </div>
    <div class="control-group">
        <label>Grid</label>
        <select id="grid">
            <option value="1" selected>On</option>
            <option value="0">Off</option>
        </select>
    </div>
    <div class="control-group">
        <label>Palette</label>
        <div class="palette-preview" id="palette-preview"></div>
    </div>
    <div class="control-group">
        <label>Preset</label>
        <select id="preset">
            <option value="overworld">Overworld (green)</option>
            <option value="water">Water (blue)</option>
            <option value="dungeon">Dungeon (brown)</option>
            <option value="ui">UI (gray/white)</option>
            <option value="link">Link (sprite)</option>
            <option value="enemies">Enemies (red)</option>
            <option value="grayscale">Grayscale</option>
        </select>
    </div>
</div>

<div id="color-picker" class="nes-color-picker"></div>

<div class="tab-bar" id="tab-bar"></div>

<div id="viewer-area"></div>

<div class="tile-info" id="tile-info">
    <canvas id="tile-zoom" class="tile-zoom" width="64" height="64"></canvas>
    <div class="tile-details" id="tile-details">
        Click a tile to inspect it.
    </div>
</div>

<script>
const NES_PALETTE = {json.dumps(NES_PALETTE_HEX)};
const DATASETS = {datasets_json};

const PRESETS = {{
    overworld:  [0x0F, 0x09, 0x19, 0x29],
    water:      [0x0F, 0x01, 0x11, 0x21],
    dungeon:    [0x0F, 0x07, 0x17, 0x27],
    ui:         [0x0F, 0x00, 0x10, 0x30],
    link:       [0x0F, 0x19, 0x29, 0x38],
    enemies:    [0x0F, 0x06, 0x16, 0x27],
    grayscale:  [0x0F, 0x00, 0x10, 0x30],
}};

let currentPalette = [0x0F, 0x09, 0x19, 0x29];
let currentDataset = 0;
let editingSwatchIdx = -1;

function getColor(palIdx) {{
    return NES_PALETTE[currentPalette[palIdx]] || '#000000';
}}

function renderPalettePreview() {{
    const container = document.getElementById('palette-preview');
    container.innerHTML = '';
    for (let i = 0; i < 4; i++) {{
        const sw = document.createElement('div');
        sw.className = 'palette-swatch';
        sw.style.backgroundColor = getColor(i);
        sw.title = `Color ${{i}}: NES $${{currentPalette[i].toString(16).padStart(2,'0').toUpperCase()}}`;
        sw.innerHTML = `<span class="idx">${{i}}</span>`;
        sw.onclick = (e) => openColorPicker(i, e);
        container.appendChild(sw);
    }}
}}

function openColorPicker(swatchIdx, event) {{
    editingSwatchIdx = swatchIdx;
    const picker = document.getElementById('color-picker');
    picker.innerHTML = '<div class="nes-color-grid" id="nes-grid"></div>';
    const grid = document.getElementById('nes-grid');
    for (let i = 0; i < 64; i++) {{
        const cell = document.createElement('div');
        cell.className = 'nes-color-cell';
        cell.style.backgroundColor = NES_PALETTE[i];
        cell.title = `$${{i.toString(16).padStart(2,'0').toUpperCase()}}`;
        cell.textContent = i.toString(16).padStart(2,'0').toUpperCase();
        if (i === currentPalette[swatchIdx]) cell.style.border = '2px solid #fff';
        cell.onclick = () => {{
            currentPalette[swatchIdx] = i;
            picker.classList.remove('active');
            renderPalettePreview();
            renderCurrentDataset();
        }};
        grid.appendChild(cell);
    }}
    picker.style.left = event.pageX + 'px';
    picker.style.top = (event.pageY + 30) + 'px';
    picker.classList.add('active');
}}

document.addEventListener('click', (e) => {{
    const picker = document.getElementById('color-picker');
    if (!picker.contains(e.target) && !e.target.classList.contains('palette-swatch')) {{
        picker.classList.remove('active');
    }}
}});

function renderCurrentDataset() {{
    const ds = DATASETS[currentDataset];
    const scale = parseInt(document.getElementById('scale').value);
    const cols = parseInt(document.getElementById('columns').value);
    const showGrid = document.getElementById('grid').value === '1';

    const area = document.getElementById('viewer-area');
    area.innerHTML = '';

    const numTiles = ds.tiles.length;
    const rows = Math.ceil(numTiles / cols);
    const gap = showGrid ? 1 : 0;
    const cw = cols * (8 + gap) + gap;
    const ch = rows * (8 + gap) + gap;

    const wrap = document.createElement('div');
    wrap.className = 'tile-grid-wrap';

    const canvas = document.createElement('canvas');
    canvas.width = cw;
    canvas.height = ch;
    canvas.style.width = (cw * scale) + 'px';
    canvas.style.height = (ch * scale) + 'px';

    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#111';
    ctx.fillRect(0, 0, cw, ch);

    const colors = [getColor(0), getColor(1), getColor(2), getColor(3)];

    for (let t = 0; t < numTiles; t++) {{
        const tx = t % cols;
        const ty = Math.floor(t / cols);
        const ox = tx * (8 + gap) + gap;
        const oy = ty * (8 + gap) + gap;
        const tile = ds.tiles[t];

        for (let y = 0; y < 8; y++) {{
            for (let x = 0; x < 8; x++) {{
                ctx.fillStyle = colors[tile[y][x]];
                ctx.fillRect(ox + x, oy + y, 1, 1);
            }}
        }}
    }}

    canvas.onclick = (e) => {{
        const rect = canvas.getBoundingClientRect();
        const mx = Math.floor((e.clientX - rect.left) / scale);
        const my = Math.floor((e.clientY - rect.top) / scale);
        const tx = Math.floor(mx / (8 + gap));
        const ty = Math.floor(my / (8 + gap));
        const tileIdx = ty * cols + tx;
        if (tileIdx < numTiles) showTileInfo(tileIdx, ds.tiles[tileIdx]);
    }};

    wrap.appendChild(canvas);
    area.appendChild(wrap);

    const info = document.createElement('p');
    info.style.cssText = 'color:#888; font-size:12px; margin-top:8px;';
    info.textContent = `${{ds.name}}: ${{numTiles}} tiles (${{numTiles * 16}} bytes, ${{rows}} rows x ${{cols}} cols)`;
    area.appendChild(info);
}}

function showTileInfo(idx, tile) {{
    const zoomCanvas = document.getElementById('tile-zoom');
    const ctx = zoomCanvas.getContext('2d');
    const s = 8; // zoom scale
    zoomCanvas.width = 8 * s;
    zoomCanvas.height = 8 * s;
    const colors = [getColor(0), getColor(1), getColor(2), getColor(3)];

    for (let y = 0; y < 8; y++) {{
        for (let x = 0; x < 8; x++) {{
            ctx.fillStyle = colors[tile[y][x]];
            ctx.fillRect(x * s, y * s, s, s);
        }}
    }}

    // Count color usage
    const counts = [0, 0, 0, 0];
    for (let y = 0; y < 8; y++)
        for (let x = 0; x < 8; x++)
            counts[tile[y][x]]++;

    const hexIdx = idx.toString(16).padStart(2, '0').toUpperCase();
    const details = document.getElementById('tile-details');
    details.innerHTML = `
        <div><span class="label">Tile Index:</span> #${{idx}} ($${{hexIdx}})</div>
        <div><span class="label">Color usage:</span>
            c0: ${{counts[0]}}px, c1: ${{counts[1]}}px, c2: ${{counts[2]}}px, c3: ${{counts[3]}}px
        </div>
        <div><span class="label">Palette:</span>
            $${{currentPalette.map(c => c.toString(16).padStart(2,'0').toUpperCase()).join(', $')}}</div>
        <div style="margin-top:5px; font-size:11px; color:#666;">
            ${{tile.map((row, y) => row.map(v => v.toString()).join('')).join('<br>')}}</div>
    `;
}}

function buildTabs() {{
    const bar = document.getElementById('tab-bar');
    bar.innerHTML = '';
    DATASETS.forEach((ds, i) => {{
        const btn = document.createElement('button');
        btn.className = 'tab-btn' + (i === currentDataset ? ' active' : '');
        btn.textContent = `${{ds.name}} (${{ds.num_tiles}} tiles)`;
        btn.onclick = () => {{ currentDataset = i; buildTabs(); renderCurrentDataset(); }};
        bar.appendChild(btn);
    }});
}}

// Event listeners
document.getElementById('scale').onchange = renderCurrentDataset;
document.getElementById('columns').onchange = renderCurrentDataset;
document.getElementById('grid').onchange = renderCurrentDataset;
document.getElementById('preset').onchange = (e) => {{
    currentPalette = [...PRESETS[e.target.value]];
    renderPalettePreview();
    renderCurrentDataset();
}};

// Initialize
renderPalettePreview();
buildTabs();
renderCurrentDataset();
</script>
</body>
</html>
"""
    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    with open(output_path, 'w') as f:
        f.write(html)
    print(f"Generated tile viewer: {output_path}")
    print(f"  Datasets: {', '.join(d['name'] for d in chr_datasets)}")


def main():
    parser = argparse.ArgumentParser(description="Generate HTML tile viewer from CHR files.")
    parser.add_argument("input", nargs="+", help="Input .chr files")
    parser.add_argument("--output", "-o", required=True, help="Output .html file")
    args = parser.parse_args()

    for f in args.input:
        if not os.path.exists(f):
            print(f"ERROR: File not found: {f}", file=sys.stderr)
            sys.exit(1)

    generate_viewer_html(args.input, args.output)


if __name__ == "__main__":
    main()
