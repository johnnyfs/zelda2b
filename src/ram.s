; ============================================================================
; ram.s - RAM Variable Allocation
; ============================================================================
; Defines (allocates storage for) all zero-page and RAM variables
; declared in globals.inc. Only this file should define these variables;
; all other files import them via .globalzp / .global in globals.inc.
; ============================================================================

.include "globals.inc"
.include "map.inc"
.include "combat.inc"
.include "bombs.inc"
.include "hud.inc"
.include "warps.inc"
.include "inventory.inc"
.include "shop.inc"

; ============================================================================
; Zero Page Variables ($0000-$00FF)
; ============================================================================

.segment "ZEROPAGE"

; --- System state ---
nmi_ready:          .res 1      ; Flag: NMI handler sets, main loop clears
nmi_counter:        .res 1      ; Incremented every NMI (vblank counter)
game_state:         .res 1      ; Current game state (see enums.inc)
frame_counter:      .res 1      ; General purpose frame counter

; --- Temp / scratch variables ---
temp_0:             .res 1
temp_1:             .res 1
temp_2:             .res 1
temp_3:             .res 1
ptr_lo:             .res 1      ; General purpose pointer (low byte)
ptr_hi:             .res 1      ; General purpose pointer (high byte)
ptr2_lo:            .res 1      ; Second pointer (low byte)
ptr2_hi:            .res 1      ; Second pointer (high byte)

; --- Gamepad state ---
pad1_state:         .res 1      ; Controller 1: current frame buttons
pad1_prev:          .res 1      ; Controller 1: previous frame buttons
pad1_pressed:       .res 1      ; Controller 1: newly pressed this frame
pad2_state:         .res 1      ; Controller 2: current frame buttons
pad2_prev:          .res 1      ; Controller 2: previous frame buttons
pad2_pressed:       .res 1      ; Controller 2: newly pressed this frame

; --- Player state ---
player_x:           .res 1      ; Player X position (pixels, integer part)
player_y:           .res 1      ; Player Y position (pixels, integer part)
player_x_sub:       .res 1      ; Player X sub-pixel (fractional byte, 8.8 fixed)
player_y_sub:       .res 1      ; Player Y sub-pixel (fractional byte, 8.8 fixed)
player_dir:         .res 1      ; Player facing direction
player_speed:       .res 1      ; Player movement speed (legacy)
player_anim_frame:  .res 1      ; Current animation frame (0 or 1)
player_anim_timer:  .res 1      ; Animation timer countdown
player_moving:      .res 1      ; Non-zero if player moved this frame

; --- PPU state ---
ppu_ctrl_shadow:    .res 1      ; Shadow copy of PPUCTRL
ppu_mask_shadow:    .res 1      ; Shadow copy of PPUMASK
scroll_x:           .res 1      ; Horizontal scroll position
scroll_y:           .res 1      ; Vertical scroll position

; --- Sprite allocation ---
oam_offset:         .res 1      ; Next free OAM slot offset (0-255)

; --- Map engine state ---
current_screen_x:   .res 1      ; Current screen X in map grid
current_screen_y:   .res 1      ; Current screen Y in map grid
current_screen_id:  .res 1      ; Computed screen index
map_row_counter:    .res 1      ; Row counter for screen loading
map_col_counter:    .res 1      ; Column counter for screen loading

; --- MMC3 bank shadows ---
current_prg_bank_0: .res 1      ; Current PRG bank at $8000-$9FFF
current_prg_bank_1: .res 1      ; Current PRG bank at $A000-$BFFF

; --- Enemy state (parallel arrays, MAX_ENEMIES=4 slots) ---
enemy_x:            .res MAX_ENEMIES    ; X positions
enemy_y:            .res MAX_ENEMIES    ; Y positions
enemy_type:         .res MAX_ENEMIES    ; Enemy type IDs
enemy_hp:           .res MAX_ENEMIES    ; Hit points
enemy_state:        .res MAX_ENEMIES    ; State (inactive/active/hurt/dying)
enemy_dir:          .res MAX_ENEMIES    ; Facing direction
enemy_timer:        .res MAX_ENEMIES    ; General purpose timer

