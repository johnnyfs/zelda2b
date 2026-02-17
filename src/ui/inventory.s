; ============================================================================
; ui/inventory.s - Overlay Inventory Screen
; ============================================================================
; Renders inventory as a bordered overlay on top of the current map.
; Opened with Start button, closed with Start again.
;
; Layout (overlay over existing map):
;   LEFT HALF:  B-equipped item + 4x3 selectable item grid + quest items
;   RIGHT HALF: Crystal obelisks (n/6) + dungeon items + counters
;
; No text descriptions — icons only.
; Cursor navigates the 4x3 grid; A assigns item to B-button.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "inventory.inc"
.include "hud.inc"
.include "map.inc"
.include "bombs.inc"

.segment "PRG_FIXED"

; ============================================================================
; B-selectable item IDs (maps grid index → ITEM_xxx)
; Grid: 4 cols x 3 rows = 12 selectable slots
; ============================================================================
b_item_table:
    .byte ITEM_BOMB         ; slot 0
    .byte ITEM_BOW          ; slot 1
    .byte ITEM_CANDLE       ; slot 2
    .byte ITEM_HOOKSHOT     ; slot 3
    .byte ITEM_HAMMER       ; slot 4
    .byte ITEM_FLUTE        ; slot 5
    .byte ITEM_POTION       ; slot 6
    .byte ITEM_NONE         ; slot 7  (empty)
    .byte ITEM_NONE         ; slot 8  (empty)
    .byte ITEM_NONE         ; slot 9  (empty)
    .byte ITEM_NONE         ; slot 10 (empty)
    .byte ITEM_NONE         ; slot 11 (empty)

; Item sprite tile indices (for 16x16 portraits = 2x2 sprites)
; Index by ITEM_xxx, gives top-left CHR tile of the 2x2 item portrait.
; Items not present use $00. Actual tiles in sprite CHR bank.
item_portrait_tiles:
    .byte $00               ; ITEM_NONE
    .byte $30               ; ITEM_SWORD    (tiles $30,$31,$32,$33)
    .byte $34               ; ITEM_SHIELD
    .byte $38               ; ITEM_BOW
    .byte $3C               ; ITEM_ARROW    (ammo, not selectable)
    .byte $40               ; ITEM_BOMB
    .byte $44               ; ITEM_KEY      (ammo, not selectable)
    .byte $48               ; ITEM_MAP      (dungeon item)
    .byte $4C               ; ITEM_COMPASS  (dungeon item)
    .byte $50               ; ITEM_POTION
    .byte $54               ; ITEM_CANDLE
    .byte $58               ; ITEM_RAFT     (quest item)
    .byte $5C               ; ITEM_HAMMER
    .byte $60               ; ITEM_FLUTE
    .byte $64               ; ITEM_HOOKSHOT
    .byte $68               ; ITEM_MAGIC_CAPE (quest item)

; Quest item list (non-selectable items displayed in quest row)
quest_item_list:
    .byte ITEM_RAFT
    .byte ITEM_MAGIC_CAPE
    .byte ITEM_SHIELD
    .byte $FF               ; terminator

; Counter item list: icon tile, item_id for count lookup
counter_items:
    ;       icon_tile, item_id
    .byte   $44, ITEM_KEY       ; Keys
    .byte   $3C, ITEM_ARROW     ; Arrows
    .byte   $40, ITEM_BOMB      ; Bombs
    .byte   $50, ITEM_POTION    ; Potions
COUNTER_COUNT = 4

; ============================================================================
; inventory_init - Initialize inventory state
; ============================================================================
; Called once at game start.
; ============================================================================

.proc inventory_init
    lda #$00
    sta inv_cursor_x
    sta inv_cursor_y
    sta inv_blink_timer
    ; selected_b_item set by item_system_init
    rts
.endproc

