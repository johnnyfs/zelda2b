#!/usr/bin/env python3
"""Merge HUD tiles from hud.chr into bg_tiles.chr at offset $20 (tile 32).

HUD tiles from hud.chr:
  Index 9 ($09) = Heart Full   -> BG tile $20
  Index 10 ($0A) = Heart Empty -> BG tile $21
  Index 11 ($0B) = Magic Full  -> BG tile $22
  Index 12 ($0C) = Magic Empty -> BG tile $23
  Index 3 ($03) = Box TL       -> BG tile $24
  Index 4 ($04) = Box TR       -> BG tile $25
  Index 5 ($05) = Box BL       -> BG tile $26
  Index 6 ($06) = Box BR       -> BG tile $27
  Index 1 ($01) = Button A     -> BG tile $28
  Index 2 ($02) = Button B     -> BG tile $29

Each CHR tile is 16 bytes (8 bytes plane 0 + 8 bytes plane 1).
"""

import sys
import os

TILE_SIZE = 16  # bytes per tile

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    assets_dir = os.path.join(script_dir, '..', 'assets', 'chr')

    bg_path = os.path.join(assets_dir, 'bg_tiles.chr')
    hud_path = os.path.join(assets_dir, 'hud.chr')

    with open(bg_path, 'rb') as f:
        bg_data = bytearray(f.read())

    with open(hud_path, 'rb') as f:
        hud_data = bytearray(f.read())

    # Ensure bg_data is 4KB (256 tiles)
    if len(bg_data) < 4096:
        bg_data.extend(b'\x00' * (4096 - len(bg_data)))

    # Map: (hud_src_index, bg_dest_index)
    tile_map = [
        (9,  0x20),  # Heart Full
        (10, 0x21),  # Heart Empty
        (11, 0x22),  # Magic Full
        (12, 0x23),  # Magic Empty
        (3,  0x24),  # Box TL
        (4,  0x25),  # Box TR
        (5,  0x26),  # Box BL
        (6,  0x27),  # Box BR
        (1,  0x28),  # Button A
        (2,  0x29),  # Button B
    ]

    for src_idx, dst_idx in tile_map:
        src_offset = src_idx * TILE_SIZE
        dst_offset = dst_idx * TILE_SIZE
        bg_data[dst_offset:dst_offset + TILE_SIZE] = hud_data[src_offset:src_offset + TILE_SIZE]
        print(f"  Copied HUD tile {src_idx:3d} (${src_idx:02X}) -> BG tile {dst_idx:3d} (${dst_idx:02X})")

    with open(bg_path, 'wb') as f:
        f.write(bg_data)

    print(f"\nWrote {len(bg_data)} bytes to {bg_path}")

if __name__ == '__main__':
    main()
