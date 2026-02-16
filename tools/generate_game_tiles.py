#!/usr/bin/env python3
"""
generate_game_tiles.py - Generate Link's Awakening-inspired NES CHR tiles.

Creates tile data inspired by the Game Boy Zelda games, adapted to NES
2bpp CHR format. These are original pixel art recreations in the style of
Link's Awakening overworld and dungeon tiles.

Output:
  assets/chr/overworld_bg.chr   - Background tiles for overworld
  assets/chr/dungeon_bg.chr     - Background tiles for dungeons
  assets/chr/sprites.chr        - Sprite tiles (Link, enemies, items)
  assets/chr/hud.chr            - HUD/UI tiles

Each tile is 8x8 pixels, 2bpp (4 colors), 16 bytes per tile.
Color indices: 0=background/transparent, 1=dark, 2=medium, 3=light
"""

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
        # Pad short rows with 0, truncate long rows
        if len(row) > 0:
            while len(row) < 8:
                row.append(0)
            rows.append(row[:8])
    assert len(rows) == 8, f"Expected 8 rows, got {len(rows)}"
    return rows


def empty():
    return [[0]*8 for _ in range(8)]


def solid(c):
    return [[c]*8 for _ in range(8)]


# =========================================================================
# OVERWORLD BACKGROUND TILES
# =========================================================================

# Tile $00: Empty/blank
TILE_EMPTY = empty()

# Tile $01: Grass (basic ground)
TILE_GRASS = t("""
22322232
32223222
22322232
23222322
22322322
32232223
22322232
22232223
""")

# Tile $02: Grass variant (slightly different pattern)
TILE_GRASS2 = t("""
22232223
22322322
32223222
22322232
22232223
22322322
23222322
22322232
""")

# Tile $03: Path/dirt (lighter)
TILE_PATH = t("""
21112111
11211121
12111211
11121112
21111211
11211121
11121112
12111211
""")

# Tile $04: Path edge top
TILE_PATH_EDGE_T = t("""
22222222
11111111
11211121
12111211
11121112
11211121
12111211
11121112
""")

# Tile $05: Water (still)
TILE_WATER = t("""
22222222
22222222
33322222
22222233
22222222
22233322
22222222
22222222
""")

# Tile $06: Water (animated frame 2)
TILE_WATER2 = t("""
22222222
22233322
22222222
22222222
33222222
22222222
22222233
22222222
""")

# Tile $07: Sand/beach
TILE_SAND = t("""
33233323
23332333
33233323
33323332
23332333
33233323
33323332
23332333
""")

# Tile $08: Tree top-left (16x16 metatile, part 1)
TILE_TREE_TL = t("""
..112233
.1223333
12233333
12333332
23333322
23333221
23332211
23322111
""")

# Tile $09: Tree top-right
TILE_TREE_TR = t("""
33221100
33332210
33333221
23333321
22333332
12233332
11233332
11122332
""")

# Tile $0A: Tree bottom-left
TILE_TREE_BL = t("""
23321111
23321111
.2321111
.2221111
..221111
..121111
...11111
...11111
""")

# Tile $0B: Tree bottom-right (trunk)
TILE_TREE_BR = t("""
11112332
11112332
11112320
11112220
11112200
11112100
11111000
11111000
""")

# Tile $0C: Bush (8x8)
TILE_BUSH = t("""
.1122110
12233221
23333332
23333332
23333332
12333321
.1233210
..111100
""")

# Tile $0D: Rock/boulder top-left
TILE_ROCK_TL = t("""
..112211
.1233321
12333321
13333321
23333211
23332111
23321111
13211111
""")

# Tile $0E: Rock/boulder top-right
TILE_ROCK_TR = t("""
11221100
12333210
12333321
12333321
11233321
11123321
11112321
11111210
""")

# Tile $0F: Flower
TILE_FLOWER = t("""
..3..3..
.323323.
.2332320
..3223..
.323323.
..3..3..
...22...
..2..2..
""")

# Tile $10: House wall
TILE_HOUSE_WALL = t("""
33333333
31111113
31111113
31111113
33333333
13111131
13111131
13111131
""")

# Tile $11: House roof
TILE_HOUSE_ROOF = t("""
........
.1111111
11222221
12222221
12222221
12333321
13333331
13333331
""")

# Tile $12: Door
TILE_DOOR = t("""
11111111
12222221
12333321
12333321
12332321
12332321
12333321
11111111
""")

