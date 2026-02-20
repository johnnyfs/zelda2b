; ==========================================================
; Title Screen Theme — Zelda 2B
; ==========================================================
; Tempo: ~120 BPM
; Key: C major
; Style: Grand, anticipatory, heroic
; Short intro phrase, then loop
;
; At 120 BPM: 1 beat = 30 frames
; ==========================================================

.include "instruments.s"

.segment "PRG_FIXED_C"

; Duration constants for 120 BPM
DUR_TITLE_QUARTER = 30
DUR_TITLE_EIGHTH = 15
DUR_TITLE_SIXTEENTH = 8
DUR_TITLE_HALF = 60
DUR_TITLE_DOTTED_HALF = 90
DUR_TITLE_WHOLE = 120

; ==========================================================
; Pulse 1 Channel — Heroic Fanfare (Instrument 0: Lead Square)
; Grand, triumphant melody
; ==========================================================
.export music_title_pulse1
music_title_pulse1:
    ; Intro: Grand fanfare (4 bars, then loop on main theme)
    ; Bar 1: Heroic opening
    .byte NOTE_C4, DUR_TITLE_QUARTER
    .byte NOTE_E4, DUR_TITLE_QUARTER
    .byte NOTE_G4, DUR_TITLE_QUARTER
    .byte NOTE_C5, DUR_TITLE_QUARTER

    ; Bar 2: Ascending triumph
    .byte NOTE_D5, DUR_TITLE_EIGHTH
    .byte NOTE_E5, DUR_TITLE_EIGHTH
    .byte NOTE_F5, DUR_TITLE_QUARTER
    .byte NOTE_E5, DUR_TITLE_QUARTER
    .byte NOTE_D5, DUR_TITLE_QUARTER

    ; Bar 3: Grand phrase
    .byte NOTE_C5, DUR_TITLE_EIGHTH
    .byte NOTE_D5, DUR_TITLE_EIGHTH
    .byte NOTE_E5, DUR_TITLE_QUARTER
    .byte NOTE_G5, DUR_TITLE_HALF

    ; Bar 4: Resolution to main loop point
    .byte NOTE_E5, DUR_TITLE_QUARTER
    .byte NOTE_C5, DUR_TITLE_QUARTER
    .byte NOTE_G4, DUR_TITLE_HALF

    ; MAIN LOOP starts here (bars 5-8)
    ; Bar 5: Main theme melody
    .byte NOTE_E5, DUR_TITLE_EIGHTH
    .byte NOTE_D5, DUR_TITLE_EIGHTH
    .byte NOTE_C5, DUR_TITLE_QUARTER
    .byte NOTE_E5, DUR_TITLE_QUARTER
    .byte NOTE_G5, DUR_TITLE_QUARTER

    ; Bar 6: Variation
    .byte NOTE_F5, DUR_TITLE_EIGHTH
    .byte NOTE_E5, DUR_TITLE_EIGHTH
    .byte NOTE_D5, DUR_TITLE_QUARTER
    .byte NOTE_C5, DUR_TITLE_QUARTER
    .byte NOTE_D5, DUR_TITLE_QUARTER

    ; Bar 7: Building anticipation
    .byte NOTE_E5, DUR_TITLE_EIGHTH
    .byte NOTE_F5, DUR_TITLE_EIGHTH
    .byte NOTE_G5, DUR_TITLE_EIGHTH
    .byte NOTE_A5, DUR_TITLE_EIGHTH
    .byte NOTE_G5, DUR_TITLE_QUARTER
    .byte NOTE_E5, DUR_TITLE_QUARTER

    ; Bar 8: Heroic conclusion
    .byte NOTE_C5, DUR_TITLE_QUARTER
    .byte NOTE_G4, DUR_TITLE_QUARTER
    .byte NOTE_E4, DUR_TITLE_HALF

    ; Loop back to bar 5 (main theme loop)
    .byte NOTE_LOOP, $00

; ==========================================================
; Pulse 2 Channel — Harmony (Instrument 1: Harmony Square)
; Supporting harmonies
; ==========================================================
.export music_title_pulse2
music_title_pulse2:
    ; Intro harmony
    ; Bar 1: C major chord
    .byte NOTE_E3, DUR_TITLE_QUARTER
    .byte NOTE_G3, DUR_TITLE_QUARTER
    .byte NOTE_C4, DUR_TITLE_QUARTER
    .byte NOTE_E4, DUR_TITLE_QUARTER

    ; Bar 2: G major chord movement
    .byte NOTE_G3, DUR_TITLE_EIGHTH
    .byte NOTE_B3, DUR_TITLE_EIGHTH
    .byte NOTE_D4, DUR_TITLE_QUARTER
    .byte NOTE_C4, DUR_TITLE_QUARTER
    .byte NOTE_B3, DUR_TITLE_QUARTER

    ; Bar 3: Am to C progression
    .byte NOTE_A3, DUR_TITLE_EIGHTH
    .byte NOTE_B3, DUR_TITLE_EIGHTH
    .byte NOTE_C4, DUR_TITLE_QUARTER
    .byte NOTE_E4, DUR_TITLE_HALF

    ; Bar 4: Resolution
    .byte NOTE_C4, DUR_TITLE_QUARTER
    .byte NOTE_E3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_HALF

    ; MAIN LOOP harmony
    ; Bar 5: Thirds harmony
    .byte NOTE_C4, DUR_TITLE_EIGHTH
    .byte NOTE_B3, DUR_TITLE_EIGHTH
    .byte NOTE_A3, DUR_TITLE_QUARTER
    .byte NOTE_C4, DUR_TITLE_QUARTER
    .byte NOTE_E4, DUR_TITLE_QUARTER

    ; Bar 6: Supporting line
    .byte NOTE_D4, DUR_TITLE_EIGHTH
    .byte NOTE_C4, DUR_TITLE_EIGHTH
    .byte NOTE_B3, DUR_TITLE_QUARTER
    .byte NOTE_A3, DUR_TITLE_QUARTER
    .byte NOTE_B3, DUR_TITLE_QUARTER

    ; Bar 7: Counter-melody
    .byte NOTE_C4, DUR_TITLE_EIGHTH
    .byte NOTE_D4, DUR_TITLE_EIGHTH
    .byte NOTE_E4, DUR_TITLE_EIGHTH
    .byte NOTE_F4, DUR_TITLE_EIGHTH
    .byte NOTE_E4, DUR_TITLE_QUARTER
    .byte NOTE_C4, DUR_TITLE_QUARTER

    ; Bar 8: Harmony resolution
    .byte NOTE_E3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_QUARTER
    .byte NOTE_G3, DUR_TITLE_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Triangle Channel — Bass Foundation (Instrument 2)
