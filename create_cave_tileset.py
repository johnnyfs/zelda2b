#!/usr/bin/env python3
"""
Generate NES cave tileset PNG for Zelda 2B.
Style for natural caves, including Death Mountain lava caves.
"""

from PIL import Image

# NES palette for cave (example)
# Index 0: black background
# Index 1: dark brown/rock
# Index 2: medium brown
# Index 3: light brown highlight
PALETTE = [
    0x00, 0x00, 0x00,  # 0: black
    0x40, 0x30, 0x20,  # 1: dark brown
    0x70, 0x50, 0x30,  # 2: medium brown
    0xA0, 0x80, 0x60,  # 3: light brown
]

# 16 columns x 4 rows = 64 tiles
WIDTH = 128
HEIGHT = 32

img = Image.new('P', (WIDTH, HEIGHT))
img.putpalette(PALETTE + [0] * 756)

def set_tile_pixel(col, row, x, y, color):
    img.putpixel((col * 8 + x, row * 8 + y), color)

def fill_tile(col, row, color):
    for y in range(8):
        for x in range(8):
            set_tile_pixel(col, row, x, y, color)

def draw_tile(col, row, pattern):
    for y in range(8):
        for x in range(8):
            c = pattern[y][x]
            color = int(c) if c.isdigit() else 0
            set_tile_pixel(col, row, x, y, color)

# Tile 0: Empty/dark
fill_tile(0, 0, 0)

# Tiles 1-4: Cave floor
cave_floor = [
    "00000000",
    "00100000",
    "00000010",
    "00000000",
    "01000000",
    "00000001",
    "00000000",
    "00010000",
]
draw_tile(1, 0, cave_floor)

# Tiles 2-9: Rock wall sections
rock_wall_1 = [
    "11111111",
    "12222211",
    "12233221",
    "12222211",
    "12223221",
    "12222211",
    "12222111",
    "11111111",
]
draw_tile(2, 0, rock_wall_1)

rock_wall_2 = [
    "11111111",
    "11222221",
    "12232221",
    "12222321",
    "12232221",
    "11222221",
    "11122211",
    "11111111",
]
draw_tile(3, 0, rock_wall_2)

rock_wall_rough = [
    "11211121",
    "12222221",
    "22332222",
    "22222322",
    "12323221",
    "12222221",
    "11222211",
    "11111211",
]
draw_tile(4, 0, rock_wall_rough)

# Cave wall edges
cave_wall_n = [
    "11111111",
    "12222221",
    "12332221",
    "12222211",
    "12222111",
    "12221111",
    "12211111",
    "12111122",
]
draw_tile(5, 0, cave_wall_n)

cave_wall_s = [
    "12111122",
    "12211111",
    "12221111",
    "12222111",
    "12222211",
    "12332221",
    "12222221",
    "11111111",
]
draw_tile(6, 0, cave_wall_s)

cave_wall_w = [
    "11122222",
    "12222222",
    "12322222",
    "12222222",
    "12222222",
    "12322222",
    "12222222",
    "11122222",
]
draw_tile(7, 0, cave_wall_w)

cave_wall_e = [
    "22222211",
    "22222221",
    "22222321",
    "22222221",
    "22222221",
    "22222321",
    "22222221",
    "22222211",
]
draw_tile(8, 0, cave_wall_e)

# Tiles 10-13: Stalactites (hanging from ceiling)
stalactite_1 = [
    "00011100",
    "00122210",
    "00122210",
    "00122210",
    "00012100",
    "00001000",
    "00000000",
    "00000000",
]
draw_tile(9, 0, stalactite_1)

stalactite_2 = [
    "01111110",
    "12222221",
    "12222221",
    "01222210",
    "00122100",
    "00012100",
    "00001000",
    "00000000",
]
draw_tile(10, 0, stalactite_2)

# Tiles 14-17: Stalagmites (rising from floor)
stalagmite_1 = [
    "00000000",
    "00000000",
    "00001000",
    "00012100",
    "00122210",
    "00122210",
    "00122210",
    "00011100",
]
draw_tile(11, 0, stalagmite_1)

stalagmite_2 = [
    "00000000",
    "00001000",
    "00012100",
    "00122100",
    "01222210",
    "12222221",
    "12222221",
    "01111110",
]
draw_tile(12, 0, stalagmite_2)