# Tile $13: Window
TILE_WINDOW = t("""
11111111
13333331
13211231
13211231
13333331
13122131
13122131
11111111
""")

# Tile $14: Cave entrance top
TILE_CAVE_TOP = t("""
11111111
12222221
13333331
13333331
.1333310
..13310.
...110..
........
""")

# Tile $15: Fence horizontal
TILE_FENCE_H = t("""
........
11111111
23232323
11111111
........
........
........
........
""")

# Tile $16: Fence vertical
TILE_FENCE_V = t("""
.12.....
.12.....
.12.....
.12.....
.12.....
.12.....
.12.....
.12.....
""")

# Tile $17: Stairs
TILE_STAIRS = t("""
33333333
.1111111
.2222222
..333333
..111111
...22222
...33333
....1111
""")

# Tile $18: Cliff edge
TILE_CLIFF = t("""
33333333
33333333
11111111
21111112
.211112.
..2112..
...22...
........
""")

# Tile $19: Bridge horizontal
TILE_BRIDGE_H = t("""
11111111
23232323
32323232
23232323
32323232
23232323
32323232
11111111
""")

# Tile $1A: Signpost top
TILE_SIGN_T = t("""
.111111.
13333331
13222231
13222231
13333331
.111111.
...11...
...11...
""")

# Tile $1B: Chest (closed)
TILE_CHEST = t("""
.111111.
13333331
12222221
11111111
12332321
12332321
12222221
11111111
""")

# Tile $1C: Pot/jar
TILE_POT = t("""
..1331..
.133331.
13333331
13322331
13322331
13333331
.133331.
..1111..
""")

# Tile $1D: Tall grass
TILE_TALL_GRASS = t("""
.3..3..3
3232.323
32323232
23232323
32323232
23232323
22222222
22222222
""")

# Tile $1E: Tombstone
TILE_TOMBSTONE = t("""
.111111.
13333331
13333331
13322331
13333331
13333331
11111111
11111111
""")

# Tile $1F: Ladder
TILE_LADDER = t("""
1....1..
1....1..
111111..
1....1..
1....1..
111111..
1....1..
1....1..
""")

# =========================================================================
# DUNGEON BACKGROUND TILES
# =========================================================================

# Tile $00: Dungeon floor
TILE_DNG_FLOOR = t("""
22222221
22222221
22222221
22222221
22222221
22222221
22222221
11111111
""")

# Tile $01: Dungeon wall
TILE_DNG_WALL = t("""
33333333
31111113
31222213
31233213
31233213
31222213
31111113
33333333
""")

# Tile $02: Dungeon wall top
TILE_DNG_WALL_T = t("""
11111111
33333333
33333333
32222223
32222223
31111113
31111113
33333333
""")

# Tile $03: Dungeon door
TILE_DNG_DOOR = t("""
11111111
1......1
1......1
1......1
1......1
1......1
1......1
11111111
""")

# Tile $04: Dungeon key block
TILE_DNG_KEYBLOCK = t("""
11111111
12222221
12311321
12133121
12133121
12311321
12222221
11111111
""")

# Tile $05: Dungeon cracked wall
TILE_DNG_CRACK = t("""
33333333
31113113
31223213
31233213
31132213
31222213
31113113
33333333
""")

# Tile $06: Dungeon torch (on wall)
TILE_DNG_TORCH = t("""
...33...
..3333..
..3223..
..1221..
...11...
...11...
...11...
..1111..
""")

# Tile $07: Dungeon pit/hole
TILE_DNG_PIT = t("""
21111112
1......1
1......1
1......1
1......1
1......1
1......1
21111112
""")

# Tile $08: Block (pushable)
TILE_DNG_BLOCK = t("""
33333333
32222223
32333323
32333323
32333323
32333323
32222223
33333333
""")

# Tile $09: Dungeon switch (floor button)
TILE_DNG_SWITCH = t("""
22222221
22112221
21122121
21222121
21222121
21122121
22112221
11111111
""")

# Tile $0A: Spike trap
TILE_DNG_SPIKES = t("""
22.22.21
2.32.321
.3.3.3.1
22222221
22.22.21
2.32.321
.3.3.3.1
11111111
""")

# Tile $0B: Dungeon chest
TILE_DNG_CHEST = t("""
.111111.
13333331
12222221
11111111
12332321
12222221
11111111
22222222
""")

