; ============================================================================
; placeholder_music.s - Minimal placeholder music data for FamiStudio engine
; ============================================================================
; Provides valid FamiStudio-format music data so the sound engine initializes
; without crashing. Contains 1 silent song. Replace with real FamiStudio
; exports when actual music is composed.
;
; Data format (FamiStudio tempo mode, standard 2A03, 5 channels):
;   Header (5 bytes):
;     byte 0:    song count
;     bytes 1-2: instrument table pointer (lo/hi)
;     bytes 3-4: DPCM sample list pointer (lo/hi)
;   Per song (14 bytes each):
;     bytes 0-9:   channel pointers (5 channels * 2 bytes lo/hi)
;     bytes 10-11: tempo envelope pointer (lo/hi)
;     byte 12:     tempo/groove index
;     byte 13:     padding
; ============================================================================

; NOTE: This file is .include'd from audio.s, which already sets the segment.
; We're already in PRG_FIXED_C.

; ============================================================================
; Music data entry point
; ============================================================================

music_data_placeholder:
    ; --- Header ---
    .byte 1                             ; Song count: 1
    .word @instruments                  ; Instrument list pointer
    .word @dpcm_samples                 ; DPCM sample list pointer

    ; --- Song 0: "Silence" ---
    ; Channel pointers (5 channels: pulse1, pulse2, triangle, noise, dpcm)
    .word @ch_silence                   ; Pulse 1
    .word @ch_silence                   ; Pulse 2
    .word @ch_silence                   ; Triangle
    .word @ch_silence                   ; Noise
    .word @ch_silence                   ; DPCM
    ; Tempo data
    .word @tempo_envelope               ; Tempo envelope pointer
    .byte $00                           ; Tempo/groove index (NTSC standard)
    .byte $00                           ; Padding

; ============================================================================
; Tempo envelope
; ============================================================================
; FamiStudio tempo envelope: a list of bytes that controls note timing.
; The first byte read by the engine is used as (value + 1) for the counter.
; A simple envelope with a single entry creates a steady beat.

@tempo_envelope:
    .byte $07                           ; tempo value (counter = 7+1 = 8 frames per tick)

; ============================================================================
; Instruments
; ============================================================================
; Each instrument is a set of 4 envelope pointers (volume, arpeggio, pitch, duty).
; Using FamiStudio's envelope format:
;   byte 0: number of entries | $C0 for "loop" flag
;   following bytes: envelope values
;
; We define one basic square wave instrument (instrument 0).

@instruments:
    .word @env_volume                   ; Instrument 0: volume envelope
    .word @env_flat_zero                ; Instrument 0: arpeggio envelope
    .word @env_flat_zero                ; Instrument 0: pitch envelope
    .word @env_flat_zero                ; Instrument 0: duty cycle envelope

; Volume envelope: immediate volume 15, hold forever
@env_volume:
    .byte $00, $0f                      ; Length=0 (1 entry), value=15

; Flat zero envelope (used for arp/pitch/duty): value 0, hold
@env_flat_zero:
    .byte $00, $00                      ; Length=0 (1 entry), value=0

; ============================================================================
; DPCM sample list (empty)
; ============================================================================

@dpcm_samples:
    ; No samples defined. Pointer table is empty.
    ; (The engine reads this only when DPCM notes are triggered.)

; ============================================================================
; Channel data: silence
; ============================================================================
; FamiStudio channel bytecode format (simplified for our needs):
;   Most bytes < $40 are note-on values
;   $32 = note stop (release/silence)
;   Bytes $41-$7F = wait/duration  ($41 = 1 frame wait, etc.)
;   $FF = loop back (followed by 2-byte offset from channel start)
;
; A minimal "infinite silence" channel:
;   - Wait the maximum duration
;   - Loop back to start

@ch_silence:
    .byte $7f                           ; Wait 63 frames
    .byte $ff, $00, $00                 ; Jump back to offset 0 (loop forever)