; --- Player combat state ---
player_state:       .res 1      ; Player action state (normal/attack)
player_attack_timer:.res 1      ; Attack animation countdown
player_hp:          .res 1      ; Current hit points
player_max_hp:      .res 1      ; Maximum hit points
player_invuln_timer:.res 1      ; Invincibility frames countdown

; --- HUD state ---
hud_dirty:          .res 1      ; Non-zero = HUD needs VRAM update
hud_hp_cache:       .res 1      ; Cached player HP (detect changes)
hud_magic_cache:    .res 1      ; Cached magic value (detect changes)

; --- Pickup state (parallel arrays, MAX_PICKUPS=4 slots) ---
pickup_x:           .res MAX_PICKUPS    ; X positions
pickup_y:           .res MAX_PICKUPS    ; Y positions
pickup_type:        .res MAX_PICKUPS    ; Pickup type IDs
pickup_state:       .res MAX_PICKUPS    ; State (inactive/active/spawning)
pickup_timer:       .res MAX_PICKUPS    ; Timer (spawn animation)

; --- Bomb state (parallel arrays, MAX_BOMBS=2 slots) ---
bomb_x:             .res MAX_BOMBS      ; X positions
bomb_y:             .res MAX_BOMBS      ; Y positions
bomb_state:         .res MAX_BOMBS      ; State (inactive/fuse/exploding/smoke)
bomb_timer:         .res MAX_BOMBS      ; Countdown timer
player_bombs:       .res 1              ; Current bomb inventory count

; --- Warp system state ---
warp_cooldown:      .res 1              ; Cooldown timer (prevents instant re-warp)

; --- Inventory / item system state ---
inv_cursor_x:       .res 1              ; Cursor column in item grid (0-3)
inv_cursor_y:       .res 1              ; Cursor row in item grid (0-3)
inv_blink_timer:    .res 1              ; Cursor blink timer
selected_b_item:    .res 1              ; Currently selected B-button item
player_keys:        .res 1              ; Key count
player_arrows:      .res 1              ; Arrow count

; --- Magic system ---
player_magic:       .res 1              ; Current magic points (0-32)
player_max_magic:   .res 1              ; Max magic (bottles * 8)
magic_bottles_count:.res 1              ; Number of magic bottles (0-4)

; --- Shop state ---
shop_active:        .res 1              ; Non-zero if current screen is a shop
shop_id:            .res 1              ; Which shop data to use (0-MAX_SHOPS)
shop_items_bought:  .res 1              ; Bitmask: bit 0/1/2 = items bought

; --- Player currency ---
player_rupees_lo:   .res 1              ; Rupees low byte (binary, 0-255)
player_rupees_hi:   .res 1              ; Rupees high byte (for max 999)

; ============================================================================
; OAM Shadow Buffer ($0200-$02FF)
; ============================================================================
; The OAM buffer is used directly by address ($0200) in the code for DMA.
; We declare the segment here so the linker doesn't warn about it.

.segment "OAM"
oam_buffer:         .res 256    ; 64 sprites x 4 bytes each (accessed at $0200)

; ============================================================================
; RAM Variables ($0300-$07FF)
; ============================================================================

.segment "RAM"

; --- PPU write buffer (for deferred VRAM writes during NMI) ---
ppu_buffer:         .res 96     ; PPU write buffer (96 bytes, HUD needs ~44)
ppu_buffer_len:     .res 1      ; Current length of buffered data

; --- Collision map (built from metatile solid flags during screen load) ---
; Each byte is 0 (passable) or 1 (solid), indexed by metatile_row * 16 + metatile_col.
; Derived from metatile attribute byte bit 7 — same data that drives visual rendering.
collision_map:      .res MAP_SCREEN_SIZE  ; 224 bytes (16x14)

; --- Player item ownership (1 byte per item: 0=not owned, 1+=owned/count) ---
player_items:       .res ITEM_COUNT       ; 16 bytes

; --- Visited screens bitmask (1 bit per screen, up to 64 screens) ---
visited_screens:    .res 8                ; 8 bytes = 64 screen bits
