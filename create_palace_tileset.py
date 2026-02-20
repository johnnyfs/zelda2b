#!/usr/bin/env python3
"""
Generate NES palace/dungeon tileset PNG for Zelda 2B.
Style inspired by Zelda 1 dungeons and Link's Awakening dungeons.
"""

from PIL import Image

# NES palette for palace (example)
# Index 0: black/dark background
# Index 1: dark stone
# Index 2: medium stone
# Index 3: light highlight
PALETTE = [
    0x10, 0x10, 0x10,  # 0: dark background
    0x50, 0x50, 0x60,  # 1: dark blue-gray stone
    0x88, 0x88, 0xA0,  # 2: medium stone
    0xD0, 0xD0, 0xE0,  # 3: light highlight
]

# 16 columns x 8 rows = 128 tiles (half bank)
WIDTH = 128
HEIGHT = 64

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

# Tile 0: Empty floor (dark)
fill_tile(0, 0, 0)

# Tiles 1-4: Floor variations
floor_plain = [
    "00000000",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
    "00000000",
]
draw_tile(1, 0, floor_plain)

floor_cracked = [
    "00000000",
    "00010000",
    "00001000",
    "00000000",
    "00000100",
    "00001000",
    "00000000",
    "00000000",
]
draw_tile(2, 0, floor_cracked)

floor_pattern = [
    "11111111",
    "12222221",
    "12000021",
    "12000021",
    "12000021",
    "12000021",
    "12222221",
    "11111111",
]
draw_tile(3, 0, floor_pattern)

# Tiles 4-19: Wall sections (north, south, east, west, corners)
# Wall top edge
wall_n = [
    "11111111",
    "12222221",
    "12333321",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
]
draw_tile(4, 0, wall_n)

# Wall bottom edge
wall_s = [
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12333321",
    "12222221",
    "11111111",
]
draw_tile(5, 0, wall_s)

# Wall left edge
wall_w = [
    "11122222",
    "12222222",
    "12322222",
    "12222222",
    "12222222",
    "12322222",
    "12222222",
    "11122222",
]
draw_tile(6, 0, wall_w)

# Wall right edge
wall_e = [
    "22222211",
    "22222221",
    "22222321",
    "22222221",
    "22222221",
    "22222321",
    "22222221",
    "22222211",
]
draw_tile(7, 0, wall_e)

# Wall solid middle
wall_solid = [
    "12222221",
    "12222221",
    "12322221",
    "12222221",
    "12222221",
    "12322221",
    "12222221",
    "12222221",
]
draw_tile(8, 0, wall_solid)

# Corner tiles
wall_corner_nw = [
    "11111111",
    "12222221",
    "12333321",
    "12222221",
    "12222221",
    "12322221",
    "12222221",
    "11122222",
]
draw_tile(9, 0, wall_corner_nw)

wall_corner_ne = [
    "11111111",
    "12222221",
    "12333321",
    "12222221",
    "12222221",
    "12222321",
    "12222221",
    "22222211",
]
draw_tile(10, 0, wall_corner_ne)

wall_corner_sw = [
    "11122222",
    "12222221",
    "12322221",
    "12222221",
    "12222221",
    "12333321",
    "12222221",
    "11111111",
]
draw_tile(11, 0, wall_corner_sw)

wall_corner_se = [
    "22222211",
    "12222221",
    "12222321",
    "12222221",
    "12222221",
    "12333321",
    "12222221",
    "11111111",
]
draw_tile(12, 0, wall_corner_se)

# Tiles 13-15: Decorative wall patterns
wall_brick = [
    "11121112",
    "22222222",
    "21211212",
    "22222222",
    "11121112",
    "22222222",
    "21211212",
    "22222222",
]
draw_tile(13, 0, wall_brick)

# Tiles 16-19: Door (closed, open, locked, key door)
door_closed = [
    "11111111",
    "12222221",
    "12333321",
    "12322321",
    "12323321",
    "12322321",
    "12222221",
    "11111111",
]
draw_tile(0, 1, door_closed)

door_open = [
    "11111111",
    "12000021",
    "12000021",
    "12000021",
    "12000021",
    "12000021",
    "12000021",
    "11111111",
]
draw_tile(1, 1, door_open)

door_locked = [
    "11111111",
    "12222221",
    "12333321",
    "12323321",
    "12333321",
    "12323321",
    "12222221",
    "11111111",
]
draw_tile(2, 1, door_locked)

door_key = [
    "11111111",
    "12222221",
    "12333321",
    "12320321",
    "12323321",
    "12320321",
    "12222221",
    "11111111",
]
draw_tile(3, 1, door_key)

# Tiles 20-23: Columns/pillars (2x2)
pillar_tl = [
    "00111100",
    "01222210",
    "12222221",
    "12333321",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
]
draw_tile(4, 1, pillar_tl)

pillar_tr = [
    "00111100",
    "01222210",
    "12222221",
    "12333321",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
]
draw_tile(5, 1, pillar_tr)

pillar_bl = [
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "01222210",
    "00111100",
    "00000000",
]
draw_tile(6, 1, pillar_bl)