# =========================================================================
# SPRITE TILES (Link, enemies, items, effects)
# =========================================================================

# Link facing down - frame 1 (16x16 = 4 tiles)
# Using 2x2 metatile arrangement: TL, TR, BL, BR

# Link down TL
LINK_DOWN_TL = t("""
.1133...
13322...
13322...
13332...
.1222...
.1312...
..112...
..112...
""")

# Link down TR
LINK_DOWN_TR = t("""
...3311.
...22331
...22331
...23331
...2221.
...2131.
...211..
...211..
""")

# Link down BL
LINK_DOWN_BL = t("""
..122...
.11232..
.12232..
.12222..
..1222..
..1122..
..1.12..
.11..12.
""")

# Link down BR
LINK_DOWN_BR = t("""
...221..
..23211.
..23221.
..22221.
..2221..
..2211..
..21.1..
.21..11.
""")

# Link up TL
LINK_UP_TL = t("""
.1133...
12233...
12233...
12223...
.1222...
.1222...
..112...
..112...
""")

# Link up TR
LINK_UP_TR = t("""
...3311.
...33221
...33221
...32221
...2221.
...2221.
...211..
...211..
""")

# Link up BL
LINK_UP_BL = t("""
..122...
.11222..
.12222..
.12222..
..1222..
..1122..
..1.12..
.11..12.
""")

# Link up BR
LINK_UP_BR = t("""
...221..
..22211.
..22221.
..22221.
..2221..
..2211..
..21.1..
.21..11.
""")

# Link right TL
LINK_RIGHT_TL = t("""
..1133..
.132233.
.132233.
.133332.
..12221.
..13121.
..11121.
..11121.
""")

# Link right TR
LINK_RIGHT_TR = t("""
........
........
........
........
.11.....
13......
.1......
........
""")

# Link right BL
LINK_RIGHT_BL = t("""
..12221.
.112232.
.122232.
.122222.
..12221.
..11221.
..1..11.
.11...1.
""")

# Link right BR
LINK_RIGHT_BR = t("""
........
........
........
........
........
........
........
........
""")

# Link walking down frame 2 BL (legs alternate)
LINK_WALK_DOWN_BL = t("""
..122...
.11232..
.12232..
.12222..
..1222..
..1221..
..12.1..
..1..11.
""")

LINK_WALK_DOWN_BR = t("""
...221..
..23211.
..23221.
..22221.
..2221..
..1221..
..1.21..
.11..1..
""")

# --- Enemies ---

# Octorok (8x8 simplified, fits in single tile)
ENEMY_OCTOROK_TL = t("""
..1111..
.123321.
12233221
12332321
13322331
13222331
.122221.
..1111..
""")

# Moblin top-left
ENEMY_MOBLIN_TL = t("""
.11111..
12222210
12333210
12332210
.1222210
..12321.
..11121.
...111..
""")

# Keese/bat
ENEMY_KEESE = t("""
........
1......1
21....12
.213312.
..1221..
..1221..
...11...
........
""")

# Zol (slime blob)
ENEMY_ZOL = t("""
........
..1111..
.123321.
12333321
12333321
.123321.
..1111..
........
""")

# --- Items ---

# Heart (full)
ITEM_HEART = t("""
.11.11..
12212210
12222210
12222210
.122210.
..1210..
...10...
........
""")

# Heart (empty)
ITEM_HEART_EMPTY = t("""
.11.11..
1..1..10
1....110
1....110
.1..110.
..110...
...10...
........
""")

# Magic bottle (full)
ITEM_MAGIC_FULL = t("""
..11....
.1221...
..11....
.1331...
13333100
13333100
.13310..
..110...
""")

# Magic bottle (empty)
ITEM_MAGIC_EMPTY = t("""
..11....
.1221...
..11....
.1111...
11111100
11111100
.11110..
..110...
""")

# Rupee
ITEM_RUPEE = t("""
...1....
..121...
.12321..
12323210
12323210
.12321..
..121...
...1....
""")

# Key
ITEM_KEY = t("""
.111....
12.1....
1..1....
.11.....
..1.....
..1.....
..11....
..1.....
""")

# Bomb
ITEM_BOMB = t("""
....31..
...3.1..
..111...
.12221..
12222210
12222210
.122210.
..1110..
""")

