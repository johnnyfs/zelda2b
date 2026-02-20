; ==========================================================
; Boss Battle Theme — Zelda 2B
; ==========================================================
; Tempo: ~160 BPM
; Key: A minor / C major
; Style: Intense, driving, fast pulse patterns
; Epic boss battle feel
;
; At 160 BPM: 1 beat = 22 frames (rounded from 22.5)
; ==========================================================

.include "instruments.s"

.segment "PRG_FIXED_C"

; Duration constants for 160 BPM
DUR_BOSS_QUARTER = 22
DUR_BOSS_EIGHTH = 11
DUR_BOSS_SIXTEENTH = 6
DUR_BOSS_HALF = 44

; ==========================================================
; Pulse 1 Channel — Aggressive Melody (Instrument 0: Lead Square)
; Fast, intense pattern
; ==========================================================
.export music_boss_pulse1
music_boss_pulse1:
    ; Intense opening riff
    ; Bar 1: Fast ascending pattern
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_C5, DUR_BOSS_EIGHTH
    .byte NOTE_D5, DUR_BOSS_EIGHTH
    .byte NOTE_E5, DUR_BOSS_EIGHTH

    ; Bar 2: Aggressive descent
    .byte NOTE_D5, DUR_BOSS_SIXTEENTH
    .byte NOTE_C5, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_EIGHTH
    .byte NOTE_G4, DUR_BOSS_EIGHTH
    .byte NOTE_A4, DUR_BOSS_QUARTER

    ; Bar 3: Chromatic tension
    .byte $41, DUR_BOSS_SIXTEENTH  ; F4
    .byte $43, DUR_BOSS_SIXTEENTH  ; G4
    .byte $44, DUR_BOSS_SIXTEENTH  ; Ab4
    .byte $45, DUR_BOSS_SIXTEENTH  ; A4
    .byte NOTE_C5, DUR_BOSS_EIGHTH
    .byte NOTE_E5, DUR_BOSS_EIGHTH
    .byte NOTE_A5, DUR_BOSS_EIGHTH

    ; Bar 4: Power descent
    .byte NOTE_G5, DUR_BOSS_EIGHTH
    .byte NOTE_E5, DUR_BOSS_EIGHTH
    .byte NOTE_C5, DUR_BOSS_EIGHTH
    .byte NOTE_A4, DUR_BOSS_EIGHTH

    ; Bar 5: Repeat pattern with variation
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_C5, DUR_BOSS_SIXTEENTH
    .byte NOTE_C5, DUR_BOSS_SIXTEENTH
    .byte NOTE_E5, DUR_BOSS_EIGHTH
    .byte NOTE_D5, DUR_BOSS_EIGHTH
    .byte NOTE_C5, DUR_BOSS_EIGHTH

    ; Bar 6: Driving rhythm
    .byte NOTE_A4, DUR_BOSS_EIGHTH
    .byte NOTE_C5, DUR_BOSS_EIGHTH
    .byte NOTE_A4, DUR_BOSS_EIGHTH
    .byte NOTE_G4, DUR_BOSS_EIGHTH

    ; Bar 7: Climax build
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_C5, DUR_BOSS_SIXTEENTH
    .byte NOTE_E5, DUR_BOSS_SIXTEENTH
    .byte NOTE_A5, DUR_BOSS_SIXTEENTH
    .byte NOTE_G5, DUR_BOSS_EIGHTH
    .byte NOTE_F5, DUR_BOSS_EIGHTH
    .byte NOTE_E5, DUR_BOSS_EIGHTH

    ; Bar 8: Resolution with tension
    .byte NOTE_D5, DUR_BOSS_EIGHTH
    .byte NOTE_C5, DUR_BOSS_EIGHTH
    .byte NOTE_A4, DUR_BOSS_QUARTER

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Pulse 2 Channel — Fast Counter-melody (Instrument 6: Stab Square)
; Staccato aggressive harmony
; ==========================================================
.export music_boss_pulse2
music_boss_pulse2:
    ; Staccato counter rhythm
    ; Bar 1: Chord stabs
    .byte NOTE_A3, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_A3, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_C4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_E4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_EIGHTH

    ; Bar 2: Fast harmony
    .byte NOTE_G4, DUR_BOSS_EIGHTH
    .byte NOTE_F4, DUR_BOSS_EIGHTH
    .byte NOTE_E4, DUR_BOSS_EIGHTH
    .byte NOTE_C4, DUR_BOSS_EIGHTH

    ; Bar 3: Aggressive pattern
    .byte NOTE_D4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_E4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_EIGHTH
    .byte NOTE_G4, DUR_BOSS_EIGHTH
    .byte NOTE_E4, DUR_BOSS_EIGHTH

    ; Bar 4: Power chords
    .byte NOTE_C4, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_E3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH

    ; Bar 5: Variation
    .byte NOTE_C4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_E4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_EIGHTH
    .byte NOTE_G4, DUR_BOSS_EIGHTH
    .byte NOTE_F4, DUR_BOSS_EIGHTH

    ; Bar 6: Driving stabs
    .byte NOTE_E4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_A4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_E4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH
    .byte NOTE_C4, DUR_BOSS_SIXTEENTH
    .byte NOTE_REST, DUR_BOSS_SIXTEENTH

    ; Bar 7: Build
    .byte NOTE_F4, DUR_BOSS_EIGHTH
    .byte NOTE_E4, DUR_BOSS_EIGHTH
    .byte NOTE_D4, DUR_BOSS_EIGHTH
    .byte NOTE_C4, DUR_BOSS_EIGHTH

    ; Bar 8: Resolution
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_E4, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_QUARTER

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Triangle Channel — Driving Bass (Instrument 2)
; Fast, pulsing bass line
; ==========================================================
.export music_boss_triangle
music_boss_triangle:
    ; Driving eighth-note bass pattern
    ; Bar 1: A root pulse
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH

    ; Bar 2: Movement
    .byte NOTE_G3, DUR_BOSS_EIGHTH
    .byte NOTE_F3, DUR_BOSS_EIGHTH
    .byte NOTE_E3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH

    ; Bar 3: Fast pattern
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_E3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_C3, DUR_BOSS_EIGHTH

    ; Bar 4: Power bass
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH

    ; Bar 5: Variation
    .byte NOTE_C3, DUR_BOSS_EIGHTH
    .byte NOTE_E3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_C3, DUR_BOSS_EIGHTH

    ; Bar 6: Driving
    .byte NOTE_E3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_E3, DUR_BOSS_EIGHTH
    .byte NOTE_C3, DUR_BOSS_EIGHTH

    ; Bar 7: Build up
    .byte NOTE_F3, DUR_BOSS_EIGHTH
    .byte NOTE_G3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_C4, DUR_BOSS_EIGHTH

    ; Bar 8: Resolution
    .byte NOTE_A3, DUR_BOSS_EIGHTH
    .byte NOTE_E3, DUR_BOSS_EIGHTH
    .byte NOTE_A3, DUR_BOSS_QUARTER

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Noise Channel — Intense Drums (Instrument 3)
; Fast, driving percussion
; ==========================================================
.export music_boss_noise
music_boss_noise:
    ; Aggressive drum pattern
    ; Bar 1: Fast hi-hat with accents
    .byte $08, DUR_BOSS_SIXTEENTH  ; Kick
    .byte $10, DUR_BOSS_SIXTEENTH  ; Hi-hat
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_SIXTEENTH  ; Kick
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH

    ; Bar 2: Continue pattern
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH

    ; Bar 3: Intense pattern
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH

    ; Bar 4: Power hits
    .byte $08, DUR_BOSS_EIGHTH
    .byte $08, DUR_BOSS_EIGHTH
    .byte $08, DUR_BOSS_EIGHTH
    .byte $10, DUR_BOSS_EIGHTH

    ; Bars 5-8: Repeat driving pattern
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH

    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH

    .byte $08, DUR_BOSS_EIGHTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $10, DUR_BOSS_SIXTEENTH
    .byte $08, DUR_BOSS_EIGHTH
    .byte $10, DUR_BOSS_EIGHTH

    .byte $08, DUR_BOSS_EIGHTH
    .byte $10, DUR_BOSS_EIGHTH
    .byte $08, DUR_BOSS_EIGHTH
    .byte $08, DUR_BOSS_EIGHTH

    ; Loop back
    .byte NOTE_LOOP, $00

; Track metadata
.export music_boss_tempo
music_boss_tempo:
    .byte 160  ; BPM

.export music_boss_channels
music_boss_channels:
    .word music_boss_pulse1
    .word music_boss_pulse2
    .word music_boss_triangle
    .word music_boss_noise
