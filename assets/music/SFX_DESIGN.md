# Zelda 2B — Sound Effects Design Document

## Overview

All SFX use the FamiStudio SFX engine with 2 simultaneous streams:
- **Channel 0 (Gameplay):** High priority — sword, hits, pickups, explosions
- **Channel 1 (UI/Ambient):** Low priority — menu cursor, dialogue beeps, doors

SFX temporarily override music on the channels they use (pulse 1/2, triangle, noise).
The engine automatically mixes by volume priority.

## Complete SFX List

### Combat SFX

| ID | Name | Channel | Duration | Description |
|----|------|---------|----------|-------------|
| 0 | Sword Swing | Noise | 4 frames | Short white noise burst, fast decay. Like a metal swoosh. |
| 1 | Sword Hit (Enemy) | Pulse1 | 5 frames | Sharp descending pulse tone + noise. Satisfying impact. |
| 2 | Sword Hit (Wall) | Noise | 6 frames | Metallic clang — noise with specific period for tonal quality. |
| 3 | Player Damage | Pulse1+Noise | 8 frames | Descending buzz + noise hit. Unpleasant, signals danger. |
| 4 | Player Death | Pulse1+Tri | 30 frames | Long descending sweep, dramatic. Triangle adds body. |
| 5 | Enemy Death | Noise | 10 frames | Explosion-like noise burst with medium decay. |
| 6 | Enemy Projectile | Pulse2 | 3 frames | Quick ascending blip, warns of incoming danger. |

### Item SFX

| ID | Name | Channel | Duration | Description |
|----|------|---------|----------|-------------|
| 7 | Rupee Pickup | Pulse1 | 4 frames | Quick ascending two-note chirp (classic Zelda sound). |
| 8 | Heart Pickup | Pulse1 | 6 frames | Rising arpeggio C-E-G (warm, healing feel). |
| 9 | Key Pickup | Pulse1 | 8 frames | Longer ascending arpeggio with sustain. Special feel. |
| 10 | Magic Pickup | Pulse1+Tri | 8 frames | Shimmering rising tone with triangle harmony. |
| 11 | Item Get (Major) | Pulse1+Pulse2 | 20 frames | Full fanfare jingle — both pulses in harmony. |

### Bomb SFX

| ID | Name | Channel | Duration | Description |
|----|------|---------|----------|-------------|
| 12 | Bomb Place | Noise | 2 frames | Short thud — low noise, very brief. |
| 13 | Bomb Fuse | Noise | ~60 frames | Repeating tick (noise + silence alternating). Looped until detonation. |
| 14 | Bomb Explode | Noise+DPCM | 15 frames | Heavy noise burst with DPCM sample for bass impact. |

### UI / Menu SFX

| ID | Name | Channel | Duration | Description |
|----|------|---------|----------|-------------|
| 15 | Menu Cursor | Pulse1 | 2 frames | Short high-pitched blip. Clean and snappy. |
| 16 | Menu Select | Pulse1 | 4 frames | Slightly longer confirming tone, two ascending notes. |
| 17 | Menu Cancel | Pulse1 | 3 frames | Descending two-note tone. |
| 18 | Pause | Pulse1+Pulse2 | 4 frames | Brief two-tone chord. Signals state change. |

### Environment SFX

| ID | Name | Channel | Duration | Description |
|----|------|---------|----------|-------------|
| 19 | Door Open | Noise | 8 frames | Sliding noise (ascending period) — stone/wood door opening. |
| 20 | Stairs | Pulse1 | 4 frames | Ascending scale snippet — 3 quick notes going up. |
| 21 | Chest Open | Pulse1+Tri | 10 frames | Rising phrase with sustain — anticipation sound. |
| 22 | Secret Found | Pulse1+Pulse2 | 15 frames | Classic Zelda "secret" jingle — descending then ascending. |

### NPC / Dialogue SFX

| ID | Name | Channel | Duration | Description |
|----|------|---------|----------|-------------|
| 23 | NPC Talk Beep | Triangle | 2 frames | Per-character text beep. Triangle for soft, non-intrusive sound. |
| 24 | Shop Buy | Pulse1 | 6 frames | Cash register-like ascending arpeggio. |
| 25 | Shop Denied | Pulse1 | 4 frames | Descending buzz — "not enough rupees" feeling. |

### Magic / Spell SFX

| ID | Name | Channel | Duration | Description |
|----|------|---------|----------|-------------|
| 26 | Magic Use | Pulse2+Tri | 8 frames | Shimmering warble — pulse with fast vibrato + triangle drone. |
| 27 | Spell Activate | Pulse1+Pulse2 | 12 frames | Dramatic ascending sweep on both pulses. Power-up feeling. |
| 28 | Shield Block | Noise | 3 frames | Sharp metallic clang — noise at specific period. |

## Implementation Notes

### Priority Rules
- When two SFX would conflict on the same channel, the one on the higher-priority
  stream (channel 0) wins.
- For gameplay: combat SFX > item SFX > environment SFX
- For UI: menu SFX play independently on channel 1

### Channel Assignment Strategy
- **Noise-heavy SFX** (sword swing, explosions, doors): Prefer noise channel to avoid
  stealing melody from music.
- **Tonal SFX** (pickups, menu): Use pulse channels briefly — FamiStudio engine
  automatically restores music after SFX ends.
- **Triangle SFX** (NPC beep): Triangle is often bass in music, so keep these very short.

### DPCM Considerations
- Bomb explosion could use a DPCM kick sample for extra bass impact
- Item Get fanfare could use a DPCM orchestra hit
- Keep DPCM SFX rare — they interfere with DPCM music channels

### Current Placeholder Status
The `placeholder_sfx.s` file currently implements 4 basic SFX:
- SFX 0: Sword swing (noise burst)
- SFX 1: Hit (descending pulse)
- SFX 2: Item pickup (rising arpeggio)
- SFX 3: Menu cursor (high blip)

All other SFX in this document are planned for future implementation.

### Design Reference
- Zelda 1 (NES) SFX: Excellent reference for sword/item sounds
- Zelda 2 (NES) SFX: Combat sounds, magic, town interactions
- Link's Awakening (GB) SFX: Good menu/UI sound design
