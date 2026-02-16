; ============================================================================
; fixed_c.s - Fixed PRG Bank at $C000-$DFFF
; ============================================================================
; Second-to-last bank, always mapped. Used for frequently-called routines
; that need to be accessible from any bank context (e.g., sound engine,
; utility code). Currently a placeholder.
; ============================================================================

.segment "PRG_FIXED_C"

; Placeholder - this bank will be populated with:
;   - FamiStudio sound engine
;   - Common lookup tables
;   - Utility routines called from switchable banks
;
; For now, just a version string for ROM identification
fixed_c_banner:
    .byte "ZELDA2B-FIXC"
    .byte $00