; ============================================================================
; inventory_open - Open inventory overlay
; ============================================================================
; Saves current nametable area (we rely on map_load_screen to restore on close).
; Draws the overlay border and contents directly to nametable.
; Sets game_state = GAME_STATE_INVENTORY.
;
; Must be called with rendering enabled; we disable, draw, re-enable.
; ============================================================================

.proc inventory_open
    ; Set game state
    lda #GAME_STATE_INVENTORY
    sta game_state

    ; Reset cursor blink
    lda #$00
    sta inv_blink_timer

    ; --- Disable rendering to write nametable ---
    lda #$00
    sta PPUMASK

    ; --- Draw overlay border ---
    jsr inv_draw_border

    ; --- Draw overlay interior (items, crystals, counters) ---
    jsr inv_draw_contents

    ; --- Re-enable rendering ---
    lda ppu_mask_shadow
    sta PPUMASK

    ; Reset scroll (overlay uses nametable 0)
    lda PPUSTATUS
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    rts
.endproc

; ============================================================================
; inventory_update - Per-frame update while inventory is open
; ============================================================================
; Handles d-pad cursor movement, A to select, Start to close.
; Draws cursor as sprites (blinking corners).
; ============================================================================

.proc inventory_update
    ; --- Blink timer ---
    inc inv_blink_timer

    ; --- Start: close inventory ---
    lda pad1_pressed
    and #BUTTON_START
    beq @no_close
    jsr inventory_close
    rts
@no_close:

    ; --- D-pad: move cursor ---
    lda pad1_pressed
    and #BUTTON_UP
    beq @no_up
    lda inv_cursor_y
    beq @no_up
    dec inv_cursor_y
@no_up:

    lda pad1_pressed
    and #BUTTON_DOWN
    beq @no_down
    lda inv_cursor_y
    cmp #(INV_GRID_ROWS - 1)
    bcs @no_down
    inc inv_cursor_y
@no_down:

    lda pad1_pressed
    and #BUTTON_LEFT
    beq @no_left
    lda inv_cursor_x
    beq @no_left
    dec inv_cursor_x
@no_left:

    lda pad1_pressed
    and #BUTTON_RIGHT
    beq @no_right
    lda inv_cursor_x
    cmp #(INV_GRID_COLS - 1)
    bcs @no_right
    inc inv_cursor_x
@no_right:

    ; --- A: select item for B-button ---
    lda pad1_pressed
    and #BUTTON_A
    beq @no_select
    ; Compute grid index = cursor_y * 4 + cursor_x
    lda inv_cursor_y
    asl                     ; *2
    asl                     ; *4
    clc
    adc inv_cursor_x
    tax
    lda b_item_table, x     ; Get ITEM_xxx for this slot
    beq @no_select           ; ITEM_NONE = can't select
    ; Check if player owns it
    tax
    lda player_items, x
    beq @no_select           ; Don't own it
    ; Assign to B-button
    lda b_item_table, x
    ; Wait - need to re-get the item id properly
    ; Re-compute: index in table
    lda inv_cursor_y
    asl
    asl
    clc
    adc inv_cursor_x
    tax
    lda b_item_table, x
    sta selected_b_item
    ; Play SFX would go here
@no_select:

    ; --- Draw cursor sprite (blinking 4-corner brackets) ---
    jsr inv_draw_cursor

    ; --- Draw equipped B item as sprite ---
    jsr inv_draw_equip_sprite

    rts
.endproc

; ============================================================================
; inventory_close - Close inventory, restore map screen
; ============================================================================

.proc inventory_close
    ; Disable rendering
    lda #$00
    sta PPUMASK

    ; Reload the current map screen (restores the nametable the overlay wrote over)
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
; inv_draw_border - Draw overlay border on nametable
; ============================================================================
; Draws a rectangular border using HUD box tiles.
; Interior filled with blank ($00) tiles.
; ============================================================================

