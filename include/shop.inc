; ============================================================================
; shop.inc - Shop System Constants and Declarations
; ============================================================================
; Zelda 1-style shop: a cave room screen with a shopkeeper NPC and 3 items
; on the floor. Player walks around normally. Press A near an item to buy.
; ============================================================================

.ifndef SHOP_INC
SHOP_INC = 1

; ============================================================================
; Shop Constants
; ============================================================================

MAX_SHOP_ITEMS      = 3
MAX_SHOPS           = 8
SHOP_ENTRY_SIZE     = 3
STARTING_RUPEES     = 50
SHOP_ITEM_RANGE     = 16

SHOP_ITEM0_X        = 40
SHOP_ITEM1_X        = 120
SHOP_ITEM2_X        = 200
SHOP_ITEMS_Y        = 128

SHOPKEEPER_X        = 120
SHOPKEEPER_Y        = 48
SHOPKEEPER_TILE     = $23
SHOP_TILE_BOMB      = $27
SHOP_TILE_SHIELD    = $29
SHOP_TILE_POTION    = $2B

; BG Font Tile Indices
FONT_TILE_A         = $40
FONT_TILE_0         = $5A
FONT_TILE_BLANK     = $00
FONT_TILE_COLON     = $64       ; Colon character tile

; Rupee counter nametable location (row 26, col 10)
; Row 26 = $23, offset = 26*32+10 = 842 = $034A => PPU addr = $2000+$034A = $234A
RUPEE_DISP_ADDR_HI  = $23
RUPEE_DISP_ADDR_LO  = $4A

; Shop Sub-States
SHOP_SUBSTATE_INIT      = 0
SHOP_SUBSTATE_BROWSE    = 1

; ============================================================================
; Shop Zero-Page Variable Declarations
; ============================================================================

.globalzp shop_active
.globalzp shop_id
.globalzp shop_items_bought
.globalzp player_rupees_lo
.globalzp player_rupees_hi

; ============================================================================
; Shop Subroutine Declarations
; ============================================================================

.global shop_init
.global shop_enter
.global shop_update
.global shop_draw_items
.global shop_draw_prices
.global shop_update_rupee_display
.global shop_data_table
.global shop_screen_table

.endif ; SHOP_INC
