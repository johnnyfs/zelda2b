; ============================================================================
; bombs.inc - Bomb System Constants and Declarations
; ============================================================================
; Defines bomb slot structures, explosion parameters, and breakable wall
; interaction constants. Bombs are placed with the B button, have a 2-second
; fuse timer, then explode to damage enemies and destroy breakable walls.
; ============================================================================

.ifndef BOMBS_INC
BOMBS_INC = 1

; ============================================================================
; Bomb System Constants
; ============================================================================

MAX_BOMBS               = 2         ; Maximum active bomb slots (2 on screen)
MAX_BOMB_INVENTORY      = 8         ; Max bombs player can carry

; Bomb states
BOMB_STATE_INACTIVE     = 0         ; Slot available
BOMB_STATE_FUSE         = 1         ; Placed, counting down
BOMB_STATE_EXPLODING    = 2         ; Explosion active (damage frame)
BOMB_STATE_SMOKE        = 3         ; Post-explosion smoke (cosmetic)

; Bomb timers
BOMB_FUSE_TIME          = 120       ; Frames until explosion (2 seconds at 60fps)
BOMB_EXPLODE_TIME       = 8         ; Frames the explosion hitbox is active
BOMB_SMOKE_TIME         = 16        ; Frames of smoke animation after explosion

; Bomb damage and radius
BOMB_DAMAGE             = 2         ; Damage dealt to enemies in blast radius
BOMB_ENEMY_HIT_DIST     = 24        ; Distance threshold for enemy damage (pixels)

; Bomb sprite tiles (from sprite pattern table)
BOMB_TILE               = $27       ; 8x8 bomb body tile
BOMB_FUSE_TILE          = $28       ; 8x8 fuse spark tile (flickers)
EXPLOSION_TILE_BASE     = $29       ; Base tile for explosion 2x2 metatile

; Breakable wall tile type (extends enums.inc tile IDs)
TILE_BREAKABLE          = 8         ; Breakable wall in collision map

; ============================================================================
; Bomb Zero-Page Variable Declarations
; ============================================================================

.globalzp bomb_x                    ; X positions (MAX_BOMBS bytes)
.globalzp bomb_y                    ; Y positions (MAX_BOMBS bytes)
.globalzp bomb_state                ; State per slot (MAX_BOMBS bytes)
.globalzp bomb_timer                ; Countdown timer (MAX_BOMBS bytes)
.globalzp player_bombs              ; Current bomb inventory count

; ============================================================================
; Bomb Subroutine Declarations
; ============================================================================

.global bomb_init                   ; Clear all bomb slots, set inventory
.global bomb_update                 ; Update all bombs (fuse, explosion, smoke)
.global bomb_draw                   ; Draw all active bomb/explosion sprites
.global bomb_place                  ; Place a bomb at player position (if available)

.endif ; BOMBS_INC
