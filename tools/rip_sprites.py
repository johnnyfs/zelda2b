#!/usr/bin/env python3
"""
rip_sprites.py - Extract sprites from reference PNG sprite sheets and
convert them to NES CHR format.

The reference sheets (from Spriters Resource) are full-color PNGs with
a green/magenta background. This tool:
1. Extracts a rectangular region from the source PNG
2. Identifies the background color (typically bright green)
3. Maps all pixel colors to 4 NES-compatible shades (0-3)
4. Outputs as NES CHR tiles (8x8, 16 bytes each)

Usage:
  # Extract a single 16x16 sprite from (x,y) in the source
  python3 rip_sprites.py ref.png --rect 32,16,16,16 -o sprite.chr

  # Extract a grid of 8x8 tiles from a region
  python3 rip_sprites.py ref.png --rect 0,0,128,128 --tile-size 8 -o tiles.chr

  # Preview what will be extracted (outputs to HTML)
  python3 rip_sprites.py ref.png --rect 32,16,16,16 --preview preview.html

  # Batch extraction from a config file
  python3 rip_sprites.py ref.png --config sprites.json -o output.chr
"""

import argparse
import json
import math
import os
import sys

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow required. pip3 install Pillow", file=sys.stderr)
    sys.exit(1)

sys.path.insert(0, os.path.dirname(__file__))
from png2chr import pixels_to_chr_tile


def identify_bg_color(img):
    """Identify the most common edge color as the background."""
    w, h = img.size
    pixels = img.load()
    edge_colors = {}

    # Sample edges
    for x in range(w):
        for y in [0, h-1]:
            c = pixels[x, y][:3] if len(pixels[x, y]) >= 3 else pixels[x, y]
            edge_colors[c] = edge_colors.get(c, 0) + 1
    for y in range(h):
        for x in [0, w-1]:
            c = pixels[x, y][:3] if len(pixels[x, y]) >= 3 else pixels[x, y]
            edge_colors[c] = edge_colors.get(c, 0) + 1

    if edge_colors:
        return max(edge_colors, key=edge_colors.get)
    return (0, 128, 0)  # default green


def color_luminance(r, g, b):
    """Compute perceived luminance (0-255)."""
    return int(0.299 * r + 0.587 * g + 0.114 * b)