.proc inv_draw_border
    ; We draw rows INV_OVERLAY_TOP to INV_OVERLAY_BOTTOM,
    ; cols INV_OVERLAY_LEFT to INV_OVERLAY_LEFT + INV_OVERLAY_W - 1.

    ; For each row in the overlay:
    lda #INV_OVERLAY_TOP
    sta temp_3              ; current row

@row_loop:
    ; Calculate PPU address for this row: $2000 + row * 32 + col
    ; PPU addr = $2000 + temp_3 * 32 + INV_OVERLAY_LEFT
    lda #$00
    sta ptr_hi              ; will accumulate high byte
    lda temp_3
    ; Multiply by 32: shift left 5 times
    asl                     ; *2
    asl                     ; *4
    asl                     ; *8
    asl                     ; *16
    asl                     ; *32  (low byte, may carry)
    sta ptr_lo
    lda temp_3
    lsr
    lsr
    lsr                     ; top bits of row*32 high byte
    clc
    adc #$20                ; + $2000 base
    sta ptr_hi

    ; Add column offset
    lda ptr_lo
    clc
    adc #INV_OVERLAY_LEFT
    sta ptr_lo
    lda ptr_hi
    adc #$00
    sta ptr_hi

    ; Set PPU address
    lda PPUSTATUS
    lda ptr_hi
    sta PPUADDR
    lda ptr_lo
    sta PPUADDR

    ; Determine what to write for this row
    lda temp_3
    cmp #INV_OVERLAY_TOP
    beq @top_row
    cmp #INV_OVERLAY_BOTTOM
    beq @bottom_row
    jmp @middle_row

@top_row:
    ; Top border: TL + (W-2 repeats of horizontal fill) + TR
    lda #HUD_TILE_BOX_TL
    sta PPUDATA
    ldx #(INV_OVERLAY_W - 2)
@top_fill:
    lda #HUD_TILE_BOX_TR    ; Use TR as horizontal bar (reuse available tile)
    sta PPUDATA
    dex
    bne @top_fill
    lda #HUD_TILE_BOX_TR
    sta PPUDATA
    jmp @next_row

@bottom_row:
    ; Bottom border
    lda #HUD_TILE_BOX_BL
    sta PPUDATA
    ldx #(INV_OVERLAY_W - 2)
@bot_fill:
    lda #HUD_TILE_BOX_BR    ; Use BR as horizontal bar
    sta PPUDATA
    dex
    bne @bot_fill
    lda #HUD_TILE_BOX_BR
    sta PPUDATA
    jmp @next_row

@middle_row:
    ; Left border tile
    lda #HUD_TILE_BOX_BL    ; vertical bar (reuse)
    sta PPUDATA
    ; Interior = blank
    ldx #(INV_OVERLAY_W - 2)
@mid_fill:
    lda #$00                ; blank tile
    sta PPUDATA
    dex
    bne @mid_fill
    ; Right border tile
    lda #HUD_TILE_BOX_BR    ; vertical bar
    sta PPUDATA

@next_row:
    inc temp_3
    lda temp_3
    cmp #(INV_OVERLAY_BOTTOM + 1)
    beq @done
    jmp @row_loop

@done:
    rts
.endproc

; ============================================================================
; inv_draw_contents - Draw inventory contents to nametable
; ============================================================================
; Writes item icons, crystal display, counters as BG tiles.
; Called during rendering-off window.
; ============================================================================

.proc inv_draw_contents
    ; --- Draw B-button label at INV_EQUIP_ROW, INV_EQUIP_COL-1 ---
    ; Write "B" tile at the equipped item position
    lda #>(PPU_NAMETABLE_0 + INV_EQUIP_ROW * 32 + INV_EQUIP_COL - 1)
    sta temp_0
    lda #<(PPU_NAMETABLE_0 + INV_EQUIP_ROW * 32 + INV_EQUIP_COL - 1)
    sta temp_1
    lda PPUSTATUS
    lda temp_0
    sta PPUADDR
    lda temp_1
    sta PPUADDR
    lda #HUD_TILE_BUTTON_B
    sta PPUDATA

    ; --- Draw item grid (BG tile placeholders for each owned item) ---
    ; For each slot in the 4x3 grid, if player owns the item,
    ; write the item's portrait tile; else write blank.
    lda #$00
    sta temp_2              ; slot index (0-11)

