; ============================================================================
; data/shop_data.s - Shop Inventory Data
; ============================================================================
.include "enums.inc"
.include "shop.inc"

.segment "PRG_FIXED"

.proc shop_data_table
    ; Shop 0: General Store
    .byte ITEM_BOMB,     10,  0
    .byte ITEM_SHIELD,   50,  0
    .byte ITEM_POTION,   30,  0
    ; Shop 1: Weapon Shop
    .byte ITEM_SWORD,    80,  0
    .byte ITEM_BOW,      60,  0
    .byte ITEM_BOMB,     10,  0
    ; Shop 2: Magic Shop
    .byte ITEM_POTION,   30,  0
    .byte ITEM_CANDLE,   40,  0
    .byte ITEM_MAGIC_CAPE, 100, 0
    ; Shops 3-7: copies of shop 0
    .byte ITEM_BOMB, 10, 0,  ITEM_SHIELD, 50, 0,  ITEM_POTION, 30, 0
    .byte ITEM_BOMB, 10, 0,  ITEM_SHIELD, 50, 0,  ITEM_POTION, 30, 0
    .byte ITEM_BOMB, 10, 0,  ITEM_SHIELD, 50, 0,  ITEM_POTION, 30, 0
    .byte ITEM_BOMB, 10, 0,  ITEM_SHIELD, 50, 0,  ITEM_POTION, 30, 0
    .byte ITEM_BOMB, 10, 0,  ITEM_SHIELD, 50, 0,  ITEM_POTION, 30, 0
.endproc

shop_screen_table:
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $00
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF
