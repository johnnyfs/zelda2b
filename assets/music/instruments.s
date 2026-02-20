; ==========================================================
; NES 2A03 Instrument Definitions for Zelda 2B
; ==========================================================
; This file defines instrument parameters for the FamiStudio engine.
; Each instrument consists of:
;   - Duty cycle (0-3 for pulse channels, 0 for triangle/noise)
;   - Volume envelope: attack, sustain, decay, release (4 bytes)
;   - Pitch envelope: enabled flag + pitch offset table
;
; For simplified format, we use:
;   Byte 0: Duty cycle (pulse) or waveform type
;   Byte 1: Attack volume (0-15)
;   Byte 2: Sustain volume (0-15)
;   Byte 3: Decay rate (frames)
;   Byte 4: Release rate (frames)
; ==========================================================

.segment "PRG_FIXED_C"

; Instrument table (5 bytes per instrument)
.export instrument_table
instrument_table:
    ; Instrument 0: Lead Square (bright, sustained melody)
    ; Duty 2 (50%), strong attack, long sustain
    .byte $02, $0F, $0C, $08, $04

    ; Instrument 1: Harmony Square (softer counter-melody)
    ; Duty 1 (25%), gentler attack, medium sustain
    .byte $01, $0C, $0A, $06, $03

    ; Instrument 2: Bass Triangle (low notes, always full volume)
    ; Triangle has no volume control, so volume values are ignored
    .byte $00, $0F, $0F, $00, $00

    ; Instrument 3: Percussion (noise channel for drums)
    ; Short, punchy envelope for rhythmic hits
    .byte $00, $0F, $08, $02, $01

    ; Instrument 4: Arpeggio Square (for chord effects)
    ; Duty 2, quick decay for staccato feel
    .byte $02, $0E, $08, $03, $02

    ; Instrument 5: Echo Square (atmospheric)
    ; Duty 0 (12.5%), soft attack, gradual decay
    .byte $00, $08, $06, $0A, $08

    ; Instrument 6: Stab Square (accents, short notes)
    ; Duty 3 (25% inverted), very quick decay
    .byte $03, $0F, $00, $01, $01

    ; Instrument 7: Soft Triangle (melodic bass)
    ; Triangle channel for gentle bass lines
    .byte $00, $0F, $0F, $00, $00

; Instrument count
.export instrument_count
instrument_count:
    .byte 8

; ==========================================================
; Note Value Constants (NTSC MIDI note numbers)
; ==========================================================
; These correspond to MIDI note numbers for reference.
; The actual frequency will be calculated by the sound engine.
; Middle C (C4) = $3C = 60
; ==========================================================

.export NOTE_C3, NOTE_D3, NOTE_E3, NOTE_F3, NOTE_G3, NOTE_A3, NOTE_B3
.export NOTE_C4, NOTE_D4, NOTE_E4, NOTE_F4, NOTE_G4, NOTE_A4, NOTE_B4
.export NOTE_C5, NOTE_D5, NOTE_E5, NOTE_F5, NOTE_G5, NOTE_A5, NOTE_B5
.export NOTE_C6, NOTE_D6, NOTE_E6

NOTE_C3 = $30  ; 48
NOTE_D3 = $32  ; 50
NOTE_E3 = $34  ; 52
NOTE_F3 = $35  ; 53
NOTE_G3 = $37  ; 55
NOTE_A3 = $39  ; 57
NOTE_B3 = $3B  ; 59

NOTE_C4 = $3C  ; 60 (Middle C)
NOTE_D4 = $3E  ; 62
NOTE_E4 = $40  ; 64
NOTE_F4 = $41  ; 65
NOTE_G4 = $43  ; 67
NOTE_A4 = $45  ; 69
NOTE_B4 = $47  ; 71

NOTE_C5 = $48  ; 72
NOTE_D5 = $4A  ; 74
NOTE_E5 = $4C  ; 76
NOTE_F5 = $4D  ; 77
NOTE_G5 = $4F  ; 79
NOTE_A5 = $51  ; 81
NOTE_B5 = $53  ; 83

NOTE_C6 = $54  ; 84
NOTE_D6 = $56  ; 86
NOTE_E6 = $58  ; 88

; Duration Constants (NTSC frames at 60fps)
; These are approximate; actual tempo may vary
.export DUR_WHOLE, DUR_HALF, DUR_QUARTER, DUR_EIGHTH, DUR_SIXTEENTH
.export DUR_DOTTED_HALF, DUR_DOTTED_QUARTER, DUR_DOTTED_EIGHTH

; At 120 BPM (2 beats per second):
; 1 beat = 30 frames
DUR_WHOLE = 120      ; 4 beats
DUR_HALF = 60        ; 2 beats
DUR_QUARTER = 30     ; 1 beat
DUR_EIGHTH = 15      ; 1/2 beat
DUR_SIXTEENTH = 8    ; 1/4 beat (rounded)

DUR_DOTTED_HALF = 90      ; 3 beats
DUR_DOTTED_QUARTER = 45   ; 1.5 beats
DUR_DOTTED_EIGHTH = 22    ; 3/4 beat (rounded)

; Special marker values
.export NOTE_REST, NOTE_END, NOTE_LOOP
NOTE_REST = $00   ; Rest (silence)
NOTE_END = $FF    ; End of track
NOTE_LOOP = $FE   ; Loop back to start