# Sword
ITEM_SWORD = t("""
......31
.....321
....321.
...321..
..321...
.1321...
..11....
..1.....
""")

# Shield
ITEM_SHIELD = t("""
.11111..
12222210
12333210
12323210
12333210
12222210
.122210.
..1110..
""")

# Arrow
ITEM_ARROW = t("""
...1....
..131...
...1....
...1....
...1....
...1....
...1....
...1....
""")

# Roc's Feather
ITEM_FEATHER = t("""
.....31.
....32..
...32...
..321...
.3211...
3211....
211.....
11......
""")

# --- Effects ---

# Sparkle frame 1
FX_SPARKLE1 = t("""
........
...3....
..131...
.31.13..
..131...
...3....
........
........
""")

# Sparkle frame 2
FX_SPARKLE2 = t("""
..3..3..
........
3......3
........
3......3
........
..3..3..
........
""")

# Explosion frame
FX_EXPLOSION = t("""
.3...3..
..3.3.3.
.3.33.3.
..33.33.
.33.33..
.3.33.3.
..3.3...
.3...3..
""")

# Shadow (8x8 under sprites)
FX_SHADOW = t("""
........
........
........
........
..1111..
.111111.
.111111.
..1111..
""")


# =========================================================================
# HUD TILES
# =========================================================================

# "A" button indicator
HUD_BTN_A = t("""
.11111.
1.....1
1.333.1
13...31
13333.1
13...31
1.....1
.11111.
""")

# "B" button indicator
HUD_BTN_B = t("""
.11111.
1.....1
1.333.1
13..3.1
1.33..1
13..3.1
1.333.1
.11111.
""")

# Item box frame TL
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

# Item box frame TR
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

# Item box frame BL
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

# Item box frame BR
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

# Minimap dot (current position)
HUD_MAP_DOT = t("""
........
........
..3333..
..3333..
..3333..
..3333..
........
........
""")

# SELECT text
HUD_ARROW_R = t("""
........
..1.....
..11....
..111...
..1111..
..111...
..11....
..1.....
""")


