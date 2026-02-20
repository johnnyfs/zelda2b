; ==========================================================
; Sound Effect Pointer Table — Zelda 2B
; Indexed lookup table for all 16 SFX
; ==========================================================

.segment "PRG_FIXED_C"

; Import all SFX symbols from sfx_data.s
.import sfx_sword_swing
.import sfx_sword_hit
.import sfx_enemy_hit
.import sfx_enemy_die
.import sfx_player_hurt
.import sfx_player_die
.import sfx_item_pickup
.import sfx_heart_pickup
.import sfx_rupee_pickup
.import sfx_menu_cursor
.import sfx_menu_select
.import sfx_door_open
.import sfx_bomb_explode
.import sfx_spell_cast
.import sfx_text_blip
.import sfx_fanfare

; ==========================================================
; SFX Index Constants (for reference)
; ==========================================================
; SFX_SWORD_SWING   = 0
; SFX_SWORD_HIT     = 1
; SFX_ENEMY_HIT     = 2
; SFX_ENEMY_DIE     = 3
; SFX_PLAYER_HURT   = 4
; SFX_PLAYER_DIE    = 5
; SFX_ITEM_PICKUP   = 6
; SFX_HEART_PICKUP  = 7
; SFX_RUPEE_PICKUP  = 8
; SFX_MENU_CURSOR   = 9
; SFX_MENU_SELECT   = 10
; SFX_DOOR_OPEN     = 11
; SFX_BOMB_EXPLODE  = 12
; SFX_SPELL_CAST    = 13
; SFX_TEXT_BLIP     = 14
; SFX_FANFARE       = 15

; ==========================================================
; Pointer Table (Low Bytes)
; ==========================================================
.export sfx_table_lo
sfx_table_lo:
    .byte <sfx_sword_swing
    .byte <sfx_sword_hit
    .byte <sfx_enemy_hit
    .byte <sfx_enemy_die
    .byte <sfx_player_hurt
    .byte <sfx_player_die
    .byte <sfx_item_pickup
    .byte <sfx_heart_pickup
    .byte <sfx_rupee_pickup
    .byte <sfx_menu_cursor
    .byte <sfx_menu_select
    .byte <sfx_door_open
    .byte <sfx_bomb_explode
    .byte <sfx_spell_cast
    .byte <sfx_text_blip
    .byte <sfx_fanfare

; ==========================================================
; Pointer Table (High Bytes)
; ==========================================================
.export sfx_table_hi
sfx_table_hi:
    .byte >sfx_sword_swing
    .byte >sfx_sword_hit
    .byte >sfx_enemy_hit
    .byte >sfx_enemy_die
    .byte >sfx_player_hurt
    .byte >sfx_player_die
    .byte >sfx_item_pickup
    .byte >sfx_heart_pickup
    .byte >sfx_rupee_pickup
    .byte >sfx_menu_cursor
    .byte >sfx_menu_select
    .byte >sfx_door_open
    .byte >sfx_bomb_explode
    .byte >sfx_spell_cast
    .byte >sfx_text_blip
    .byte >sfx_fanfare

; ==========================================================
; SFX Count
; ==========================================================
.export sfx_count
sfx_count = 16
