; ============================================================================
; audio_config.inc - FamiStudio Sound Engine Configuration
; ============================================================================
; External configuration for the FamiStudio sound engine.
; We use FAMISTUDIO_CFG_EXTERNAL=1 so all config is defined here,
; not inside famistudio_ca65.s itself.
; ============================================================================

.ifndef AUDIO_CONFIG_INC
AUDIO_CONFIG_INC = 1

; ============================================================================
; 1) Segment configuration for ca65
; ============================================================================
; Map FamiStudio segments to our linker config segments.
; ZP = zero page, RAM = general RAM ($0300-$07FF), code = fixed PRG bank.

.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  RAM
.define FAMISTUDIO_CA65_CODE_SEGMENT PRG_FIXED_C

; ============================================================================
; 2) Audio expansion: NONE
; ============================================================================
; We use standard 2A03 only (MMC3 mapper, no audio expansion chips).
; Do NOT enable any FAMISTUDIO_EXP_xxx defines.

; ============================================================================
; 3) Global engine configuration
; ============================================================================

; We must use external config mode
FAMISTUDIO_CFG_EXTERNAL       = 1

; NTSC only (standard North American NES)
FAMISTUDIO_CFG_NTSC_SUPPORT   = 1

; Enable sound effects with 2 simultaneous streams
FAMISTUDIO_CFG_SFX_SUPPORT    = 1
FAMISTUDIO_CFG_SFX_STREAMS    = 2

; Enable DPCM support for drum samples etc.
FAMISTUDIO_CFG_DPCM_SUPPORT   = 1

; Smooth vibrato (eliminates pops on pitch changes for pulse channels)
FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1

; Thread safety - not needed since we call update from NMI only
; FAMISTUDIO_CFG_THREAD         = 1

; ============================================================================
; 4) Feature toggles
; ============================================================================
; Enable features we expect to use in our music. Disable unused ones
; to save CPU and ROM space. Enable more as needed when importing real music.

; FamiStudio tempo mode (not FamiTracker tempo)
; FAMISTUDIO_USE_FAMITRACKER_TEMPO = 1

; Release notes (note-off with release envelope phase)
FAMISTUDIO_USE_RELEASE_NOTES  = 1

; Volume track (per-channel volume control)
FAMISTUDIO_USE_VOLUME_TRACK   = 1

; Pitch track (per-channel pitch offset)
FAMISTUDIO_USE_PITCH_TRACK    = 1

; Slide notes (portamento/glide effects)
FAMISTUDIO_USE_SLIDE_NOTES    = 1

; Vibrato effect
FAMISTUDIO_USE_VIBRATO        = 1

; Arpeggio (chord-like rapid note alternation)
FAMISTUDIO_USE_ARPEGGIO       = 1

; DPCM delta counter (for volume control of DPCM channel)
FAMISTUDIO_USE_DELTA_COUNTER  = 1

; Features we do NOT need yet (uncomment when needed):
; FAMISTUDIO_USE_VOLUME_SLIDES     = 1
; FAMISTUDIO_USE_NOISE_SLIDE_NOTES = 1
; FAMISTUDIO_USE_DUTYCYCLE_EFFECT  = 1
; FAMISTUDIO_USE_PHASE_RESET       = 1
; FAMISTUDIO_USE_DPCM_BANKSWITCHING = 1
; FAMISTUDIO_USE_DPCM_EXTENDED_RANGE = 1

.endif ; AUDIO_CONFIG_INC
