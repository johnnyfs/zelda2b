#!/usr/bin/env python3
"""
build_ripped_mockup.py - Extract sprites from Link's Awakening reference sheets
and generate a comprehensive HTML mockup for operator approval.

This extracts real game sprites from the downloaded sprite sheets, converts
them to NES 4-shade format, and renders them in a game-like mockup.
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

from PIL import Image
from rip_sprites import map_to_4_shades, identify_bg_color

REF_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'reference')
BUILD_DIR = os.path.join(os.path.dirname(__file__), '..', 'build')

def load_ref(name):
    path = os.path.join(REF_DIR, name)
    img = Image.open(path).convert('RGBA')
    bg = identify_bg_color(img)
    return img, bg

def extract(img, bg, x, y, w, h):
    return map_to_4_shades(img, (x, y, w, h), bg)

def main():
    os.makedirs(BUILD_DIR, exist_ok=True)

    # Load reference images
    link_img, link_bg = load_ref('link_sprites.png')
    ow_img, ow_bg = load_ref('overworld_tileset.png')
    enemy_img, enemy_bg = load_ref('minor_enemies.png')
    items_img, items_bg = load_ref('weapons_items_hud.png')

    # =====================================================================
    # EXTRACT SPRITES
    # =====================================================================

    sprites = {}

    # --- Link (16x16 each, from idle/walk row at y=11) ---
    link_defs = [
        ('link_idle_down', 1, 11),
        ('link_walk_down', 18, 11),
        ('link_idle_up', 35, 11),
        ('link_walk_up', 52, 11),
        ('link_idle_right', 73, 11),
        ('link_walk_right_1', 90, 11),
        ('link_walk_right_2', 107, 11),
        ('link_idle_left', 124, 11),
        ('link_walk_left_1', 141, 11),
        ('link_walk_left_2', 158, 11),
    ]
    for name, x, y in link_defs:
        sprites[name] = extract(link_img, link_bg, x, y, 16, 16)

    # --- Link Sword Attack (row starting ~y=59) ---
    sword_defs = [
        ('link_sword_down', 1, 59),
        ('link_sword_up', 35, 59),
        ('link_sword_right', 73, 59),
        ('link_sword_left', 124, 59),
    ]
    for name, x, y in sword_defs:
        sprites[name] = extract(link_img, link_bg, x, y, 16, 16)

    # --- Overworld tiles (16x16 metatiles) ---
    # The overworld tileset is arranged as 16x16 blocks
    # Top area has various terrain metatiles
    ow_defs = [
        # Grass/ground area (top-left region)
        ('ow_grass_1', 0, 176, 16, 16),
        ('ow_grass_2', 16, 176, 16, 16),
        ('ow_grass_3', 32, 176, 16, 16),
        ('ow_path_1', 48, 176, 16, 16),
        # Trees
        ('ow_tree_1', 160, 128, 16, 16),
        ('ow_tree_2', 176, 128, 16, 16),
        ('ow_tree_3', 160, 144, 16, 16),
        ('ow_tree_4', 176, 144, 16, 16),
        # Water tiles
        ('ow_water_1', 272, 336, 16, 16),
        ('ow_water_2', 288, 336, 16, 16),
        ('ow_water_3', 272, 352, 16, 16),
        ('ow_water_4', 288, 352, 16, 16),
        # House/building tiles
        ('ow_house_1', 0, 0, 16, 16),
        ('ow_house_2', 16, 0, 16, 16),
        ('ow_house_3', 0, 16, 16, 16),
        ('ow_house_4', 16, 16, 16, 16),
        # Cliff/wall
        ('ow_cliff_1', 0, 128, 16, 16),
        ('ow_cliff_2', 16, 128, 16, 16),
        # Cave entrance area
        ('ow_cave_1', 192, 128, 16, 16),
        ('ow_cave_2', 208, 128, 16, 16),
        # Rock
        ('ow_rock', 128, 176, 16, 16),
        # Bush
        ('ow_bush', 144, 176, 16, 16),
        # Flowers
        ('ow_flowers', 96, 176, 16, 16),
        # Sand
        ('ow_sand', 336, 336, 16, 16),
    ]
    for entry in ow_defs:
        name = entry[0]
        x, y, w, h = entry[1], entry[2], entry[3], entry[4]
        sprites[name] = extract(ow_img, ow_bg, x, y, w, h)

    # --- Enemies (16x16 each) ---
    enemy_defs = [
        ('enemy_octorok', 1, 148, 16, 16),
        ('enemy_moblin', 1, 165, 16, 16),
        ('enemy_leever', 1, 100, 16, 16),
        ('enemy_crow', 1, 49, 16, 16),
        ('enemy_ghini', 161, 49, 16, 16),
        ('enemy_darknut', 45, 49, 16, 16),
        ('enemy_zol', 333, 871, 16, 16),
        ('enemy_keese', 280, 412, 16, 16),
        ('enemy_gel', 360, 871, 16, 16),
        ('enemy_armos', 1, 18, 16, 16),
        ('enemy_boulder', 185, 18, 16, 16),
    ]
    for name, x, y, w, h in enemy_defs:
        sprites[name] = extract(enemy_img, enemy_bg, x, y, w, h)

    # --- Items (8x8 or 16x16) ---
    # Hearts: full = solid red, empty = white outline, half = split
    # Per operator: "solid single color red/blue vs white, half = left-half color, right-half white"
    # Create these programmatically since they need specific NES-style rendering

    # Heart full (8x8) - solid fill color 2 with outline 1
    sprites['heart_full'] = [
        [0,1,1,0,1,1,0,0],
        [1,2,2,1,2,2,1,0],
        [1,2,2,2,2,2,1,0],
        [1,2,2,2,2,2,1,0],
        [0,1,2,2,2,1,0,0],
        [0,0,1,2,1,0,0,0],
        [0,0,0,1,0,0,0,0],
        [0,0,0,0,0,0,0,0],
    ]

    # Heart empty (8x8) - just outline
    sprites['heart_empty'] = [
        [0,1,1,0,1,1,0,0],
        [1,3,3,1,3,3,1,0],
        [1,3,3,3,3,3,1,0],
        [1,3,3,3,3,3,1,0],
        [0,1,3,3,3,1,0,0],
        [0,0,1,3,1,0,0,0],
        [0,0,0,1,0,0,0,0],
        [0,0,0,0,0,0,0,0],
    ]

    # Heart half (8x8) - left half filled, right half white
    sprites['heart_half'] = [
        [0,1,1,0,1,1,0,0],
        [1,2,2,1,3,3,1,0],
        [1,2,2,2,3,3,1,0],
        [1,2,2,3,3,3,1,0],
        [0,1,2,3,3,1,0,0],
        [0,0,1,3,1,0,0,0],
        [0,0,0,1,0,0,0,0],
        [0,0,0,0,0,0,0,0],
    ]

    # Magic bottle full (8x8) - solid blue fill
    sprites['magic_full'] = [
        [0,0,1,1,0,0,0,0],
        [0,1,3,3,1,0,0,0],
        [0,0,1,1,0,0,0,0],
        [0,1,2,2,1,0,0,0],
        [1,2,2,2,2,1,0,0],
        [1,2,2,2,2,1,0,0],
        [0,1,2,2,1,0,0,0],
        [0,0,1,1,0,0,0,0],
    ]

    # Magic bottle empty (8x8) - white/outline
    sprites['magic_empty'] = [
        [0,0,1,1,0,0,0,0],
        [0,1,3,3,1,0,0,0],
        [0,0,1,1,0,0,0,0],
        [0,1,3,3,1,0,0,0],
        [1,3,3,3,3,1,0,0],
        [1,3,3,3,3,1,0,0],
        [0,1,3,3,1,0,0,0],
        [0,0,1,1,0,0,0,0],
    ]

    # Magic bottle half (8x8) - left half blue, right half white
    sprites['magic_half'] = [
        [0,0,1,1,0,0,0,0],
        [0,1,3,3,1,0,0,0],
        [0,0,1,1,0,0,0,0],
        [0,1,2,3,1,0,0,0],
        [1,2,2,3,3,1,0,0],
        [1,2,2,3,3,1,0,0],
        [0,1,2,3,1,0,0,0],
        [0,0,1,1,0,0,0,0],
    ]

    # Rupee (8x8)
    sprites['rupee'] = [
        [0,0,0,1,0,0,0,0],
        [0,0,1,2,1,0,0,0],
        [0,1,2,3,2,1,0,0],
        [1,2,3,2,3,2,1,0],
        [1,2,3,2,3,2,1,0],
        [0,1,2,3,2,1,0,0],
        [0,0,1,2,1,0,0,0],
        [0,0,0,1,0,0,0,0],
    ]

    # Key (8x8)
    sprites['key'] = [
        [0,1,1,1,0,0,0,0],
        [1,2,0,2,1,0,0,0],
        [1,0,0,0,1,0,0,0],
        [0,1,1,1,0,0,0,0],
        [0,0,2,0,0,0,0,0],
        [0,0,2,0,0,0,0,0],
        [0,0,2,2,0,0,0,0],
        [0,0,2,0,0,0,0,0],
    ]

    # Bomb (8x8)
    sprites['bomb'] = [
        [0,0,0,0,3,1,0,0],
        [0,0,0,3,0,1,0,0],
        [0,0,1,1,1,0,0,0],
        [0,1,2,2,2,1,0,0],
        [1,2,2,2,2,2,1,0],
        [1,2,2,2,2,2,1,0],
        [0,1,2,2,2,1,0,0],
        [0,0,1,1,1,0,0,0],
    ]

    # =====================================================================
    # GENERATE HTML MOCKUP
    # =====================================================================

    # NES palette colors
    nes_palette_js = """