# Tiles 18-21: Underground water
cave_water = [
    "11111111",
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "11222211",
    "11111111",
    "11111111",
]
draw_tile(13, 0, cave_water)

cave_water_edge_n = [
    "11111111",
    "00000000",
    "00000000",
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "11222211",
]
draw_tile(14, 0, cave_water_edge_n)

cave_water_edge_s = [
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "11222211",
    "00000000",
    "00000000",
    "11111111",
]
draw_tile(15, 0, cave_water_edge_s)

# Row 1: Lava tiles for Death Mountain
lava_1 = [
    "33333333",
    "33222233",
    "32111123",
    "32111123",
    "32222223",
    "33222233",
    "33333333",
    "33333333",
]
draw_tile(0, 1, lava_1)

lava_2 = [
    "33333333",
    "32222223",
    "21111112",
    "21133112",
    "22122222",
    "32222223",
    "33333333",
    "33333333",
]
draw_tile(1, 1, lava_2)

lava_edge_n = [
    "22222222",
    "11111111",
    "33333333",
    "32222223",
    "21111112",
    "21111112",
    "22222222",
    "32222223",
]
draw_tile(2, 1, lava_edge_n)

lava_edge_s = [
    "32222223",
    "22222222",
    "21111112",
    "21111112",
    "32222223",
    "33333333",
    "11111111",
    "22222222",
]
draw_tile(3, 1, lava_edge_s)

# Tiles for cave entrance/exit areas
cave_entrance_floor = [
    "11111111",
    "11111111",
    "11111111",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
]
draw_tile(4, 1, cave_entrance_floor)

# Rock formations (2x2 large rock)
rock_tl = [
    "00011111",
    "00122221",
    "01222211",
    "12222111",
    "12221111",
    "12211111",
    "12211111",
    "12111111",
]
draw_tile(5, 1, rock_tl)

rock_tr = [
    "11111000",
    "12222100",
    "11222210",
    "11122221",
    "11112221",
    "11111221",
    "11111221",
    "11111121",
]
draw_tile(6, 1, rock_tr)

rock_bl = [
    "12211111",
    "12221111",
    "01222111",
    "01122211",
    "00112221",
    "00011221",
    "00001111",
    "00000000",
]
draw_tile(7, 1, rock_bl)

rock_br = [
    "11111221",
    "11112221",
    "11122210",
    "11222100",
    "12221100",
    "12211000",
    "11110000",
    "00000000",
]
draw_tile(8, 1, rock_br)

# Cave corners
cave_corner_nw = [
    "11111111",
    "12222221",
    "12332221",
    "12222111",
    "12211111",
    "12111111",
    "11112222",
    "11122222",
]
draw_tile(9, 1, cave_corner_nw)

cave_corner_ne = [
    "11111111",
    "12222221",
    "12232321",
    "11122221",
    "11111221",
    "11111121",
    "22221111",
    "22221111",
]
draw_tile(10, 1, cave_corner_ne)

cave_corner_sw = [
    "11122222",
    "12111122",
    "12211112",
    "12222111",
    "12232211",
    "12222221",
    "12222221",
    "11111111",
]
draw_tile(11, 1, cave_corner_sw)

cave_corner_se = [
    "22221111",
    "22111121",
    "21111221",
    "11122221",
    "11232221",
    "12222221",
    "12222221",
    "11111111",
]
draw_tile(12, 1, cave_corner_se)

# Additional decorative elements
crack_pattern = [
    "00000000",
    "00001000",
    "00011000",
    "00010000",
    "00010000",
    "00100000",
    "01000000",
    "00000000",
]
draw_tile(13, 1, crack_pattern)

# Small decorations
pebble_1 = [
    "00000000",
    "00000000",
    "00001100",
    "00012210",
    "00012210",
    "00001100",
    "00000000",
    "00000000",
]
draw_tile(14, 1, pebble_1)

pebble_2 = [
    "00000000",
    "00011000",
    "00121100",
    "00122110",
    "00012210",
    "00001100",
    "00000000",
    "00000000",
]
draw_tile(15, 1, pebble_2)

print("Cave tileset created: 64 tiles")
img.save('/Users/jschmidt/lab/hub/.hub-data/projects/a79ec915-7144-4467-8392-2d2c0af9a18e/workspaces/0a7ebf0c-38ed-41c6-a0d0-3b3d580abd60/zelda2b/assets/tilesets/cave.png')
print("Saved to assets/tilesets/cave.png")
