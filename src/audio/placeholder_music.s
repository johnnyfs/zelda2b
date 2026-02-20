; ============================================================================
; placeholder_music.s - Zelda 2 Overworld Theme (FamiStudio engine format)
; ============================================================================
; Transcribed from Zelda 2: The Adventure of Link (NES, 1987) by Akito
; Nakatsuka. Simplified 4-channel arrangement (Pulse1=melody, Pulse2=harmony,
; Triangle=bass, Noise=percussion).
;
; Per project constraint fd6dc004: No original music. All assets sourced from
; existing Zelda games.
;
; Data format notes (FamiStudio tempo mode, standard 2A03, 5 channels):
;   Channel bytecodes:
;     $00       = note off / release
;     $01-$3F   = notes (internal note = byte + 12)
;     $42 lo hi = loop to absolute address
;     $70-$7F   = set volume (lower nibble)
;     $80+even  = set instrument (index = (byte & $7F) >> 1)
;     $80+odd   = wait/repeat (count = (byte & $7F) >> 1 additional rows)
; ============================================================================

; NOTE: This file is .include'd from audio.s, which already sets the segment.
; We're already in PRG_FIXED_C.

; ============================================================================
; ALL constants must be defined BEFORE the first label, because ca65 = defs
; break local (@) label scope.
; ============================================================================

; --- Note byte values ---
; Byte value = FamiStudio internal note - 12
; Octaves: C1=byte 1, C2=byte 13, C3=byte 25, C4=byte 37, C5=byte 49

; Octave 2 (bass)
NOTE_D2  = $03
NOTE_E2  = $05
NOTE_F2  = $06
NOTE_G2  = $08
NOTE_A2  = $0A
NOTE_Bb2 = $0B

; Octave 3
NOTE_C3  = $0D
NOTE_D3  = $0F
NOTE_E3  = $11
NOTE_F3  = $12
NOTE_G3  = $14
NOTE_A3  = $16
NOTE_Bb3 = $17

; Octave 4
NOTE_C4  = $19
NOTE_D4  = $1B
NOTE_E4  = $1D
NOTE_F4  = $1E
NOTE_G4  = $20
NOTE_A4  = $22
NOTE_Bb4 = $23
NOTE_B4  = $24

; Octave 5
NOTE_C5  = $25
NOTE_D5  = $27
NOTE_E5  = $29
NOTE_F5  = $2A
NOTE_G5  = $2C
NOTE_A5  = $2E
NOTE_Bb5 = $2F

; --- Duration (extra rows after a note) ---
; 1 row = 1 tick = 6 frames at 60fps = 100ms. Quarter = 4 rows @ 150 BPM.
WAIT_1   = $83                  ; +1 row  (total 2 = 8th note)
WAIT_2   = $85                  ; +2 rows (total 3 = dotted 8th)
WAIT_3   = $87                  ; +3 rows (total 4 = quarter)
WAIT_5   = $8B                  ; +5 rows (total 6 = dotted quarter)
WAIT_7   = $8F                  ; +7 rows (total 8 = half note)
WAIT_11  = $97                  ; +11 rows (total 12 = dotted half)
WAIT_15  = $9F                  ; +15 rows (total 16 = whole)

; --- Instruments ---
INST_0   = $80                  ; Pulse lead
INST_1   = $82                  ; Pulse harmony
INST_2   = $84                  ; Triangle bass
INST_3   = $86                  ; Noise percussion

; --- Volume ---
VOL_15   = $7F
VOL_12   = $7C
VOL_10   = $7A
VOL_8    = $78

; --- Special ---
NOTE_OFF = $00                  ; Note stop (note value 0 — no pitch)
RELEASE  = $45                  ; Release note opcode (triggers release envelope)
LOOP_CMD = $42

; --- Noise note values ---
NOISE_KICK  = $01
NOISE_SNARE = $04
NOISE_HAT   = $09

; ============================================================================
; Music data entry point (all local labels below are in this scope)
; ============================================================================

