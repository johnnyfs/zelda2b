; ==========================================================
; Cave Theme — Zelda 2B
; ==========================================================
; Tempo: ~90 BPM
; Key: E minor
; Style: Dark, sparse, echoing, minimal instrumentation
; Inspired by Zelda cave/dungeon ambience
;
; At 90 BPM: 1 beat = 40 frames
; ==========================================================

.include "instruments.s"

.segment "PRG_FIXED_C"

; Duration constants for 90 BPM
DUR_CAVE_QUARTER = 40
DUR_CAVE_EIGHTH = 20
DUR_CAVE_SIXTEENTH = 10
DUR_CAVE_HALF = 80
DUR_CAVE_WHOLE = 160

; ==========================================================
; Pulse 1 Channel — Sparse Melody (Instrument 5: Echo Square)
; Very minimal, echoing notes
; ==========================================================
.export music_cave_pulse1
music_cave_pulse1:
    ; Very sparse, echoing pattern
    ; Bar 1: Single note, long silence
    .byte NOTE_E4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 2: Echo response
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte NOTE_E4, DUR_CAVE_SIXTEENTH
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_SIXTEENTH

    ; Bar 3: Higher echo
    .byte NOTE_B4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte NOTE_REST, DUR_CAVE_EIGHTH
    .byte NOTE_G4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 4: Descending
    .byte NOTE_E4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 5: Variation
    .byte NOTE_D4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte NOTE_REST, DUR_CAVE_EIGHTH
    .byte NOTE_E4, DUR_CAVE_SIXTEENTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_SIXTEENTH

    ; Bar 6: Silence and echo
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_G4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 7: High sustained note (eerie)
    .byte NOTE_B4, DUR_CAVE_QUARTER
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte NOTE_REST, DUR_CAVE_HALF

    ; Bar 8: Return to root
    .byte NOTE_E4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Pulse 2 Channel — Minimal Harmony (Instrument 5: Echo Square)
; Sparse counter-echoes
; ==========================================================
.export music_cave_pulse2
music_cave_pulse2:
    ; Very minimal harmony, mostly rests
    ; Bar 1: Silence
    .byte NOTE_REST, DUR_CAVE_WHOLE

    ; Bar 2: Single echo
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_G3, DUR_CAVE_SIXTEENTH
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte NOTE_REST, DUR_CAVE_SIXTEENTH

    ; Bar 3: Answer
    .byte NOTE_REST, DUR_CAVE_EIGHTH
    .byte NOTE_D4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_HALF

    ; Bar 4: Silence
    .byte NOTE_REST, DUR_CAVE_WHOLE

    ; Bar 5: Low note
    .byte NOTE_E3, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 6: High echo
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte NOTE_B3, DUR_CAVE_SIXTEENTH
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_SIXTEENTH

    ; Bar 7: Silence mostly
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte NOTE_D4, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 8: Resolution
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_E3, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Triangle Channel — Deep Bass (Instrument 2)
; Very low, sustained, atmospheric
; ==========================================================
.export music_cave_triangle
music_cave_triangle:
    ; Deep, droning bass notes
    ; Bar 1: Low E pedal
    .byte NOTE_E3, DUR_CAVE_WHOLE

    ; Bar 2: Sustain
    .byte NOTE_E3, DUR_CAVE_WHOLE

    ; Bar 3: Subtle movement
    .byte NOTE_E3, DUR_CAVE_HALF
    .byte NOTE_G3, DUR_CAVE_QUARTER
    .byte NOTE_E3, DUR_CAVE_QUARTER

    ; Bar 4: Back to root
    .byte NOTE_E3, DUR_CAVE_WHOLE

    ; Bar 5: Lower D for variation
    .byte NOTE_D3, DUR_CAVE_HALF
    .byte NOTE_E3, DUR_CAVE_HALF

    ; Bar 6: Sustain
    .byte NOTE_G3, DUR_CAVE_HALF
    .byte NOTE_E3, DUR_CAVE_HALF

    ; Bar 7: High tension
    .byte NOTE_B3, DUR_CAVE_QUARTER
    .byte NOTE_A3, DUR_CAVE_QUARTER
    .byte NOTE_G3, DUR_CAVE_HALF

    ; Bar 8: Resolution
    .byte NOTE_E3, DUR_CAVE_WHOLE

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Noise Channel — Dripping/Ambient Sounds (Instrument 3)
; Very sparse, atmospheric noise
; ==========================================================
.export music_cave_noise
music_cave_noise:
    ; Water drips and ambient cave sounds
    ; Bar 1: Drip
    .byte $10, DUR_CAVE_EIGHTH  ; High noise (drip)
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 2: Another drip
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte $10, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 3: Echo drip
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte $10, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 4: Silence
    .byte NOTE_REST, DUR_CAVE_WHOLE

    ; Bar 5: Low rumble
    .byte $08, DUR_CAVE_EIGHTH  ; Low noise (distant rumble)
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 6: Drip pattern
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte $10, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte $10, DUR_CAVE_EIGHTH

    ; Bar 7: Silence mostly
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte NOTE_REST, DUR_CAVE_QUARTER
    .byte $10, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Bar 8: Final drip
    .byte NOTE_REST, DUR_CAVE_HALF
    .byte $10, DUR_CAVE_EIGHTH
    .byte NOTE_REST, DUR_CAVE_EIGHTH

    ; Loop back
    .byte NOTE_LOOP, $00

; Track metadata
.export music_cave_tempo
music_cave_tempo:
    .byte 90  ; BPM

.export music_cave_channels
music_cave_channels:
    .word music_cave_pulse1
    .word music_cave_pulse2
    .word music_cave_triangle
    .word music_cave_noise
