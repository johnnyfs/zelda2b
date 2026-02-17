; ============================================================================
; warps.s - Cave Entrance/Exit Warp System
; ============================================================================
; Implements warp points that teleport the player between screens when
; stepping on a door metatile (ID 7) that matches a warp table entry.
;
; Called each frame during gameplay. Converts player position to metatile
; coordinates, checks if standing on a door, then scans the warp table
; for a matching (screen_id, tile_x, tile_y) entry. If found, executes
; the warp: disables rendering, loads the destination screen, repositions
; the player, redraws the HUD, and re-enables rendering.
;
; A cooldown timer prevents instant re-warping when arriving at a
; destination that is itself a warp point.
;
; This code runs in PRG_FIXED ($E000-$FFFF).
; Warp table data is in PRG_FIXED_C ($C000-$DFFF).
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"
.include "warps.inc"
.include "hud.inc"
.include "combat.inc"

.segment "PRG_FIXED"

; ============================================================================
; warp_init - Initialize warp system
; ============================================================================
; Call during game init. Clears the cooldown timer.
; ============================================================================

.proc warp_init
    lda #$00
    sta warp_cooldown
    rts
.endproc

; ============================================================================
; warp_check - Check if player is on a warp tile and execute warp
; ============================================================================
; Call once per frame during gameplay (after player_update, before transition).
; Returns: A = 1 if warp occurred, A = 0 if not
; Clobbers: A, X, Y, temp_0, temp_1, temp_2, temp_3, ptr_lo/hi, ptr2_lo
; ============================================================================

.proc warp_check
    ; --- Tick down cooldown timer ---
    lda warp_cooldown
    beq @no_cooldown
    dec warp_cooldown
    lda #$00                    ; No warp during cooldown
    rts
@no_cooldown:

    ; --- Convert player position to metatile coordinates ---
    ; metatile_x = (player_x + 6) / 16  (center of hitbox)
    lda player_x
    clc
    adc #6                      ; Center of hitbox (~6px inset for 16px sprite)
    lsr
    lsr
    lsr
    lsr
    sta temp_0                  ; temp_0 = metatile_x (0-15)

    ; metatile_y = (player_y + 6 - STATUS_BAR_Y_PX) / 16
    lda player_y
    clc
    adc #6                      ; Center of hitbox
    sec
    sbc #STATUS_BAR_Y_PX        ; Subtract 16px status bar
    bcc @no_warp                ; Above status bar = not on map
    lsr
    lsr
    lsr
    lsr
    sta temp_1                  ; temp_1 = metatile_y (0-13)

    ; --- Check if standing on a door metatile ---
    ; Read metatile ID from screen data at (tile_x, tile_y)
    ; offset = tile_y * 16 + tile_x
    lda temp_1
    asl
    asl
    asl
    asl                         ; A = tile_y * 16
    clc
    adc temp_0                  ; A = tile_y * 16 + tile_x
    tay                         ; Y = offset into screen data

    ; Set up pointer to current screen data
    ldx current_screen_id
    lda screen_ptrs_lo, x
    sta ptr_lo
    lda screen_ptrs_hi, x
    sta ptr_hi
    lda (ptr_lo), y             ; A = metatile ID at player position

    cmp #METATILE_DOOR
    bne @no_warp                ; Not on a door tile

    ; --- Scan warp table for matching entry ---
    ; Looking for: src_screen_id == current_screen_id
    ;              src_tile_x == temp_0
    ;              src_tile_y == temp_1
    ldx #$00                    ; X = byte offset into warp table

@scan_loop:
    cpx #(MAX_WARPS * WARP_ENTRY_SIZE)
    bcs @no_warp                ; Scanned all entries, no match

    ; Check for end-of-table sentinel ($FF)
    lda warp_table, x
    cmp #$FF
    beq @no_warp

    ; Check src_screen_id
    cmp current_screen_id
    bne @next_entry

    ; Check src_tile_x
    lda warp_table + 1, x
    cmp temp_0
    bne @next_entry

    ; Check src_tile_y
    lda warp_table + 2, x
    cmp temp_1
    bne @next_entry

    ; --- Match found! Save destination info ---
    lda warp_table + 3, x       ; dest_screen_id
    sta temp_2
    lda warp_table + 4, x       ; dest_x_px
    sta temp_3
    lda warp_table + 5, x       ; dest_y_px
    sta ptr2_lo                 ; Stash dest_y temporarily

    jmp @execute_warp

@next_entry:
    ; Advance to next warp entry (6 bytes)
    txa
    clc
    adc #WARP_ENTRY_SIZE
    tax
    jmp @scan_loop

@no_warp:
    lda #$00
    rts

@execute_warp:
    ; --- Disable rendering ---
    lda #$00
    sta PPUMASK

    ; --- Clear enemies on screen change ---
    ldx #$00
