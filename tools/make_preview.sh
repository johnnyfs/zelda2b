#!/bin/bash
# make_preview.sh — Generate an HTML page that plays the ROM in jsNES
#
# Usage: ./tools/make_preview.sh build/zelda2b.nes [output.html]
#
# The ROM is base64-encoded and embedded directly in the HTML.
# Requires: base64 command, jsnes.min.js in tools/

set -euo pipefail

ROM="${1:?Usage: $0 <rom.nes> [output.html]}"
OUTPUT="${2:-build/preview.html}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JSNES="${SCRIPT_DIR}/jsnes.min.js"

if [ ! -f "$ROM" ]; then
    echo "ERROR: ROM file not found: $ROM" >&2
    exit 1
fi

if [ ! -f "$JSNES" ]; then
    echo "WARNING: jsnes.min.js not found at $JSNES" >&2
    echo "The preview will have a placeholder. Download jsNES separately." >&2
    JSNES_CONTENT="// jsNES not available — placeholder
console.log('jsNES not bundled. Download from https://github.com/bfirsh/jsnes');"
else
    JSNES_CONTENT="$(cat "$JSNES")"
fi

ROM_B64="$(base64 < "$ROM")"
ROM_SIZE="$(wc -c < "$ROM" | tr -d ' ')"

mkdir -p "$(dirname "$OUTPUT")"

cat > "$OUTPUT" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Zelda 2B — ROM Preview</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { background: #111; color: #eee; font-family: monospace; text-align: center; padding: 20px; }
h1 { color: #e94560; font-size: 16px; margin-bottom: 10px; }
.info { color: #888; font-size: 12px; margin-bottom: 15px; }
canvas { image-rendering: pixelated; border: 2px solid #333; }
#controls { margin-top: 10px; }
button { background: #e94560; color: #fff; border: none; padding: 8px 16px;
         cursor: pointer; font-family: inherit; margin: 0 4px; }
button:hover { background: #c73654; }
.keys { color: #666; font-size: 11px; margin-top: 10px; }
</style>
</head>
<body>
<h1>Zelda 2B — NES ROM Preview</h1>
<div class="info">ROM: ${ROM_SIZE} bytes | Built: $(date -u +%Y-%m-%d\ %H:%M\ UTC)</div>
<canvas id="screen" width="256" height="240"></canvas>
<div id="controls">
    <button onclick="startNES()">Start</button>
    <button onclick="resetNES()">Reset</button>
</div>
<div class="keys">
    Arrows = D-pad | Z = B | X = A | Enter = Start | Shift = Select
</div>
<script>
${JSNES_CONTENT}
</script>
<script>
const ROM_B64 = "${ROM_B64}";
let nes = null;

function b64ToArray(b64) {
    const binary = atob(b64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
    return bytes;
}

function startNES() {
    if (typeof jsnes === 'undefined') {
        alert('jsNES library not loaded. See console for details.');
        return;
    }
    const canvas = document.getElementById('screen');
    const ctx = canvas.getContext('2d');
    const imageData = ctx.createImageData(256, 240);

    nes = new jsnes.NES({
        onFrame: function(frameBuffer) {
            for (let i = 0; i < frameBuffer.length; i++) {
                imageData.data[i * 4] = frameBuffer[i] & 0xFF;
                imageData.data[i * 4 + 1] = (frameBuffer[i] >> 8) & 0xFF;
                imageData.data[i * 4 + 2] = (frameBuffer[i] >> 16) & 0xFF;
                imageData.data[i * 4 + 3] = 0xFF;
            }
            ctx.putImageData(imageData, 0, 0);
        }
    });

    const romData = b64ToArray(ROM_B64);
    const romStr = String.fromCharCode.apply(null, romData);
    nes.loadROM(romStr);

    function frame() { nes.frame(); requestAnimationFrame(frame); }
    requestAnimationFrame(frame);

    // Keyboard mapping
    const KEY_MAP = {
        38: jsnes.Controller.BUTTON_UP,    // Up
        40: jsnes.Controller.BUTTON_DOWN,  // Down
        37: jsnes.Controller.BUTTON_LEFT,  // Left
        39: jsnes.Controller.BUTTON_RIGHT, // Right
        90: jsnes.Controller.BUTTON_B,     // Z
        88: jsnes.Controller.BUTTON_A,     // X
        13: jsnes.Controller.BUTTON_START, // Enter
        16: jsnes.Controller.BUTTON_SELECT // Shift
    };
    document.addEventListener('keydown', e => {
        if (KEY_MAP[e.keyCode] !== undefined) {
            nes.buttonDown(1, KEY_MAP[e.keyCode]);
            e.preventDefault();
        }
    });
    document.addEventListener('keyup', e => {
        if (KEY_MAP[e.keyCode] !== undefined) {
            nes.buttonUp(1, KEY_MAP[e.keyCode]);
            e.preventDefault();
        }
    });
}

function resetNES() {
    if (nes) {
        const romData = b64ToArray(ROM_B64);
        const romStr = String.fromCharCode.apply(null, romData);
        nes.loadROM(romStr);
    }
}
</script>
</body>
</html>
HTMLEOF

echo "OK: Preview HTML written to $OUTPUT (ROM embedded as base64)"
