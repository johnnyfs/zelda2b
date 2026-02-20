#!/usr/bin/env python3
"""
chr2png.py — Render NES CHR data as a PNG image for visual review.

Each CHR tile is 8x8 pixels, 2 bits per pixel (16 bytes per tile).
Output is an indexed PNG with a configurable NES-style palette.

Usage:
  python3 chr2png.py input.chr output.png
  python3 chr2png.py input.chr output.png --cols 16 --scale 2
  python3 chr2png.py input.chr output.png --palette "#000000,#555555,#aaaaaa,#ffffff"
"""

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow is required. Install with: pip3 install Pillow", file=sys.stderr)
    sys.exit(1)


# Default NES-ish grayscale palette for review
DEFAULT_PALETTE = [(0, 0, 0), (85, 85, 85), (170, 170, 170), (255, 255, 255)]

# Full NES palette (64 colors) for reference when rendering with real palettes
NES_PALETTE = [
    (84, 84, 84), (0, 30, 116), (8, 16, 144), (48, 0, 136),
    (68, 0, 100), (92, 0, 48), (84, 4, 0), (60, 24, 0),
    (32, 42, 0), (8, 58, 0), (0, 64, 0), (0, 60, 0),
    (0, 50, 60), (0, 0, 0), (0, 0, 0), (0, 0, 0),
    (152, 150, 152), (8, 76, 196), (48, 50, 236), (92, 30, 228),
    (136, 20, 176), (160, 20, 100), (152, 34, 32), (120, 60, 0),
    (84, 90, 0), (40, 114, 0), (8, 124, 0), (0, 118, 40),
    (0, 102, 120), (0, 0, 0), (0, 0, 0), (0, 0, 0),
    (236, 238, 236), (76, 154, 236), (120, 124, 236), (176, 98, 236),
    (228, 84, 236), (236, 88, 180), (236, 106, 100), (212, 136, 32),
    (160, 170, 0), (116, 196, 0), (76, 208, 32), (56, 204, 108),
    (56, 180, 204), (60, 60, 60), (0, 0, 0), (0, 0, 0),
    (236, 238, 236), (168, 204, 236), (188, 188, 236), (212, 178, 236),
    (236, 174, 236), (236, 174, 212), (236, 180, 176), (228, 196, 144),
    (204, 210, 120), (180, 222, 120), (168, 226, 144), (152, 226, 180),
    (160, 214, 228), (160, 162, 160), (0, 0, 0), (0, 0, 0),
]


def parse_palette(palette_str: str) -> list:
    """Parse a comma-separated list of hex colors."""
    colors = []
    for c in palette_str.split(","):
        c = c.strip().lstrip("#")
        if len(c) == 6:
            colors.append((int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16)))
        else:
            raise ValueError(f"Invalid color: {c}")
    return colors


def chr_to_pixels(chr_data: bytes) -> list:
    """Decode CHR data into a list of tiles, each tile = 8x8 array of palette indices (0-3)."""
    tiles = []
    num_tiles = len(chr_data) // 16
    for t in range(num_tiles):
        offset = t * 16
        tile = []
        for row in range(8):
            row_pixels = []
            byte0 = chr_data[offset + row]
            byte1 = chr_data[offset + 8 + row]
            for col in range(8):
                bit = 7 - col
                val = ((byte0 >> bit) & 1) | (((byte1 >> bit) & 1) << 1)
                row_pixels.append(val)
            tile.append(row_pixels)
        tiles.append(tile)
    return tiles


def render_chr(chr_data: bytes, cols: int = 16, scale: int = 1,
               palette: list = None) -> Image.Image:
    """Render CHR data as a PIL Image."""
    if palette is None:
        palette = DEFAULT_PALETTE

    tiles = chr_to_pixels(chr_data)
    if not tiles:
        raise ValueError("No tiles found in CHR data.")

    num_tiles = len(tiles)
    rows = (num_tiles + cols - 1) // cols

    img_w = cols * 8 * scale
    img_h = rows * 8 * scale
    img = Image.new("RGB", (img_w, img_h), palette[0])

    for idx, tile in enumerate(tiles):
        tx = (idx % cols) * 8
        ty = (idx // cols) * 8
        for r in range(8):
            for c in range(8):
                color = palette[tile[r][c]]
                for sy in range(scale):
                    for sx in range(scale):
                        img.putpixel((
                            (tx + c) * scale + sx,
                            (ty + r) * scale + sy
                        ), color)

    return img


def main():
    parser = argparse.ArgumentParser(description="Render NES CHR data as PNG")
    parser.add_argument("input", help="Input CHR file")
    parser.add_argument("output", help="Output PNG file")
    parser.add_argument("--cols", type=int, default=16,
                        help="Number of tile columns in output (default: 16)")
    parser.add_argument("--scale", type=int, default=2,
                        help="Pixel scale factor (default: 2)")
    parser.add_argument("--palette", type=str, default=None,
                        help="4 hex colors, comma-separated (e.g., '#000,#555,#aaa,#fff')")
    parser.add_argument("--nes-palette", type=str, default=None,
                        help="4 NES palette indices, comma-separated (e.g., '0x0F,0x00,0x10,0x30')")
    args = parser.parse_args()

    chr_data = Path(args.input).read_bytes()
    if len(chr_data) < 16:
        print(f"ERROR: CHR file too small ({len(chr_data)} bytes, need at least 16)", file=sys.stderr)
        sys.exit(1)

    palette = DEFAULT_PALETTE
    if args.palette:
        palette = parse_palette(args.palette)
    elif args.nes_palette:
        indices = [int(x.strip(), 0) for x in args.nes_palette.split(",")]
        palette = [NES_PALETTE[i & 0x3F] for i in indices]

    img = render_chr(chr_data, cols=args.cols, scale=args.scale, palette=palette)
    img.save(args.output)

    num_tiles = len(chr_data) // 16
    print(f"OK: Rendered {num_tiles} tiles to {args.output} ({img.size[0]}x{img.size[1]})")


if __name__ == "__main__":
    main()
