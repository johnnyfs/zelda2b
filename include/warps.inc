; ============================================================================
; warps.inc - Cave Warp System Constants and Declarations
; ============================================================================
; Defines the warp table format and exports for the cave entrance/exit system.
; A warp triggers when the player stands on a door metatile (ID 7) and the
; tile coordinates match a warp table entry.
; ============================================================================

.ifndef WARPS_INC
WARPS_INC = 1

; ============================================================================
; Warp Table Constants
; ============================================================================

MAX_WARPS           = 16        ; Maximum warp entries
WARP_ENTRY_SIZE     = 6         ; Bytes per warp entry
METATILE_DOOR       = 7         ; Door metatile ID (triggers warp check)

; Warp entry format (6 bytes each):
;   Byte 0: src_screen_id   - Screen where the warp entrance is
;   Byte 1: src_tile_x      - Metatile X coordinate of entrance (0-15)
;   Byte 2: src_tile_y      - Metatile Y coordinate of entrance (0-13)
;   Byte 3: dest_screen_id  - Screen to warp to
;   Byte 4: dest_x_px       - Player X pixel position at destination
;   Byte 5: dest_y_px       - Player Y pixel position at destination

; Warp cooldown to prevent instant re-warp
WARP_COOLDOWN_FRAMES = 30      ; Half a second at 60fps

; ============================================================================
; Warp System Subroutines
; ============================================================================

.global warp_init               ; Initialize warp system (clear cooldown)
.global warp_check              ; Check if player is on a warp tile, execute if so

; ============================================================================
; Warp System Variables
; ============================================================================

.globalzp warp_cooldown         ; Cooldown timer (prevents instant re-warp)

; ============================================================================
; Warp Table Data
; ============================================================================

.global warp_table              ; Warp table in PRG_FIXED_C

.endif ; WARPS_INC