# =========================================================================
# OUTPUT
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


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "chr")
    os.makedirs(out_dir, exist_ok=True)

    # Overworld BG tiles (padded to 4096 bytes = 256 tiles)
    overworld_tiles = [
        TILE_EMPTY,      # $00
        TILE_GRASS,      # $01
        TILE_GRASS2,     # $02
        TILE_PATH,       # $03
        TILE_PATH_EDGE_T,# $04
        TILE_WATER,      # $05
        TILE_WATER2,     # $06
        TILE_SAND,       # $07
        TILE_TREE_TL,    # $08
        TILE_TREE_TR,    # $09
        TILE_TREE_BL,    # $0A
        TILE_TREE_BR,    # $0B
        TILE_BUSH,       # $0C
        TILE_ROCK_TL,    # $0D
        TILE_ROCK_TR,    # $0E
        TILE_FLOWER,     # $0F
        TILE_HOUSE_WALL, # $10
        TILE_HOUSE_ROOF, # $11
        TILE_DOOR,       # $12
        TILE_WINDOW,     # $13
        TILE_CAVE_TOP,   # $14
        TILE_FENCE_H,    # $15
        TILE_FENCE_V,    # $16
        TILE_STAIRS,     # $17
        TILE_CLIFF,      # $18
        TILE_BRIDGE_H,   # $19
        TILE_SIGN_T,     # $1A
        TILE_CHEST,      # $1B
        TILE_POT,        # $1C
        TILE_TALL_GRASS, # $1D
        TILE_TOMBSTONE,  # $1E
        TILE_LADDER,     # $1F
    ]
    ow_data = pad_to_bank(build_chr(overworld_tiles))
    ow_path = os.path.join(out_dir, "overworld_bg.chr")
    with open(ow_path, 'wb') as f:
        f.write(ow_data)
    print(f"Overworld BG: {len(overworld_tiles)} tiles -> {ow_path} ({len(ow_data)} bytes)")

    # Dungeon BG tiles
    dungeon_tiles = [
        TILE_EMPTY,       # $00
        TILE_DNG_FLOOR,   # $01
        TILE_DNG_WALL,    # $02
        TILE_DNG_WALL_T,  # $03
        TILE_DNG_DOOR,    # $04
        TILE_DNG_KEYBLOCK,# $05
        TILE_DNG_CRACK,   # $06
        TILE_DNG_TORCH,   # $07
        TILE_DNG_PIT,     # $08
        TILE_DNG_BLOCK,   # $09
        TILE_DNG_SWITCH,  # $0A
        TILE_DNG_SPIKES,  # $0B
        TILE_DNG_CHEST,   # $0C
    ]
    dng_data = pad_to_bank(build_chr(dungeon_tiles))
    dng_path = os.path.join(out_dir, "dungeon_bg.chr")
    with open(dng_path, 'wb') as f:
        f.write(dng_data)
    print(f"Dungeon BG: {len(dungeon_tiles)} tiles -> {dng_path} ({len(dng_data)} bytes)")

    # Sprite tiles (Link, enemies, items, effects)
    sprite_tiles = [
        TILE_EMPTY,      # $00 - blank
        # Link facing down ($01-$04)
        LINK_DOWN_TL,    # $01
        LINK_DOWN_TR,    # $02
        LINK_DOWN_BL,    # $03
        LINK_DOWN_BR,    # $04
        # Link facing up ($05-$08)
        LINK_UP_TL,      # $05
        LINK_UP_TR,      # $06
        LINK_UP_BL,      # $07
        LINK_UP_BR,      # $08
        # Link facing right ($09-$0C)
        LINK_RIGHT_TL,   # $09
        LINK_RIGHT_TR,   # $0A
        LINK_RIGHT_BL,   # $0B
        LINK_RIGHT_BR,   # $0C
        # Link walk frame 2 down legs ($0D-$0E)
        LINK_WALK_DOWN_BL, # $0D
        LINK_WALK_DOWN_BR, # $0E
        # Enemies ($0F-$12)
        ENEMY_OCTOROK_TL,# $0F
        ENEMY_MOBLIN_TL, # $10
        ENEMY_KEESE,     # $11
        ENEMY_ZOL,       # $12
        # Items ($13-$1E)
        ITEM_HEART,      # $13
        ITEM_HEART_EMPTY,# $14
        ITEM_MAGIC_FULL, # $15
        ITEM_MAGIC_EMPTY,# $16
        ITEM_RUPEE,      # $17
        ITEM_KEY,        # $18
        ITEM_BOMB,       # $19
        ITEM_SWORD,      # $1A
        ITEM_SHIELD,     # $1B
        ITEM_ARROW,      # $1C
        ITEM_FEATHER,    # $1D
        # Effects ($1E-$21)
        FX_SPARKLE1,     # $1E
        FX_SPARKLE2,     # $1F
        FX_EXPLOSION,    # $20
        FX_SHADOW,       # $21
    ]
    spr_data = pad_to_bank(build_chr(sprite_tiles))
    spr_path = os.path.join(out_dir, "sprites.chr")
    with open(spr_path, 'wb') as f:
        f.write(spr_data)
    print(f"Sprites: {len(sprite_tiles)} tiles -> {spr_path} ({len(spr_data)} bytes)")

    # HUD tiles
    hud_tiles = [
        TILE_EMPTY,      # $00
        HUD_BTN_A,       # $01
        HUD_BTN_B,       # $02
        HUD_BOX_TL,      # $03
        HUD_BOX_TR,      # $04
        HUD_BOX_BL,      # $05
        HUD_BOX_BR,      # $06
        HUD_MAP_DOT,     # $07
        HUD_ARROW_R,     # $08
        ITEM_HEART,      # $09 (copy for HUD)
        ITEM_HEART_EMPTY,# $0A (copy for HUD)
        ITEM_MAGIC_FULL, # $0B (copy for HUD)
        ITEM_MAGIC_EMPTY,# $0C (copy for HUD)
    ]
    hud_data = pad_to_bank(build_chr(hud_tiles))
    hud_path = os.path.join(out_dir, "hud.chr")
    with open(hud_path, 'wb') as f:
        f.write(hud_data)
    print(f"HUD: {len(hud_tiles)} tiles -> {hud_path} ({len(hud_data)} bytes)")

    # Also generate a combined file for the viewer
    all_data = ow_data + spr_data
    all_path = os.path.join(out_dir, "tiles.chr")
    with open(all_path, 'wb') as f:
        f.write(all_data)
    print(f"Combined (OW+Sprites): -> {all_path} ({len(all_data)} bytes)")

    print("\nDone! Run tile_viewer_gen.py to preview these tiles.")


if __name__ == "__main__":
    main()
