; ============================================================================
; ui/map_screen.s - Overlay Map Screen (16x16 Overworld Grid)
; ============================================================================
; Renders a 16x16 minimap grid as a bordered overlay.
; Opened with Select button, closed with Select or Start.
;
; Each cell = 1 BG tile representing one overworld screen.
; Visited screens shown as MAP_TILE_EXPLORED, unvisited as blank.
; Current position shown with a blinking sprite.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "inventory.inc"
.include "hud.inc"
.include "map.inc"

.segment "PRG_FIXED"

; ============================================================================
; map_screen_open - Open map overlay
; ============================================================================

.proc map_screen_open
    lda #GAME_STATE_MAP_SCREEN
    sta game_state

    ; Reset blink timer (reuse inv_blink_timer)
    lda #$00
    sta inv_blink_timer

    ; --- Disable rendering ---
    lda #$00
    sta PPUMASK

    ; --- Ensure PPUCTRL increment mode = +1 (horizontal) ---
    lda ppu_ctrl_shadow
    and #<~PPUCTRL_INC_32   ; Clear increment-32 bit
    sta PPUCTRL

    ; --- Draw overlay border (same as inventory) ---
    jsr map_draw_border

    ; --- Draw 16x16 minimap grid ---
    jsr map_draw_grid

    ; --- Re-enable rendering ---
    lda ppu_mask_shadow
    sta PPUMASK

    ; Reset scroll
    lda PPUSTATUS
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    rts
.endproc

; ============================================================================
; map_screen_update - Per-frame update while map is open
; ============================================================================

.proc map_screen_update
    ; --- Blink timer ---
    inc inv_blink_timer

    ; --- Select or Start: close map ---
    lda pad1_pressed
    and #(BUTTON_SELECT | BUTTON_START)
    beq @no_close
    jsr map_screen_close
    rts
@no_close:

    ; --- Draw current position blinking sprite ---
    jsr map_draw_position_sprite

    rts
.endproc

; ============================================================================
; map_screen_close - Close map, restore gameplay screen
; ============================================================================

.proc map_screen_close
    ; Disable rendering
    lda #$00
    sta PPUMASK

    ; Reload current map screen
    lda current_screen_id
    jsr map_load_screen

    ; Redraw HUD
    jsr hud_init

    ; Re-enable rendering
    lda ppu_mask_shadow
    sta PPUMASK

    ; Reset scroll
    lda PPUSTATUS
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    ; Return to gameplay
    lda #GAME_STATE_GAMEPLAY
    sta game_state
    rts
.endproc

; ============================================================================
; map_draw_border - Draw overlay border (same layout as inventory)
; ============================================================================

.proc map_draw_border
    lda #INV_OVERLAY_TOP
    sta temp_3

@row_loop:
    ; PPU addr = $2000 + temp_3 * 32 + INV_OVERLAY_LEFT
    lda temp_3
    asl
    asl
    asl
    asl
    asl
    sta ptr_lo
    lda temp_3
    lsr
    lsr
    lsr
    clc
    adc #$20
    sta ptr_hi
    lda ptr_lo
    clc
    adc #INV_OVERLAY_LEFT
    sta ptr_lo
    lda ptr_hi
    adc #$00
    sta ptr_hi

    lda PPUSTATUS
    lda ptr_hi
    sta PPUADDR
    lda ptr_lo
    sta PPUADDR

    lda temp_3
    cmp #INV_OVERLAY_TOP
    beq @top_row
    cmp #INV_OVERLAY_BOTTOM
    beq @bottom_row
    jmp @middle_row

@top_row:
    lda #HUD_TILE_BOX_TL
    sta PPUDATA
    ldx #(INV_OVERLAY_W - 2)
@top_fill:
    lda #HUD_TILE_BOX_TR
    sta PPUDATA
    dex
    bne @top_fill
    lda #HUD_TILE_BOX_TR
    sta PPUDATA
    jmp @next_row

@bottom_row:
    lda #HUD_TILE_BOX_BL
    sta PPUDATA
    ldx #(INV_OVERLAY_W - 2)
@bot_fill:
    lda #HUD_TILE_BOX_BR
    sta PPUDATA
    dex
    bne @bot_fill
    lda #HUD_TILE_BOX_BR
    sta PPUDATA
    jmp @next_row

@middle_row:
    lda #HUD_TILE_BOX_BL
    sta PPUDATA
    ldx #(INV_OVERLAY_W - 2)
@mid_fill:
    lda #$00
    sta PPUDATA
    dex
    bne @mid_fill
    lda #HUD_TILE_BOX_BR
    sta PPUDATA

@next_row:
    inc temp_3
    lda temp_3
    cmp #(INV_OVERLAY_BOTTOM + 1)
    beq @border_done
    jmp @row_loop