music_data_placeholder:
    ; --- Header ---
    .byte 1                             ; Song count: 1
    .word @instruments                  ; Instrument list pointer
    .word @dpcm_samples                 ; DPCM sample list pointer

    ; --- Song 0: "Overworld" ---
    .word @ch_pulse1                    ; Pulse 1 (melody)
    .word @ch_pulse2                    ; Pulse 2 (harmony)
    .word @ch_triangle                  ; Triangle (bass)
    .word @ch_noise                     ; Noise (percussion)
    .word @ch_dpcm_silence              ; DPCM (unused)
    .word @tempo_envelope               ; Tempo envelope pointer
    .byte $00                           ; Tempo/groove index (NTSC)
    .byte $00                           ; Padding

; ============================================================================
; Tempo envelope
; ============================================================================
@tempo_envelope:
    .byte $05                           ; 6 frames/row = 150 BPM (quarter = 4 rows)

; ============================================================================
; Instruments (4 pointers each: volume, arpeggio, duty, pitch)
; ============================================================================
@instruments:
    ; Instrument 0: Pulse Lead
    .word @env_vol_lead
    .word @env_flat_zero
    .word @env_duty_50
    .word @env_flat_pitch

    ; Instrument 1: Pulse Harmony
    .word @env_vol_harmony
    .word @env_flat_zero
    .word @env_duty_25
    .word @env_flat_pitch

    ; Instrument 2: Triangle Bass
    .word @env_vol_tri
    .word @env_flat_zero
    .word @env_flat_zero                ; duty ignored for triangle
    .word @env_flat_pitch

    ; Instrument 3: Noise Percussion
    .word @env_vol_noise
    .word @env_flat_zero
    .word @env_flat_zero
    .word @env_flat_pitch

; ============================================================================
; Envelopes
; ============================================================================
; FamiStudio envelope byte encoding:
;   $80-$FF = output value (actual = byte - 192, so $C0=0, $CF=15)
;   $01-$7F = repeat counter (sustain current value for N more frames)
;   $00     = loop marker, next byte = position to jump to
;
; VOLUME envelopes: byte[0] = release index (0=none). Note-on starts at
; env_ptr=1. On note-off, if byte[0]!=0, env_ptr jumps to byte[0].
;
; ARPEGGIO envelopes: byte[0] = release index. Note-on resets to 0.
;
; DUTY envelopes: byte[0] = release index. Note-on resets to 0.
;
; PITCH envelopes: byte[0] = relative(0)/absolute flag. env_ptr starts at 1.

; --- Pulse lead volume: attack 15, decay to 11, sustain, release to 0 ---
@env_vol_lead:
    .byte $07                           ; [0] release index: jump to [7]
    .byte $CF                           ; [1] attack: vol 15 (note-on start)
    .byte $CD                           ; [2] vol 13
    .byte $CC                           ; [3] vol 12
    .byte $CB                           ; [4] sustain: vol 11
    .byte $00, $04                      ; [5,6] loop to [4] (sustain forever)
    .byte $C0                           ; [7] release: vol 0
    .byte $7F                           ; [8] hold silence
    .byte $00, $07                      ; [9,10] loop at [7] (stay silent)

; Pulse harmony volume: softer
@env_vol_harmony:
    .byte $06                           ; [0] release index: jump to [6]
    .byte $CA                           ; [1] attack: vol 10
    .byte $C9                           ; [2] vol 9
    .byte $C8                           ; [3] sustain: vol 8
    .byte $00, $03                      ; [4,5] loop to [3]
    .byte $C0                           ; [6] release: vol 0
    .byte $7F                           ; [7] hold
    .byte $00, $06                      ; [8,9] loop at [6]

; Triangle volume: on/off
@env_vol_tri:
    .byte $05                           ; [0] release index: jump to [5]
    .byte $CF                           ; [1] on (note-on)
    .byte $7F                           ; [2] hold 127 frames
    .byte $00, $01                      ; [3,4] loop to [1]
    .byte $C0                           ; [5] release: off
    .byte $7F                           ; [6] hold
    .byte $00, $05                      ; [7,8] loop at [5]

; Noise volume: quick decay (no release needed for percussion)
@env_vol_noise:
    .byte $00                           ; [0] no release
    .byte $CC                           ; [1] vol 12 (note-on start)
    .byte $C8                           ; [2] vol 8
    .byte $C4                           ; [3] vol 4
    .byte $C1                           ; [4] vol 1
    .byte $C0                           ; [5] vol 0
    .byte $7F                           ; [6] hold silence
    .byte $00, $05                      ; [7,8] loop at [5]

