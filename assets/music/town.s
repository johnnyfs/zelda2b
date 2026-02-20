; ==========================================================
; Town Theme — Zelda 2B
; ==========================================================
; Tempo: ~100 BPM
; Key: F major
; Style: Peaceful, warm, safe haven feel
; Inspired by Zelda 2 town theme but original composition
;
; At 100 BPM: 1 beat = 36 frames
; ==========================================================

.include "instruments.s"

.segment "PRG_FIXED_C"

; Duration constants for 100 BPM
DUR_TOWN_QUARTER = 36
DUR_TOWN_EIGHTH = 18
DUR_TOWN_SIXTEENTH = 9
DUR_TOWN_HALF = 72
DUR_TOWN_DOTTED_QUARTER = 54

; ==========================================================
; Pulse 1 Channel — Main Melody (Instrument 1: Harmony Square)
; Softer tone for peaceful feel
; ==========================================================
.export music_town_pulse1
music_town_pulse1:
    ; Gentle, flowing melody
    ; Bar 1: F major opening
    .byte NOTE_F4, DUR_TOWN_EIGHTH
    .byte NOTE_G4, DUR_TOWN_EIGHTH
    .byte NOTE_A4, DUR_TOWN_QUARTER
    .byte NOTE_C5, DUR_TOWN_QUARTER

    ; Bar 2: Descending phrase
    .byte NOTE_A4, DUR_TOWN_EIGHTH
    .byte NOTE_G4, DUR_TOWN_EIGHTH
    .byte NOTE_F4, DUR_TOWN_QUARTER
    .byte NOTE_D4, DUR_TOWN_QUARTER

    ; Bar 3: Rise and fall
    .byte NOTE_E4, DUR_TOWN_EIGHTH
    .byte NOTE_F4, DUR_TOWN_EIGHTH
    .byte NOTE_G4, DUR_TOWN_EIGHTH
    .byte NOTE_A4, DUR_TOWN_EIGHTH
    .byte NOTE_G4, DUR_TOWN_QUARTER

    ; Bar 4: Resolution
    .byte NOTE_F4, DUR_TOWN_QUARTER
    .byte NOTE_A3, DUR_TOWN_EIGHTH
    .byte NOTE_C4, DUR_TOWN_EIGHTH
    .byte NOTE_F4, DUR_TOWN_QUARTER

    ; Bar 5: Variation with higher notes
    .byte NOTE_A4, DUR_TOWN_EIGHTH
    .byte NOTE_C5, DUR_TOWN_EIGHTH
    .byte NOTE_D5, DUR_TOWN_QUARTER
    .byte NOTE_C5, DUR_TOWN_EIGHTH
    .byte NOTE_A4, DUR_TOWN_EIGHTH

    ; Bar 6: Gentle descent
    .byte NOTE_G4, DUR_TOWN_EIGHTH
    .byte NOTE_E4, DUR_TOWN_EIGHTH
    .byte NOTE_C4, DUR_TOWN_QUARTER
    .byte NOTE_E4, DUR_TOWN_QUARTER

    ; Bar 7: Warm phrase
    .byte NOTE_F4, DUR_TOWN_EIGHTH
    .byte NOTE_A4, DUR_TOWN_EIGHTH
    .byte NOTE_C5, DUR_TOWN_EIGHTH
    .byte NOTE_D5, DUR_TOWN_EIGHTH
    .byte NOTE_C5, DUR_TOWN_QUARTER

    ; Bar 8: Calm ending
    .byte NOTE_A4, DUR_TOWN_QUARTER
    .byte NOTE_F4, DUR_TOWN_QUARTER
    .byte NOTE_C4, DUR_TOWN_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Pulse 2 Channel — Accompaniment (Instrument 4: Arpeggio)
