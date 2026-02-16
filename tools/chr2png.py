#!/usr/bin/env python3
"""
chr2png.py - Convert NES CHR tile data back to indexed-color PNG.

This is the reverse of png2chr.py, used for verification and preview.

NES CHR format:
  Each 8x8 tile is 16 bytes:
    Bytes 0-7:  Bit plane 0 (low bit of each pixel)
    Bytes 8-15: Bit plane 1 (high bit of each pixel)
  Pixel value = (plane1_bit << 1) | plane0_bit, giving values 0-3.

Output:
  Indexed-color PNG with 4 palette entries.
  Tiles arranged in a grid (default 16 tiles wide, like NES CHR layout).

Usage:
  python3 chr2png.py input.chr output.png
  python3 chr2png.py input.chr output.png --columns 16
  python3 chr2png.py input.chr output.png --palette 0F,29,19,09
  python3 chr2png.py input.chr output.png --scale 4
"""

import argparse
import os
import struct
import sys

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow is required. Install with: pip3 install Pillow", file=sys.stderr)
    sys.exit(1)


# NES master palette (NTSC) - 64 entries, RGB values
# Based on the commonly used "2C02" palette
NES_PALETTE = [
    (0x62, 0x62, 0x62), (0x00, 0x2E, 0x98), (0x11, 0x13, 0xB1), (0x3A, 0x00, 0xA4),
    (0x5C, 0x00, 0x7E), (0x6E, 0x00, 0x40), (0x6C, 0x07, 0x00), (0x56, 0x1D, 0x00),
    (0x33, 0x35, 0x00), (0x0B, 0x48, 0x00), (0x00, 0x52, 0x00), (0x00, 0x4F, 0x08),
    (0x00, 0x40, 0x4D), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xAB, 0xAB, 0xAB), (0x0D, 0x57, 0xFF), (0x35, 0x36, 0xFF), (0x6B, 0x1C, 0xFF),
    (0x98, 0x0B, 0xD5), (0xAF, 0x0D, 0x7B), (0xAD, 0x25, 0x21), (0x90, 0x44, 0x00),
    (0x64, 0x62, 0x00), (0x31, 0x78, 0x00), (0x08, 0x82, 0x00), (0x00, 0x7F, 0x2A),
    (0x00, 0x6E, 0x82), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xFF, 0xFF, 0xFF), (0x53, 0xAE, 0xFF), (0x79, 0x8D, 0xFF), (0xB4, 0x74, 0xFF),
    (0xE4, 0x6F, 0xFF), (0xF8, 0x6C, 0xCF), (0xF8, 0x7F, 0x77), (0xDD, 0x9C, 0x35),
    (0xB1, 0xB5, 0x0C), (0x7F, 0xCA, 0x1C), (0x56, 0xD4, 0x45), (0x40, 0xD0, 0x7D),
    (0x41, 0xC1, 0xCF), (0x4E, 0x4E, 0x4E), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
    (0xFF, 0xFF, 0xFF), (0xB6, 0xDB, 0xFF), (0xC5, 0xCB, 0xFF), (0xDA, 0xC2, 0xFF),
    (0xF0, 0xC0, 0xFF), (0xFA, 0xBF, 0xEB), (0xFA, 0xC7, 0xC3), (0xEF, 0xD4, 0xA5),
    (0xDF, 0xDE, 0x96), (0xCA, 0xE7, 0x9B), (0xB7, 0xEB, 0xAF), (0xAE, 0xEA, 0xC9),
    (0xAF, 0xE3, 0xEA), (0xB5, 0xB5, 0xB5), (0x00, 0x00, 0x00), (0x00, 0x00, 0x00),
]


def chr_tile_to_pixels(data):
    """Convert 16 bytes of CHR data to an 8x8 grid of pixel values (0-3).

    Args:
        data: 16 bytes of CHR tile data.

    Returns:
        list of 8 rows, each row is a list of 8 ints (0-3).
    """
    assert len(data) == 16, f"Expected 16 bytes, got {len(data)}"
    pixels = []
    for y in range(8):
        row = []
        b0 = data[y]       # plane 0
        b1 = data[y + 8]   # plane 1
        for x in range(8):
            bit = 7 - x
            p0 = (b0 >> bit) & 1
            p1 = (b1 >> bit) & 1
            row.append((p1 << 1) | p0)
        pixels.append(row)
    return pixels