; Flat zero arpeggio (value 0, looped; no release)
@env_flat_zero:
    .byte $C0                           ; [0] value 0 (note-on resets to 0)
    .byte $7F                           ; [1] hold 127 frames
    .byte $00, $00                      ; [2,3] loop to [0]

; Duty 50% square (value 2; note-on resets to 0)
@env_duty_50:
    .byte $C2                           ; [0] duty 2 = 50%
    .byte $7F                           ; [1] hold
    .byte $00, $00                      ; [2,3] loop to [0]

; Duty 25% square (value 1; note-on resets to 0)
@env_duty_25:
    .byte $C1                           ; [0] duty 1 = 25%
    .byte $7F                           ; [1] hold
    .byte $00, $00                      ; [2,3] loop to [0]

; Flat pitch (no modulation, relative mode)
@env_flat_pitch:
    .byte $00                           ; [0] relative mode flag
    .byte $C0                           ; [1] pitch offset 0 (note-on starts here)
    .byte $7F                           ; [2] hold
    .byte $00, $01                      ; [3,4] loop to [1]

; ============================================================================
; DPCM (empty)
; ============================================================================
@dpcm_samples:

@ch_dpcm_silence:
    .byte $7f                           ; wait 63
    .byte LOOP_CMD
    .word @ch_dpcm_silence

; ============================================================================
; Pulse 1 - Melody
; ============================================================================
; Recognizable Zelda 2 overworld melody in D minor.
; A section (8 bars) + B section (8 bars), loops.

@ch_pulse1:
    .byte INST_0                        ; pulse lead
    .byte VOL_15                        ; max volume

@p1_section_a:
    ; -- Bar 1: driving D5 riff --
    .byte NOTE_D5, WAIT_1               ; D5 8th
    .byte NOTE_D5, WAIT_1               ; D5 8th
    .byte NOTE_D5, WAIT_1               ; D5 8th
    .byte NOTE_D5                       ; D5 16th
    .byte NOTE_E5                       ; E5 16th

    ; -- Bar 2: descending run --
    .byte NOTE_F5, WAIT_1               ; F5 8th
    .byte NOTE_E5, WAIT_1               ; E5 8th
    .byte NOTE_D5, WAIT_1               ; D5 8th
    .byte NOTE_C5, WAIT_1               ; C5 8th

    ; -- Bar 3: ornamental turn --
    .byte NOTE_D5, WAIT_1               ; D5 8th
    .byte NOTE_E5                       ; E5 16th
    .byte NOTE_D5                       ; D5 16th
    .byte NOTE_C5, WAIT_1               ; C5 8th
    .byte NOTE_Bb4, WAIT_1              ; Bb4 8th

    ; -- Bar 4: resolve + rest --
    .byte NOTE_A4, WAIT_7               ; A4 half
    .byte RELEASE, WAIT_7              ; rest half

    ; -- Bar 5: ascending answer --
    .byte NOTE_A4, WAIT_1               ; A4 8th
    .byte NOTE_Bb4, WAIT_1              ; Bb4 8th
    .byte NOTE_C5, WAIT_1               ; C5 8th
    .byte NOTE_D5, WAIT_1               ; D5 8th

    ; -- Bar 6: descending answer --
    .byte NOTE_C5, WAIT_1               ; C5 8th
    .byte NOTE_Bb4, WAIT_1              ; Bb4 8th
    .byte NOTE_A4, WAIT_1               ; A4 8th
    .byte NOTE_G4, WAIT_1               ; G4 8th

    ; -- Bar 7: ascending again --
    .byte NOTE_A4, WAIT_1
    .byte NOTE_Bb4, WAIT_1
    .byte NOTE_C5, WAIT_1
    .byte NOTE_D5, WAIT_1

    ; -- Bar 8: resolve + rest --
    .byte NOTE_A4, WAIT_7               ; A4 half
    .byte RELEASE, WAIT_7              ; rest half

    ; ---- Section B: higher register variation ----

    ; -- Bar 9: F5 riff (parallel to bar 1) --
    .byte NOTE_F5, WAIT_1
    .byte NOTE_F5, WAIT_1
    .byte NOTE_F5, WAIT_1
    .byte NOTE_F5
    .byte NOTE_G5

    ; -- Bar 10: descending from A5 --
    .byte NOTE_A5, WAIT_1
    .byte NOTE_G5, WAIT_1
    .byte NOTE_F5, WAIT_1
    .byte NOTE_E5, WAIT_1

    ; -- Bar 11: ornamental turn --
    .byte NOTE_F5, WAIT_1
    .byte NOTE_G5
    .byte NOTE_F5
    .byte NOTE_E5, WAIT_1
    .byte NOTE_D5, WAIT_1

    ; -- Bar 12: resolve to C5 --
    .byte NOTE_C5, WAIT_7               ; C5 half
    .byte RELEASE, WAIT_7              ; rest half

    ; -- Bar 13: return of D5 riff --
    .byte NOTE_D5, WAIT_1
    .byte NOTE_D5, WAIT_1
    .byte NOTE_D5, WAIT_1
    .byte NOTE_D5
    .byte NOTE_E5

    ; -- Bar 14: descending --
    .byte NOTE_F5, WAIT_1
    .byte NOTE_E5, WAIT_1
    .byte NOTE_D5, WAIT_1
    .byte NOTE_C5, WAIT_1

    ; -- Bar 15: cadential motion --
    .byte NOTE_Bb4, WAIT_1
    .byte NOTE_C5, WAIT_1
    .byte NOTE_D5, WAIT_1
    .byte NOTE_A4, WAIT_1

    ; -- Bar 16: final resolve + rest --
    .byte NOTE_D5, WAIT_7               ; D5 half
    .byte RELEASE, WAIT_7              ; rest half

    ; Loop to section A
    .byte LOOP_CMD
    .word @p1_section_a

