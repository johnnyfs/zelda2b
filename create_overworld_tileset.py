#!/usr/bin/env python3
"""
Generate NES overworld tileset PNG for Zelda 2B.
Style inspired by Link's Awakening and LttP, adapted to NES 4-color constraints.
"""

from PIL import Image

# NES palette for overworld (example - will be finalized by PaletteDesigner)
# Index 0: background (light green grass base)
# Index 1: dark outline/shadow
# Index 2: medium detail
# Index 3: highlight
PALETTE = [
    0x88, 0xD8, 0x70,  # 0: light green (grass base)
    0x18, 0x50, 0x18,  # 1: dark green (outlines, shadows)
    0x30, 0x90, 0x30,  # 2: medium green (detail)
    0xF8, 0xF8, 0xD8,  # 3: light cream (highlights)
]

# Tile layout: 16 columns x 16 rows = 256 tiles total
WIDTH = 128  # 16 tiles * 8 pixels
HEIGHT = 128  # 16 rows * 8 pixels

img = Image.new('P', (WIDTH, HEIGHT))
img.putpalette(PALETTE + [0] * 756)

def set_tile_pixel(col, row, x, y, color):
    """Set a pixel within a tile at grid position (col, row)."""
    img.putpixel((col * 8 + x, row * 8 + y), color)

def fill_tile(col, row, color):
    """Fill entire tile with one color."""
    for y in range(8):
        for x in range(8):
            set_tile_pixel(col, row, x, y, color)

def draw_tile(col, row, pattern):
    """Draw a tile from an 8x8 pattern (list of 8 strings, each 8 chars)."""
    for y in range(8):
        for x in range(8):
            c = pattern[y][x]
            color = int(c) if c.isdigit() else 0
            set_tile_pixel(col, row, x, y, color)

# Tile 0: Empty/grass base (all index 0 for efficiency)
fill_tile(0, 0, 0)

# Tiles 1-4: Grass variations with subtle texture
grass_patterns = [
    # Tile 1: Light grass dots
    ["00000000",
     "00000200",
     "00000000",
     "00200000",
     "00000000",
     "00000020",
     "00000000",
     "02000000"],
    # Tile 2: Grass with more texture
    ["00020000",
     "00000000",
     "20000002",
     "00000000",
     "00020000",
     "00000200",
     "00000000",
     "00000000"],
    # Tile 3: Dense grass
    ["02000200",
     "00020002",
     "20020000",
     "00000020",
     "00200002",
     "20000200",
     "00020000",
     "00000020"],
]
for i, pattern in enumerate(grass_patterns):
    draw_tile(i + 1, 0, pattern)

# Tiles 4-7: Dirt/path
dirt_pattern = [
    "22222222",
    "21212222",
    "22222122",
    "22121222",
    "22222212",
    "21222122",
    "22122222",
    "22222221",
]
draw_tile(4, 0, dirt_pattern)

# Tiles 8-15: Water tiles (animated - 2 frames)
# Water base tile
water_base = [
    "11111111",
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "11222211",
    "11111111",
    "11111111",
]
draw_tile(8, 0, water_base)

# Water with waves
water_wave = [
    "11111111",
    "11222211",
    "12332321",
    "12332321",
    "12223221",
    "11222211",
    "11111111",
    "11111111",
]
draw_tile(9, 0, water_wave)

# Water shore edges (north, south, east, west)
water_shore_n = [
    "22222222",
    "22222222",
    "11111111",
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "11222211",
]
draw_tile(10, 0, water_shore_n)

water_shore_s = [
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "11222211",
    "11111111",
    "22222222",
    "22222222",
]
draw_tile(11, 0, water_shore_s)

water_shore_e = [
    "11111122",
    "11222222",
    "12232222",
    "12232222",
    "12222222",
    "11222222",
    "11111122",
    "11111122",
]
draw_tile(12, 0, water_shore_e)

water_shore_w = [
    "22111111",
    "22222211",
    "22232321",
    "22232321",
    "22222221",
    "22222211",
    "22111111",
    "22111111",
]
draw_tile(13, 0, water_shore_w)

# Tiles 16-19: Tree top-left, top-right, bottom-left, bottom-right
tree_tl = [
    "00001111",
    "00112221",
    "01222321",
    "12223221",
    "12232321",
    "12223221",
    "01222221",
    "00112211",
]
draw_tile(0, 1, tree_tl)

