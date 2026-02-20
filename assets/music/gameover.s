; ==========================================================
; Game Over Theme — Zelda 2B
; ==========================================================
; Tempo: ~80 BPM
; Key: A minor
; Style: Short, somber, melancholic
; 4 bars total, does NOT loop (plays once and ends)
;
; At 80 BPM: 1 beat = 45 frames
; ==========================================================

.include "instruments.s"

.segment "PRG_FIXED_C"

; Duration constants for 80 BPM
DUR_GO_QUARTER = 45
DUR_GO_EIGHTH = 22
DUR_GO_HALF = 90
DUR_GO_DOTTED_HALF = 135
DUR_GO_WHOLE = 180

; ==========================================================
; Pulse 1 Channel — Sad Melody (Instrument 1: Harmony Square)
; Gentle, melancholic
; ==========================================================
.export music_gameover_pulse1
music_gameover_pulse1:
    ; Bar 1: Descending phrase of defeat
    .byte NOTE_A4, DUR_GO_QUARTER
    .byte NOTE_G4, DUR_GO_QUARTER
    .byte NOTE_F4, DUR_GO_QUARTER
    .byte NOTE_E4, DUR_GO_QUARTER

    ; Bar 2: Sigh-like descent
    .byte NOTE_D4, DUR_GO_EIGHTH
    .byte NOTE_E4, DUR_GO_EIGHTH
    .byte NOTE_F4, DUR_GO_QUARTER
    .byte NOTE_E4, DUR_GO_HALF

    ; Bar 3: Resignation
    .byte NOTE_C4, DUR_GO_QUARTER
    .byte NOTE_D4, DUR_GO_QUARTER
    .byte NOTE_E4, DUR_GO_HALF

    ; Bar 4: Final descent to resolution
    .byte NOTE_D4, DUR_GO_QUARTER
    .byte NOTE_C4, DUR_GO_QUARTER
    .byte NOTE_A3, DUR_GO_HALF

    ; End marker (no loop)
    .byte NOTE_END, $00

; ==========================================================
; Pulse 2 Channel — Harmony (Instrument 5: Echo Square)
; Soft, echoing support
; ==========================================================
.export music_gameover_pulse2
music_gameover_pulse2:
    ; Bar 1: Minor chord tones
    .byte NOTE_C4, DUR_GO_QUARTER
    .byte NOTE_E4, DUR_GO_QUARTER
    .byte NOTE_D4, DUR_GO_QUARTER
    .byte NOTE_C4, DUR_GO_QUARTER

    ; Bar 2: Sad harmony
    .byte NOTE_A3, DUR_GO_QUARTER
    .byte NOTE_C4, DUR_GO_QUARTER
    .byte NOTE_B3, DUR_GO_HALF

    ; Bar 3: Supporting descent
    .byte NOTE_A3, DUR_GO_QUARTER
    .byte NOTE_B3, DUR_GO_QUARTER
    .byte NOTE_C4, DUR_GO_HALF

    ; Bar 4: Final resolution
    .byte NOTE_B3, DUR_GO_QUARTER
    .byte NOTE_A3, DUR_GO_QUARTER
    .byte NOTE_E3, DUR_GO_HALF

    ; End marker (no loop)
    .byte NOTE_END, $00

; ==========================================================
; Triangle Channel — Bass (Instrument 2)
; Slow, mournful bass
; ==========================================================
.export music_gameover_triangle
music_gameover_triangle:
    ; Bar 1: Am progression
    .byte NOTE_A3, DUR_GO_HALF
    .byte NOTE_F3, DUR_GO_HALF

    ; Bar 2: Dm to E
    .byte NOTE_D3, DUR_GO_HALF
    .byte NOTE_E3, DUR_GO_HALF

    ; Bar 3: Am
    .byte NOTE_A3, DUR_GO_HALF
    .byte NOTE_C3, DUR_GO_HALF

    ; Bar 4: Final Am resolution
    .byte NOTE_E3, DUR_GO_HALF
    .byte NOTE_A3, DUR_GO_HALF

    ; End marker (no loop)
    .byte NOTE_END, $00

; ==========================================================
; Noise Channel — Minimal (Instrument 3)
; Very sparse, somber
; ==========================================================
.export music_gameover_noise
music_gameover_noise:
    ; Bar 1: Single low beat
    .byte $08, DUR_GO_QUARTER  ; Low thud
    .byte NOTE_REST, DUR_GO_DOTTED_HALF

    ; Bar 2: Another somber beat
    .byte NOTE_REST, DUR_GO_HALF
    .byte $08, DUR_GO_QUARTER
    .byte NOTE_REST, DUR_GO_QUARTER

    ; Bar 3: Minimal
    .byte NOTE_REST, DUR_GO_WHOLE

    ; Bar 4: Final beat of defeat
    .byte NOTE_REST, DUR_GO_HALF
    .byte $08, DUR_GO_QUARTER
    .byte NOTE_REST, DUR_GO_QUARTER

    ; End marker (no loop)
    .byte NOTE_END, $00

; Track metadata
.export music_gameover_tempo
music_gameover_tempo:
    .byte 80  ; BPM

.export music_gameover_channels
music_gameover_channels:
    .word music_gameover_pulse1
    .word music_gameover_pulse2
    .word music_gameover_triangle
    .word music_gameover_noise