const NES = [
    [0x62,0x62,0x62],[0x00,0x2E,0x98],[0x11,0x13,0xB1],[0x3A,0x00,0xA4],
    [0x5C,0x00,0x7E],[0x6E,0x00,0x40],[0x6C,0x07,0x00],[0x56,0x1D,0x00],
    [0x33,0x35,0x00],[0x0B,0x48,0x00],[0x00,0x52,0x00],[0x00,0x4F,0x08],
    [0x00,0x40,0x4D],[0x00,0x00,0x00],[0x00,0x00,0x00],[0x00,0x00,0x00],
    [0xAB,0xAB,0xAB],[0x0D,0x57,0xFF],[0x35,0x36,0xFF],[0x6B,0x1C,0xFF],
    [0x98,0x0B,0xD5],[0xAF,0x0D,0x7B],[0xAD,0x25,0x21],[0x90,0x44,0x00],
    [0x64,0x62,0x00],[0x31,0x78,0x00],[0x08,0x82,0x00],[0x00,0x7F,0x2A],
    [0x00,0x6E,0x82],[0x00,0x00,0x00],[0x00,0x00,0x00],[0x00,0x00,0x00],
    [0xFF,0xFF,0xFF],[0x53,0xAE,0xFF],[0x79,0x8D,0xFF],[0xB4,0x74,0xFF],
    [0xE4,0x6F,0xFF],[0xF8,0x6C,0xCF],[0xF8,0x7F,0x77],[0xDD,0x9C,0x35],
    [0xB1,0xB5,0x0C],[0x7F,0xCA,0x1C],[0x56,0xD4,0x45],[0x40,0xD0,0x7D],
    [0x41,0xC1,0xCF],[0x4E,0x4E,0x4E],[0x00,0x00,0x00],[0x00,0x00,0x00],
    [0xFF,0xFF,0xFF],[0xB6,0xDB,0xFF],[0xC5,0xCB,0xFF],[0xDA,0xC2,0xFF],
    [0xF0,0xC0,0xFF],[0xFA,0xBF,0xEB],[0xFA,0xC7,0xC3],[0xEF,0xD4,0xA5],
    [0xDF,0xDE,0x96],[0xCA,0xE7,0x9B],[0xB7,0xEB,0xAF],[0xAE,0xEA,0xC9],
    [0xAF,0xE3,0xEA],[0xB5,0xB5,0xB5],[0x00,0x00,0x00],[0x00,0x00,0x00],
];
function rgb(i) { const c=NES[i]; return `rgb(${c[0]},${c[1]},${c[2]})`; }
"""

    sprites_json = json.dumps({k: v for k, v in sprites.items()})

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Zelda 2B - Ripped Graphics Mockup</title>
<style>
* {{ margin:0; padding:0; box-sizing:border-box; }}
body {{ font-family:'Courier New',monospace; background:#1a1a2e; color:#eee; padding:20px; }}
h1 {{ color:#e94560; margin-bottom:5px; }}
h2 {{ color:#53aeff; margin:25px 0 10px; font-size:18px; border-bottom:1px solid #333; padding-bottom:5px; }}
h3 {{ color:#ccc; margin:12px 0 6px; font-size:14px; }}
p.note {{ color:#888; font-size:12px; margin-bottom:10px; }}
canvas {{ image-rendering:pixelated; }}
.scene-box {{ background:#000; padding:2px; border-radius:4px; display:inline-block; border:1px solid #333; margin:8px; }}
.row {{ display:flex; flex-wrap:wrap; gap:12px; margin:10px 0; }}
.card {{ background:#16213e; border-radius:6px; padding:8px; text-align:center; }}
.card .name {{ font-size:10px; color:#aaa; margin-top:4px; }}
.anim-frames {{ display:flex; gap:4px; align-items:center; }}
.anim-frames .arrow {{ color:#53aeff; }}
</style>
</head>
<body>
<h1>Zelda 2B - Ripped Graphics Mockup (Link's Awakening)</h1>
<p class="note">Sprites ripped from Link's Awakening DX reference sheets, adapted to NES 4-shade 2bpp format. All sprites shown at game scale with NES palettes.</p>

<h2>1. Link - All Directions + Walk Animation</h2>
<p class="note">16x16 sprites. Palette: $0F/$19/$29/$38 (green tunic, skin). Walk cycle = idle + walk frame alternating.</p>
<div class="row" id="link-anims"></div>

<h2>2. Link - Sword Attack</h2>
<div class="row" id="link-sword"></div>

<h2>3. Overworld Metatiles (16x16, from LA tileset)</h2>
<p class="note">Ripped from the overworld tileset. BG palette 0: $0F/$09/$19/$29 (green).</p>
<div class="row" id="ow-tiles"></div>

<h2>4. Enemies (16x16 sprites)</h2>
<p class="note">Ripped from LA enemy sheets. Enemy palette: $0F/$06/$16/$27 (red).</p>
<div class="row" id="enemies"></div>

<h2>5. Items - Hearts, Magic, Collectibles</h2>
<p class="note">Hearts: full=red, half=left-red/right-white, empty=white outline. Magic bottles: full=blue, half, empty. Per operator spec.</p>
<div class="row" id="items"></div>

<h2>6. Full Overworld Scene</h2>
<p class="note">Complete 256x240 NES screen with ripped tiles, Link, enemies, items, and HUD.</p>
<div id="ow-scene"></div>

<h2>7. Full Dungeon Scene</h2>
<div id="dng-scene"></div>

<script>
{nes_palette_js}
const S = {sprites_json};

const PAL = {{
    link: [0x0F, 0x19, 0x29, 0x38],
    green: [0x0F, 0x09, 0x19, 0x29],
    water: [0x0F, 0x0C, 0x1C, 0x2C],
    brown: [0x0F, 0x07, 0x17, 0x27],
    warmUI: [0x0F, 0x07, 0x27, 0x38],
    enemy: [0x0F, 0x06, 0x16, 0x27],
    enemyBlue: [0x0F, 0x02, 0x12, 0x22],
    items: [0x0F, 0x12, 0x21, 0x30],
    fx: [0x0F, 0x18, 0x28, 0x30],
    heartPal: [0x0F, 0x06, 0x16, 0x30],  // red hearts
    magicPal: [0x0F, 0x02, 0x12, 0x30],  // blue magic
}};

function drawSprite(ctx, name, x, y, pal, scale) {{
    const px = S[name];
    if (!px) return;
    for (let py = 0; py < px.length; py++)
        for (let pxx = 0; pxx < px[py].length; pxx++) {{
            const ci = px[py][pxx];
            if (ci === 0) continue;
            ctx.fillStyle = rgb(pal[ci]);
            ctx.fillRect(x + pxx*scale, y + py*scale, scale, scale);
        }}
}}

function drawSpriteBG(ctx, name, x, y, pal, scale) {{
    const px = S[name];
    if (!px) return;
    for (let py = 0; py < px.length; py++)
        for (let pxx = 0; pxx < px[py].length; pxx++) {{
            ctx.fillStyle = rgb(pal[px[py][pxx]]);
            ctx.fillRect(x + pxx*scale, y + py*scale, scale, scale);
        }}
}}

function mkCanvas(parent, w, h, dispScale) {{
    const box = document.createElement('div');
    box.className = 'scene-box';
    const c = document.createElement('canvas');
    c.width = w; c.height = h;
    c.style.width = (w*dispScale)+'px'; c.style.height = (h*dispScale)+'px';
    box.appendChild(c);
    parent.appendChild(box);
    return c.getContext('2d');
}}

function addCard(parent, name, drawFn, w, h, ds) {{
    const card = document.createElement('div');
    card.className = 'card';
    const box = document.createElement('div');
    box.className = 'scene-box';
    const c = document.createElement('canvas');
    c.width = w; c.height = h;
    c.style.width = (w*ds)+'px'; c.style.height = (h*ds)+'px';
    const ctx = c.getContext('2d');
    ctx.fillStyle = rgb(0x0F); ctx.fillRect(0,0,w,h);
    drawFn(ctx);
    box.appendChild(c);
    card.appendChild(box);
    const label = document.createElement('div');
    label.className = 'name'; label.textContent = name;
    card.appendChild(label);
    parent.appendChild(card);
}}

function addAnimCard(parent, label, frames, pal, ds) {{
    const card = document.createElement('div');
    card.className = 'card';
    const row = document.createElement('div');
    row.className = 'anim-frames';
    frames.forEach((name, i) => {{
        if (i > 0) {{ const a = document.createElement('span'); a.className='arrow'; a.textContent='→'; row.appendChild(a); }}
        const box = document.createElement('div');
        box.className = 'scene-box';
        const c = document.createElement('canvas');
        c.width = 16; c.height = 16;
        c.style.width = (16*ds)+'px'; c.style.height = (16*ds)+'px';
        const ctx = c.getContext('2d');
        ctx.fillStyle = rgb(0x0F); ctx.fillRect(0,0,16,16);
        drawSprite(ctx, name, 0, 0, pal, 1);
        box.appendChild(c);
        row.appendChild(box);
    }});
    card.appendChild(row);
    const lb = document.createElement('div');
    lb.className = 'name'; lb.textContent = label;
    card.appendChild(lb);
    parent.appendChild(card);
}}

// 1. Link animations
const la = document.getElementById('link-anims');
addAnimCard(la, 'Down (walk)', ['link_idle_down','link_walk_down'], PAL.link, 4);
addAnimCard(la, 'Up (walk)', ['link_idle_up','link_walk_up'], PAL.link, 4);
addAnimCard(la, 'Right (walk)', ['link_idle_right','link_walk_right_1','link_walk_right_2'], PAL.link, 4);
addAnimCard(la, 'Left (walk)', ['link_idle_left','link_walk_left_1','link_walk_left_2'], PAL.link, 4);

// 2. Link sword
const ls = document.getElementById('link-sword');
addAnimCard(ls, 'Sword Down', ['link_sword_down'], PAL.link, 4);
addAnimCard(ls, 'Sword Up', ['link_sword_up'], PAL.link, 4);
addAnimCard(ls, 'Sword Right', ['link_sword_right'], PAL.link, 4);
addAnimCard(ls, 'Sword Left', ['link_sword_left'], PAL.link, 4);

// 3. Overworld tiles
const ot = document.getElementById('ow-tiles');
const owTileNames = Object.keys(S).filter(k => k.startsWith('ow_'));
owTileNames.forEach(name => {{
    const label = name.replace('ow_','').replace(/_/g,' ');
    addCard(ot, label, ctx => drawSpriteBG(ctx, name, 0, 0, PAL.green, 1), 16, 16, 4);
}});

// 4. Enemies
const en = document.getElementById('enemies');
const enemyNames = Object.keys(S).filter(k => k.startsWith('enemy_'));
enemyNames.forEach(name => {{
    const label = name.replace('enemy_','').replace(/_/g,' ');
    addCard(en, label, ctx => drawSprite(ctx, name, 0, 0, PAL.enemy, 1), 16, 16, 4);
}});

// 5. Items
const it = document.getElementById('items');
addCard(it, 'Heart Full', ctx => drawSprite(ctx, 'heart_full', 0, 0, PAL.heartPal, 1), 8, 8, 6);
addCard(it, 'Heart Half', ctx => drawSprite(ctx, 'heart_half', 0, 0, PAL.heartPal, 1), 8, 8, 6);
addCard(it, 'Heart Empty', ctx => drawSprite(ctx, 'heart_empty', 0, 0, PAL.heartPal, 1), 8, 8, 6);
addCard(it, 'Magic Full', ctx => drawSprite(ctx, 'magic_full', 0, 0, PAL.magicPal, 1), 8, 8, 6);
addCard(it, 'Magic Half', ctx => drawSprite(ctx, 'magic_half', 0, 0, PAL.magicPal, 1), 8, 8, 6);
addCard(it, 'Magic Empty', ctx => drawSprite(ctx, 'magic_empty', 0, 0, PAL.magicPal, 1), 8, 8, 6);
addCard(it, 'Rupee', ctx => drawSprite(ctx, 'rupee', 0, 0, PAL.fx, 1), 8, 8, 6);
addCard(it, 'Key', ctx => drawSprite(ctx, 'key', 0, 0, PAL.fx, 1), 8, 8, 6);
addCard(it, 'Bomb', ctx => drawSprite(ctx, 'bomb', 0, 0, PAL.fx, 1), 8, 8, 6);

// 6. Full overworld scene
{{
    const ctx = mkCanvas(document.getElementById('ow-scene'), 256, 240, 2);
    ctx.fillStyle = rgb(0x0F); ctx.fillRect(0,0,256,240);

    // Ground fill with ripped grass
    for (let y=24; y<240; y+=16)
        for (let x=0; x<256; x+=16) {{
            const gn = (x+y)%48<16 ? 'ow_grass_1' : ((x+y)%48<32 ? 'ow_grass_2' : 'ow_grass_3');
            drawSpriteBG(ctx, gn, x, y, PAL.green, 1);
        }}

    // Path
    for (let x=64; x<192; x+=16)
        drawSpriteBG(ctx, 'ow_path_1', x, 128, PAL.green, 1);

    // Trees
    [[16,40],[48,56],[208,40],[224,72],[192,168]].forEach(([tx,ty]) => {{
        drawSpriteBG(ctx, 'ow_tree_1', tx, ty, PAL.green, 1);
        drawSpriteBG(ctx, 'ow_tree_2', tx+16, ty, PAL.green, 1);
        drawSpriteBG(ctx, 'ow_tree_3', tx, ty+16, PAL.green, 1);
        drawSpriteBG(ctx, 'ow_tree_4', tx+16, ty+16, PAL.green, 1);
    }});

    // Water
    for (let y=192; y<240; y+=16)
        for (let x=0; x<80; x+=16) {{
            const wn = (x+y)%32<16 ? 'ow_water_1' : 'ow_water_2';
            drawSpriteBG(ctx, wn, x, y, PAL.water, 1);
        }}

    // House
    drawSpriteBG(ctx, 'ow_house_1', 128, 48, PAL.brown, 1);
    drawSpriteBG(ctx, 'ow_house_2', 144, 48, PAL.brown, 1);
    drawSpriteBG(ctx, 'ow_house_3', 128, 64, PAL.brown, 1);
    drawSpriteBG(ctx, 'ow_house_4', 144, 64, PAL.brown, 1);

    // Rocks & bushes
    drawSpriteBG(ctx, 'ow_rock', 96, 88, PAL.green, 1);
    drawSpriteBG(ctx, 'ow_bush', 80, 104, PAL.green, 1);
    drawSpriteBG(ctx, 'ow_bush', 176, 152, PAL.green, 1);

    // Link
    drawSprite(ctx, 'link_idle_down', 128, 128, PAL.link, 1);

    // Enemies
    drawSprite(ctx, 'enemy_octorok', 192, 128, PAL.enemy, 1);
    drawSprite(ctx, 'enemy_moblin', 80, 160, PAL.enemy, 1);

    // Items on ground
    drawSprite(ctx, 'rupee', 160, 140, PAL.fx, 1);
    drawSprite(ctx, 'heart_full', 96, 180, PAL.heartPal, 1);

    // HUD
    ctx.fillStyle = rgb(0x0F); ctx.fillRect(0,0,256,24);
    for (let i=0;i<3;i++) drawSprite(ctx,'heart_full',8+i*10,4,PAL.heartPal,1);
    drawSprite(ctx,'heart_half',38,4,PAL.heartPal,1);
    drawSprite(ctx,'heart_empty',48,4,PAL.heartPal,1);
    drawSprite(ctx,'magic_full',68,3,PAL.magicPal,1);
    drawSprite(ctx,'magic_full',78,3,PAL.magicPal,1);
    drawSprite(ctx,'magic_half',88,3,PAL.magicPal,1);
    drawSprite(ctx,'rupee',200,8,PAL.fx,1);
    drawSprite(ctx,'key',230,8,PAL.fx,1);
    drawSprite(ctx,'bomb',172,8,PAL.fx,1);
}}

// 7. Dungeon scene
{{
    const ctx = mkCanvas(document.getElementById('dng-scene'), 256, 240, 2);
    ctx.fillStyle = rgb(0x0F); ctx.fillRect(0,0,256,240);

    // Floor
    for (let y=24; y<240; y+=16)
        for (let x=0; x<256; x+=16)
            drawSpriteBG(ctx, 'ow_cliff_1', x, y, PAL.brown, 1);

    // Walls (top)
    for (let x=0; x<256; x+=16) {{
        drawSpriteBG(ctx, 'ow_cave_1', x, 24, PAL.brown, 1);
        drawSpriteBG(ctx, 'ow_cave_2', x, 40, PAL.brown, 1);
    }}

    // Side walls
    for (let y=56; y<224; y+=16) {{
        drawSpriteBG(ctx, 'ow_cliff_2', 0, y, PAL.brown, 1);
        drawSpriteBG(ctx, 'ow_cliff_2', 240, y, PAL.brown, 1);
    }}

    // Bottom wall
    for (let x=0; x<256; x+=16)
        drawSpriteBG(ctx, 'ow_cave_1', x, 224, PAL.brown, 1);

    // Link
    drawSprite(ctx, 'link_idle_up', 120, 160, PAL.link, 1);

    // Enemies
    drawSprite(ctx, 'enemy_keese', 64, 100, PAL.enemy, 1);
    drawSprite(ctx, 'enemy_zol', 192, 140, PAL.enemyBlue, 1);

    // Items
    drawSprite(ctx, 'key', 48, 168, PAL.fx, 1);

    // HUD
    ctx.fillStyle = rgb(0x0F); ctx.fillRect(0,0,256,24);
    for (let i=0;i<3;i++) drawSprite(ctx,'heart_full',8+i*10,4,PAL.heartPal,1);
    drawSprite(ctx,'heart_half',38,4,PAL.heartPal,1);
    drawSprite(ctx,'heart_empty',48,4,PAL.heartPal,1);
    drawSprite(ctx,'magic_full',68,3,PAL.magicPal,1);
    drawSprite(ctx,'magic_half',78,3,PAL.magicPal,1);
    drawSprite(ctx,'rupee',200,8,PAL.fx,1);
    drawSprite(ctx,'key',230,8,PAL.fx,1);
}}

</script>
</body>
</html>"""

    output_path = os.path.join(BUILD_DIR, 'ripped_mockup.html')
    with open(output_path, 'w') as f:
        f.write(html)
    print(f"Generated: {output_path}")
    print(f"Sprites extracted: {len(sprites)}")


if __name__ == "__main__":
    main()