tree_tr = [
    "11110000",
    "12221100",
    "12332210",
    "12232221",
    "12323221",
    "12223221",
    "12222210",
    "11222100",
]
draw_tile(1, 1, tree_tr)

tree_bl = [
    "00011111",
    "00111211",
    "00112211",
    "00011111",
    "00001110",
    "00001110",
    "00001110",
    "00001110",
]
draw_tile(2, 1, tree_bl)

tree_br = [
    "11111000",
    "11211100",
    "11221100",
    "11111000",
    "01110000",
    "01110000",
    "01110000",
    "01110000",
]
draw_tile(3, 1, tree_br)

# Tiles 20-23: Bush top-left, top-right, bottom-left, bottom-right
bush_tl = [
    "00000011",
    "00011221",
    "00122321",
    "01222321",
    "01223221",
    "01222221",
    "00122211",
    "00011110",
]
draw_tile(4, 1, bush_tl)

bush_tr = [
    "11000000",
    "12211000",
    "12332100",
    "12332210",
    "12232210",
    "12222210",
    "11222100",
    "01111000",
]
draw_tile(5, 1, bush_tr)

bush_bl = [
    "00001110",
    "00011110",
    "00011100",
    "00001100",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
]
draw_tile(6, 1, bush_bl)

bush_br = [
    "01110000",
    "01111000",
    "00111000",
    "00110000",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
]
draw_tile(7, 1, bush_br)

# Tiles 24-27: Rock/boulder (2x2)
rock_tl = [
    "00001111",
    "00112221",
    "01222221",
    "12222211",
    "12222111",
    "12221111",
    "12211111",
    "12211111",
]
draw_tile(8, 1, rock_tl)

rock_tr = [
    "11110000",
    "12221100",
    "12222210",
    "11222221",
    "11122221",
    "11112221",
    "11111221",
    "11111221",
]
draw_tile(9, 1, rock_tr)

rock_bl = [
    "12221111",
    "12221111",
    "01222111",
    "01122211",
    "00112221",
    "00011221",
    "00001111",
    "00000000",
]
draw_tile(10, 1, rock_bl)

rock_br = [
    "11112221",
    "11112221",
    "11122210",
    "11222100",
    "12221100",
    "12211000",
    "11110000",
    "00000000",
]
draw_tile(11, 1, rock_br)

# Tiles 28-31: Mountain/cliff wall (vertical, decorative)
mountain_l = [
    "11111111",
    "12222111",
    "12221111",
    "12211111",
    "12111111",
    "12211111",
    "12221111",
    "12222111",
]
draw_tile(12, 1, mountain_l)

mountain_r = [
    "11111111",
    "11122221",
    "11112221",
    "11111221",
    "11111121",
    "11111221",
    "11112221",
    "11122221",
]
draw_tile(13, 1, mountain_r)

# Tiles 32-39: House/building exterior
# House wall
house_wall = [
    "11111111",
    "12222221",
    "12111121",
    "12111121",
    "12111121",
    "12111121",
    "12222221",
    "11111111",
]
draw_tile(0, 2, house_wall)

# House roof left
house_roof_l = [
    "00000111",
    "00011221",
    "00122211",
    "01222111",
    "12221111",
    "11111111",
    "11111111",
    "11111111",
]
draw_tile(1, 2, house_roof_l)

# House roof right
house_roof_r = [
    "11100000",
    "12211000",
    "11222100",
    "11122210",
    "11112221",
    "11111111",
    "11111111",
    "11111111",
]
draw_tile(2, 2, house_roof_r)

# House door
house_door = [
    "11111111",
    "12222221",
    "12111121",
    "12111121",
    "12131121",
    "12111121",
    "12111121",
    "12222221",
]
draw_tile(3, 2, house_door)

# Tiles 40-43: Bridge horizontal
bridge_h = [
    "11111111",
    "22222222",
    "33333333",
    "22222222",
    "22222222",
    "33333333",
    "22222222",
    "11111111",
]
draw_tile(8, 2, bridge_h)

# Tiles 44-47: Bridge vertical
bridge_v = [
    "12321232",
    "12321232",
    "12321232",
    "12321232",
    "12321232",
    "12321232",
    "12321232",
    "12321232",
]
draw_tile(9, 2, bridge_v)

