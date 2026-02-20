; ============================================================================
; globals.inc - Global Variable Declarations
; ============================================================================
; Defines all shared zero-page and RAM variables, plus import/export
; declarations for cross-module symbols.
; ============================================================================

.ifndef GLOBALS_INC
GLOBALS_INC = 1

.include "enums.inc"

; ============================================================================
; Zero Page Variables ($0000-$00FF)
; Organized by subsystem for clarity.
; ============================================================================

.globalzp nmi_ready             ; Flag: NMI handler sets, main loop clears
.globalzp nmi_counter           ; Incremented every NMI (vblank counter)
.globalzp game_state            ; Current game state (see enums.inc)
.globalzp frame_counter         ; General purpose frame counter

; --- Temp / scratch variables (used by any routine, not preserved) ---
.globalzp temp_0
.globalzp temp_1
.globalzp temp_2
.globalzp temp_3
.globalzp ptr_lo                ; General purpose pointer (low byte)
.globalzp ptr_hi                ; General purpose pointer (high byte)
.globalzp ptr2_lo               ; Second pointer (low byte)
.globalzp ptr2_hi               ; Second pointer (high byte)

; --- Gamepad state ---
.globalzp pad1_state            ; Controller 1: current frame buttons
.globalzp pad1_prev             ; Controller 1: previous frame buttons
.globalzp pad1_pressed          ; Controller 1: newly pressed this frame
.globalzp pad2_state            ; Controller 2: current frame buttons
.globalzp pad2_prev             ; Controller 2: previous frame buttons
.globalzp pad2_pressed          ; Controller 2: newly pressed this frame

; --- Player state ---
.globalzp player_x              ; Player X position (pixels, integer part)
.globalzp player_y              ; Player Y position (pixels, integer part)
.globalzp player_x_sub          ; Player X sub-pixel (fractional byte, 8.8 fixed)
.globalzp player_y_sub          ; Player Y sub-pixel (fractional byte, 8.8 fixed)
.globalzp player_dir            ; Player facing direction
.globalzp player_speed          ; Player movement speed (legacy)
.globalzp player_anim_frame     ; Current animation frame (0 or 1)
.globalzp player_anim_timer     ; Animation timer countdown
.globalzp player_moving         ; Non-zero if player moved this frame

; --- PPU state ---
.globalzp ppu_ctrl_shadow       ; Shadow copy of PPUCTRL
.globalzp ppu_mask_shadow       ; Shadow copy of PPUMASK
.globalzp scroll_x              ; Horizontal scroll position
.globalzp scroll_y              ; Vertical scroll position

; --- Sprite allocation ---
.globalzp oam_offset            ; Next free OAM slot offset (0-255)

; --- MMC3 bank shadows ---
.globalzp current_prg_bank_0    ; Current PRG bank at $8000-$9FFF
.globalzp current_prg_bank_1    ; Current PRG bank at $A000-$BFFF

; ============================================================================
; RAM Variables ($0300-$07FF)
; ============================================================================

; --- PPU write buffer (for deferred VRAM writes during NMI) ---
.global ppu_buffer              ; PPU write buffer (64 bytes)
.global ppu_buffer_len          ; Current length of buffered data

; --- Collision map (derived from metatile solid flags at screen load time) ---
.global collision_map           ; 224 bytes (16x14): 0=passable, 1=solid

; ============================================================================
; Shared Subroutine Imports/Exports
; ============================================================================

; -- init.s --
.global reset_handler

; -- nmi.s --
.global nmi_handler

; -- vectors.s --
.global irq_handler

; -- main.s --
.global main_loop

; -- mmc3.s --
.global switch_prg_bank_0
.global switch_prg_bank_1
.global switch_chr_2k_0
.global switch_chr_2k_1
.global switch_chr_1k_0
.global switch_chr_1k_1
.global switch_chr_1k_2
.global switch_chr_1k_3
.global set_mirroring
.global init_mmc3

; -- gamepad.s --
.global read_gamepads

; -- gfx/ppu.s --
.global ppu_wait_vblank
.global ppu_load_palette
.global ppu_clear_nametable
.global ppu_write_string
.global ppu_buffer_write

; -- gfx/sprites.s --
.global clear_oam
.global alloc_sprite
.global push_sprite

; -- data/palettes.s --
.global default_palette

; -- audio/audio.s --
.global audio_init
.global audio_update
.global audio_play_song
.global audio_stop_music
.global audio_pause_music
.global audio_play_sfx

; -- player/player.s --
.global player_init
.global player_update
.global player_draw

; -- map/map_collision.s --
.global check_collision

; -- data/test_screen.s --
.global load_test_screen

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
.global bit_mask_table

; -- map/warps.s --
.global warp_init
.global warp_check
.global warp_table
.globalzp warp_cooldown

; -- npc/shop.s --
.global shop_init
.global shop_enter
.global shop_update
.global shop_draw_items
.global shop_draw_prices
.global shop_update_rupee_display

; -- data/shop_data.s --
.global shop_data_table
.global shop_screen_table

; -- npc/dialog.s --
.global dialog_init
.global dialog_open
.global dialog_update
.global dialog_close
.global npc_init
.global npc_spawn_screen
.global npc_draw
.global npc_check_interact

; -- dialog zero-page vars --
.globalzp dialog_state
.globalzp dialog_id
.globalzp dialog_ptr_lo
.globalzp dialog_ptr_hi
.globalzp dialog_char_timer
.globalzp dialog_line
.globalzp dialog_col
.globalzp dialog_page
.globalzp npc_count

; -- dialog/NPC RAM vars --
.global npc_x
.global npc_y
.global npc_tile
.global npc_dialog_id
.global dialog_line_buf

.endif ; GLOBALS_INC
