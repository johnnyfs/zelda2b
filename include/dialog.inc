; ============================================================================
; dialog.inc - NPC Dialog System Constants and Declarations
; ============================================================================
; Provides a typewriter-style dialog box at the bottom of the screen.
; Player presses A near an NPC to trigger dialog; A advances/closes,
; B speeds up text rendering. Dialog box occupies nametable rows 26-27.
; ============================================================================

.ifndef DIALOG_INC
DIALOG_INC = 1

; ============================================================================
; Dialog Constants
; ============================================================================

; Dialog box nametable position (bottom of screen, rows 26-27)
; Row 26 = $2000 + (26 * 32) = $2000 + $0340 = $2340
; Row 27 = $2000 + (27 * 32) = $2000 + $0360 = $2360
DIALOG_ROW0_ADDR_HI     = $23
DIALOG_ROW0_ADDR_LO     = $40
DIALOG_ROW1_ADDR_HI     = $23
DIALOG_ROW1_ADDR_LO     = $60

; Dialog box text area: 28 chars wide (columns 2-29), 2 rows
DIALOG_TEXT_COL          = 2           ; Starting column for text
DIALOG_TEXT_WIDTH        = 28          ; Characters per line
DIALOG_TEXT_LINES        = 2           ; Lines per page
DIALOG_MAX_PAGES         = 4           ; Maximum pages per dialog

; Typewriter timing
DIALOG_CHAR_DELAY        = 3           ; Frames per character (normal)
DIALOG_CHAR_FAST         = 1           ; Frames per character (B held)

; Dialog border tiles (use existing font range)
; We'll use simple bracket-style borders from the font
DIALOG_TILE_BORDER_H     = $64         ; Horizontal border (reuse colon or dash)
DIALOG_TILE_BORDER_V     = $64         ; Vertical border
DIALOG_TILE_CORNER       = $64         ; Corner tile
DIALOG_TILE_BLANK        = $00         ; Empty tile

; Special character codes in dialog strings
CHAR_END                 = $FF         ; End of dialog string
CHAR_PG                  = $FE         ; Page break

; Font tile mapping (already in bg_tiles.chr)
; FONT_TILE_A = $40 (A), FONT_TILE_0 = $5A (0)
; Uses same constants from shop.inc
DIALOG_FONT_A            = $40         ; Tile index for 'A'
DIALOG_FONT_0            = $5A         ; Tile index for '0'
DIALOG_FONT_SPACE        = $00         ; Space = blank tile

; NPC detection range (pixels)
NPC_INTERACT_RANGE       = 20          ; Distance to trigger dialog

; NPC system
MAX_NPCS                 = 4           ; Maximum NPCs per screen

; NPC sprite tile (use a distinctive placeholder from sprite pattern table)
NPC_SPRITE_TILE          = $23         ; Same as shopkeeper tile

; Dialog sub-states
DIALOG_SUBSTATE_IDLE     = 0           ; No dialog active
DIALOG_SUBSTATE_DRAWING  = 1           ; Typewriter rendering text
DIALOG_SUBSTATE_WAITING  = 2           ; Page complete, waiting for A
DIALOG_SUBSTATE_CLOSING  = 3           ; Closing dialog, restoring BG

; ============================================================================
; Dialog Zero-Page Variable Declarations
; ============================================================================

.globalzp dialog_state                 ; Sub-state (idle/drawing/waiting/closing)
.globalzp dialog_id                    ; Current dialog ID
.globalzp dialog_ptr_lo                ; Pointer to current char in string (lo)
.globalzp dialog_ptr_hi                ; Pointer to current char in string (hi)
.globalzp dialog_char_timer            ; Typewriter delay counter
.globalzp dialog_line                  ; Current line (0 or 1)
.globalzp dialog_col                   ; Current column position
.globalzp dialog_page                  ; Current page number

; ============================================================================
; Dialog RAM Variable Declarations
; ============================================================================

.global dialog_line_buf                ; 28-byte line buffer for PPU writes

; ============================================================================
; NPC Zero-Page Variable Declarations
; ============================================================================

.globalzp npc_count                    ; Number of active NPCs on this screen

; ============================================================================
; NPC RAM Variable Declarations (parallel arrays)
; ============================================================================

.global npc_x                          ; NPC X positions
.global npc_y                          ; NPC Y positions
.global npc_tile                       ; NPC sprite tile indices
.global npc_dialog_id                  ; NPC dialog IDs

; ============================================================================
; Dialog Subroutine Declarations
; ============================================================================

.global dialog_init                    ; Clear dialog state
.global dialog_open                    ; A = dialog_id, opens dialog box
.global dialog_update                  ; Per-frame update during GAME_STATE_DIALOG
.global dialog_close                   ; Restore gameplay state and redraw map

; ============================================================================
; NPC Subroutine Declarations
; ============================================================================

.global npc_init                       ; Clear NPC slots
.global npc_spawn_screen               ; Spawn NPCs for current screen
.global npc_draw                       ; Draw NPC sprites
.global npc_check_interact             ; Check A-button near NPC, trigger dialog

.endif ; DIALOG_INC