def parse_nes_palette(palette_str):
    """Parse a comma-separated list of NES palette indices (hex).

    Args:
        palette_str: e.g. "0F,29,19,09"

    Returns:
        list of 4 (R, G, B) tuples.
    """
    parts = palette_str.split(',')
    if len(parts) != 4:
        raise ValueError(f"Palette must have exactly 4 entries, got {len(parts)}")
    colors = []
    for p in parts:
        idx = int(p.strip(), 16)
        if idx < 0 or idx > 0x3F:
            raise ValueError(f"Palette index {p} out of range (00-3F)")
        colors.append(NES_PALETTE[idx])
    return colors


def chr_to_image(chr_data, columns=16, palette_colors=None, scale=1):
    """Convert CHR binary data to a PIL Image.

    Args:
        chr_data: bytes of CHR data (must be multiple of 16).
        columns: number of tiles per row in output image.
        palette_colors: list of 4 (R,G,B) tuples. If None, uses grayscale.
        scale: integer scale factor for output.

    Returns:
        PIL.Image in RGB mode.
    """
    if len(chr_data) % 16 != 0:
        raise ValueError(f"CHR data size {len(chr_data)} is not a multiple of 16")

    num_tiles = len(chr_data) // 16
    if num_tiles == 0:
        raise ValueError("CHR data is empty")

    rows = (num_tiles + columns - 1) // columns
    img_w = columns * 8
    img_h = rows * 8

    if palette_colors is None:
        # Default grayscale
        palette_colors = [(0, 0, 0), (85, 85, 85), (170, 170, 170), (255, 255, 255)]

    # Create indexed image
    img = Image.new('P', (img_w, img_h), 0)

    # Set palette
    flat_palette = []
    for r, g, b in palette_colors:
        flat_palette.extend([r, g, b])
    # Pad to 256 entries
    flat_palette.extend([0, 0, 0] * (256 - len(palette_colors)))
    img.putpalette(flat_palette)

    # Fill in tiles
    pixels = img.load()
    for tile_idx in range(num_tiles):
        tx = tile_idx % columns
        ty = tile_idx // columns
        offset = tile_idx * 16
        tile_data = chr_data[offset:offset + 16]
        tile_pixels = chr_tile_to_pixels(tile_data)

        for y in range(8):
            for x in range(8):
                px_x = tx * 8 + x
                px_y = ty * 8 + y
                pixels[px_x, px_y] = tile_pixels[y][x]

    # Convert to RGB for display
    rgb_img = img.convert('RGB')

    if scale > 1:
        rgb_img = rgb_img.resize(
            (img_w * scale, img_h * scale),
            Image.NEAREST
        )

    return rgb_img, img  # return both RGB and indexed


def main():
    parser = argparse.ArgumentParser(
        description="Convert NES CHR tile data to PNG image."
    )
    parser.add_argument("input", help="Input .chr file")
    parser.add_argument("output", help="Output .png file")
    parser.add_argument("--columns", type=int, default=16,
                        help="Tiles per row in output (default: 16)")
    parser.add_argument("--palette", type=str, default=None,
                        help="NES palette as 4 hex values, e.g. '0F,29,19,09'")
    parser.add_argument("--scale", type=int, default=1,
                        help="Scale factor for output (default: 1)")
    parser.add_argument("--indexed", action="store_true",
                        help="Output as indexed-color PNG (palette mode)")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"ERROR: File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    with open(args.input, 'rb') as f:
        chr_data = f.read()

    if len(chr_data) == 0:
        print("ERROR: CHR file is empty", file=sys.stderr)
        sys.exit(1)

    if len(chr_data) % 16 != 0:
        print(f"WARNING: CHR file size {len(chr_data)} is not a multiple of 16",
              file=sys.stderr)
        # Truncate to valid tile boundary
        chr_data = chr_data[:len(chr_data) // 16 * 16]

    num_tiles = len(chr_data) // 16
    print(f"Input: {args.input} ({num_tiles} tiles, {len(chr_data)} bytes)")

    palette_colors = None
    if args.palette:
        palette_colors = parse_nes_palette(args.palette)

    rgb_img, indexed_img = chr_to_image(
        chr_data,
        columns=args.columns,
        palette_colors=palette_colors,
        scale=args.scale
    )

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)

    if args.indexed and args.scale == 1:
        indexed_img.save(args.output)
    else:
        rgb_img.save(args.output)

    print(f"Output: {args.output} ({rgb_img.size[0]}x{rgb_img.size[1]})")


if __name__ == "__main__":
    main()
