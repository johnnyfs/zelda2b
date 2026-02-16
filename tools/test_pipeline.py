#!/usr/bin/env python3
"""
test_pipeline.py - Test the png2chr / chr2png round-trip pipeline.

Creates test PNG images with known tile patterns, converts to CHR,
converts back to PNG, and verifies pixel-perfect round-trip.
"""

import os
import sys
import struct

sys.path.insert(0, os.path.dirname(__file__))

from PIL import Image

# Import our tools
from png2chr import pixels_to_chr_tile, png_to_chr, validate_png
from chr2png import chr_tile_to_pixels, chr_to_image


def test_single_tile_roundtrip():
    """Test that a single tile survives the round-trip."""
    print("Test: single tile round-trip...", end=" ")

    # Create a known 8x8 tile pattern
    test_pattern = [
        [0, 0, 1, 1, 2, 2, 3, 3],
        [0, 1, 2, 3, 0, 1, 2, 3],
        [3, 2, 1, 0, 3, 2, 1, 0],
        [1, 1, 1, 1, 2, 2, 2, 2],
        [0, 0, 0, 0, 3, 3, 3, 3],
        [3, 0, 3, 0, 3, 0, 3, 0],
        [1, 2, 1, 2, 1, 2, 1, 2],
        [0, 3, 0, 3, 0, 3, 0, 3],
    ]

    # Convert to CHR
    chr_data = pixels_to_chr_tile(test_pattern)
    assert len(chr_data) == 16, f"Expected 16 bytes, got {len(chr_data)}"

    # Convert back
    decoded = chr_tile_to_pixels(chr_data)

    # Compare
    for y in range(8):
        for x in range(8):
            assert test_pattern[y][x] == decoded[y][x], \
                f"Mismatch at ({x},{y}): {test_pattern[y][x]} != {decoded[y][x]}"

    print("PASS")


def test_full_image_roundtrip():
    """Test full image -> CHR -> image round-trip."""
    print("Test: full image round-trip...", end=" ")

    # Create a 32x16 test image (4x2 tiles = 8 tiles)
    w, h = 32, 16
    img = Image.new('P', (w, h))

    # Set a 4-color palette
    palette = [0] * 768  # 256 * 3
    palette[0:3] = [0, 0, 0]        # index 0: black
    palette[3:6] = [85, 85, 85]     # index 1: dark gray
    palette[6:9] = [170, 170, 170]  # index 2: light gray
    palette[9:12] = [255, 255, 255] # index 3: white
    img.putpalette(palette)

    # Fill with a test pattern
    pixels = img.load()
    for y in range(h):
        for x in range(w):
            pixels[x, y] = (x + y) % 4

    # Save test PNG
    test_dir = os.path.join(os.path.dirname(__file__), "..", "build", "test")
    os.makedirs(test_dir, exist_ok=True)
    test_png = os.path.join(test_dir, "test_input.png")
    img.save(test_png)

    # Validate
    errors = validate_png(img)
    assert not errors, f"Validation errors: {errors}"

    # Convert to CHR
    chr_data, num_tiles = png_to_chr(img)
    assert num_tiles == 8, f"Expected 8 tiles, got {num_tiles}"
    assert len(chr_data) == 128, f"Expected 128 bytes, got {len(chr_data)}"

    test_chr = os.path.join(test_dir, "test.chr")
    with open(test_chr, 'wb') as f:
        f.write(chr_data)

    # Convert back to image
    rgb_img, indexed_img = chr_to_image(chr_data, columns=4)

    # Verify pixel values match
    indexed_pixels = indexed_img.load()
    for y in range(h):
        for x in range(w):
            expected = (x + y) % 4
            actual = indexed_pixels[x, y]
            assert expected == actual, \
                f"Pixel ({x},{y}): expected {expected}, got {actual}"

    # Save output for visual inspection
    test_output = os.path.join(test_dir, "test_output.png")
    rgb_img.save(test_output)

    print("PASS")


def test_existing_chr():
    """Test converting existing placeholder CHR files."""
    print("Test: existing CHR files...", end=" ")

    chr_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "chr")
    test_dir = os.path.join(os.path.dirname(__file__), "..", "build", "test")
    os.makedirs(test_dir, exist_ok=True)

    for fname in ["bg_tiles.chr", "sprite_tiles.chr", "placeholder.chr"]:
        fpath = os.path.join(chr_dir, fname)
        if not os.path.exists(fpath):
            print(f"\n  SKIP: {fname} not found", end="")
            continue

        with open(fpath, 'rb') as f:
            data = f.read()

        if len(data) == 0:
            print(f"\n  SKIP: {fname} is empty", end="")
            continue

        num_tiles = len(data) // 16
        rgb_img, indexed_img = chr_to_image(data, columns=16)

        out_path = os.path.join(test_dir, fname.replace('.chr', '.png'))
        rgb_img.save(out_path)
        print(f"\n  {fname}: {num_tiles} tiles -> {out_path}", end="")

    print(" PASS")


def test_all_zeros_and_ones():
    """Test edge case: all-zero tile and all-ones tile."""
    print("Test: edge cases (all zeros/ones)...", end=" ")

    # All zeros
    zero_tile = [[0]*8 for _ in range(8)]
    chr_data = pixels_to_chr_tile(zero_tile)
    assert chr_data == bytes(16), "All-zero tile should be 16 zero bytes"
    decoded = chr_tile_to_pixels(chr_data)
    for y in range(8):
        for x in range(8):
            assert decoded[y][x] == 0

    # All threes (both planes all 1s)
    three_tile = [[3]*8 for _ in range(8)]
    chr_data = pixels_to_chr_tile(three_tile)
    assert chr_data == bytes([0xFF]*16), "All-3 tile should be 16 0xFF bytes"
    decoded = chr_tile_to_pixels(chr_data)
    for y in range(8):
        for x in range(8):
            assert decoded[y][x] == 3

    print("PASS")


if __name__ == "__main__":
    print("=== Graphics Pipeline Tests ===\n")
    test_single_tile_roundtrip()
    test_full_image_roundtrip()
    test_all_zeros_and_ones()
    test_existing_chr()
    print("\n=== All tests passed! ===")
