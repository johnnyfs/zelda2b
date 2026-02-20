#!/usr/bin/env python3
"""
validate_chr.py — Validate NES CHR files for correct format and size.

Checks:
- File size is a multiple of 16 bytes (each tile = 16 bytes)
- File size is a multiple of 1024 bytes (each CHR bank = 1KB = 64 tiles)
- Optional: check that file fits in specified number of banks
- Reports tile count and bank count

Usage:
  python3 validate_chr.py file.chr
  python3 validate_chr.py file.chr --max-banks 4
  python3 validate_chr.py assets/sprites/*.chr assets/tilesets/*.chr
"""

import argparse
import sys
from pathlib import Path


def validate_chr(filepath: str, max_banks: int = 0) -> bool:
    """Validate a single CHR file. Returns True if valid."""
    path = Path(filepath)
    if not path.exists():
        print(f"FAIL: {filepath} — file not found")
        return False

    size = path.stat().st_size
    if size == 0:
        print(f"FAIL: {filepath} — empty file")
        return False

    if size % 16 != 0:
        print(f"FAIL: {filepath} — {size} bytes, not a multiple of 16 (incomplete tile)")
        return False

    tiles = size // 16
    banks = size / 1024

    warnings = []
    if size % 1024 != 0:
        warnings.append(f"not aligned to 1KB bank boundary ({banks:.2f} banks)")

    if max_banks > 0 and banks > max_banks:
        print(f"FAIL: {filepath} — {banks:.1f} banks exceeds max {max_banks}")
        return False

    status = "OK"
    warn_str = ""
    if warnings:
        warn_str = " [WARN: " + "; ".join(warnings) + "]"

    print(f"{status}: {filepath} — {tiles} tiles, {size} bytes ({banks:.1f} banks){warn_str}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Validate NES CHR files")
    parser.add_argument("files", nargs="+", help="CHR files to validate")
    parser.add_argument("--max-banks", type=int, default=0,
                        help="Maximum number of 1KB CHR banks allowed (0=no limit)")
    args = parser.parse_args()

    all_ok = True
    for f in args.files:
        if not validate_chr(f, args.max_banks):
            all_ok = False

    if not all_ok:
        sys.exit(1)
    print(f"\nAll {len(args.files)} file(s) valid.")


if __name__ == "__main__":
    main()