; Light arpeggiated chords
; ==========================================================
.export music_town_pulse2
music_town_pulse2:
    ; Arpeggiated chord pattern
    ; Bar 1: F major arpeggio
    .byte NOTE_F3, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_C4, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_F3, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_C4, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_F3, DUR_TOWN_QUARTER

    ; Bar 2: Dm arpeggio
    .byte NOTE_D3, DUR_TOWN_SIXTEENTH
    .byte NOTE_F3, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_F3, DUR_TOWN_SIXTEENTH
    .byte NOTE_D3, DUR_TOWN_SIXTEENTH
    .byte NOTE_F3, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_F3, DUR_TOWN_SIXTEENTH
    .byte NOTE_D3, DUR_TOWN_QUARTER

    ; Bar 3: C major arpeggio
    .byte NOTE_C3, DUR_TOWN_SIXTEENTH
    .byte NOTE_E3, DUR_TOWN_SIXTEENTH
    .byte NOTE_G3, DUR_TOWN_SIXTEENTH
    .byte NOTE_E3, DUR_TOWN_SIXTEENTH
    .byte NOTE_C3, DUR_TOWN_SIXTEENTH
    .byte NOTE_E3, DUR_TOWN_SIXTEENTH
    .byte NOTE_G3, DUR_TOWN_SIXTEENTH
    .byte NOTE_E3, DUR_TOWN_SIXTEENTH
    .byte NOTE_C3, DUR_TOWN_QUARTER

    ; Bar 4: F major return
    .byte NOTE_F3, DUR_TOWN_EIGHTH
    .byte NOTE_A3, DUR_TOWN_EIGHTH
    .byte NOTE_C4, DUR_TOWN_QUARTER
    .byte NOTE_F3, DUR_TOWN_QUARTER

    ; Bar 5: Am arpeggio
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_C4, DUR_TOWN_SIXTEENTH
    .byte NOTE_E4, DUR_TOWN_SIXTEENTH
    .byte NOTE_C4, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_SIXTEENTH
    .byte NOTE_C4, DUR_TOWN_SIXTEENTH
    .byte NOTE_E4, DUR_TOWN_SIXTEENTH
    .byte NOTE_C4, DUR_TOWN_SIXTEENTH
    .byte NOTE_A3, DUR_TOWN_QUARTER

    ; Bar 6: C major
    .byte NOTE_C3, DUR_TOWN_QUARTER
    .byte NOTE_E3, DUR_TOWN_QUARTER
    .byte NOTE_G3, DUR_TOWN_QUARTER

    ; Bar 7: F to C progression
    .byte NOTE_F3, DUR_TOWN_EIGHTH
    .byte NOTE_A3, DUR_TOWN_EIGHTH
    .byte NOTE_C4, DUR_TOWN_EIGHTH
    .byte NOTE_E4, DUR_TOWN_EIGHTH
    .byte NOTE_C4, DUR_TOWN_QUARTER

    ; Bar 8: Peaceful resolution
    .byte NOTE_F3, DUR_TOWN_QUARTER
    .byte NOTE_C3, DUR_TOWN_QUARTER
    .byte NOTE_F3, DUR_TOWN_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Triangle Channel — Bass Line (Instrument 2)
; ==========================================================
.export music_town_triangle
music_town_triangle:
    ; Warm, steady bass
    ; Bar 1: F root
    .byte NOTE_F3, DUR_TOWN_QUARTER
    .byte NOTE_F3, DUR_TOWN_EIGHTH
    .byte NOTE_C3, DUR_TOWN_EIGHTH
    .byte NOTE_F3, DUR_TOWN_QUARTER

    ; Bar 2: D minor
    .byte NOTE_D3, DUR_TOWN_QUARTER
    .byte NOTE_D3, DUR_TOWN_EIGHTH
    .byte NOTE_A3, DUR_TOWN_EIGHTH
    .byte NOTE_D3, DUR_TOWN_QUARTER

    ; Bar 3: C major
    .byte NOTE_C3, DUR_TOWN_QUARTER
    .byte NOTE_G3, DUR_TOWN_EIGHTH
    .byte NOTE_C3, DUR_TOWN_EIGHTH
    .byte NOTE_E3, DUR_TOWN_QUARTER

    ; Bar 4: F return
    .byte NOTE_F3, DUR_TOWN_QUARTER
    .byte NOTE_A3, DUR_TOWN_QUARTER
    .byte NOTE_F3, DUR_TOWN_QUARTER

    ; Bar 5: A minor
    .byte NOTE_A3, DUR_TOWN_QUARTER
    .byte NOTE_E3, DUR_TOWN_QUARTER
    .byte NOTE_A3, DUR_TOWN_QUARTER

    ; Bar 6: C major
    .byte NOTE_C3, DUR_TOWN_QUARTER
    .byte NOTE_E3, DUR_TOWN_EIGHTH
    .byte NOTE_G3, DUR_TOWN_EIGHTH
    .byte NOTE_C3, DUR_TOWN_QUARTER

    ; Bar 7: F to C
    .byte NOTE_F3, DUR_TOWN_EIGHTH
    .byte NOTE_A3, DUR_TOWN_EIGHTH
    .byte NOTE_C3, DUR_TOWN_EIGHTH
    .byte NOTE_E3, DUR_TOWN_EIGHTH
    .byte NOTE_C3, DUR_TOWN_QUARTER

    ; Bar 8: Resolution to F
    .byte NOTE_F3, DUR_TOWN_QUARTER
    .byte NOTE_C3, DUR_TOWN_QUARTER
    .byte NOTE_F3, DUR_TOWN_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Noise Channel — Minimal Percussion (Instrument 3)
; Very subtle, peaceful rhythm
; ==========================================================
.export music_town_noise
music_town_noise:
    ; Gentle, ambient sounds (optional light percussion)
    ; Bars 1-2: Soft hi-hat on beats 2 and 4
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    ; Bars 3-4: Continue pattern
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    ; Bars 5-8: Same gentle pattern
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_QUARTER
    .byte $10, DUR_TOWN_EIGHTH
    .byte NOTE_REST, DUR_TOWN_EIGHTH

    ; Loop back
    .byte NOTE_LOOP, $00

; Track metadata
.export music_town_tempo
music_town_tempo:
    .byte 100  ; BPM

.export music_town_channels
music_town_channels:
    .word music_town_pulse1
    .word music_town_pulse2
    .word music_town_triangle
    .word music_town_noise
