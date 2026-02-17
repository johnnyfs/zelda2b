#!/usr/bin/env python3
"""
generate_combined_preview.py - Generate a combined HTML preview of all tiles.

Reads bg_tiles.chr, sprite_tiles.chr, and font.chr and renders them
into a single interactive HTML preview page.
"""

import json
import os
import struct
import sys


def chr_to_pixels(chr_data, tile_index):
    """Decode a single 8x8 tile from CHR binary data at given tile index."""
    offset = tile_index * 16
    if offset + 16 > len(chr_data):
        return [[0]*8 for _ in range(8)]

    pixels = []
    for row in range(8):
        lo_byte = chr_data[offset + row]
        hi_byte = chr_data[offset + 8 + row]
        row_pixels = []
        for bit in range(7, -1, -1):
            lo_bit = (lo_byte >> bit) & 1
            hi_bit = (hi_byte >> bit) & 1
            row_pixels.append((hi_bit << 1) | lo_bit)
        pixels.append(row_pixels)
    return pixels


def tile_to_flat(pixels):
    """Flatten 8x8 tile to 64-element list."""
    flat = []
    for row in pixels:
        flat.extend(row)
    return flat


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.join(script_dir, "..")
    chr_dir = os.path.join(project_dir, "assets", "chr")

    # Read CHR files
    bg_path = os.path.join(chr_dir, "bg_tiles.chr")
    sprite_path = os.path.join(chr_dir, "sprite_tiles.chr")
    font_path = os.path.join(chr_dir, "font.chr")
    hud_path = os.path.join(chr_dir, "hud_widgets.chr")

    with open(bg_path, 'rb') as f:
        bg_data = f.read()
    with open(sprite_path, 'rb') as f:
        sprite_data = f.read()

    font_data = None
    if os.path.exists(font_path):
        with open(font_path, 'rb') as f:
            font_data = f.read()

    hud_data = None
    if os.path.exists(hud_path):
        with open(hud_path, 'rb') as f:
            hud_data = f.read()

    # Decode BG tiles
    bg_tiles = {}
    bg_labels = {
        0x00: "Empty", 0x01: "Grass A", 0x02: "Grass B", 0x03: "Grass C",
        0x04: "Tree TL", 0x05: "Tree TR", 0x06: "Tree BL", 0x07: "Tree BR",
        0x08: "Water TL", 0x09: "Water TR", 0x0A: "Water BL", 0x0B: "Water BR",
        0x0C: "Path A", 0x0D: "Path B",
        0x0E: "Rock TL", 0x0F: "Rock TR", 0x10: "Rock BL", 0x11: "Rock BR",
        0x12: "Floor TL", 0x13: "Floor TR", 0x14: "Floor BL", 0x15: "Floor BR",
        0x16: "Door TL", 0x17: "Door TR", 0x18: "Door BL", 0x19: "Door BR",
        0x1A: "Sand A", 0x1B: "Sand B",
        0x1C: "Bush TL", 0x1D: "Bush TR", 0x1E: "Bush BL", 0x1F: "Bush BR",
        0x20: "Heart F", 0x21: "Heart E", 0x22: "Magic F", 0x23: "Magic E",
        0x24: "Box TL", 0x25: "Box TR", 0x26: "Box BL", 0x27: "Box BR",
        0x28: "Btn A", 0x29: "Btn B",
        0x2A: "Bridge TL", 0x2B: "Bridge TR", 0x2C: "Bridge BL", 0x2D: "Bridge BR",
        0x2E: "StoneW TL", 0x2F: "StoneW TR", 0x30: "StoneW BL", 0x31: "StoneW BR",
        0x32: "Border TL", 0x33: "Border TR", 0x34: "Border BL", 0x35: "Border BR",
    }
    for i in range(0x36):
        pixels = chr_to_pixels(bg_data, i)
        bg_tiles[i] = tile_to_flat(pixels)

    # Decode sprite tiles
    sprite_tiles = {}
    sprite_labels = {
        0x21: "Octo TL", 0x22: "Octo TR", 0x23: "Octo BL",
        0x24: "Heart TL", 0x25: "Heart TR",
        0x26: "Rupee TL", 0x27: "Rupee TR",
        0x28: "Bomb TL", 0x29: "Bomb TR",
        0x2A: "Key TL", 0x2B: "Key TR",
        0x2D: "Sword V", 0x2E: "Sword H",
        0x30: "OctD TL", 0x31: "OctD TR", 0x32: "OctD BL", 0x33: "OctD BR",
        0x34: "OctU TL", 0x35: "OctU TR", 0x36: "OctU BL", 0x37: "OctU BR",
        0x38: "OctR TL", 0x39: "OctR TR", 0x3A: "OctR BL", 0x3B: "OctR BR",
        0x3C: "OctL TL", 0x3D: "OctL TR", 0x3E: "OctL BL", 0x3F: "OctL BR",
        0x40: "NPC F TL", 0x41: "NPC F TR", 0x42: "NPC F BL", 0x43: "NPC F BR",
        0x44: "NPC S TL", 0x45: "NPC S TR", 0x46: "NPC S BL", 0x47: "NPC S BR",
    }
    # Also include Link sprites $00-$1F
    for i in range(0x20):
        pixels = chr_to_pixels(sprite_data, i)
        flat = tile_to_flat(pixels)
        if any(v != 0 for v in flat):
            sprite_tiles[i] = flat
    # Then the specific tiles we defined
    for idx in list(sprite_labels.keys()):
        pixels = chr_to_pixels(sprite_data, idx)
        sprite_tiles[idx] = tile_to_flat(pixels)

    # Font tiles
    font_tile_data = {}
    if font_data:
        font_chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?.,-:'\"`()/♥◆>< ^v"
        for i in range(min(56, len(font_data) // 16)):
            pixels = chr_to_pixels(font_data, i)
            flat = tile_to_flat(pixels)
            if any(v != 0 for v in flat):
                font_tile_data[i] = flat

    # Metatile compositions for assembled view
    bg_metatiles = [
        ("Grass", [0x01, 0x02, 0x03, 0x01], "2x2"),
        ("Tree", [0x04, 0x05, 0x06, 0x07], "2x2"),
        ("Water", [0x08, 0x09, 0x0A, 0x0B], "2x2"),
        ("Rock", [0x0E, 0x0F, 0x10, 0x11], "2x2"),
        ("Bush", [0x1C, 0x1D, 0x1E, 0x1F], "2x2"),
        ("Door", [0x16, 0x17, 0x18, 0x19], "2x2"),
        ("Stone Floor", [0x12, 0x13, 0x14, 0x15], "2x2"),
        ("Bridge", [0x2A, 0x2B, 0x2C, 0x2D], "2x2"),
        ("Stone Wall", [0x2E, 0x2F, 0x30, 0x31], "2x2"),
        ("Border", [0x32, 0x33, 0x34, 0x35], "2x2"),
    ]

    sprite_metatiles = [
        ("Octorok Down", [0x30, 0x31, 0x32, 0x33], "2x2"),
        ("Octorok Up", [0x34, 0x35, 0x36, 0x37], "2x2"),
        ("Octorok Right", [0x38, 0x39, 0x3A, 0x3B], "2x2"),
        ("Octorok Left", [0x3C, 0x3D, 0x3E, 0x3F], "2x2"),
        ("NPC Front", [0x40, 0x41, 0x42, 0x43], "2x2"),
        ("NPC Side", [0x44, 0x45, 0x46, 0x47], "2x2"),
        ("Heart", [0x24, 0x25], "1x2"),
        ("Rupee", [0x26, 0x27], "1x2"),
        ("Bomb", [0x28, 0x29], "1x2"),
        ("Key", [0x2A, 0x2B], "1x2"),
    ]

    hud_metatiles = [
        ("HUD Heart F", [0x20], "1x1"),
        ("HUD Heart E", [0x21], "1x1"),
        ("HUD Magic F", [0x22], "1x1"),
        ("HUD Magic E", [0x23], "1x1"),
        ("Item Box", [0x24, 0x25, 0x26, 0x27], "2x2"),
        ("Btn A", [0x28], "1x1"),
        ("Btn B", [0x29], "1x1"),
    ]

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Zelda 2B - Complete Tile Preview</title>
<style>
* {{ margin:0; padding:0; box-sizing:border-box; }}
body {{ background:#0a0a1a; color:#e0e0e0; font-family:'Courier New',monospace; padding:16px; max-width:960px; margin:0 auto; }}
h1 {{ color:#ffd700; text-align:center; font-size:22px; margin-bottom:6px; }}
.subtitle {{ text-align:center; color:#888; font-size:11px; margin-bottom:12px; }}
h2 {{ color:#87ceeb; margin:16px 0 6px; font-size:16px; border-bottom:1px solid #333; padding-bottom:3px; }}
h3 {{ color:#aaa; margin:10px 0 5px; font-size:12px; }}
.pal {{ text-align:center; margin:10px 0; padding:8px; background:#0d0d1a; border-radius:6px; }}
.pal label {{ margin:0 6px; cursor:pointer; padding:3px 8px; border:1px solid #444; border-radius:3px; font-size:11px; display:inline-block; margin-bottom:3px; }}
.pal label:hover {{ border-color:#ffd700; }}
.mg {{ display:flex; flex-wrap:wrap; gap:14px; margin:8px 0; }}
.mi {{ text-align:center; }}
.mi canvas {{ border:1px solid #444; image-rendering:pixelated; display:block; margin:0 auto 3px; background:#000; }}
.mi .l {{ font-size:10px; color:#aaa; }}
.tg {{ display:flex; flex-wrap:wrap; gap:4px; margin:6px 0; }}
.ti {{ text-align:center; }}
.ti canvas {{ border:1px solid #222; image-rendering:pixelated; display:block; margin:0 auto 1px; }}
.ti .l {{ font-size:8px; color:#555; max-width:50px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }}
.sample {{ margin:6px 0; padding:6px 10px; background:#0d0d1a; border-radius:4px; }}
.sample canvas {{ image-rendering:pixelated; display:block; margin:3px 0; }}
.sample .sl {{ font-size:10px; color:#555; margin-bottom:2px; }}
.info {{ font-size:10px; color:#555; text-align:center; margin-top:14px; padding-top:6px; border-top:1px solid #222; }}
</style>
</head>
<body>
<h1>Zelda 2B - Complete Tile Preview</h1>
<p class="subtitle">BG tiles (bg_tiles.chr) + Sprite tiles (sprite_tiles.chr) + Font (font.chr)</p>

<div class="pal" id="pal-bg">
    <strong>BG Palette:</strong>
    <label><input type="radio" name="bgpal" value="green" checked> OW Green</label>
    <label><input type="radio" name="bgpal" value="blue"> Water Blue</label>
    <label><input type="radio" name="bgpal" value="brown"> Dungeon</label>
    <label><input type="radio" name="bgpal" value="white"> White</label>
</div>
<div class="pal" id="pal-sp">
    <strong>Sprite Palette:</strong>
    <label><input type="radio" name="sppal" value="enemy" checked> Enemy Red</label>
    <label><input type="radio" name="sppal" value="link"> Link Green</label>
    <label><input type="radio" name="sppal" value="item"> Item Blue</label>
    <label><input type="radio" name="sppal" value="npc"> NPC Brown</label>
</div>

<h2>BG Metatiles (16x16 assembled)</h2>
<div class="mg" id="bg-meta"></div>

<h2>Sprite Metatiles (16x16 assembled)</h2>
<div class="mg" id="sp-meta"></div>

<h2>HUD Widgets (BG $20-$29)</h2>
<div class="mg" id="hud-meta"></div>

<h2>BG Tiles (individual 8x8)</h2>
<h3>Terrain $00-$1F</h3>
<div class="tg" id="bg-terrain"></div>
<h3>Post-HUD $2A-$35</h3>
<div class="tg" id="bg-extra"></div>

<h2>Sprite Tiles (individual 8x8)</h2>
<h3>Items $24-$2B</h3>
<div class="tg" id="sp-items"></div>
<h3>Octorok $30-$3F</h3>
<div class="tg" id="sp-octorok"></div>
<h3>NPC $40-$47</h3>
<div class="tg" id="sp-npc"></div>
<h3>Weapons $2D-$2E</h3>
<div class="tg" id="sp-weapons"></div>

<h2>Font Sample</h2>
<div id="font-sample"></div>
<h3>Font Tiles</h3>
<div class="tg" id="font-grid"></div>

<div class="info">
generate_combined_preview.py | NES 2bpp CHR format<br>
BG: 44 terrain + 10 HUD tiles | Sprites: Link + Octorok + Items + NPC | Font: A-Z, 0-9, punctuation
</div>

<script>
const bgTiles = {json.dumps({str(k): v for k, v in bg_tiles.items()})};
const bgLabels = {json.dumps({str(k): v for k, v in bg_labels.items()})};
const spTiles = {json.dumps({str(k): v for k, v in sprite_tiles.items()})};
const spLabels = {json.dumps({str(k): v for k, v in sprite_labels.items()})};
const fontTiles = {json.dumps({str(k): v for k, v in font_tile_data.items()})};
const bgMeta = {json.dumps(bg_metatiles)};
const spMeta = {json.dumps(sprite_metatiles)};
const hudMeta = {json.dumps(hud_metatiles)};

const pals = {{
    green: ['#0F0F0F','#003800','#00A800','#44D800'],
    blue:  ['#0F0F0F','#000088','#0058D8','#6888FC'],
    brown: ['#0F0F0F','#5C3800','#AC7C00','#FCB838'],
    white: ['#0F0F0F','#545454','#A8A8A8','#FCFCFC'],
    enemy: ['#0F0F0F','#880000','#D80000','#FCFCFC'],
    link:  ['#0F0F0F','#004400','#00A800','#FCFCFC'],
    item:  ['#0F0F0F','#0000A8','#3838D8','#FCFCFC'],
    npc:   ['#0F0F0F','#5C3800','#AC7C00','#FCFCFC'],
}};
let bgPal='green', spPal='enemy';

function dt(ctx,data,ox,oy,sc,pal,transp) {{
    if(!data) return;
    const c=pals[pal];
    for(let y=0;y<8;y++) for(let x=0;x<8;x++) {{
        const v=data[y*8+x];
        if(v===0 && transp) {{
            ctx.fillStyle=((ox/8+oy/8+x+y)%2===0)?'#0a0a1a':'#151530';
        }} else ctx.fillStyle=c[v];
        ctx.fillRect((ox+x)*sc,(oy+y)*sc,sc,sc);
    }}
}}

function renderMeta(containerId, defs, tileSource, pal, transp) {{
    const g=document.getElementById(containerId);
    g.innerHTML='';
    const sc=4;
    for(const [name,ids,type] of defs) {{
        const it=document.createElement('div');
        it.className='mi';
        const cv=document.createElement('canvas');
        if(type==='2x2') {{
            cv.width=16*sc; cv.height=16*sc;
            const ctx=cv.getContext('2d');
            dt(ctx,tileSource[String(ids[0])],0,0,sc,pal,transp);
            dt(ctx,tileSource[String(ids[1])],8,0,sc,pal,transp);
            dt(ctx,tileSource[String(ids[2])],0,8,sc,pal,transp);
            dt(ctx,tileSource[String(ids[3])],8,8,sc,pal,transp);
        }} else if(type==='1x2') {{
            cv.width=16*sc; cv.height=8*sc;
            const ctx=cv.getContext('2d');
            dt(ctx,tileSource[String(ids[0])],0,0,sc,pal,transp);
            dt(ctx,tileSource[String(ids[1])],8,0,sc,pal,transp);
        }} else {{
            cv.width=8*sc; cv.height=8*sc;
            const ctx=cv.getContext('2d');
            dt(ctx,tileSource[String(ids[0])],0,0,sc,pal,transp);
        }}
        const lb=document.createElement('div');
        lb.className='l'; lb.textContent=name;
        it.appendChild(cv); it.appendChild(lb);
        g.appendChild(it);
    }}
}}

function renderTileGrid(containerId, tileSource, labelSource, indices, pal, transp) {{
    const g=document.getElementById(containerId);
    g.innerHTML='';
    for(const idx of indices) {{
        const data=tileSource[String(idx)];
        if(!data) continue;
        const it=document.createElement('div');
        it.className='ti';
        const cv=document.createElement('canvas');
        cv.width=40; cv.height=40;
        const ctx=cv.getContext('2d');
        dt(ctx,data,0,0,5,pal,transp);
        const lb=document.createElement('div');
        lb.className='l';
        lb.textContent=(labelSource[String(idx)]||'')+'$'+idx.toString(16).toUpperCase().padStart(2,'0');
        it.appendChild(cv); it.appendChild(lb);
        g.appendChild(it);
    }}
}}

function renderFont() {{
    const cont=document.getElementById('font-sample');
    cont.innerHTML='';
    const texts=["THE LEGEND OF ZELDA","LINK HAS 3 HEARTS","BUY FOR 50 RUPEES?","ABCDEFGHIJKLM","NOPQRSTUVWXYZ"];
    const charMap={{' ':0}};
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').forEach((c,i)=>charMap[c]=i+1);
    '0123456789'.split('').forEach((c,i)=>charMap[c]=27+i);
    Object.assign(charMap,{{'!':37,'?':38,'.':39,',':40,'-':41,':':42,"'":43,'"':44,'(':45,')':46,'/':47}});
    const sc=3;
    for(const text of texts) {{
        const d=document.createElement('div');
        d.className='sample';
        const sl=document.createElement('div');
        sl.className='sl'; sl.textContent=text;
        d.appendChild(sl);
        const cv=document.createElement('canvas');
        cv.width=text.length*8*sc; cv.height=8*sc;
        cv.style.imageRendering='pixelated';
        const ctx=cv.getContext('2d');
        const c=pals.white;
        for(let ci=0;ci<text.length;ci++) {{
            const ch=text[ci].toUpperCase();
            let ti=charMap[ch]; if(ti===undefined) ti=0;
            const td=fontTiles[String(ti)];
            if(!td) continue;
            for(let y=0;y<8;y++) for(let x=0;x<8;x++) {{
                ctx.fillStyle=c[td[y*8+x]];
                ctx.fillRect((ci*8+x)*sc,y*sc,sc,sc);
            }}
        }}
        d.appendChild(cv);
        cont.appendChild(d);
    }}
    // Font grid
    const fg=document.getElementById('font-grid');
    fg.innerHTML='';
    const fontLabels=' ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?.,-:\\'\"()/'.split('');
    for(const [idxStr,data] of Object.entries(fontTiles)) {{
        const idx=parseInt(idxStr);
        const it=document.createElement('div');
        it.className='ti';
        const cv=document.createElement('canvas');
        cv.width=32; cv.height=32;
        const ctx=cv.getContext('2d');
        dt(ctx,data,0,0,4,'white',false);
        const lb=document.createElement('div');
        lb.className='l';
        lb.textContent=fontLabels[idx]||('$'+idx.toString(16).toUpperCase().padStart(2,'0'));
        it.appendChild(cv); it.appendChild(lb);
        fg.appendChild(it);
    }}
}}

function renderAll() {{
    renderMeta('bg-meta', bgMeta, bgTiles, bgPal, false);
    renderMeta('sp-meta', spMeta, spTiles, spPal, true);
    renderMeta('hud-meta', hudMeta, bgTiles, 'white', false);
    const bgRange=[]; for(let i=0;i<0x20;i++) bgRange.push(i);
    renderTileGrid('bg-terrain', bgTiles, bgLabels, bgRange, bgPal, false);
    const bgExtra=[]; for(let i=0x2A;i<=0x35;i++) bgExtra.push(i);
    renderTileGrid('bg-extra', bgTiles, bgLabels, bgExtra, bgPal, false);
    renderTileGrid('sp-items', spTiles, spLabels, [0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B], spPal, true);
    const octRange=[]; for(let i=0x30;i<=0x3F;i++) octRange.push(i);
    renderTileGrid('sp-octorok', spTiles, spLabels, octRange, 'enemy', true);
    renderTileGrid('sp-npc', spTiles, spLabels, [0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47], 'npc', true);
    renderTileGrid('sp-weapons', spTiles, spLabels, [0x2D,0x2E], spPal, true);
    renderFont();
}}

document.querySelectorAll('input[name="bgpal"]').forEach(r=>{{
    r.addEventListener('change',function(){{ bgPal=this.value; renderAll(); }});
}});
document.querySelectorAll('input[name="sppal"]').forEach(r=>{{
    r.addEventListener('change',function(){{ spPal=this.value; renderAll(); }});
}});
renderAll();
</script>
</body>
</html>"""

    output_path = os.path.join(project_dir, "combined_preview.html")
    with open(output_path, 'w') as f:
        f.write(html)
    print(f"Combined preview -> {output_path}")

    # Also copy to agent workspace for operator_prompt
    agent_workspace = os.environ.get('AGENT_WORKSPACE',
        '/var/folders/fw/0jyyy8c50yzck5p0y1k600_w0000gp/T/agent-hub-60613148-KR3BVW')
    import shutil
    dest = os.path.join(agent_workspace, 'combined_preview.html')
    shutil.copy2(output_path, dest)
    print(f"Copied to agent workspace -> {dest}")


if __name__ == "__main__":
    main()