def map_to_4_shades(img, rect, bg_color=None, transparency_threshold=200):
    """Extract a region from the image and map to 4 NES shades (0-3).

    Shade mapping:
      0 = transparent/background
      1 = darkest (outlines, shadows)
      2 = medium (main color body)
      3 = lightest (highlights, skin)

    Args:
        img: PIL Image in RGBA or RGB mode
        rect: (x, y, w, h) region to extract
        bg_color: (r,g,b) background color to treat as transparent
        transparency_threshold: alpha below this = transparent

    Returns:
        list of rows, each row is a list of ints 0-3
    """
    x0, y0, rw, rh = rect
    img_w, img_h = img.size

    # Clamp to image bounds
    x0 = max(0, min(x0, img_w - 1))
    y0 = max(0, min(y0, img_h - 1))
    rw = min(rw, img_w - x0)
    rh = min(rh, img_h - y0)

    pixels = img.load()
    has_alpha = img.mode == 'RGBA'

    # First pass: collect all non-bg colors and their luminances
    color_lums = {}
    for py in range(rh):
        for px in range(rw):
            ix, iy = x0 + px, y0 + py
            if ix >= img_w or iy >= img_h:
                continue
            pixel = pixels[ix, iy]
            if has_alpha and len(pixel) == 4:
                r, g, b, a = pixel
                if a < transparency_threshold:
                    continue
            else:
                r, g, b = pixel[:3]
                a = 255

            rgb = (r, g, b)
            # Check if it's the background color
            if bg_color and rgb == bg_color:
                continue

            # Check if close to bg color (within tolerance)
            if bg_color:
                dr = abs(r - bg_color[0])
                dg = abs(g - bg_color[1])
                db = abs(b - bg_color[2])
                if dr + dg + db < 30:
                    continue

            lum = color_luminance(r, g, b)
            color_lums[rgb] = lum

    if not color_lums:
        # All transparent/bg
        return [[0] * rw for _ in range(rh)]

    # Determine shade boundaries from luminance distribution
    lums = sorted(set(color_lums.values()))

    if len(lums) <= 1:
        # Only one shade present
        thresholds = [128, 128, 128]
    elif len(lums) == 2:
        mid = (lums[0] + lums[1]) // 2
        thresholds = [mid, mid, mid]
    elif len(lums) == 3:
        thresholds = [
            (lums[0] + lums[1]) // 2,
            (lums[1] + lums[2]) // 2,
            255
        ]
    else:
        # K-means style: split into 3 groups
        # Use percentile-based thresholds
        n = len(lums)
        thresholds = [
            lums[n // 3],
            lums[2 * n // 3],
            255
        ]

    def lum_to_shade(lum):
        """Map luminance to shade 1-3 (1=dark, 3=light)."""
        if lum <= thresholds[0]:
            return 1
        elif lum <= thresholds[1]:
            return 2
        else:
            return 3

    # Second pass: build the pixel grid
    result = []
    for py in range(rh):
        row = []
        for px in range(rw):
            ix, iy = x0 + px, y0 + py
            if ix >= img_w or iy >= img_h:
                row.append(0)
                continue

            pixel = pixels[ix, iy]
            if has_alpha and len(pixel) == 4:
                r, g, b, a = pixel
                if a < transparency_threshold:
                    row.append(0)
                    continue
            else:
                r, g, b = pixel[:3]

            rgb = (r, g, b)
            if bg_color and rgb == bg_color:
                row.append(0)
                continue
            if bg_color:
                dr = abs(r - bg_color[0])
                dg = abs(g - bg_color[1])
                db = abs(b - bg_color[2])
                if dr + dg + db < 30:
                    row.append(0)
                    continue

            lum = color_luminance(r, g, b)
            row.append(lum_to_shade(lum))

        result.append(row)

    return result


def grid_to_chr_tiles(pixel_grid, tile_size=8):
    """Convert a pixel grid into CHR tile data.

    The grid is split into tile_size x tile_size blocks,
    left-to-right, top-to-bottom.

    Returns:
        bytes: CHR data
        int: number of tiles
    """
    h = len(pixel_grid)
    w = len(pixel_grid[0]) if h > 0 else 0

    tiles_x = w // tile_size
    tiles_y = h // tile_size
    num_tiles = tiles_x * tiles_y

    chr_data = bytearray()

    for ty in range(tiles_y):
        for tx in range(tiles_x):
            # Extract 8x8 block from the tile_size block
            # If tile_size > 8, we extract multiple 8x8 tiles
            for sub_y in range(tile_size // 8):
                for sub_x in range(tile_size // 8):
                    tile_rows = []
                    for row in range(8):
                        pixel_row = []
                        for col in range(8):
                            py = ty * tile_size + sub_y * 8 + row
                            px = tx * tile_size + sub_x * 8 + col
                            if py < h and px < w:
                                pixel_row.append(pixel_grid[py][px])
                            else:
                                pixel_row.append(0)
                        tile_rows.append(pixel_row)
                    chr_data.extend(pixels_to_chr_tile(tile_rows))

    actual_tiles = len(chr_data) // 16
    return bytes(chr_data), actual_tiles


def extract_sprite(img, rect, bg_color=None, tile_size=8):
    """Extract sprite from image at rect, return CHR data.

    Args:
        img: PIL Image
        rect: (x, y, w, h)
        bg_color: background color tuple or None for auto-detect
        tile_size: 8 or 16

    Returns:
        bytes: CHR data
        list: pixel grid (for preview)
    """
    pixels = map_to_4_shades(img, rect, bg_color)
    chr_data, num_tiles = grid_to_chr_tiles(pixels, tile_size=8)
    return chr_data, pixels


def process_config(img, config, bg_color):
    """Process a batch config file.

    Config format (JSON):
    {
      "sprites": [
        {"name": "link_down_1", "rect": [32, 16, 16, 16]},
        {"name": "grass", "rect": [0, 0, 16, 16]},
        ...
      ]
    }

    Returns:
        dict: name -> (chr_data, pixel_grid)
    """
    results = {}
    for entry in config.get("sprites", []):
        name = entry["name"]
        rect = tuple(entry["rect"])
        chr_data, pixels = extract_sprite(img, rect, bg_color)
        results[name] = (chr_data, pixels)
    return results


def generate_preview_html(img_path, extractions, output_path):
    """Generate an HTML preview of extracted sprites."""
    html_parts = ["""<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<title>Sprite Extraction Preview</title>
<style>
body { font-family: monospace; background: #1a1a2e; color: #eee; padding: 20px; }
h1 { color: #e94560; }
.sprite { display: inline-block; margin: 10px; text-align: center; background: #16213e; padding: 10px; border-radius: 6px; }
.sprite canvas { image-rendering: pixelated; border: 1px solid #333; }
.sprite .name { font-size: 11px; color: #aaa; margin-top: 4px; }
.sprite .info { font-size: 9px; color: #666; }
</style></head><body>
<h1>Sprite Extraction Preview</h1>
<p style="color:#888">Source: """ + os.path.basename(img_path) + """</p>
<div id="sprites"></div>
<script>
const sprites = """]

    sprite_data = []
    for name, (chr_data, pixels) in extractions.items():
        h = len(pixels)
        w = len(pixels[0]) if h > 0 else 0
        sprite_data.append({
            "name": name,
            "width": w,
            "height": h,
            "pixels": pixels,
            "chr_size": len(chr_data),
        })

    html_parts.append(json.dumps(sprite_data))
    html_parts.append(""";
const colors = ['#000000', '#555555', '#aaaaaa', '#ffffff'];
const container = document.getElementById('sprites');
sprites.forEach(s => {
    const div = document.createElement('div');
    div.className = 'sprite';
    const scale = Math.max(1, Math.floor(64 / Math.max(s.width, s.height)));
    const c = document.createElement('canvas');
    c.width = s.width; c.height = s.height;
    c.style.width = (s.width * scale) + 'px';
    c.style.height = (s.height * scale) + 'px';
    const ctx = c.getContext('2d');
    for (let y = 0; y < s.height; y++)
        for (let x = 0; x < s.width; x++) {
            ctx.fillStyle = colors[s.pixels[y][x]];
            ctx.fillRect(x, y, 1, 1);
        }
    div.appendChild(c);
    div.innerHTML += '<div class="name">' + s.name + '</div>';
    div.innerHTML += '<div class="info">' + s.width + 'x' + s.height + ' (' + s.chr_size + ' bytes)</div>';
    container.appendChild(div);
});
</script></body></html>""")

    with open(output_path, 'w') as f:
        f.write(''.join(html_parts))
    print(f"Preview: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Extract sprites from reference PNGs to NES CHR format.")
    parser.add_argument("input", help="Input PNG sprite sheet")
    parser.add_argument("-o", "--output", help="Output .chr file")
    parser.add_argument("--rect", help="Region to extract: x,y,w,h")
    parser.add_argument("--tile-size", type=int, default=8, help="Tile size (8 or 16)")
    parser.add_argument("--bg-color", help="Background color as R,G,B (auto if omitted)")
    parser.add_argument("--config", help="Batch config JSON file")
    parser.add_argument("--preview", help="Output HTML preview file")
    args = parser.parse_args()

    img = Image.open(args.input).convert('RGBA')

    if args.bg_color:
        bg = tuple(int(x) for x in args.bg_color.split(','))
    else:
        bg = identify_bg_color(img)
    print(f"Background color: {bg}")

    if args.config:
        with open(args.config) as f:
            config = json.load(f)
        results = process_config(img, config, bg)

        if args.preview:
            generate_preview_html(args.input, results, args.preview)

        if args.output:
            all_chr = bytearray()
            for name, (chr_data, _) in results.items():
                all_chr.extend(chr_data)
                print(f"  {name}: {len(chr_data)} bytes ({len(chr_data)//16} tiles)")
            os.makedirs(os.path.dirname(args.output) or '.', exist_ok=True)
            with open(args.output, 'wb') as f:
                f.write(all_chr)
            print(f"Total: {len(all_chr)} bytes -> {args.output}")
    elif args.rect:
        rect = tuple(int(x) for x in args.rect.split(','))
        chr_data, pixels = extract_sprite(img, rect, bg, args.tile_size)

        if args.preview:
            generate_preview_html(args.input, {"sprite": (chr_data, pixels)}, args.preview)

        if args.output:
            os.makedirs(os.path.dirname(args.output) or '.', exist_ok=True)
            with open(args.output, 'wb') as f:
                f.write(chr_data)
            print(f"Extracted {len(chr_data)} bytes ({len(chr_data)//16} tiles) -> {args.output}")
    else:
        print("ERROR: Specify --rect or --config", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