pillar_br = [
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "01222210",
    "00111100",
    "00000000",
]
draw_tile(7, 1, pillar_br)

# Tiles 24-27: Stairs
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
draw_tile(8, 1, stairs_up)

stairs_down = [
    "11111112",
    "11111122",
    "11111222",
    "11112222",
    "11122222",
    "11222222",
    "12222222",
    "22222222",
]
draw_tile(9, 1, stairs_down)

# Tiles 28-31: Pit/hole (2x2)
pit_tl = [
    "00000000",
    "00000000",
    "00011111",
    "00122222",
    "01222222",
    "12222222",
    "12222222",
    "12222222",
]
draw_tile(10, 1, pit_tl)

pit_tr = [
    "00000000",
    "00000000",
    "11111000",
    "22222100",
    "22222210",
    "22222221",
    "22222221",
    "22222221",
]
draw_tile(11, 1, pit_tr)

pit_bl = [
    "12222222",
    "12222222",
    "01222222",
    "00122222",
    "00011111",
    "00000000",
    "00000000",
    "00000000",
]
draw_tile(12, 1, pit_bl)

pit_br = [
    "22222221",
    "22222221",
    "22222210",
    "22222100",
    "11111000",
    "00000000",
    "00000000",
    "00000000",
]
draw_tile(13, 1, pit_br)

# Tiles 32-35: Torch/brazier
torch_off = [
    "00011000",
    "00011000",
    "00122100",
    "01222210",
    "12222221",
    "12222221",
    "01222210",
    "00111100",
]
draw_tile(14, 1, torch_off)

torch_on_1 = [
    "00033000",
    "00333300",
    "00122100",
    "01222210",
    "12222221",
    "12222221",
    "01222210",
    "00111100",
]
draw_tile(15, 1, torch_on_1)

# Tiles 36-39: Statue/decoration (2x2)
statue_tl = [
    "00111100",
    "01233210",
    "12233221",
    "12333321",
    "12233221",
    "12222221",
    "12222221",
    "12222221",
]
draw_tile(0, 2, statue_tl)

statue_tr = [
    "00111100",
    "01233210",
    "12233221",
    "12333321",
    "12233221",
    "12222221",
    "12222221",
    "12222221",
]
draw_tile(1, 2, statue_tr)

statue_bl = [
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "11222211",
    "00111100",
]
draw_tile(2, 2, statue_bl)

statue_br = [
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "12222221",
    "11222211",
    "00111100",
]
draw_tile(3, 2, statue_br)

# Tiles 40-43: Treasure chest (2x1, closed and open)
chest_closed_l = [
    "00000000",
    "00111111",
    "01223333",
    "12222222",
    "12222222",
    "12222222",
    "11111111",
    "00000000",
]
draw_tile(4, 2, chest_closed_l)

chest_closed_r = [
    "00000000",
    "11111100",
    "33332210",
    "22222221",
    "22222221",
    "22222221",
    "11111111",
    "00000000",
]
draw_tile(5, 2, chest_closed_r)

chest_open_l = [
    "00111111",
    "01223333",
    "01200003",
    "12200002",
    "12200002",
    "12222222",
    "11111111",
    "00000000",
]
draw_tile(6, 2, chest_open_l)

chest_open_r = [
    "11111100",
    "33332210",
    "30000210",
    "20000221",
    "20000221",
    "22222221",
    "11111111",
    "00000000",
]
draw_tile(7, 2, chest_open_r)

# Tiles 44-47: Pushable block
block_push = [
    "11111111",
    "12222221",
    "12333321",
    "12322321",
    "12323321",
    "12322321",
    "12222221",
    "11111111",
]
draw_tile(8, 2, block_push)

# Tiles 48-55: Water/lava for special rooms
water_dungeon = [
    "11111111",
    "11222211",
    "12233221",
    "12233221",
    "12222221",
    "11222211",
    "11111111",
    "11111111",
]
draw_tile(9, 2, water_dungeon)

lava = [
    "33333333",
    "32222223",
    "22111122",
    "22111122",
    "22222222",
    "32222223",
    "33333333",
    "33333333",
]
draw_tile(10, 2, lava)

# Tiles 56-63: Decorative floor tiles
floor_decor_1 = [
    "00000000",
    "00111100",
    "01222210",
    "01233210",
    "01233210",
    "01222210",
    "00111100",
    "00000000",
]
draw_tile(11, 2, floor_decor_1)

floor_decor_2 = [
    "00100100",
    "01211210",
    "12222221",
    "02222220",
    "02222220",
    "12222221",
    "01211210",
    "00100100",
]
draw_tile(12, 2, floor_decor_2)

# Fill remaining space with useful variations
print("Palace tileset created: 128 tiles")
img.save('/Users/jschmidt/lab/hub/.hub-data/projects/a79ec915-7144-4467-8392-2d2c0af9a18e/workspaces/0a7ebf0c-38ed-41c6-a0d0-3b3d580abd60/zelda2b/assets/tilesets/palace.png')
print("Saved to assets/tilesets/palace.png")
