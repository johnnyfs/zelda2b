; ============================================================================
; hud.inc - HUD (Heads-Up Display) Constants and Declarations
; ============================================================================
; Defines tile indices, layout constants, and subroutine declarations
; for the status bar at the top of the screen.
; ============================================================================

.ifndef HUD_INC
HUD_INC = 1

; ============================================================================
; HUD BG Tile Indices (in BG pattern table $0000)
; ============================================================================
; These tiles are merged from hud.chr into bg_tiles.chr at offset $20.

HUD_TILE_HEART_FULL     = $20       ; Filled heart
HUD_TILE_HEART_EMPTY    = $21       ; Empty heart container
HUD_TILE_MAGIC_FULL     = $22       ; Filled magic bottle
HUD_TILE_MAGIC_EMPTY    = $23       ; Empty magic bottle
HUD_TILE_BOX_TL         = $24       ; Item box frame top-left
HUD_TILE_BOX_TR         = $25       ; Item box frame top-right
HUD_TILE_BOX_BL         = $26       ; Item box frame bottom-left
HUD_TILE_BOX_BR         = $27       ; Item box frame bottom-right
HUD_TILE_BUTTON_A       = $28       ; A button indicator
HUD_TILE_BUTTON_B       = $29       ; B button indicator
HUD_TILE_RUPEE          = $2A       ; Rupee icon (blue diamond)
HUD_TILE_BLANK          = $00       ; Empty/blank tile
HUD_TILE_DIGIT_0        = $5A       ; Digit "0" (digits 1-9 follow: $5B-$63)

; ============================================================================
; HUD Layout Constants
; ============================================================================

HUD_MAX_HEARTS          = 8         ; Maximum displayable hearts
HUD_MAX_MAGIC           = 4         ; Maximum displayable magic bottles
HUD_PALETTE             = 3         ; BG palette index for HUD (palette 3)

; Nametable row positions (tile rows 0-1 = 16 pixels)
; Row 0: Hearts on left, B-item box top, Magic on right
; Row 1: Hearts label area, B-item box bottom, Magic label area
;
; Nametable 0 starts at $2000, each row = 32 bytes
; Row 0: $2000-$201F
; Row 1: $2020-$203F

; Heart positions: row 0, columns 1-8
HUD_HEARTS_ROW          = 0
HUD_HEARTS_COL          = 1         ; Starting column for hearts

; B-item box: rows 0-1, columns 13-16  (center of 32-tile row)
HUD_ITEM_BOX_COL        = 14        ; Top-left corner of item box

; Magic positions: row 0, columns 20-23
HUD_MAGIC_ROW           = 0
HUD_MAGIC_COL           = 20        ; Starting column for magic bottles

; Rupee display: row 0, columns 24-26 (icon + 2 digits)
HUD_RUPEE_COL           = 24        ; Column for rupee icon

; PPU addresses for HUD rows
HUD_ROW0_ADDR           = $2000     ; Nametable row 0
HUD_ROW1_ADDR           = $2020     ; Nametable row 1

; ============================================================================
; HUD Zero-Page Variable Declarations
; ============================================================================

.globalzp hud_dirty                 ; Non-zero = HUD needs VRAM update
.globalzp hud_hp_cache              ; Cached player HP (to detect changes)
.globalzp hud_magic_cache           ; Cached magic value (to detect changes)
.globalzp hud_rupee_cache           ; Cached rupee count (to detect changes)

; ============================================================================
; HUD Subroutine Declarations
; ============================================================================

.global hud_init                    ; Write full HUD to nametable (rendering off)
.global hud_update                  ; Check for changes, queue buffer writes
.global hud_draw_full               ; Redraw entire HUD via PPU buffer
.global hud_write_vram              ; Write 64 HUD tiles to PPUDATA (no addr setup)
.global hud_queue_magic             ; Queue magic bottle PPU buffer update
.global hud_queue_rupees            ; Queue rupee count PPU buffer update

.endif ; HUD_INC
