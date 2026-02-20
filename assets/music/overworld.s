; ==========================================================
; Overworld Theme — Zelda 2B
; ==========================================================
; Tempo: ~140 BPM (faster than 120 BPM base)
; Key: A minor / C major
; Style: Adventurous, upbeat, exploration feel
; Inspired by Zelda 2 overworld but original composition
;
; At 140 BPM: 1 beat = 26 frames (rounded from 25.7)
; ==========================================================

.include "instruments.s"

.segment "PRG_FIXED_C"

; Duration constants for 140 BPM
DUR_OW_QUARTER = 26
DUR_OW_EIGHTH = 13
DUR_OW_SIXTEENTH = 7
DUR_OW_HALF = 52

; ==========================================================
; Pulse 1 Channel — Main Melody (Instrument 0: Lead Square)
; ==========================================================
.export music_overworld_pulse1
music_overworld_pulse1:
    ; Intro phrase (8 bars)
    ; Bar 1: A-C-E pattern (Am chord outline)
    .byte NOTE_A4, DUR_OW_EIGHTH
    .byte NOTE_C5, DUR_OW_EIGHTH
    .byte NOTE_E5, DUR_OW_QUARTER
    .byte NOTE_A4, DUR_OW_EIGHTH
    .byte NOTE_C5, DUR_OW_EIGHTH

    ; Bar 2: Continue upward
    .byte NOTE_E5, DUR_OW_EIGHTH
    .byte NOTE_A5, DUR_OW_EIGHTH
    .byte NOTE_G5, DUR_OW_QUARTER
    .byte NOTE_E5, DUR_OW_EIGHTH
    .byte NOTE_C5, DUR_OW_EIGHTH

    ; Bar 3: F-G-A ascent
    .byte NOTE_F4, DUR_OW_EIGHTH
    .byte NOTE_G4, DUR_OW_EIGHTH
    .byte NOTE_A4, DUR_OW_QUARTER
    .byte NOTE_C5, DUR_OW_QUARTER

    ; Bar 4: Descending phrase
    .byte NOTE_B4, DUR_OW_EIGHTH
    .byte NOTE_A4, DUR_OW_EIGHTH
    .byte NOTE_G4, DUR_OW_QUARTER
    .byte NOTE_E4, DUR_OW_QUARTER

    ; Bar 5: Repeat with variation
    .byte NOTE_A4, DUR_OW_EIGHTH
    .byte NOTE_C5, DUR_OW_EIGHTH
    .byte NOTE_E5, DUR_OW_QUARTER
    .byte NOTE_D5, DUR_OW_EIGHTH
    .byte NOTE_C5, DUR_OW_EIGHTH

    ; Bar 6: G major feel
    .byte NOTE_B4, DUR_OW_EIGHTH
    .byte NOTE_D5, DUR_OW_EIGHTH
    .byte NOTE_G5, DUR_OW_QUARTER
    .byte NOTE_F5, DUR_OW_EIGHTH
    .byte NOTE_E5, DUR_OW_EIGHTH

    ; Bar 7: Climax
    .byte NOTE_A5, DUR_OW_EIGHTH
    .byte NOTE_G5, DUR_OW_EIGHTH
    .byte NOTE_F5, DUR_OW_EIGHTH
    .byte NOTE_E5, DUR_OW_EIGHTH
    .byte NOTE_D5, DUR_OW_QUARTER

    ; Bar 8: Resolution
    .byte NOTE_C5, DUR_OW_QUARTER
    .byte NOTE_A4, DUR_OW_QUARTER
    .byte NOTE_E4, DUR_OW_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Pulse 2 Channel — Harmony/Counter-melody (Instrument 1)
