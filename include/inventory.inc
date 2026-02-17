; ============================================================================
; inventory.inc - Inventory / Item System Declarations
; ============================================================================
; Declares zero-page variables and constants for the inventory and item
; system. These variables are allocated in ram.s.
; ============================================================================

.ifndef INVENTORY_INC
INVENTORY_INC = 1

; ============================================================================
; Inventory Zero-Page Variable Declarations
; ============================================================================

.globalzp inv_cursor_x              ; Cursor column in item grid (0-3)
.globalzp inv_cursor_y              ; Cursor row in item grid (0-3)
.globalzp inv_blink_timer           ; Cursor blink timer
.globalzp selected_b_item           ; Currently selected B-button item
.globalzp player_keys               ; Key count
.globalzp player_arrows             ; Arrow count

; --- Magic system ---
.globalzp player_magic              ; Current magic points (0-32)
.globalzp player_max_magic          ; Max magic (bottles * 8)
.globalzp magic_bottles_count       ; Number of magic bottles (0-4)

; ============================================================================
; RAM Variable Declarations
; ============================================================================

.global player_items                ; Item ownership array (ITEM_COUNT bytes)
.global visited_screens             ; Visited screen bitmask (8 bytes)

.endif ; INVENTORY_INC
