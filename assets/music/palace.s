; ==========================================================
; Palace/Dungeon Theme — Zelda 2B
; ==========================================================
; Tempo: ~120 BPM
; Key: D minor
; Style: Tense, mysterious, dungeon exploration
; Inspired by Zelda 2 palace theme but original composition
;
; At 120 BPM: 1 beat = 30 frames
; ==========================================================

.include "instruments.s"

.segment "PRG_FIXED_C"

; Duration constants for 120 BPM
DUR_PAL_QUARTER = 30
DUR_PAL_EIGHTH = 15
DUR_PAL_SIXTEENTH = 8
DUR_PAL_HALF = 60
DUR_PAL_DOTTED_QUARTER = 45

; ==========================================================
; Pulse 1 Channel — Main Melody (Instrument 0: Lead Square)
; ==========================================================
.export music_palace_pulse1
music_palace_pulse1:
    ; Ominous descending pattern
    ; Bar 1: D minor arpeggio descent
    .byte NOTE_D5, DUR_PAL_EIGHTH
    .byte NOTE_A4, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_EIGHTH
    .byte NOTE_D4, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_QUARTER

    ; Bar 2: Tension build
    .byte NOTE_E4, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_EIGHTH
    .byte NOTE_G4, DUR_PAL_EIGHTH
    .byte NOTE_A4, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_QUARTER

    ; Bar 3: Minor second tension (D-Eb)
    .byte NOTE_D4, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_SIXTEENTH
    .byte $33, DUR_PAL_SIXTEENTH  ; Eb4 (D# = $33)
    .byte NOTE_D4, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_SIXTEENTH
    .byte $33, DUR_PAL_SIXTEENTH
    .byte NOTE_D4, DUR_PAL_QUARTER

    ; Bar 4: Ascending phrase
    .byte NOTE_D4, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_EIGHTH
    .byte NOTE_A4, DUR_PAL_EIGHTH
    .byte $3D, DUR_PAL_EIGHTH  ; Db5 (C#5)
    .byte NOTE_D5, DUR_PAL_QUARTER

    ; Bar 5: Variation with chromatic touch
    .byte NOTE_D5, DUR_PAL_EIGHTH
    .byte $4B, DUR_PAL_EIGHTH  ; Eb5 (D#5)
    .byte NOTE_D5, DUR_PAL_EIGHTH
    .byte NOTE_A4, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_QUARTER

    ; Bar 6: Sparse, echoing
    .byte NOTE_G4, DUR_PAL_QUARTER
    .byte NOTE_REST, DUR_PAL_EIGHTH
    .byte NOTE_A4, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_QUARTER

    ; Bar 7: Building tension
    .byte NOTE_A4, DUR_PAL_EIGHTH
    .byte $3D, DUR_PAL_EIGHTH  ; Db5
    .byte NOTE_D5, DUR_PAL_EIGHTH
    .byte $4B, DUR_PAL_EIGHTH  ; Eb5
    .byte NOTE_F5, DUR_PAL_QUARTER

    ; Bar 8: Resolution (incomplete, leaves tension)
    .byte NOTE_D5, DUR_PAL_QUARTER
    .byte NOTE_A4, DUR_PAL_QUARTER
    .byte NOTE_D4, DUR_PAL_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Pulse 2 Channel — Harmony (Instrument 5: Echo Square)
; ==========================================================
.export music_palace_pulse2
music_palace_pulse2:
    ; Sustained chords and counter-melody
    ; Bar 1: D minor chord tones
    .byte NOTE_D4, DUR_PAL_QUARTER
    .byte NOTE_F4, DUR_PAL_QUARTER
    .byte NOTE_A3, DUR_PAL_QUARTER

    ; Bar 2: Tension harmony
    .byte NOTE_A3, DUR_PAL_QUARTER
    .byte NOTE_C4, DUR_PAL_QUARTER
    .byte NOTE_F3, DUR_PAL_QUARTER

    ; Bar 3: Dissonant hold
    .byte NOTE_D3, DUR_PAL_HALF
    .byte $33, DUR_PAL_QUARTER  ; Eb3 (half-step dissonance)

    ; Bar 4: Ascending with main melody
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_F3, DUR_PAL_EIGHTH
    .byte NOTE_A3, DUR_PAL_EIGHTH
    .byte NOTE_D4, DUR_PAL_EIGHTH
    .byte NOTE_A3, DUR_PAL_QUARTER

    ; Bar 5: Echo pattern
    .byte NOTE_REST, DUR_PAL_EIGHTH
    .byte NOTE_D4, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_QUARTER

    ; Bar 6: Sparse sustains
    .byte NOTE_G3, DUR_PAL_HALF
    .byte NOTE_REST, DUR_PAL_QUARTER

    ; Bar 7: Minor thirds
    .byte NOTE_F3, DUR_PAL_EIGHTH
    .byte NOTE_A3, DUR_PAL_EIGHTH
    .byte NOTE_D4, DUR_PAL_EIGHTH
    .byte NOTE_F4, DUR_PAL_EIGHTH
    .byte NOTE_A4, DUR_PAL_QUARTER

    ; Bar 8: Resolution
    .byte NOTE_D4, DUR_PAL_QUARTER
    .byte NOTE_F3, DUR_PAL_QUARTER
    .byte NOTE_D3, DUR_PAL_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Triangle Channel — Bass Line (Instrument 2)
; ==========================================================
.export music_palace_triangle
music_palace_triangle:
    ; Deep, ominous bass pattern
    ; Bar 1: Low D pedal tone
    .byte NOTE_D3, DUR_PAL_QUARTER
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_D3, DUR_PAL_QUARTER

    ; Bar 2: Movement
    .byte NOTE_F3, DUR_PAL_QUARTER
    .byte NOTE_E3, DUR_PAL_QUARTER
    .byte NOTE_D3, DUR_PAL_QUARTER

    ; Bar 3: Pedal with chromatic
    .byte NOTE_D3, DUR_PAL_QUARTER
    .byte $31, DUR_PAL_EIGHTH  ; Eb3
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_D3, DUR_PAL_QUARTER

    ; Bar 4: Ascending bass
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_F3, DUR_PAL_EIGHTH
    .byte NOTE_A3, DUR_PAL_QUARTER
    .byte NOTE_D3, DUR_PAL_QUARTER

    ; Bar 5: Variation
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_A3, DUR_PAL_EIGHTH
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_A3, DUR_PAL_EIGHTH
    .byte NOTE_D3, DUR_PAL_QUARTER

    ; Bar 6: G minor feel
    .byte NOTE_G3, DUR_PAL_QUARTER
    .byte NOTE_G3, DUR_PAL_EIGHTH
    .byte NOTE_D3, DUR_PAL_EIGHTH
    .byte NOTE_G3, DUR_PAL_QUARTER

    ; Bar 7: Tension build
    .byte NOTE_A3, DUR_PAL_EIGHTH
    .byte NOTE_G3, DUR_PAL_EIGHTH
    .byte NOTE_F3, DUR_PAL_EIGHTH
    .byte NOTE_E3, DUR_PAL_EIGHTH
    .byte NOTE_D3, DUR_PAL_QUARTER

    ; Bar 8: Return to root
    .byte NOTE_D3, DUR_PAL_QUARTER
    .byte NOTE_A3, DUR_PAL_QUARTER
    .byte NOTE_D3, DUR_PAL_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Noise Channel — Ambient Percussion (Instrument 3)
; ==========================================================
.export music_palace_noise
music_palace_noise:
    ; Sparse, atmospheric percussion
    ; Bar 1: Low rumble on beat 1
    .byte $08, DUR_PAL_EIGHTH  ; Low noise
    .byte NOTE_REST, DUR_PAL_HALF
    .byte NOTE_REST, DUR_PAL_EIGHTH

    ; Bar 2: Echo on beat 3
    .byte NOTE_REST, DUR_PAL_QUARTER
    .byte NOTE_REST, DUR_PAL_QUARTER
    .byte $08, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_EIGHTH

    ; Bar 3: Minimal
    .byte $10, DUR_PAL_EIGHTH  ; Hi noise (drip/echo)
    .byte NOTE_REST, DUR_PAL_QUARTER
    .byte NOTE_REST, DUR_PAL_EIGHTH
    .byte $10, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_EIGHTH

    ; Bar 4: Low rumble
    .byte $08, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_HALF
    .byte NOTE_REST, DUR_PAL_EIGHTH

    ; Bars 5-8: Variation of pattern
    .byte NOTE_REST, DUR_PAL_QUARTER
    .byte $10, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_EIGHTH
    .byte $10, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_EIGHTH

    .byte $08, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_QUARTER
    .byte NOTE_REST, DUR_PAL_EIGHTH
    .byte $08, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_EIGHTH

    .byte NOTE_REST, DUR_PAL_QUARTER
    .byte $10, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_QUARTER

    .byte $08, DUR_PAL_EIGHTH
    .byte NOTE_REST, DUR_PAL_HALF
    .byte NOTE_REST, DUR_PAL_EIGHTH

    ; Loop back
    .byte NOTE_LOOP, $00

; Track metadata
.export music_palace_tempo
music_palace_tempo:
    .byte 120  ; BPM

.export music_palace_channels
music_palace_channels:
    .word music_palace_pulse1
    .word music_palace_pulse2
    .word music_palace_triangle
    .word music_palace_noise