; Strong, heroic bass line
; ==========================================================
.export music_title_triangle
music_title_triangle:
    ; Intro bass
    ; Bar 1: C root strong beats
    .byte NOTE_C3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_QUARTER

    ; Bar 2: G bass movement
    .byte NOTE_G3, DUR_TITLE_QUARTER
    .byte NOTE_D3, DUR_TITLE_QUARTER
    .byte NOTE_G3, DUR_TITLE_QUARTER
    .byte NOTE_B3, DUR_TITLE_QUARTER

    ; Bar 3: Am to C
    .byte NOTE_A3, DUR_TITLE_QUARTER
    .byte NOTE_E3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_HALF

    ; Bar 4: Resolution bass
    .byte NOTE_C3, DUR_TITLE_QUARTER
    .byte NOTE_E3, DUR_TITLE_QUARTER
    .byte NOTE_G3, DUR_TITLE_HALF

    ; MAIN LOOP bass
    ; Bar 5: Driving pattern
    .byte NOTE_C3, DUR_TITLE_EIGHTH
    .byte NOTE_C3, DUR_TITLE_EIGHTH
    .byte NOTE_E3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_QUARTER
    .byte NOTE_G3, DUR_TITLE_QUARTER

    ; Bar 6: Movement
    .byte NOTE_F3, DUR_TITLE_QUARTER
    .byte NOTE_D3, DUR_TITLE_QUARTER
    .byte NOTE_G3, DUR_TITLE_QUARTER
    .byte NOTE_B3, DUR_TITLE_QUARTER

    ; Bar 7: Build
    .byte NOTE_C3, DUR_TITLE_EIGHTH
    .byte NOTE_D3, DUR_TITLE_EIGHTH
    .byte NOTE_E3, DUR_TITLE_EIGHTH
    .byte NOTE_F3, DUR_TITLE_EIGHTH
    .byte NOTE_G3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_QUARTER

    ; Bar 8: Strong resolution
    .byte NOTE_C3, DUR_TITLE_QUARTER
    .byte NOTE_G3, DUR_TITLE_QUARTER
    .byte NOTE_C3, DUR_TITLE_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; ==========================================================
; Noise Channel — Triumphant Percussion (Instrument 3)
; Fanfare-style drums
; ==========================================================
.export music_title_noise
music_title_noise:
    ; Intro drums - fanfare accents
    ; Bar 1: Strong beats
    .byte $08, DUR_TITLE_QUARTER  ; Kick
    .byte $08, DUR_TITLE_QUARTER
    .byte $08, DUR_TITLE_QUARTER
    .byte $08, DUR_TITLE_QUARTER

    ; Bar 2: With cymbals
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH  ; Cymbal
    .byte $08, DUR_TITLE_QUARTER
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_QUARTER

    ; Bar 3: Building
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_QUARTER
    .byte $10, DUR_TITLE_HALF  ; Sustained cymbal

    ; Bar 4: Transition to loop
    .byte $08, DUR_TITLE_QUARTER
    .byte $08, DUR_TITLE_QUARTER
    .byte $08, DUR_TITLE_HALF

    ; MAIN LOOP drums
    ; Bar 5: Steady beat with hi-hat
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH

    ; Bar 6: Continue pattern
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH

    ; Bar 7: Build with accents
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_EIGHTH
    .byte $10, DUR_TITLE_EIGHTH
    .byte $08, DUR_TITLE_QUARTER
    .byte $10, DUR_TITLE_QUARTER

    ; Bar 8: Strong ending
    .byte $08, DUR_TITLE_QUARTER
    .byte $10, DUR_TITLE_QUARTER
    .byte $08, DUR_TITLE_HALF

    ; Loop back
    .byte NOTE_LOOP, $00

; Track metadata
.export music_title_tempo
music_title_tempo:
    .byte 120  ; BPM

.export music_title_channels
music_title_channels:
    .word music_title_pulse1
    .word music_title_pulse2
    .word music_title_triangle
    .word music_title_noise