; ============================================================================
; Pulse 2 - Harmony (thirds/fifths below melody)
; ============================================================================

@ch_pulse2:
    .byte INST_1
    .byte VOL_12

@p2_section_a:
    ; -- Bar 1 --
    .byte NOTE_A4, WAIT_1
    .byte NOTE_A4, WAIT_1
    .byte NOTE_A4, WAIT_1
    .byte NOTE_A4
    .byte NOTE_Bb4

    ; -- Bar 2 --
    .byte NOTE_D5, WAIT_1
    .byte NOTE_C5, WAIT_1
    .byte NOTE_Bb4, WAIT_1
    .byte NOTE_A4, WAIT_1

    ; -- Bar 3 --
    .byte NOTE_Bb4, WAIT_1
    .byte NOTE_C5
    .byte NOTE_Bb4
    .byte NOTE_A4, WAIT_1
    .byte NOTE_G4, WAIT_1

    ; -- Bar 4 --
    .byte NOTE_F4, WAIT_7
    .byte RELEASE, WAIT_7

    ; -- Bar 5 --
    .byte NOTE_F4, WAIT_1
    .byte NOTE_G4, WAIT_1
    .byte NOTE_A4, WAIT_1
    .byte NOTE_Bb4, WAIT_1

    ; -- Bar 6 --
    .byte NOTE_A4, WAIT_1
    .byte NOTE_G4, WAIT_1
    .byte NOTE_F4, WAIT_1
    .byte NOTE_E4, WAIT_1

    ; -- Bar 7 --
    .byte NOTE_F4, WAIT_1
    .byte NOTE_G4, WAIT_1
    .byte NOTE_A4, WAIT_1
    .byte NOTE_Bb4, WAIT_1

    ; -- Bar 8 --
    .byte NOTE_F4, WAIT_7
    .byte RELEASE, WAIT_7

    ; -- Bar 9 --
    .byte NOTE_C5, WAIT_1
    .byte NOTE_C5, WAIT_1
    .byte NOTE_C5, WAIT_1
    .byte NOTE_C5
    .byte NOTE_D5

    ; -- Bar 10 --
    .byte NOTE_F5, WAIT_1
    .byte NOTE_E5, WAIT_1
    .byte NOTE_D5, WAIT_1
    .byte NOTE_C5, WAIT_1

    ; -- Bar 11 --
    .byte NOTE_D5, WAIT_1
    .byte NOTE_E5
    .byte NOTE_D5
    .byte NOTE_C5, WAIT_1
    .byte NOTE_Bb4, WAIT_1

    ; -- Bar 12 --
    .byte NOTE_A4, WAIT_7
    .byte RELEASE, WAIT_7

    ; -- Bar 13 --
    .byte NOTE_A4, WAIT_1
    .byte NOTE_A4, WAIT_1
    .byte NOTE_A4, WAIT_1
    .byte NOTE_A4
    .byte NOTE_Bb4

    ; -- Bar 14 --
    .byte NOTE_D5, WAIT_1
    .byte NOTE_C5, WAIT_1
    .byte NOTE_Bb4, WAIT_1
    .byte NOTE_A4, WAIT_1

    ; -- Bar 15 --
    .byte NOTE_G4, WAIT_1
    .byte NOTE_A4, WAIT_1
    .byte NOTE_Bb4, WAIT_1
    .byte NOTE_F4, WAIT_1

    ; -- Bar 16 --
    .byte NOTE_A4, WAIT_7
    .byte RELEASE, WAIT_7

    .byte LOOP_CMD
    .word @p2_section_a

