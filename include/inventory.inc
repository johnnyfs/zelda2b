; ============================================================================
; inventory.inc - Inventory, Map Screen, and Item System Constants
; ============================================================================
; Shared constants, variable declarations, and subroutine exports for:
;   - Overlay inventory screen (Start button)
;   - Overlay map screen (Select button)
;   - Item dispatch / B-button system
;   - Magic system
; ============================================================================

.ifndef INVENTORY_INC
INVENTORY_INC = 1

.include "enums.inc"

; ============================================================================
; Inventory Overlay Layout Constants
; ============================================================================
; The inventory appears as a bordered overlay on top of the current map.
; NES screen = 32x30 tiles. HUD = rows 0-1.
; Overlay: rows 3-27 (25 tile rows), cols 1-30 (30 tile cols)
; Border drawn with HUD_TILE_BOX_* corners + filled edges.

INV_OVERLAY_TOP     = 3         ; First tile row of overlay (below HUD + 1 gap)
INV_OVERLAY_LEFT    = 1         ; First tile column of overlay
INV_OVERLAY_W       = 30        ; Width in tiles (cols 1-30)
INV_OVERLAY_H       = 25        ; Height in tile rows (rows 3-27)
INV_OVERLAY_BOTTOM  = 27        ; Last tile row of overlay

; Item grid: 4 columns x 3 rows of 16x16 items (2x2 tiles each)
; Positioned on left side of overlay, starting at tile row 7, col 3
INV_GRID_TOP        = 7         ; Tile row where item grid starts
INV_GRID_LEFT       = 3         ; Tile column where item grid starts
INV_GRID_COLS       = 4         ; Grid columns
INV_GRID_ROWS       = 3         ; Grid rows
INV_GRID_CELL_W     = 3         ; Tiles per cell width (2 + 1 gap)
INV_GRID_CELL_H     = 3         ; Tiles per cell height (2 + 1 gap)

; B-item equipped display: tile row 4-5, cols 3-6
INV_EQUIP_ROW       = 4         ; Row for "B" label + equipped item
INV_EQUIP_COL       = 4         ; Column for equipped item icon

; Quest items row: below item grid, row 17-18, cols 3-14
INV_QUEST_ROW       = 17        ; Tile row for quest items
INV_QUEST_COL       = 3         ; Starting column

; Crystal obelisks: right side, row 4-8, cols 18-29
INV_CRYSTAL_ROW     = 4         ; Tile row for crystal display
INV_CRYSTAL_COL     = 18        ; Starting column for crystals
INV_CRYSTAL_COUNT   = 6         ; Total crystal slots

; Dungeon items: right side, row 10-11, cols 18-24
INV_DUNGEON_ROW     = 10        ; Tile row for dungeon items
INV_DUNGEON_COL     = 18

; Counters (keys, arrows, bombs, rupees): right side, rows 13-18
INV_COUNTER_ROW     = 13        ; Starting row for counters
INV_COUNTER_COL     = 18        ; Starting column

; ============================================================================
; Map Screen Overlay Layout Constants
; ============================================================================
; Map screen appears as overlay, same border style as inventory.
; Shows a 16x16 overworld minimap grid.
; Each cell = 1 tile (8x8 pixels) = 1 overworld screen.

MAP_DISP_TOP        = 5         ; Tile row for top of map grid
MAP_DISP_LEFT       = 8         ; Tile column for left of map grid (centered)
MAP_DISP_W          = 16        ; Grid width = 16 screens
MAP_DISP_H          = 16        ; Grid height = 16 screens
MAP_TOTAL_CELLS     = 256       ; 16 * 16 total cells

; Map tile indices (in BG pattern table)
MAP_TILE_UNEXPLORED = $00       ; Dark/blank tile (unexplored)
MAP_TILE_EXPLORED   = $2A       ; Explored overworld tile (use a visible tile)
MAP_TILE_CURRENT    = $2B       ; Current position (bright/blinking via sprites)
MAP_TILE_TOWN       = $2C       ; Town tile
MAP_TILE_DUNGEON    = $2D       ; Dungeon entrance tile

; ============================================================================
; Item System Constants
; ============================================================================

; Max counts for countable items
MAX_KEYS            = 9
MAX_ARROWS          = 30
MAX_BOMBS_INV       = 8         ; Renamed to avoid conflict with bombs.inc MAX_BOMBS
MAX_POTIONS         = 4

; Magic costs
MAGIC_COST_CANDLE   = 4
MAGIC_COST_HOOKSHOT = 8
MAGIC_COST_CAPE     = 2         ; Per-frame cost

; Selectable B-items (indices into a dispatch table)
; These map to ITEM_xxx constants from enums.inc
; Only items that can be assigned to B-button:
;   ITEM_BOMB=5, ITEM_BOW=3, ITEM_CANDLE=10, ITEM_HOOKSHOT=14,
;   ITEM_HAMMER=12, ITEM_FLUTE=13, ITEM_POTION=9

; ============================================================================
; Inventory / Item System Zero Page Variable Declarations
; ============================================================================

.globalzp inv_cursor_x          ; Cursor column in item grid (0..INV_GRID_COLS-1)
.globalzp inv_cursor_y          ; Cursor row in item grid (0..INV_GRID_ROWS-1)
.globalzp inv_blink_timer       ; Cursor blink animation timer
.globalzp selected_b_item       ; ITEM_xxx ID currently assigned to B-button
.globalzp b_item_cooldown       ; Frames until B-item can be used again (0=ready)
.globalzp player_keys           ; Current key count
.globalzp player_arrows         ; Current arrow count
.globalzp player_magic          ; Current magic points (0-32)
.globalzp player_max_magic      ; Maximum magic (bottles * 8)
.globalzp magic_bottles_count   ; Number of magic bottles (0-4)

; ============================================================================
; RAM Variable Declarations
; ============================================================================

.global player_items            ; ITEM_COUNT bytes: 0=not owned, 1+=owned/count
.global visited_screens         ; 8 bytes bitmask (64 screen bits)

; ============================================================================
; Subroutine Exports
; ============================================================================

; -- ui/inventory.s --
.global inventory_init
.global inventory_open
.global inventory_update
.global inventory_close

; -- ui/map_screen.s --
.global map_screen_open
.global map_screen_update
.global map_screen_close

; -- items/item_system.s --
.global item_system_init
.global item_use_b
.global item_give
.global magic_consume
.global mark_current_screen_visited

.endif ; INVENTORY_INC