@grid_loop:
    ; Get item_id for this slot
    ldx temp_2
    lda b_item_table, x
    sta temp_0              ; item_id

    ; Calculate nametable position for this slot:
    ; row = INV_GRID_TOP + (slot / 4) * INV_GRID_CELL_H
    ; col = INV_GRID_LEFT + (slot % 4) * INV_GRID_CELL_W
    lda temp_2
    lsr
    lsr                     ; /4 = row index
    sta temp_1              ; grid_row
    ; tile_row = INV_GRID_TOP + grid_row * 3
    ; Multiply grid_row * 3:
    asl                     ; *2
    clc
    adc temp_1              ; *3
    clc
    adc #INV_GRID_TOP       ; + base row
    sta temp_3              ; tile_row for this cell

    ; col index = slot & 3
    lda temp_2
    and #$03
    sta temp_1              ; grid_col
    ; tile_col = INV_GRID_LEFT + grid_col * 3
    asl                     ; *2
    clc
    adc temp_1              ; *3
    clc
    adc #INV_GRID_LEFT
    ; Now A = tile_col, temp_3 = tile_row

    ; PPU addr = $2000 + tile_row * 32 + tile_col
    pha                     ; save tile_col
    lda temp_3
    ; Multiply row by 32
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
    adc #$20                ; + $2000 high byte
    sta ptr_hi
    pla                     ; restore tile_col
    clc
    adc ptr_lo
    sta ptr_lo
    lda ptr_hi
    adc #$00
    sta ptr_hi

    ; Set PPU address
    lda PPUSTATUS
    lda ptr_hi
    sta PPUADDR
    lda ptr_lo
    sta PPUADDR

    ; Check if player owns this item
    ldx temp_0              ; item_id
    beq @empty_slot         ; ITEM_NONE
    lda player_items, x
    beq @empty_slot

    ; Player owns it: write portrait top-left tile
    lda item_portrait_tiles, x
    sta PPUDATA
    ; Write top-right tile (base+1)
    clc
    adc #$01
    ; Actually we need to re-read. Let's just use the tile+1 approach.
    ; But PPUDATA auto-increments by 1, so next write goes to col+1.
    ; For a 2x2 portrait we need:
    ;   (row, col): TL   (row, col+1): TR
    ;   (row+1, col): BL  (row+1, col+1): BR
    ; PPU increments horizontally by default, so TL then TR is fine.
    ; But BL/BR need a new address. For simplicity, just write TL here.
    ; The sprite overlay will handle the 16x16 rendering.
    ; Actually, let's just write TL tile as the BG indicator.
    jmp @next_slot

@empty_slot:
    lda #$00                ; blank tile
    sta PPUDATA

@next_slot:
    inc temp_2
    lda temp_2
    cmp #(INV_GRID_COLS * INV_GRID_ROWS)
    bne @grid_loop

    ; --- Draw crystal obelisks ---
    jsr inv_draw_crystals

    ; --- Draw counters ---
    jsr inv_draw_counters

    rts
.endproc

; ============================================================================
; inv_draw_crystals - Draw crystal obelisk display (n/6)
; ============================================================================
; Draws 6 obelisk tiles at INV_CRYSTAL_ROW. Filled ones use a bright tile,
; empty ones use a dark tile.
; crystal_count stored in player_items+ITEM_NONE area — we'll use a
; dedicated variable. For now we hardcode 0 crystals (placeholder).
; ============================================================================