; ============================================================================
; Triangle - Bass (quarter note root motion)
; ============================================================================

@ch_triangle:
    .byte INST_2

@tri_loop:
    ; Section A bass — each melodic "bar" = 8 rows, bars 4/8 = 16 rows
    ; Total: 3*8 + 16 + 3*8 + 16 = 80 rows (matches melody)
    .byte NOTE_D3, WAIT_3               ; Bar 1: Dm (qtr+qtr = 8 rows)
    .byte NOTE_D3, WAIT_3
    .byte NOTE_Bb2, WAIT_3              ; Bar 2: Bb (qtr+qtr = 8 rows)
    .byte NOTE_F3, WAIT_3
    .byte NOTE_G3, WAIT_3               ; Bar 3: Gm (qtr+qtr = 8 rows)
    .byte NOTE_G3, WAIT_3
    .byte NOTE_D3, WAIT_7               ; Bar 4: Dm (half+half = 16 rows)
    .byte NOTE_A3, WAIT_7

    .byte NOTE_F3, WAIT_3               ; Bar 5: F
    .byte NOTE_F3, WAIT_3
    .byte NOTE_C3, WAIT_3               ; Bar 6: C
    .byte NOTE_C3, WAIT_3
    .byte NOTE_F3, WAIT_3               ; Bar 7: F
    .byte NOTE_F3, WAIT_3
    .byte NOTE_D3, WAIT_7               ; Bar 8: Dm (half+half)
    .byte NOTE_A2, WAIT_7

    ; Section B bass
    .byte NOTE_F3, WAIT_3               ; Bar 9: F
    .byte NOTE_F3, WAIT_3
    .byte NOTE_F3, WAIT_3               ; Bar 10: F/C
    .byte NOTE_C3, WAIT_3
    .byte NOTE_Bb2, WAIT_3              ; Bar 11: Bb
    .byte NOTE_Bb2, WAIT_3
    .byte NOTE_F3, WAIT_7               ; Bar 12: F (half+half)
    .byte NOTE_C3, WAIT_7

    .byte NOTE_D3, WAIT_3               ; Bar 13: Dm
    .byte NOTE_D3, WAIT_3
    .byte NOTE_Bb2, WAIT_3              ; Bar 14: Bb
    .byte NOTE_F3, WAIT_3
    .byte NOTE_G3, WAIT_3               ; Bar 15: Gm
    .byte NOTE_D3, WAIT_3
    .byte NOTE_D3, WAIT_7               ; Bar 16: Dm (half+half)
    .byte NOTE_A2, WAIT_7

    .byte LOOP_CMD
    .word @tri_loop

; ============================================================================
; Noise - Percussion (8th note grid, 2-bar pattern)
; ============================================================================

@ch_noise:
    .byte INST_3

@noise_loop:
    ; kick-hat-snare-hat pattern, 2 bars
    .byte NOISE_KICK,  WAIT_1           ; 1: kick
    .byte NOISE_HAT,   WAIT_1           ; 2: hat
    .byte NOISE_SNARE, WAIT_1           ; 3: snare
    .byte NOISE_HAT,   WAIT_1           ; 4: hat
    .byte NOISE_KICK,  WAIT_1           ; 5: kick
    .byte NOISE_HAT,   WAIT_1           ; 6: hat
    .byte NOISE_SNARE, WAIT_1           ; 7: snare
    .byte NOISE_HAT,   WAIT_1           ; 8: hat

    .byte LOOP_CMD
    .word @noise_loop
