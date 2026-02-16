; ============================================================================
; enums.inc - Game State Enumerations and Constants
; ============================================================================
; All game-wide enumeration values and constant IDs.
; ============================================================================

.ifndef ENUMS_INC
ENUMS_INC = 1

; ============================================================================
; Game State Enum
; Used by game_state variable to control the main state machine.
; ============================================================================

GAME_STATE_TITLE        = 0
GAME_STATE_GAMEPLAY     = 1
GAME_STATE_PAUSED       = 2
GAME_STATE_INVENTORY    = 3
GAME_STATE_MAP_SCREEN   = 4
GAME_STATE_DIALOG       = 5
GAME_STATE_SHOP         = 6
GAME_STATE_GAME_OVER    = 7

GAME_STATE_COUNT        = 8

; ============================================================================
; Direction Enum
; Used for player/enemy facing direction and movement.
; ============================================================================

DIR_UP      = 0
DIR_DOWN    = 1
DIR_LEFT    = 2
DIR_RIGHT   = 3

DIR_COUNT   = 4

; ============================================================================
; Item IDs (placeholder)
; Will be expanded as items are added to the game.
; ============================================================================

ITEM_NONE       = 0
ITEM_SWORD      = 1
ITEM_SHIELD     = 2
ITEM_BOW        = 3
ITEM_ARROW      = 4
ITEM_BOMB       = 5
ITEM_KEY        = 6
ITEM_MAP        = 7
ITEM_COMPASS    = 8
ITEM_POTION     = 9
ITEM_CANDLE     = 10
ITEM_RAFT       = 11
ITEM_HAMMER     = 12
ITEM_FLUTE      = 13
ITEM_HOOKSHOT   = 14
ITEM_MAGIC_CAPE = 15

ITEM_COUNT      = 16

; ============================================================================
; Enemy IDs (placeholder)
; Will be expanded as enemies are added to the game.
; ============================================================================

ENEMY_NONE          = 0
ENEMY_OCTOROK       = 1
ENEMY_MOBLIN        = 2
ENEMY_DARKNUT       = 3
ENEMY_STALFOS       = 4
ENEMY_KEESE         = 5
ENEMY_TEKTITE       = 6
ENEMY_LEEVER        = 7
ENEMY_ZORA          = 8
ENEMY_ROPE          = 9
ENEMY_GORIYA        = 10
ENEMY_WIZZROBE      = 11
ENEMY_LIKE_LIKE     = 12
ENEMY_IRON_KNUCKLE  = 13
ENEMY_BOSS_01       = 14
ENEMY_BOSS_02       = 15

ENEMY_COUNT         = 16

; ============================================================================
; Tile IDs (placeholder for collision/type identification)
; ============================================================================

TILE_EMPTY      = 0
TILE_SOLID      = 1
TILE_GRASS      = 2
TILE_WATER      = 3
TILE_SAND       = 4
TILE_STAIRS     = 5
TILE_DOOR       = 6
TILE_CHEST      = 7

.endif ; ENUMS_INC