.proc inv_draw_crystals
    ; PPU address for crystal row
    lda PPUSTATUS
    lda #>(PPU_NAMETABLE_0 + INV_CRYSTAL_ROW * 32 + INV_CRYSTAL_COL)
    sta PPUADDR
    lda #<(PPU_NAMETABLE_0 + INV_CRYSTAL_ROW * 32 + INV_CRYSTAL_COL)
    sta PPUADDR

    ; For now, all 6 empty (placeholder - crystal count not yet tracked)
    ldx #INV_CRYSTAL_COUNT
@loop:
    lda #HUD_TILE_MAGIC_EMPTY   ; Reuse magic empty tile as obelisk placeholder
    sta PPUDATA
    dex
    bne @loop

    rts
.endproc

; ============================================================================
; inv_draw_counters - Draw item counters (keys, arrows, bombs, potions)
; ============================================================================
; Each counter: icon tile + "xNN" display (two digit tiles).
; We use HUD tiles for digits if available, or simple count tiles.
; ============================================================================

.proc inv_draw_counters
    lda #$00
    sta temp_2              ; counter index (0-3)

@counter_loop:
    ; Calculate PPU address: INV_COUNTER_ROW + index*2, INV_COUNTER_COL
    lda temp_2
    asl                     ; *2 (2 rows per counter)
    clc
    adc #INV_COUNTER_ROW
    sta temp_3              ; tile row

    ; PPU addr = $2000 + row*32 + col
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
    adc #INV_COUNTER_COL
    sta ptr_lo
    lda ptr_hi
    adc #$00
    sta ptr_hi

    lda PPUSTATUS
    lda ptr_hi
    sta PPUADDR
    lda ptr_lo
    sta PPUADDR

    ; Write icon tile for this counter
    lda temp_2
    asl                     ; *2 (2 bytes per entry in counter_items)
    tax
    lda counter_items, x    ; icon tile
    sta PPUDATA

    ; Write count value as a single tile (tens digit not needed for small counts)
    ; Get item_id from counter_items table
    lda temp_2
    asl
    tax
    inx                     ; second byte = item_id
    lda counter_items, x
    tax
    lda player_items, x     ; Get count
    ; For bombs, use player_bombs instead
    cpx #ITEM_BOMB
    bne @not_bomb_count
    lda player_bombs
@not_bomb_count:
    ; Clamp to 0-9 and convert to tile index
    cmp #10
    bcc @under_ten
    lda #9
@under_ten:
    ; Write as a digit tile. We don't have digit tiles yet, so write raw value.
    ; Placeholder: write the count value directly (will appear as whatever chr tile)
    sta PPUDATA

    inc temp_2
    lda temp_2
    cmp #COUNTER_COUNT
    bne @counter_loop

    rts
.endproc

; ============================================================================
; inv_draw_cursor - Draw blinking cursor around selected grid cell (sprites)
; ============================================================================
; Uses 4 sprites as corner brackets around the current grid cell.
; Blinks by hiding sprites on alternating 16-frame intervals.
; ============================================================================

.proc inv_draw_cursor
    ; Check blink state: visible when bit 4 of blink_timer is clear
    lda inv_blink_timer
    and #$10
    beq @visible
    rts                     ; Hidden phase — don't draw