@clear_enemies:
    cpx #MAX_ENEMIES
    bcs @clear_pickups_start
    lda #$00
    sta enemy_state, x
    inx
    jmp @clear_enemies

@clear_pickups_start:
    ; --- Clear pickups on screen change ---
    ldx #$00
@clear_pickups:
    cpx #MAX_PICKUPS
    bcs @load_dest
    lda #$00
    sta pickup_state, x
    inx
    jmp @clear_pickups

@load_dest:
    ; --- Update screen ID ---
    lda temp_2                  ; dest_screen_id
    sta current_screen_id

    ; --- Update screen_x/y for consistency with grid transition system ---
    ; Cave screens (id >= MAP_GRID_TOTAL) get safe mid-range values
    ; that won't trigger edge transitions in map_check_transition
    cmp #MAP_GRID_TOTAL
    bcs @cave_screen

    ; Overworld screen: compute x = id % MAP_GRID_W, y = id / MAP_GRID_W
    ldy #$00                    ; Y = quotient (screen_y)
@div_loop:
    cmp #MAP_GRID_W_CONST
    bcc @div_done
    sec
    sbc #MAP_GRID_W_CONST
    iny
    jmp @div_loop
@div_done:
    sta current_screen_x        ; remainder = screen_x
    sty current_screen_y        ; quotient = screen_y
    jmp @load_screen

@cave_screen:
    ; Cave screens: set screen_x/y to safe mid-range values
    ; These won't be 0 (preventing left/top transition) and won't be
    ; at max (preventing right/bottom transition), keeping the player
    ; trapped in the cave until they use the exit warp
    lda #$01
    sta current_screen_x
    sta current_screen_y

@load_screen:
    ; Load the destination screen into the nametable
    lda current_screen_id
    jsr map_load_screen

    ; --- Set player position at destination ---
    lda temp_3                  ; dest_x_px
    sta player_x
    lda ptr2_lo                 ; dest_y_px (stashed earlier)
    sta player_y

    ; --- Set warp cooldown to prevent instant re-warp ---
    lda #WARP_COOLDOWN_FRAMES
    sta warp_cooldown

    ; --- Redraw HUD (screen load cleared it) ---
    jsr hud_draw_full

    ; --- Re-enable rendering ---
    lda ppu_mask_shadow
    sta PPUMASK

    ; --- Reset scroll position ---
    lda PPUSTATUS               ; Reset PPU address latch
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    ; --- Return: warp occurred ---
    lda #$01
    rts
.endproc

; ============================================================================
; Warp Table Data (in PRG_FIXED_C for always-accessible data)
; ============================================================================

.segment "PRG_FIXED_C"

; Format: src_screen, src_tile_x, src_tile_y, dest_screen, dest_x_px, dest_y_px
;
; Screen 3 has two cave entrances (doors at metatile positions):
;   Left cave door:  tile (4, 4)  -> warp to cave screen 6
;   Right cave door: tile (11, 4) -> warp to cave screen 7
;
; Cave screen 6 exit door at tile (7, 12) -> back to screen 3
; Cave screen 7 exit door at tile (7, 12) -> back to screen 3
;
; Screen 4 has building doors:
;   Left building:   tile (3, 4)  -> warp to cave screen 6
;   Right building:  tile (12, 4) -> warp to cave screen 7
;   Bottom-left:     tile (4, 11) -> warp to cave screen 6
;   Bottom-right:    tile (11, 11)-> warp to cave screen 7

warp_table:
    ; --- Screen 3: Southern woods cave entrances ---
    ; Left cave entrance -> Cave A interior (screen 6)
    ; Player arrives near bottom of cave (Y=192 = 12 metatiles from top + status bar)
    .byte 3, 4, 4, 6, 120, 160

    ; Right cave entrance -> Cave B interior (screen 7)
    .byte 3, 11, 4, 7, 120, 160

    ; --- Cave A (screen 6): exit door -> back to screen 3 left cave ---
    ; Exit at tile (7,12), player arrives just below the door on screen 3
    .byte 6, 7, 12, 3, 64, 96
    ; Also check tile (8,12) since the door is 2 metatiles wide
    .byte 6, 8, 12, 3, 64, 96

    ; --- Cave B (screen 7): exit door -> back to screen 3 right cave ---
    .byte 7, 7, 12, 3, 176, 96
    .byte 7, 8, 12, 3, 176, 96

    ; --- Screen 4: Village building entrances ---
    ; Left building door -> Cave A (shop placeholder)
    .byte 4, 3, 4, 6, 120, 160

    ; Right building door -> Cave B (NPC placeholder)
    .byte 4, 12, 4, 7, 120, 160

    ; Bottom-left building door -> Cave A
    .byte 4, 4, 11, 6, 120, 160

    ; Bottom-right building door -> Cave B
    .byte 4, 11, 11, 7, 120, 160

    ; --- End sentinel ---
    .byte $FF, $FF, $FF, $FF, $FF, $FF
