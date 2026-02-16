; ============================================================================
; map_vars.s - Map Engine Variable Allocation (stub)
; ============================================================================
; Map variables are allocated in ram.s to avoid duplicates.
; This file kept for Makefile compatibility.
; ============================================================================

.include "map.inc"

.segment "ZEROPAGE"
; All map ZP vars allocated in ram.s
