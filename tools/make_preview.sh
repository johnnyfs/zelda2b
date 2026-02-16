#!/usr/bin/env bash
#
# make_preview.sh - Generate a playable HTML preview of the NES ROM
#
# Usage:
#   ./tools/make_preview.sh [path/to/rom.nes]
#
# Defaults to build/zelda2b.nes if no argument is given.
# Outputs to build/preview.html
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

ROM_PATH="${1:-${PROJECT_DIR}/build/zelda2b.nes}"
TEMPLATE="${SCRIPT_DIR}/play_template.html"
OUTPUT="${PROJECT_DIR}/build/preview.html"

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

if [ ! -f "$TEMPLATE" ]; then
    echo "ERROR: Template not found: $TEMPLATE" >&2
    exit 1
fi

if [ ! -f "$ROM_PATH" ]; then
    echo "ERROR: ROM file not found: $ROM_PATH" >&2
    echo "  Build the ROM first, then run this script." >&2
    echo "  Usage: $0 [path/to/rom.nes]" >&2
    exit 1
fi

# Check file size (NES ROMs should be at least 16 bytes for the header)
ROM_SIZE=$(wc -c < "$ROM_PATH" | tr -d ' ')
if [ "$ROM_SIZE" -lt 16 ]; then
    echo "ERROR: ROM file is too small ($ROM_SIZE bytes). Is it a valid NES ROM?" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Generate preview
# ---------------------------------------------------------------------------

echo "Generating preview..."
echo "  ROM:      $ROM_PATH ($ROM_SIZE bytes)"
echo "  Template: $TEMPLATE"
echo "  Output:   $OUTPUT"

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT")"

# Base64 encode the ROM
# macOS and GNU coreutils both support base64, but flags differ for wrapping.
# We use tr to strip any newlines for maximum compatibility.
ROM_BASE64=$(base64 < "$ROM_PATH" | tr -d '\n\r')

if [ -z "$ROM_BASE64" ]; then
    echo "ERROR: Failed to base64-encode the ROM." >&2
    exit 1
fi

# Replace the placeholder in the template.
# We use a Python one-liner for reliable string replacement, since the base64
# data can be very large and may contain characters that trip up sed.
python3 -c "
import sys
template = open(sys.argv[1], 'r').read()
rom_b64 = sys.argv[2]
result = template.replace('PLACEHOLDER_ROM_BASE64', rom_b64)
open(sys.argv[3], 'w').write(result)
" "$TEMPLATE" "$ROM_BASE64" "$OUTPUT"

# Verify output was created
if [ ! -f "$OUTPUT" ]; then
    echo "ERROR: Failed to create output file." >&2
    exit 1
fi

OUTPUT_SIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo ""
echo "Preview generated successfully!"
echo "  Output: $OUTPUT ($OUTPUT_SIZE bytes)"
echo "  Open in browser to play."