# Tiles 48-51: Cave entrance (2x2)
cave_tl = [
    "00000000",
    "00000000",
    "00011111",
    "00122221",
    "01222111",
    "12221000",
    "12210000",
    "12200000",
]
draw_tile(0, 3, cave_tl)

cave_tr = [
    "00000000",
    "00000000",
    "11111000",
    "12222100",
    "11122210",
    "00012221",
    "00001221",
    "00000221",
]
draw_tile(1, 3, cave_tr)

cave_bl = [
    "12100000",
    "12100000",
    "12200000",
    "01220000",
    "00122000",
    "00012210",
    "00001111",
    "00000000",
]
draw_tile(2, 3, cave_bl)

cave_br = [
    "00001221",
    "00001221",
    "00000221",
    "00002210",
    "00022100",
    "01221000",
    "11110000",
    "00000000",
]
draw_tile(3, 3, cave_br)

# Tiles 52-59: Fence/wall sections
fence_h = [
    "00000000",
    "00000000",
    "11111111",
    "22222222",
    "22222222",
    "11111111",
    "00000000",
    "00000000",
]
draw_tile(4, 3, fence_h)

fence_v = [
    "00110011",
    "00110011",
    "00110011",
    "00110011",
    "00110011",
    "00110011",
    "00110011",
    "00110011",
]
draw_tile(5, 3, fence_v)

# Tiles 60-67: Sand/desert
sand_base = [
    "22222222",
    "22322222",
    "22222222",
    "22223222",
    "22222222",
    "23222222",
    "22222222",
    "22222322",
]
draw_tile(6, 3, sand_base)

# Tiles 68-75: Flower decorations (single tile)
flower_1 = [
    "00000000",
    "00000000",
    "00003000",
    "00032300",
    "00003000",
    "00001000",
    "00001000",
    "00000000",
]
draw_tile(7, 3, flower_1)

# Tiles 76-83: Stairs up
stairs_up = [
    "22222222",
    "12222222",
    "11222222",
    "11122222",
    "11112222",
    "11111222",
    "11111122",
    "11111112",
]
draw_tile(8, 3, stairs_up)

# Tiles 84-91: Sign post
sign_post = [
    "11111111",
    "12222221",
    "12333321",
    "12333321",
    "12222221",
    "11111111",
    "00011100",
    "00011100",
]
draw_tile(9, 3, sign_post)

# Fill remaining tiles with variations and connectors
# Tiles 92-99: Corner pieces for water
water_corner_nw = [
    "22222222",
    "22222211",
    "22211111",
    "22111222",
    "21122232",
    "11223322",
    "11223322",
    "11222221",
]
draw_tile(10, 3, water_corner_nw)

water_corner_ne = [
    "22222222",
    "11222222",
    "11111222",
    "22211122",
    "23221121",
    "22332211",
    "22332211",
    "12222211",
]
draw_tile(11, 3, water_corner_ne)

water_corner_sw = [
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "21111222",
    "22221122",
    "22222222",
    "22222222",
]
draw_tile(12, 3, water_corner_sw)

water_corner_se = [
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "22211121",
    "22111222",
    "22222222",
    "22222222",
]
draw_tile(13, 3, water_corner_se)

# Tiles 100-107: Stone tiles
stone_tile = [
    "11111111",
    "12222221",
    "12333321",
    "12332221",
    "12322221",
    "12222221",
    "11111111",
    "11111111",
]
draw_tile(14, 3, stone_tile)

# Add more variations for seamless tiling
# Row 4 - more tree variations, small rocks, etc.
small_rock = [
    "00000000",
    "00011100",
    "00122210",
    "01222221",
    "01222221",
    "00122210",
    "00011100",
    "00000000",
]
draw_tile(0, 4, small_rock)

# Tall grass
tall_grass = [
    "00020002",
    "00020002",
    "00212120",
    "02212122",
    "02121220",
    "00212120",
    "00020002",
    "00020002",
]
draw_tile(1, 4, tall_grass)

# Fill more useful tiles
# Additional ground transitions, decorations, etc.

print("Overworld tileset created: 256 tiles (16x16 grid)")
img.save('/Users/jschmidt/lab/hub/.hub-data/projects/a79ec915-7144-4467-8392-2d2c0af9a18e/workspaces/0a7ebf0c-38ed-41c6-a0d0-3b3d580abd60/zelda2b/assets/tilesets/overworld.png')
print("Saved to assets/tilesets/overworld.png")
