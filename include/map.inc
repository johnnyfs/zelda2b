; ============================================================================
; map.inc - Map Engine Constants and Declarations
; ============================================================================
; Constants, variable declarations, and subroutine imports for the map engine.
; ============================================================================

.ifndef MAP_INC
MAP_INC = 1

; ============================================================================
; Map Screen Dimensions (in metatiles)
; ============================================================================
; Top 2 tile rows (16 pixels) are reserved for the status bar.
; Map area: 16 metatiles wide x 14 metatiles tall = 28 tile rows.
; Total nametable: 2 status rows + 28 map rows = 30 tile rows.
; Each metatile is 2x2 hardware tiles (16x16 pixels).
; Map pixel area: 256x224 (status bar takes top 16px)

MAP_SCREEN_W        = 16        ; Screen width in metatiles
MAP_SCREEN_H        = 14        ; Screen height in metatiles (was 15, -1 for status bar)
MAP_SCREEN_SIZE     = 224       ; MAP_SCREEN_W * MAP_SCREEN_H bytes per screen
MAP_SCREEN_BYTES    = 224       ; Alias for MAP_SCREEN_SIZE

; Status bar layout
STATUS_BAR_ROWS     = 2         ; Tile rows reserved for status bar at top
STATUS_BAR_Y_PX     = 16        ; Pixel height of status bar

; ============================================================================
; Map Grid Dimensions (in screens)
; ============================================================================
; The overworld is a grid of screens.
; These MUST be assembly-time constants (not .global exports) because they
; are used in immediate-mode instructions like: cmp #MAP_GRID_W_CONST

MAP_GRID_W_CONST    = 3         ; Grid width (screens)
MAP_GRID_H_CONST    = 2         ; Grid height (screens)
MAP_GRID_TOTAL      = 6         ; Total screens (W * H)

; ============================================================================
; Metatile Constants
; ============================================================================

METATILE_SIZE       = 5         ; Bytes per metatile entry (TL, TR, BL, BR, attr)
METATILE_COUNT      = 16        ; Total metatile definitions
METATILE_SOLID_BIT  = $80       ; Bit 7 of attribute = solid flag

; ============================================================================
; Map Engine Zero Page Variables
; ============================================================================

.globalzp current_screen_x          ; Current screen X in map grid (0..MAP_GRID_W-1)
.globalzp current_screen_y          ; Current screen Y in map grid (0..MAP_GRID_H-1)
.globalzp current_screen_id         ; Computed screen index (y * MAP_GRID_W + x)
.globalzp map_row_counter           ; Temp: row counter for screen loading
.globalzp map_col_counter           ; Temp: column counter for screen loading

; ============================================================================
; Map Engine Subroutines
; ============================================================================

.global map_load_screen             ; Load screen A into nametable
.global map_get_screen_id           ; Compute screen ID from x,y position
.global map_init                    ; Initialize map engine, load first screen
.global map_check_transition        ; Check if player at screen edge, transition

; ============================================================================
; Map Data Symbols
; ============================================================================

.global metatile_table              ; 16 metatile definitions (5 bytes each)
.global screen_ptrs_lo              ; Low bytes of screen data pointers
.global screen_ptrs_hi              ; High bytes of screen data pointers

.endif ; MAP_INC