; ==========================================================
.export music_overworld_pulse2
music_overworld_pulse2:
    ; Harmony line, supporting the melody
    ; Bar 1: Am chord tones
    .byte NOTE_C4, DUR_OW_QUARTER
    .byte NOTE_E4, DUR_OW_QUARTER
    .byte NOTE_A3, DUR_OW_QUARTER

    ; Bar 2: C major
    .byte NOTE_E4, DUR_OW_QUARTER
    .byte NOTE_C4, DUR_OW_QUARTER
    .byte NOTE_G3, DUR_OW_QUARTER

    ; Bar 3: F-G progression
    .byte NOTE_F3, DUR_OW_QUARTER
    .byte NOTE_G3, DUR_OW_QUARTER
    .byte NOTE_A3, DUR_OW_QUARTER

    ; Bar 4: Em chord
    .byte NOTE_G3, DUR_OW_QUARTER
    .byte NOTE_E3, DUR_OW_QUARTER
    .byte NOTE_B3, DUR_OW_QUARTER

    ; Bar 5: Variation
    .byte NOTE_C4, DUR_OW_EIGHTH
    .byte NOTE_E4, DUR_OW_EIGHTH
    .byte NOTE_A4, DUR_OW_QUARTER
    .byte NOTE_G4, DUR_OW_QUARTER

    ; Bar 6: G chord
    .byte NOTE_D4, DUR_OW_QUARTER
    .byte NOTE_G4, DUR_OW_QUARTER
    .byte NOTE_B4, DUR_OW_QUARTER

    ; Bar 7: Counter movement
    .byte NOTE_C4, DUR_OW_EIGHTH
    .byte NOTE_D4, DUR_OW_EIGHTH
    .byte NOTE_E4, DUR_OW_EIGHTH
    .byte NOTE_F4, DUR_OW_EIGHTH
    .byte NOTE_G4, DUR_OW_QUARTER

    ; Bar 8: Resolution
    .byte NOTE_A3, DUR_OW_QUARTER
    .byte NOTE_C4, DUR_OW_QUARTER
    .byte NOTE_A3, DUR_OW_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Triangle Channel — Bass Line (Instrument 2)
; ==========================================================
.export music_overworld_triangle
music_overworld_triangle:
    ; Walking bass pattern
    ; Bar 1: A root
    .byte NOTE_A3, DUR_OW_QUARTER
    .byte NOTE_A3, DUR_OW_EIGHTH
    .byte NOTE_A3, DUR_OW_EIGHTH
    .byte NOTE_A3, DUR_OW_QUARTER

    ; Bar 2: C root
    .byte NOTE_C3, DUR_OW_QUARTER
    .byte NOTE_C3, DUR_OW_EIGHTH
    .byte NOTE_E3, DUR_OW_EIGHTH
    .byte NOTE_G3, DUR_OW_QUARTER

    ; Bar 3: F-G bass
    .byte NOTE_F3, DUR_OW_QUARTER
    .byte NOTE_G3, DUR_OW_QUARTER
    .byte NOTE_A3, DUR_OW_QUARTER

    ; Bar 4: E root
    .byte NOTE_E3, DUR_OW_QUARTER
    .byte NOTE_E3, DUR_OW_EIGHTH
    .byte NOTE_G3, DUR_OW_EIGHTH
    .byte NOTE_E3, DUR_OW_QUARTER

    ; Bar 5: A pattern
    .byte NOTE_A3, DUR_OW_EIGHTH
    .byte NOTE_A3, DUR_OW_EIGHTH
    .byte NOTE_C3, DUR_OW_EIGHTH
    .byte NOTE_E3, DUR_OW_EIGHTH
    .byte NOTE_A3, DUR_OW_QUARTER

    ; Bar 6: G pattern
    .byte NOTE_G3, DUR_OW_QUARTER
    .byte NOTE_G3, DUR_OW_EIGHTH
    .byte NOTE_B3, DUR_OW_EIGHTH
    .byte NOTE_D3, DUR_OW_QUARTER

    ; Bar 7: Ascending
    .byte NOTE_F3, DUR_OW_EIGHTH
    .byte NOTE_G3, DUR_OW_EIGHTH
    .byte NOTE_A3, DUR_OW_EIGHTH
    .byte NOTE_B3, DUR_OW_EIGHTH
    .byte NOTE_C4, DUR_OW_QUARTER

    ; Bar 8: Resolution to A
    .byte NOTE_A3, DUR_OW_QUARTER
    .byte NOTE_E3, DUR_OW_QUARTER
    .byte NOTE_A3, DUR_OW_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Noise Channel — Percussion (Instrument 3)
; ==========================================================
.export music_overworld_noise
music_overworld_noise:
    ; Simple hi-hat pattern on off-beats
    ; Bar 1
    .byte $10, DUR_OW_EIGHTH  ; Hi-hat
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    ; Bar 2
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    ; Bars 3-8: Repeat pattern
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH
    .byte $10, DUR_OW_EIGHTH
    .byte NOTE_REST, DUR_OW_EIGHTH

    ; Loop back
    .byte NOTE_LOOP, $00

; Track metadata
.export music_overworld_tempo
music_overworld_tempo:
    .byte 140  ; BPM

.export music_overworld_channels
music_overworld_channels:
    .word music_overworld_pulse1
    .word music_overworld_pulse2
    .word music_overworld_triangle
    .word music_overworld_noise
