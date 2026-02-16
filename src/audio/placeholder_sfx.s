; ============================================================================
; placeholder_sfx.s - Minimal placeholder SFX data for FamiStudio engine
; ============================================================================
; Provides valid FamiStudio SFX data with basic placeholder sound effects.
; Replace with real FamiStudio SFX exports when final sounds are designed.
;
; SFX data format:
;   Outer structure (passed to famistudio_sfx_init):
;     bytes 0-1: pointer to SFX entry table (NTSC)
;     bytes 2-3: pointer to SFX entry table (PAL) [if dual support]
;
;   SFX entry table: array of 2-byte pointers (lo/hi), one per SFX
;
;   SFX stream data (bytecode per effect):
;     Byte with bit 7 set ($80+offset): register write
;       Next byte is the value to write to output_buf[offset]
;     Byte with bit 7 clear, non-zero (1-127): repeat count (frames)
;     Byte = $00: end of SFX
;
;   Output buffer offsets:
;     $80 = Pulse1 vol/duty     $83 = Pulse2 vol/duty     $86 = Tri linear
;     $81 = Pulse1 period lo    $84 = Pulse2 period lo    $87 = Tri period lo
;     $82 = Pulse1 period hi    $85 = Pulse2 period hi    $88 = Tri period hi
;     $89 = Noise vol           $8A = Noise period
; ============================================================================

; NOTE: This file is .include'd from audio.s, which already sets the segment.
; We're already in PRG_FIXED_C.

; ============================================================================
; SFX data entry point
; ============================================================================

sfx_data_placeholder:
    ; Pointer to SFX entry table (NTSC only, no dual support)
    .word @sfx_entry_table

; ============================================================================
; SFX entry table - pointers to each sound effect
; ============================================================================
; Index these with the SFX_xxx constants from audio.inc

@sfx_entry_table:
    .word @sfx_sword_swing              ; SFX 0: sword swing
    .word @sfx_hit                      ; SFX 1: hit/damage
    .word @sfx_pickup                   ; SFX 2: item pickup
    .word @sfx_menu_cursor              ; SFX 3: menu cursor move

; ============================================================================
; SFX 0: Sword swing - short noise burst (swoosh)
; ============================================================================
; Uses noise channel: fast descending noise
; Duration: ~4 frames

@sfx_sword_swing:
    ; Frame 1: noise vol=15, short period
    .byte $89, $3F                      ; Noise vol = $3F (vol 15, constant)
    .byte $8A, $03                      ; Noise period = 3 (high frequency)
    .byte $01                           ; Play 1 frame
    ; Frame 2: noise vol=10, slightly longer period
    .byte $89, $3A                      ; Noise vol = $3A (vol 10)
    .byte $8A, $05                      ; Noise period = 5
    .byte $01                           ; Play 1 frame
    ; Frame 3: noise vol=5
    .byte $89, $35                      ; Noise vol = $35 (vol 5)
    .byte $8A, $07                      ; Noise period = 7
    .byte $01                           ; Play 1 frame
    ; Frame 4: noise vol=2
    .byte $89, $32                      ; Noise vol = $32 (vol 2)
    .byte $8A, $09                      ; Noise period = 9
    .byte $01                           ; Play 1 frame
    ; Silence and end
    .byte $89, $30                      ; Noise vol = 0
    .byte $00                           ; End of SFX

; ============================================================================
; SFX 1: Hit/damage - descending pulse beep
; ============================================================================
; Uses pulse 1 channel: sharp descending tone
; Duration: ~5 frames

@sfx_hit:
    ; Frame 1: pulse1 duty=50%, vol=15, high pitch
    .byte $80, $BF                      ; Pulse1 vol = $BF (duty 10, vol 15)
    .byte $81, $C4                      ; Pulse1 period lo = $C4 (A4 ~440Hz)
    .byte $82, $00                      ; Pulse1 period hi = $00
    .byte $01                           ; Play 1 frame
    ; Frame 2: lower pitch
    .byte $80, $BC                      ; Vol 12
    .byte $81, $E0                      ; Lower pitch
    .byte $82, $00
    .byte $01
    ; Frame 3: even lower
    .byte $80, $B8                      ; Vol 8
    .byte $81, $40                      ; Lower pitch
    .byte $82, $01
    .byte $01
    ; Frame 4: low
    .byte $80, $B4                      ; Vol 4
    .byte $81, $80                      ; Low pitch
    .byte $82, $01
    .byte $01
    ; Silence and end
    .byte $80, $B0                      ; Pulse1 vol = 0
    .byte $00                           ; End of SFX

; ============================================================================
; SFX 2: Item pickup - rising pulse arpeggio (C-E-G-C')
; ============================================================================
; Uses pulse 1: classic Zelda "pickup" jingle
; Duration: ~8 frames

@sfx_pickup:
    ; Frame 1-2: C5 (~523 Hz, period $D5 for NTSC)
    .byte $80, $BF                      ; Pulse1 50% duty, vol 15
    .byte $81, $D5                      ; Period lo
    .byte $82, $00                      ; Period hi
    .byte $02                           ; Play 2 frames
    ; Frame 3-4: E5 (~659 Hz, period $A9)
    .byte $81, $A9                      ; Period lo
    .byte $82, $00                      ; Period hi
    .byte $02                           ; Play 2 frames
    ; Frame 5-6: G5 (~784 Hz, period $8E)
    .byte $81, $8E                      ; Period lo
    .byte $82, $00                      ; Period hi
    .byte $02                           ; Play 2 frames
    ; Frame 7-8: C6 (~1047 Hz, period $69)
    .byte $81, $69                      ; Period lo
    .byte $82, $00                      ; Period hi
    .byte $04                           ; Play 4 frames
    ; Fade out
    .byte $80, $B8                      ; Vol 8
    .byte $02                           ; Play 2 frames
    .byte $80, $B4                      ; Vol 4
    .byte $02                           ; Play 2 frames
    ; Silence and end
    .byte $80, $B0                      ; Pulse1 vol = 0
    .byte $00                           ; End of SFX

; ============================================================================
; SFX 3: Menu cursor - short high-pitched beep
; ============================================================================
; Uses pulse 1: quick 2-frame blip
; Duration: ~3 frames

@sfx_menu_cursor:
    ; Frame 1: high pitched beep
    .byte $80, $BF                      ; Pulse1 50% duty, vol 15
    .byte $81, $70                      ; High pitch (~1200 Hz)
    .byte $82, $00                      ; Period hi
    .byte $01                           ; Play 1 frame
    ; Frame 2: slightly quieter
    .byte $80, $B8                      ; Vol 8
    .byte $01                           ; Play 1 frame
    ; Silence and end
    .byte $80, $B0                      ; Pulse1 vol = 0
    .byte $00                           ; End of SFX
