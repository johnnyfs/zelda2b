; ============================================================================
; map_screens.s - Screen Data for Dungeon Map
; ============================================================================
; Map grid: 3 wide x 2 tall = 6 screens
;
;   [ Screen 0 ] [ Screen 1 ] [ Screen 2 ]
;   [ Screen 3 ] [ Screen 4 ] [ Screen 5 ]
;
; Each screen = 16 x 14 metatiles = 224 bytes, row-major order.
; (14 rows because top 2 tile rows are reserved for status bar)
;
; Metatile IDs used for dungeon rooms:
;   0 = empty floor  (tile $00, walkable) - blank/dark floor
;   1 = ground dots  (tile $02, walkable) - textured walkable floor
;   6 = brick wall   (tile $01, SOLID)    - dungeon walls/borders
;   7 = door         (tile $00, walkable) - doorway openings
;  14 = stone wall   (tile $01, SOLID)    - interior pillars/obstacles
;
; Design: Each screen is a dungeon room with clear brick-wall borders
; and dotted-ground floors. Doorways are gaps in the walls that align
; with adjacent screens for seamless transitions.
;
; Placed in PRG_FIXED_C so data is always accessible.
; ============================================================================

.include "map.inc"

.segment "PRG_FIXED_C"

; ============================================================================
; Screen Pointer Tables
; ============================================================================

screen_ptrs_lo:
    .byte <screen_0, <screen_1, <screen_2
    .byte <screen_3, <screen_4, <screen_5

screen_ptrs_hi:
    .byte >screen_0, >screen_1, >screen_2
    .byte >screen_3, >screen_4, >screen_5

; ============================================================================
; Screen 0: Starting dungeon room (top-left)
; Exits: RIGHT (row 6-7), DOWN (col 7-8)
; ============================================================================
screen_0:
    ; Row 0:  solid top wall
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
    ; Row 1:  wall + floor
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 2
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 3:  floor with interior pillar
    .byte  6, 1, 1, 1,14, 1, 1, 1, 1, 1, 1,14, 1, 1, 1, 6
    ; Row 4
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 5
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 6:  right exit (door gap)
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 7:  right exit continued
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 8
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 9:  floor with interior pillar
    .byte  6, 1, 1, 1,14, 1, 1, 1, 1, 1, 1,14, 1, 1, 1, 6
    ; Row 10
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 11
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 12
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 13: bottom wall with door gap (col 7-8)
    .byte  6, 6, 6, 6, 6, 6, 6, 1, 1, 6, 6, 6, 6, 6, 6, 6

; ============================================================================
; Screen 1: Corridor room (top-center)
; Exits: LEFT (row 6-7), RIGHT (row 6-7)
; ============================================================================
screen_1:
    ; Row 0:  solid top wall
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
    ; Row 1
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 2:  internal wall structures
    .byte  6, 1, 1, 6, 6, 1, 1, 1, 1, 1, 1, 6, 6, 1, 1, 6
    ; Row 3
    .byte  6, 1, 1, 6, 6, 1, 1, 1, 1, 1, 1, 6, 6, 1, 1, 6
    ; Row 4
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 5
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 6:  left+right exits
    .byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 7
    .byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 8
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 9
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 10: internal wall structures
    .byte  6, 1, 1, 6, 6, 1, 1, 1, 1, 1, 1, 6, 6, 1, 1, 6
    ; Row 11
    .byte  6, 1, 1, 6, 6, 1, 1, 1, 1, 1, 1, 6, 6, 1, 1, 6
    ; Row 12
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 13: solid bottom wall
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6

; ============================================================================
; Screen 2: Treasure room (top-right)
; Exits: LEFT (row 6-7), DOWN (col 7-8)
; ============================================================================
screen_2:
    ; Row 0:  solid top wall
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
    ; Row 1
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 2:  alcoves on right
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 3:  central chamber walls
    .byte  6, 1, 1, 6, 6, 6, 6, 1, 1, 6, 6, 6, 6, 1, 1, 6
    ; Row 4
    .byte  6, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 5
    .byte  6, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 6:  left exit
    .byte  1, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 7
    .byte  1, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 8
    .byte  6, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 9
    .byte  6, 1, 1, 6, 6, 6, 6, 1, 1, 6, 6, 6, 6, 1, 1, 6
    ; Row 10
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 11
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 12
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 13: bottom wall with door gap (col 7-8)
    .byte  6, 6, 6, 6, 6, 6, 6, 1, 1, 6, 6, 6, 6, 6, 6, 6

; ============================================================================
; Screen 3: Lower-left dungeon room
; Exits: UP (col 7-8), RIGHT (row 6-7)
; ============================================================================
screen_3:
    ; Row 0:  top wall with door gap (col 7-8) connecting to screen 0
    .byte  6, 6, 6, 6, 6, 6, 6, 1, 1, 6, 6, 6, 6, 6, 6, 6
    ; Row 1
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 2
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 3:  L-shaped wall structure
    .byte  6, 1, 1, 6, 6, 6, 1, 1, 1, 1, 6, 6, 6, 1, 1, 6
    ; Row 4
    .byte  6, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 5
    .byte  6, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 6:  right exit
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 7
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 8
    .byte  6, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 1, 6
    ; Row 9
    .byte  6, 1, 1, 6, 6, 6, 1, 1, 1, 1, 6, 6, 6, 1, 1, 6
    ; Row 10
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 11
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 12
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 13: solid bottom wall
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6

; ============================================================================
; Screen 4: Central hub (bottom-center)
; Exits: LEFT (row 6-7), RIGHT (row 6-7)
; ============================================================================
screen_4:
    ; Row 0:  solid top wall
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
    ; Row 1
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 2:  diamond pattern of pillars
    .byte  6, 1, 1, 1, 1, 1, 1,14, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 3
    .byte  6, 1, 1, 1, 1, 1,14, 1,14, 1, 1, 1, 1, 1, 1, 6
    ; Row 4
    .byte  6, 1, 1, 1, 1,14, 1, 1, 1,14, 1, 1, 1, 1, 1, 6
    ; Row 5
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 6:  left+right exits
    .byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 7
    .byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ; Row 8
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 9
    .byte  6, 1, 1, 1, 1,14, 1, 1, 1,14, 1, 1, 1, 1, 1, 6
    ; Row 10
    .byte  6, 1, 1, 1, 1, 1,14, 1,14, 1, 1, 1, 1, 1, 1, 6
    ; Row 11
    .byte  6, 1, 1, 1, 1, 1, 1,14, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 12
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 13: solid bottom wall
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6

; ============================================================================
; Screen 5: Boss room (bottom-right)
; Exits: LEFT (row 6-7), UP (col 7-8)
; ============================================================================
screen_5:
    ; Row 0:  top wall with door gap (col 7-8) connecting to screen 2
    .byte  6, 6, 6, 6, 6, 6, 6, 1, 1, 6, 6, 6, 6, 6, 6, 6
    ; Row 1
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 2:  arena walls
    .byte  6, 1, 6, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 6, 1, 6
    ; Row 3
    .byte  6, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 6
    ; Row 4
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 5
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 6:  left exit
    .byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 7
    .byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 8
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 9
    .byte  6, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 6
    ; Row 10
    .byte  6, 1, 6, 6, 1, 1, 1, 1, 1, 1, 1, 1, 6, 6, 1, 6
    ; Row 11
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 12
    .byte  6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6
    ; Row 13: solid bottom wall (no exit)
    .byte  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
