; metatiles.s - Fixed to use existing CHR tiles
.include "map.inc"
.segment "PRG_FIXED_C"
metatile_table:
    .byte $00, $00, $00, $00, $00  ; 0: Empty floor
    .byte $02, $02, $02, $02, $00  ; 1: Ground (dots)
    .byte $02, $00, $00, $02, $00  ; 2: Ground variant
    .byte $01, $01, $01, $01, $81  ; 3: Tree/obstacle (SOLID)
    .byte $03, $03, $03, $03, $82  ; 4: Water (SOLID)
    .byte $00, $00, $00, $00, $01  ; 5: Path
    .byte $01, $01, $01, $01, $81  ; 6: Wall (SOLID)
    .byte $00, $00, $00, $00, $01  ; 7: Door
    .byte $01, $01, $01, $01, $81  ; 8: Border (SOLID)
    .byte $01, $01, $01, $01, $81  ; 9: Border L (SOLID)
    .byte $01, $01, $01, $01, $81  ; 10: Border R (SOLID)
    .byte $02, $02, $02, $02, $03  ; 11: Sand
    .byte $02, $02, $02, $02, $00  ; 12: Bush
    .byte $00, $00, $00, $00, $01  ; 13: Stone floor
    .byte $01, $01, $01, $01, $81  ; 14: Stone wall (SOLID)
    .byte $02, $02, $02, $02, $03  ; 15: Bridge