@visible:

    ; Calculate pixel position of cursor cell:
    ; pixel_x = (INV_GRID_LEFT + cursor_x * INV_GRID_CELL_W) * 8
    ; pixel_y = (INV_GRID_TOP + cursor_y * INV_GRID_CELL_H) * 8 - 1 (OAM Y offset)
    lda inv_cursor_x
    ; *3 (INV_GRID_CELL_W)
    sta temp_0
    asl                     ; *2
    clc
    adc temp_0              ; *3
    clc
    adc #INV_GRID_LEFT
    asl
    asl
    asl                     ; *8 = pixel X
    sta temp_0              ; cursor pixel X

    lda inv_cursor_y
    sta temp_1
    asl
    clc
    adc temp_1              ; *3
    clc
    adc #INV_GRID_TOP
    asl
    asl
    asl                     ; *8
    sec
    sbc #$01                ; OAM Y is -1 scanline
    sta temp_1              ; cursor pixel Y

    ; Draw 4 corner sprites using a simple bracket tile
    ; We'll use tile $7E for cursor corner (placeholder in sprite CHR)
    ; Top-left corner
    ldx oam_offset
    lda temp_1              ; Y
    sta $0200, x
    inx
    lda #$7E                ; cursor tile
    sta $0200, x
    inx
    lda #OAM_PALETTE_3      ; bright palette
    sta $0200, x
    inx
    lda temp_0              ; X
    sta $0200, x
    inx

    ; Top-right corner
    lda temp_1
    sta $0200, x
    inx
    lda #$7E
    sta $0200, x
    inx
    lda #(OAM_PALETTE_3 | OAM_FLIP_H)
    sta $0200, x
    inx
    lda temp_0
    clc
    adc #8                  ; offset right by 8px (item is 16px but we mark edge)
    sta $0200, x
    inx

    ; Bottom-left corner
    lda temp_1
    clc
    adc #8
    sta $0200, x
    inx
    lda #$7E
    sta $0200, x
    inx
    lda #(OAM_PALETTE_3 | OAM_FLIP_V)
    sta $0200, x
    inx
    lda temp_0
    sta $0200, x
    inx

    ; Bottom-right corner
    lda temp_1
    clc
    adc #8
    sta $0200, x
    inx
    lda #$7E
    sta $0200, x
    inx
    lda #(OAM_PALETTE_3 | OAM_FLIP_H | OAM_FLIP_V)
    sta $0200, x
    inx
    lda temp_0
    clc
    adc #8
    sta $0200, x
    inx

    stx oam_offset

@done:
    rts
.endproc

; ============================================================================
; inv_draw_equip_sprite - Draw currently equipped B-item as a sprite
; ============================================================================
; Draws 2x2 sprite (16x16) of the selected_b_item next to the B label.
; ============================================================================

.proc inv_draw_equip_sprite
    lda selected_b_item
    beq @done               ; ITEM_NONE = nothing equipped
    tax
    lda item_portrait_tiles, x
    sta temp_0              ; base tile

    ; Position: next to B label
    ; pixel_y = INV_EQUIP_ROW * 8 - 1
    ; pixel_x = INV_EQUIP_COL * 8
    ldx oam_offset

    ; Top-left
    lda #(INV_EQUIP_ROW * 8 - 1)
    sta $0200, x
    inx
    lda temp_0
    sta $0200, x
    inx
    lda #OAM_PALETTE_0
    sta $0200, x
    inx
    lda #(INV_EQUIP_COL * 8)
    sta $0200, x
    inx

    ; Top-right
    lda #(INV_EQUIP_ROW * 8 - 1)
    sta $0200, x
    inx
    lda temp_0
    clc
    adc #$01
    sta $0200, x
    inx
    lda #OAM_PALETTE_0
    sta $0200, x
    inx
    lda #(INV_EQUIP_COL * 8 + 8)
    sta $0200, x
    inx

    ; Bottom-left
    lda #(INV_EQUIP_ROW * 8 + 7)
    sta $0200, x
    inx
    lda temp_0
    clc
    adc #$02
    sta $0200, x
    inx
    lda #OAM_PALETTE_0
    sta $0200, x
    inx
    lda #(INV_EQUIP_COL * 8)
    sta $0200, x
    inx

    ; Bottom-right
    lda #(INV_EQUIP_ROW * 8 + 7)
    sta $0200, x
    inx
    lda temp_0
    clc
    adc #$03
    sta $0200, x
    inx
    lda #OAM_PALETTE_0
    sta $0200, x
    inx
    lda #(INV_EQUIP_COL * 8 + 8)
    sta $0200, x
    inx

    stx oam_offset
@done:
    rts
.endproc
