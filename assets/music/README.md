# Zelda 2B — Audio System

## Architecture

The audio system uses the **FamiStudio Sound Engine** (v4.4.1, ca65 version) for all music
and sound effects. It targets the standard NES 2A03 audio hardware with no expansion chips:

- 2 pulse wave channels (square wave with duty cycle control)
- 1 triangle wave channel (bass/melody)
- 1 noise channel (percussion/SFX)
- 1 DPCM channel (digital samples)

## File Layout

```
lib/
  famistudio_ca65.s          # FamiStudio sound engine (DO NOT EDIT)
  NoteTables/                # Binary note lookup tables (DO NOT EDIT)
    famistudio_note_table_lsb.bin
    famistudio_note_table_msb.bin

src/audio/
  audio_config.inc           # FamiStudio engine configuration (features, segments)
  audio.s                    # Audio API wrapper (init, update, play, stop, sfx)
  placeholder_music.s        # Placeholder silent music data
  placeholder_sfx.s          # Placeholder SFX data (4 basic effects)

include/
  audio.inc                  # Public API interface (song/SFX constants, function imports)

assets/music/
  README.md                  # This file
  SOUNDTRACK_PLAN.md         # Full soundtrack plan with sources and priorities
  SFX_DESIGN.md              # Complete SFX design document
```

## API Usage

From any game code module:

```asm
.include "audio.inc"

; Initialize (called once in reset_handler)
jsr audio_init

; Play a song
lda #SONG_OVERWORLD        ; Song index constant
jsr audio_play_song

; Play a sound effect
lda #SFX_SWORD_SWING       ; SFX index constant
ldx #SFX_CHAN_GAMEPLAY      ; Channel 0 (gameplay) or 1 (UI)
jsr audio_play_sfx

; Stop music
jsr audio_stop_music

; Pause/unpause music
lda #1                     ; 1=pause, 0=unpause
jsr audio_pause_music

; Update (called every frame from NMI handler — already wired up)
jsr audio_update
```

## Adding New Music

1. Compose or import music in **FamiStudio** (desktop application)
2. Export using: `File > Export > Code (Assembly)`
   - Select "FamiStudio" tempo mode
   - Select ca65 assembler
   - Enable features matching `audio_config.inc` settings
3. Place the exported `.s` file in `src/audio/`
4. Update `audio.s` to `.include` the new data file
5. Add song index constants to `include/audio.inc`
6. Update `audio_init` in `audio.s` to point to the new music data

## Adding New SFX

1. Design SFX in FamiStudio's SFX editor
2. Export as ca65 assembly
3. Replace/extend `placeholder_sfx.s` with the exported data
4. Add SFX index constants to `include/audio.inc`
5. Update `audio_init` to point to new SFX data

## Configuration

The FamiStudio engine is configured in `src/audio/audio_config.inc`. Key settings:

- **NTSC only** (no PAL support needed)
- **2 SFX streams** (gameplay + UI)
- **DPCM enabled** (for future drum samples)
- **Features enabled:** volume track, pitch track, slide notes, vibrato, arpeggio, release notes, delta counter
- **Smooth vibrato** (eliminates pops on pulse channels)

## Memory Map

The sound engine code and data live in `PRG_FIXED_C` ($C000-$DFFF), which is always mapped.
ZP variables go in `ZEROPAGE`, RAM variables in `RAM`.

If music data grows beyond ~4KB (the free space in PRG_FIXED_C after engine code), we'll
need to bank-switch music data into a swappable bank ($8000-$9FFF).
