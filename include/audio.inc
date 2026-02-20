; ============================================================================
; audio.inc - Audio System Public Interface
; ============================================================================
; Import this to use the audio system from other modules.
; ============================================================================

.ifndef AUDIO_INC
AUDIO_INC = 1

; ============================================================================
; Public API - call these from your game code
; ============================================================================

.global audio_init          ; Initialize audio system (call once at startup)
.global audio_update        ; Update audio engine (call once per frame from NMI)
.global audio_play_song     ; Play a song: A = song index
.global audio_stop_music    ; Stop music playback
.global audio_pause_music   ; Pause/unpause: A = 0 unpause, 1 pause
.global audio_play_sfx      ; Play SFX: A = sfx index, X = channel (0 or 1)

; ============================================================================
; Song indices
; ============================================================================

SONG_OVERWORLD      = 0     ; Zelda 2 overworld theme

; ============================================================================
; SFX indices
; ============================================================================

SFX_SWORD_SWING     = 0
SFX_HIT             = 1
SFX_PICKUP          = 2
SFX_MENU_CURSOR     = 3

; ============================================================================
; SFX channel assignments
; ============================================================================
; Channel 0: gameplay SFX (sword, hit, pickup) — higher priority
; Channel 1: UI SFX (menu cursor, etc.) — lower priority

SFX_CHAN_GAMEPLAY    = 0
SFX_CHAN_UI          = 1

.endif ; AUDIO_INC
