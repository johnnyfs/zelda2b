#!/usr/bin/env python3
"""
png2chr.py - Convert indexed-color PNG images to NES CHR format.

NES CHR format:
  Each 8x8 tile is 16 bytes:
    Bytes 0-7:  Bit plane 0 (low bit of each pixel, one byte per row)
    Bytes 8-15: Bit plane 1 (high bit of each pixel, one byte per row)
  Pixel value = (plane1_bit << 1) | plane0_bit, giving values 0-3.

Input:
  An indexed-color PNG with exactly 4 palette entries (indices 0-3).
  Tiles are read left-to-right, top-to-bottom in 8x8 pixel blocks.
  Image width and height must be multiples of 8.

Output:
  Binary .chr file with 16 bytes per tile.

Usage:
  python3 png2chr.py input.png output.chr
  python3 png2chr.py --validate input.png       # validate only, no output
  python3 png2chr.py --info input.png            # show tile count and dimensions
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


def pixels_to_chr_tile(pixels):
    """Convert an 8x8 grid of pixel values (0-3) to 16 bytes of NES CHR data.

    Args:
        pixels: list of 8 rows, each row is a list/tuple of 8 ints (0-3).

    Returns:
        bytes: 16 bytes of CHR tile data.
    """
    assert len(pixels) == 8, f"Expected 8 rows, got {len(pixels)}"
    plane0 = bytearray(8)
    plane1 = bytearray(8)
    for y in range(8):
        row = pixels[y]
        assert len(row) == 8, f"Row {y}: expected 8 pixels, got {len(row)}"
        b0 = 0
        b1 = 0
        for x in range(8):
            px = row[x]
            if px < 0 or px > 3:
                raise ValueError(f"Pixel ({x},{y}) has value {px}, must be 0-3")
            bit = 7 - x
            b0 |= (px & 1) << bit
            b1 |= ((px >> 1) & 1) << bit
        plane0[y] = b0
        plane1[y] = b1
    return bytes(plane0) + bytes(plane1)


def validate_png(img):
    """Validate that a PNG image is suitable for CHR conversion.

    Returns:
        list of error strings (empty if valid).
    """
    errors = []

    if img.mode != 'P':
        errors.append(f"Image mode is '{img.mode}', expected 'P' (indexed/palette mode).")
        errors.append("Convert to indexed color with exactly 4 colors first.")
        return errors

    # Check palette size
    palette = img.getpalette()
    if palette is None:
        errors.append("Image has no palette.")
        return errors

    # Count unique palette indices actually used
    pixel_data = list(img.getdata())
    unique_indices = set(pixel_data)
    max_index = max(unique_indices) if unique_indices else 0

    if max_index > 3:
        errors.append(f"Image uses palette index {max_index}, max allowed is 3 (4 colors).")
        errors.append(f"Unique indices used: {sorted(unique_indices)}")

    # Check dimensions
    w, h = img.size
    if w % 8 != 0:
        errors.append(f"Width {w} is not a multiple of 8.")
    if h % 8 != 0:
        errors.append(f"Height {h} is not a multiple of 8.")

    return errors


def png_to_chr(img):
    """Convert an indexed-color PIL Image to NES CHR data.

    Tiles are extracted left-to-right, top-to-bottom in 8x8 blocks.

    Args:
        img: PIL.Image in mode 'P' (indexed color), dimensions multiple of 8.

    Returns:
        bytes: CHR data (16 bytes per tile).
        int: number of tiles.
    """
    w, h = img.size
    tiles_x = w // 8
    tiles_y = h // 8
    num_tiles = tiles_x * tiles_y

    pixel_data = list(img.getdata())
    chr_data = bytearray()

    for ty in range(tiles_y):
        for tx in range(tiles_x):
            tile_pixels = []
            for row in range(8):
                pixel_row = []
                for col in range(8):
                    px_x = tx * 8 + col
                    px_y = ty * 8 + row
                    idx = px_y * w + px_x
                    pixel_row.append(pixel_data[idx])
                tile_pixels.append(pixel_row)
            chr_data.extend(pixels_to_chr_tile(tile_pixels))

    return bytes(chr_data), num_tiles


def main():
    parser = argparse.ArgumentParser(
        description="Convert indexed-color PNG to NES CHR tile format."
    )
    parser.add_argument("input", help="Input PNG file (indexed color, 4 colors)")
    parser.add_argument("output", nargs="?", help="Output .chr file")
    parser.add_argument("--validate", action="store_true",
                        help="Validate input only, don't produce output")
    parser.add_argument("--info", action="store_true",
                        help="Show image info (tile count, dimensions)")
    parser.add_argument("--force", action="store_true",
                        help="Force conversion even if validation warns (non-fatal)")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"ERROR: File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    img = Image.open(args.input)

    if args.info:
        w, h = img.size
        print(f"Image: {args.input}")
        print(f"  Size: {w}x{h} pixels")
        print(f"  Mode: {img.mode}")
        if img.mode == 'P':
            pixel_data = list(img.getdata())
            unique = sorted(set(pixel_data))
            print(f"  Unique palette indices: {unique}")
            palette = img.getpalette()
            if palette:
                print(f"  Palette colors (RGB):")
                for i in unique:
                    r, g, b = palette[i*3], palette[i*3+1], palette[i*3+2]
                    print(f"    [{i}] = ({r}, {g}, {b}) #{r:02x}{g:02x}{b:02x}")
        if w % 8 == 0 and h % 8 == 0:
            tiles_x = w // 8
            tiles_y = h // 8
            total = tiles_x * tiles_y
            print(f"  Tiles: {tiles_x}x{tiles_y} = {total} tiles ({total * 16} bytes)")
        else:
            print(f"  WARNING: Dimensions not multiple of 8, cannot tile")
        sys.exit(0)

    # Validate
    errors = validate_png(img)
    if errors:
        print("Validation errors:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        if not args.force:
            sys.exit(1)
        print("Continuing with --force...", file=sys.stderr)

    if args.validate:
        if not errors:
            w, h = img.size
            tiles = (w // 8) * (h // 8)
            print(f"OK: {args.input} - {w}x{h}, {tiles} tiles")
        sys.exit(0 if not errors else 1)

    # Convert
    if not args.output:
        print("ERROR: Output file required (or use --validate/--info)", file=sys.stderr)
        sys.exit(1)

    chr_data, num_tiles = png_to_chr(img)

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, 'wb') as f:
        f.write(chr_data)

    print(f"Converted {num_tiles} tiles ({len(chr_data)} bytes) -> {args.output}")


if __name__ == "__main__":
    main()
