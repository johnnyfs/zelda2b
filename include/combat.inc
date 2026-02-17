; ============================================================================
; combat.inc - Combat System Constants and Declarations
; ============================================================================
; Defines enemy slot structures, player combat state, and combat constants.
; ============================================================================

.ifndef COMBAT_INC
COMBAT_INC = 1

; ============================================================================
; Enemy System Constants
; ============================================================================

MAX_ENEMIES         = 4         ; Maximum active enemy slots

; Enemy states
ENEMY_STATE_INACTIVE    = 0     ; Slot is empty / available
ENEMY_STATE_ACTIVE      = 1     ; Normal active state
ENEMY_STATE_HURT        = 2     ; Hit reaction (knockback/flash)
ENEMY_STATE_DYING       = 3     ; Death animation

; Enemy timers
ENEMY_HURT_TIME         = 20    ; Frames of hurt/knockback state
ENEMY_DEATH_TIME        = 16    ; Frames of death animation
ENEMY_WANDER_TIME       = 60    ; Frames between direction changes (Octorok)

; Enemy stats
OCTOROK_HP              = 2     ; Octorok hit points
OCTOROK_SPEED           = 1     ; Pixels per frame

; Enemy sprite tile (use a distinct tile from sprite pattern table $1000+)
; Using tile $21 area - unused distinctive tile for placeholder enemy
ENEMY_TILE_BASE         = $21   ; Base tile for enemy 2x2 metatile (TL)

; ============================================================================
; Player Combat Constants
; ============================================================================

; Player states (extends player behavior, not game_state)
PLAYER_STATE_NORMAL     = 0     ; Normal movement
PLAYER_STATE_ATTACK     = 1     ; Sword attack animation

; Attack constants
ATTACK_DURATION         = 12    ; Frames the attack state lasts
SWORD_REACH             = 16    ; Pixels the sword hitbox extends

; Player damage constants
PLAYER_MAX_HP           = 6     ; Starting max HP (3 hearts)
PLAYER_INVULN_TIME      = 60    ; Frames of invincibility after taking damage
DAMAGE_FROM_ENEMY       = 1     ; Damage per enemy contact

; Sword hitbox size
SWORD_HITBOX_W          = 12    ; Sword hitbox width
SWORD_HITBOX_H          = 12    ; Sword hitbox height

; Sword sprite tiles (placeholder - vertical and horizontal blade)
; Uses 2 tiles: one for up/down (vertical blade), one for left/right (horizontal)
; These are single 8x8 sprites drawn alongside the player during attack state.
SWORD_TILE_VERT         = $2D   ; Vertical sword blade (for up/down attacks)
SWORD_TILE_HORIZ        = $2E   ; Horizontal sword blade (for left/right attacks)

; Sword sprite offsets from player position (pixels)
SWORD_OFFSET_UP_X       = 4     ; Centered on player (16px sprite, sword is 8px)
SWORD_OFFSET_UP_Y       = -10   ; Above player
SWORD_OFFSET_DOWN_X     = 4     ; Centered on player
SWORD_OFFSET_DOWN_Y     = 16    ; Below player
SWORD_OFFSET_LEFT_X     = -10   ; Left of player
SWORD_OFFSET_LEFT_Y     = 4     ; Centered vertically
SWORD_OFFSET_RIGHT_X    = 16    ; Right of player
SWORD_OFFSET_RIGHT_Y    = 4     ; Centered vertically

; ============================================================================
; Enemy Zero-Page Variable Declarations
; ============================================================================
; Each enemy has parallel arrays indexed by slot (0..MAX_ENEMIES-1)

.globalzp enemy_x               ; X positions (4 bytes)
.globalzp enemy_y               ; Y positions (4 bytes)
.globalzp enemy_type            ; Enemy type ID (4 bytes)
.globalzp enemy_hp              ; Hit points (4 bytes)
.globalzp enemy_state           ; State per slot (4 bytes)
.globalzp enemy_dir             ; Facing direction (4 bytes)
.globalzp enemy_timer           ; General purpose timer (4 bytes)

; ============================================================================
; Player Combat Zero-Page Variables
; ============================================================================

.globalzp player_state          ; Player action state (normal/attack)
.globalzp player_attack_timer   ; Countdown during attack animation
.globalzp player_hp             ; Current hit points
.globalzp player_max_hp         ; Maximum hit points
.globalzp player_invuln_timer   ; Invincibility countdown after damage

; ============================================================================
; Pickup System Constants
; ============================================================================

MAX_PICKUPS             = 4         ; Maximum active pickup slots

; Pickup types
PICKUP_NONE             = 0         ; Empty slot
PICKUP_HEART            = 1         ; Restores 1 HP
PICKUP_MAGIC            = 2         ; Restores magic (future)
PICKUP_RUPEE            = 3         ; Green rupee (value 1)

; Pickup states
PICKUP_STATE_INACTIVE   = 0         ; Slot available
PICKUP_STATE_ACTIVE     = 1         ; On ground, collectible
PICKUP_STATE_SPAWNING   = 2         ; Brief spawn animation (rising)

; Pickup timers
PICKUP_LIFETIME         = 0         ; 0 = persist until collected (no timeout)
PICKUP_SPAWN_TIME       = 8         ; Frames of spawn animation
PICKUP_COLLECT_DIST     = 12        ; Overlap distance for collection

; Pickup sprite tiles (from sprite pattern table)
PICKUP_HEART_TILE       = $25       ; Single 8x8 tile for heart pickup
PICKUP_RUPEE_TILE       = $26       ; Single 8x8 tile for green rupee

; Rupee values
RUPEE_VALUE_GREEN       = 1         ; Green rupee value

; ============================================================================
; Pickup Zero-Page Variable Declarations
; ============================================================================

.globalzp pickup_x              ; X positions (MAX_PICKUPS bytes)
.globalzp pickup_y              ; Y positions (MAX_PICKUPS bytes)
.globalzp pickup_type           ; Pickup type (MAX_PICKUPS bytes)
.globalzp pickup_state          ; State (MAX_PICKUPS bytes)
.globalzp pickup_timer          ; Timer (MAX_PICKUPS bytes)

; ============================================================================
; Combat Subroutine Declarations
; ============================================================================

; -- enemies/enemy_common.s --
.global enemy_init              ; Clear all enemy slots
.global enemy_update            ; Update all active enemies
.global enemy_draw              ; Draw all active enemy sprites
.global enemy_spawn_screen      ; Spawn enemies for current screen

; -- enemies/enemy_types.s --
.global enemy_ai_octorok        ; Octorok wander AI

; -- player/player_combat.s --
.global combat_init             ; Initialize player combat state
.global combat_update           ; Check for attack input, handle sword
.global check_player_damage     ; Check enemy overlap, apply damage

; -- items/pickups.s --
.global pickup_init             ; Clear all pickup slots
.global pickup_update           ; Update pickups (collection check + animation)
.global pickup_draw             ; Draw all active pickup sprites
.global pickup_spawn            ; Spawn a pickup: A=type, temp_2=X, temp_3=Y

.endif ; COMBAT_INC
