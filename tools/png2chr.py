#!/usr/bin/env python3
"""
png2chr.py — Convert indexed PNG images to NES CHR format.

NES CHR tiles are 8x8 pixels, 2 bits per pixel (4 colors).
Each tile = 16 bytes: 8 bytes for bit-plane 0, then 8 bytes for bit-plane 1.

Input:  An indexed-color PNG (palette indices 0-3 per pixel).
        Width must be a multiple of 8. Height must be a multiple of 8.
        Tiles are read left-to-right, top-to-bottom in 8x8 chunks.

Output: Raw CHR binary data. Each tile = 16 bytes.

Usage:
  python3 png2chr.py input.png output.chr
  python3 png2chr.py input.png output.chr --pad 1024
      (pad output to a multiple of 1024 bytes = 1 CHR bank)
"""

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow is required. Install with: pip3 install Pillow", file=sys.stderr)
    sys.exit(1)


def png_to_chr(img: Image.Image) -> bytes:
    """Convert an indexed PNG image to NES CHR data."""
    if img.mode != "P":
        # Try to convert — if it's RGBA with <= 4 colors, quantize
        if img.mode in ("RGBA", "RGB", "L"):
            img = img.quantize(colors=4, method=Image.Quantize.MEDIANCUT)
        else:
            raise ValueError(f"Unsupported image mode: {img.mode}. Need indexed (P) PNG.")

    w, h = img.size
    if w % 8 != 0 or h % 8 != 0:
        raise ValueError(f"Image dimensions {w}x{h} must be multiples of 8.")

    # Use get_flattened_data if available (Pillow 14+), else fall back
    if hasattr(img, 'get_flattened_data'):
        pixels = list(img.get_flattened_data())
    else:
        pixels = list(img.getdata())
    chr_data = bytearray()

    tiles_x = w // 8
    tiles_y = h // 8

    for ty in range(tiles_y):
        for tx in range(tiles_x):
            plane0 = bytearray(8)
            plane1 = bytearray(8)
            for row in range(8):
                for col in range(8):
                    px = pixels[(ty * 8 + row) * w + (tx * 8 + col)]
                    if px > 3:
                        px = px & 0x03  # Clamp to 2-bit
                    bit = 7 - col
                    if px & 1:
                        plane0[row] |= (1 << bit)
                    if px & 2:
                        plane1[row] |= (1 << bit)
            chr_data.extend(plane0)
            chr_data.extend(plane1)

    return bytes(chr_data)


def main():
    parser = argparse.ArgumentParser(description="Convert indexed PNG to NES CHR format")
    parser.add_argument("input", help="Input PNG file (indexed, palette indices 0-3)")
    parser.add_argument("output", help="Output CHR file")
    parser.add_argument("--pad", type=int, default=0,
                        help="Pad output to multiple of N bytes (e.g., 1024 for 1 CHR bank)")
    args = parser.parse_args()

    img = Image.open(args.input)
    chr_data = png_to_chr(img)

    if args.pad > 0:
        remainder = len(chr_data) % args.pad
        if remainder != 0:
            chr_data += b'\x00' * (args.pad - remainder)

    Path(args.output).write_bytes(chr_data)
    tile_count = len(chr_data) // 16
    bank_count = len(chr_data) / 1024
    print(f"OK: {tile_count} tiles, {len(chr_data)} bytes ({bank_count:.1f} CHR banks)")


if __name__ == "__main__":
    main()
