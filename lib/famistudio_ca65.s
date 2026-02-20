; ==========================================================
; FamiStudio Sound Engine — ca65 version (STUB)
; ==========================================================
; This is a STUB placeholder for the FamiStudio sound engine.
; The real engine will be downloaded from:
;   https://github.com/BleuBleu/FamiStudio
;
; The actual engine provides:
;   - famistudio_init      : Initialize the engine
;   - famistudio_music_play: Start playing a song
;   - famistudio_music_stop: Stop music
;   - famistudio_sfx_init  : Initialize SFX
;   - famistudio_sfx_play  : Play a sound effect
;   - famistudio_update    : Call once per frame (in NMI)
;
; Configuration defines (set before .include):
;   FAMISTUDIO_CFG_EXTERNAL     = 1
;   FAMISTUDIO_CFG_SFX_SUPPORT  = 1
;   FAMISTUDIO_CFG_SFX_STREAMS  = 4
;   FAMISTUDIO_CFG_DPCM_SUPPORT = 0
;   FAMISTUDIO_USE_VOLUME_TRACK = 1
;
; For now, these are no-op stubs so the project can build.
; ==========================================================

.export famistudio_init
.export famistudio_music_play
.export famistudio_music_stop
.export famistudio_music_pause
.export famistudio_sfx_init
.export famistudio_sfx_play
.export famistudio_update

.segment "PRG_FIXED_C"

famistudio_init:
famistudio_music_play:
famistudio_music_stop:
famistudio_music_pause:
famistudio_sfx_init:
famistudio_sfx_play:
famistudio_update:
    rts
