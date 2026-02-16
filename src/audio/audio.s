; ============================================================================
; audio.s - Audio System Wrapper
; ============================================================================
; High-level audio API that wraps the FamiStudio sound engine.
; Provides a clean interface for the rest of the game to play music and SFX.
;
; This module:
;   1. Configures and includes the FamiStudio ca65 sound engine
;   2. Exports a simplified API (audio_init, audio_update, etc.)
;   3. Manages the mapping between game SFX IDs and engine SFX channels
;
; Memory: This module uses the PRG_FIXED_C segment ($C000-$DFFF) which is
; always mapped. The FamiStudio engine code, ZP vars, and RAM vars are
; allocated via the segment defines in audio_config.inc.
;
; Called from:
;   - reset_handler -> audio_init (once at startup)
;   - nmi_handler   -> audio_update (every frame)
;   - game code     -> audio_play_song, audio_stop_music, audio_play_sfx
; ============================================================================

.include "audio_config.inc"

; ============================================================================
; Include the FamiStudio sound engine
; ============================================================================
; The engine is configured externally via audio_config.inc defines.
; It allocates its own ZP and RAM variables, and places code in PRG_FIXED_C.

.include "../../lib/famistudio_ca65.s"

; ============================================================================
; Include placeholder music and SFX data
; ============================================================================
; These will be replaced with real FamiStudio exports later.

.include "placeholder_music.s"
.include "placeholder_sfx.s"

; ============================================================================
; Audio API implementation
; ============================================================================

.segment "PRG_FIXED_C"

; ============================================================================
; audio_init - Initialize the audio system
; ============================================================================
; Call once during game startup (after NES hardware init).
; Sets up the FamiStudio engine with our music and SFX data.
;
; Trashes: A, X, Y
; ============================================================================

.export audio_init
.proc audio_init
    ; Initialize FamiStudio with our music data
    ; famistudio_init: A=platform (1=NTSC), X=data_ptr_lo, Y=data_ptr_hi
    lda #1                              ; NTSC
    ldx #<music_data_placeholder
    ldy #>music_data_placeholder
    jsr famistudio_init

    ; Initialize SFX engine with our SFX data
    ; famistudio_sfx_init: X=sfx_data_lo, Y=sfx_data_hi
    ldx #<sfx_data_placeholder
    ldy #>sfx_data_placeholder
    jsr famistudio_sfx_init

    rts
.endproc

; ============================================================================
; audio_update - Update the audio engine (call from NMI)
; ============================================================================
; Must be called exactly once per frame, ideally during NMI/vblank.
; Updates all music channels and active SFX streams.
;
; Trashes: A, X, Y
; ============================================================================

.export audio_update
.proc audio_update
    jsr famistudio_update
    rts
.endproc

; ============================================================================
; audio_play_song - Start playing a song
; ============================================================================
; [in] A: Song index (0-based)
;
; Trashes: A, X, Y
; ============================================================================

.export audio_play_song
.proc audio_play_song
    jsr famistudio_music_play
    rts
.endproc

; ============================================================================
; audio_stop_music - Stop all music playback
; ============================================================================
; Silences all music channels. SFX continue unaffected.
;
; Trashes: A, X, Y
; ============================================================================

.export audio_stop_music
.proc audio_stop_music
    jsr famistudio_music_stop
    rts
.endproc

; ============================================================================
; audio_pause_music - Pause or unpause music
; ============================================================================
; [in] A: 0 = unpause, non-zero = pause
;
; Trashes: A, X, Y
; ============================================================================

.export audio_pause_music
.proc audio_pause_music
    jsr famistudio_music_pause
    rts
.endproc

; ============================================================================
; audio_play_sfx - Play a sound effect
; ============================================================================
; [in] A: SFX index (0-based, see audio.inc for constants)
; [in] X: SFX channel (SFX_CHAN_GAMEPLAY=0, SFX_CHAN_UI=1)
;
; The channel determines priority. If a SFX is already playing on the
; requested channel, the new SFX replaces it. Use channel 0 for important
; gameplay sounds and channel 1 for UI/ambient sounds.
;
; Trashes: A, X, Y
; ============================================================================

.export audio_play_sfx
.proc audio_play_sfx
    ; Map our channel index to FamiStudio's FAMISTUDIO_SFX_CHx offset
    ; Channel 0 -> FAMISTUDIO_SFX_CH0
    ; Channel 1 -> FAMISTUDIO_SFX_CH1
    cpx #1
    beq @ch1
@ch0:
    ldx #FAMISTUDIO_SFX_CH0
    jmp @play
@ch1:
    ldx #FAMISTUDIO_SFX_CH1
@play:
    ; famistudio_sfx_play: A=sfx_index, X=channel_offset
    jsr famistudio_sfx_play
    rts
.endproc