@border_done:
    rts
.endproc

; ============================================================================
; map_draw_grid - Draw 16x16 minimap grid on nametable
; ============================================================================
; Each cell is 1 tile. Grid starts at MAP_DISP_TOP, MAP_DISP_LEFT.
; Checks visited_screens bitmask for each cell.
;
; The actual overworld is MAP_GRID_W_CONST x MAP_GRID_H_CONST (currently 3x2),
; but the display grid is 16x16 to match the design spec.
; Screens outside the actual map range show as permanently unexplored.
; ============================================================================

.proc map_draw_grid
    lda #$00
    sta temp_2              ; row counter (0-15)

@row_loop:
    ; PPU addr = $2000 + (MAP_DISP_TOP + row) * 32 + MAP_DISP_LEFT
    lda temp_2
    clc
    adc #MAP_DISP_TOP
    sta temp_3              ; tile row

    asl
    asl
    asl
    asl
    asl
    sta ptr_lo
    lda temp_3
    lsr
    lsr
    lsr
    clc
    adc #$20
    sta ptr_hi
    lda ptr_lo
    clc
    adc #MAP_DISP_LEFT
    sta ptr_lo
    lda ptr_hi
    adc #$00
    sta ptr_hi

    lda PPUSTATUS
    lda ptr_hi
    sta PPUADDR
    lda ptr_lo
    sta PPUADDR

    ; Write 16 cells for this row
    lda #$00
    sta temp_0              ; col counter (0-15)

@col_loop:
    ; Check if this cell is within the actual map bounds
    ; Actual map: cols 0..MAP_GRID_W_CONST-1, rows 0..MAP_GRID_H_CONST-1
    lda temp_0              ; col
    cmp #MAP_GRID_W_CONST
    bcs @out_of_bounds
    lda temp_2              ; row
    cmp #MAP_GRID_H_CONST
    bcs @out_of_bounds

    ; Within bounds: compute screen index = row * MAP_GRID_W_CONST + col
    ; Multiply row by MAP_GRID_W_CONST (currently 3)
    lda temp_2
    ; *3: val + val*2
    sta temp_1
    asl
    clc
    adc temp_1
    clc
    adc temp_0              ; + col = screen index
    ; Check visited_screens bitmask
    ; byte_index = screen_index / 8, bit_index = screen_index & 7
    tax                     ; save screen index
    lsr
    lsr
    lsr                     ; /8 = byte index
    tay                     ; Y = byte index
    txa                     ; restore screen index
    and #$07                ; bit index
    tax
    lda bit_mask_table, x   ; get bit mask
    and visited_screens, y  ; test bit
    beq @unvisited

    ; Visited cell
    lda #MAP_TILE_EXPLORED
    sta PPUDATA
    jmp @next_col

@unvisited:
    lda #MAP_TILE_UNEXPLORED
    sta PPUDATA
    jmp @next_col

@out_of_bounds:
    ; Outside actual map: draw as blank/border
    lda #MAP_TILE_UNEXPLORED
    sta PPUDATA

@next_col:
    inc temp_0
    lda temp_0
    cmp #MAP_DISP_W
    bne @col_loop

    ; Next row
    inc temp_2
    lda temp_2
    cmp #MAP_DISP_H
    beq @grid_done
    jmp @row_loop
@grid_done:
    rts
.endproc

; ============================================================================
; map_draw_position_sprite - Draw blinking sprite at current map position
; ============================================================================
; Places a sprite at the current_screen_x, current_screen_y position
; in the minimap grid. Blinks using inv_blink_timer.
; ============================================================================

.proc map_draw_position_sprite
    ; Blink: visible when bit 3 of timer is clear
    lda inv_blink_timer
    and #$08
    bne @done

    ; Calculate pixel position:
    ; X = (MAP_DISP_LEFT + current_screen_x) * 8
    ; Y = (MAP_DISP_TOP + current_screen_y) * 8 - 1
    lda current_screen_x
    clc
    adc #MAP_DISP_LEFT
    asl
    asl
    asl
    sta temp_0              ; pixel X

    lda current_screen_y
    clc
    adc #MAP_DISP_TOP
    asl
    asl
    asl
    sec
    sbc #$01                ; OAM Y offset
    sta temp_1              ; pixel Y

    ; Draw single sprite as position marker
    ldx oam_offset
    lda temp_1
    sta $0200, x
    inx
    lda #$7F                ; Position marker tile (placeholder)
    sta $0200, x
    inx
    lda #OAM_PALETTE_3      ; Bright palette
    sta $0200, x
    inx
    lda temp_0
    sta $0200, x
    inx
    stx oam_offset

@done:
    rts
.endproc

; bit_mask_table is defined in item_system.s and imported via .global
