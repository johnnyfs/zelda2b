# Zelda 2B — Soundtrack Plan

## Overview

NES 2A03 audio (no expansion chips): 2 pulse waves, 1 triangle, 1 noise, 1 DPCM.
Sound engine: FamiStudio (ca65 integration, FamiStudio tempo mode).

Music will be sourced from three pools:
1. **Zelda 2 (NES)** — direct NSF rips/recreations, most authentic
2. **Link's Awakening (GB)** — 4-channel Game Boy music, close match to NES capabilities
3. **Link to the Past (SNES)** — downsampled/arranged for NES, more complex source material
4. **Original compositions** — for any gaps

## Complete Song List

| # | Song Name | Context | Source | Priority | Notes |
|---|-----------|---------|--------|----------|-------|
| 0 | Title Theme | Title screen | Zelda 2 title | P1 | Iconic, sets the tone |
| 1 | Overworld Theme | Overworld exploration | Zelda 2 overworld | P1 | Main gameplay music |
| 2 | Town Theme | Village/NPC areas | Zelda 2 town | P2 | Calm, explorative |
| 3 | Palace Theme 1 | Dungeons 1-3 | Zelda 2 palace | P1 | Core dungeon music |
| 4 | Palace Theme 2 | Dungeons 4-6 | Zelda 2 great palace | P2 | Later dungeon variant |
| 5 | Great Palace | Final dungeon | Zelda 2 great palace | P3 | End-game tension |
| 6 | Cave/Underground | Cave exploration | Link's Awakening cave | P1 | Underground areas |
| 7 | Boss Battle | Boss encounters | Zelda 2 boss / LttP boss arr. | P2 | Intense combat |
| 8 | Shop Theme | Merchant/shop screens | Link's Awakening shop | P3 | Short loop, cheerful |
| 9 | Game Over | Player death | Zelda 2 game over | P2 | Short, somber |
| 10 | Fanfare | Item get/dungeon clear | Zelda series fanfare | P1 | Short jingle (2-3 sec) |
| 11 | Sleeping Zelda | Intro/story scene | Zelda 2 intro | P3 | Story moment |
| 12 | Death Mountain | Death Mountain caves | Original / Zelda 2 | P3 | Tense, deep |

## Priority Tiers

- **P1 (Tech Demo):** Title, Overworld, Palace 1, Cave, Fanfare — minimum viable soundtrack
- **P2 (Alpha):** Town, Boss, Game Over, Palace 2 — complete gameplay coverage
- **P3 (Full):** Shop, Sleeping Zelda, Great Palace, Death Mountain — polish

## Source Strategy

### Zelda 2 NSF Rips
The original Zelda 2 music exists in NSF format. These can be loaded into FamiStudio
and re-exported with our engine settings. The NES-to-NES translation is lossless.

### Link's Awakening (Game Boy)
GB has 2 pulse + 1 wave + 1 noise — very similar to NES 2A03. Main differences:
- GB wave channel → NES triangle (limited but workable)
- GB uses different timer values → need period recalculation
- Several fan-made FamiTracker/FamiStudio covers already exist

### Link to the Past (SNES)
SNES SPC700 has 8 sample-based voices — much richer than NES. Arrangements require:
- Choosing which 2-3 melody/harmony lines to keep
- Adapting bass to triangle channel
- Simplifying percussion to noise channel
- Possible DPCM for kick drum samples

### FamiStudio Workflow
1. Import/compose in FamiStudio application
2. Export as ca65 assembly data (.s file)
3. Replace placeholder_music.s includes with real data
4. Add song indices to audio.inc constants
5. Test in emulator

## DPCM Sample Budget

We have limited DPCM address space ($C000-$FFFF in CPU space, mapped from PRG ROM).
Budget allocation:
- Kick drum: ~400 bytes (short, punchy)
- Snare: ~300 bytes
- Orchestra hit: ~500 bytes (for fanfare)
- Total target: <2KB of DPCM samples

## Technical Constraints

- All music must fit in PRG_FIXED_C bank ($C000-$DFFF = 8KB) alongside engine code
- If music data exceeds this, we'll need to bank-switch music data into $8000-$9FFF
- Each song's channel data should target <500 bytes for reasonable compression
- FamiStudio tempo mode preferred (more precise than FamiTracker tempo)
- NTSC only (60 Hz tick rate)
