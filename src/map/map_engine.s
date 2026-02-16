; ============================================================================
; map_engine.s - Map Engine Core
; ============================================================================
; Handles loading screens from map data into the PPU nametable.
; Top 2 tile rows (16 pixels) reserved for status bar.
; Map area: 16x14 metatiles (256x224 pixels).
; Each metatile is 2x2 hardware tiles (16x16 pixels).
;
; Nametable layout:
;   $2000-$203F: Status bar (2 tile rows, 64 bytes)
;   $2040-$23BF: Map metatiles (14 rows x 2 tile rows = 28 tile rows, 896 bytes)
;   $23C0-$23FF: Attribute table (64 bytes)
;
; This code runs in the fixed bank (PRG_FIXED).
; Metatile and screen data are in PRG_FIXED_C.
; ============================================================================

.include "nes.inc"
.include "mmc3.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"

.segment "PRG_FIXED"

; ============================================================================
; map_init - Initialize map engine and load the starting screen
; ============================================================================
; Sets up initial position at screen (0,0) and loads the first screen.
; Must be called after PPU init and palette loading.
; ============================================================================

.proc map_init
    ; Start at grid position (0, 0)
    lda #$00
    sta current_screen_x
    sta current_screen_y

    ; Compute screen ID and load it
    jsr map_get_screen_id
    lda current_screen_id
    jsr map_load_screen

    rts
.endproc

; ============================================================================
; map_get_screen_id - Compute screen index from grid position
; ============================================================================
; Computes: current_screen_id = current_screen_y * MAP_GRID_W + current_screen_x
; Result stored in current_screen_id.
; ============================================================================

.proc map_get_screen_id
    lda current_screen_y
    ; Multiply by MAP_GRID_W (3): y*3 = y*2 + y
    asl a                   ; A = y * 2
    clc
    adc current_screen_y    ; A = y * 3
    clc
    adc current_screen_x    ; A = y * 3 + x
    sta current_screen_id
    rts
.endproc

; ============================================================================
; map_load_screen - Load a screen into nametable 0
; ============================================================================
; Input: A = screen index (0-5)
; Disables rendering, writes status bar + metatile map + attributes, re-enables.
; ============================================================================

.proc map_load_screen
    ; Save screen index
    tax

    ; --- Disable rendering for bulk VRAM writes ---
    lda #$00
    sta PPUMASK

    ; --- Set up pointer to screen data ---
    ; ptr_lo/ptr_hi = address of screen data
    lda screen_ptrs_lo, x
    sta ptr_lo
    lda screen_ptrs_hi, x
    sta ptr_hi

    ; --- Set PPU address to nametable 0 ($2000) ---
    lda PPUSTATUS           ; Reset address latch
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; --- Write status bar (2 tile rows = 64 tiles) ---
    ; Fill with tile $00 (blank) for now — status bar rendering
    ; will be implemented later with health/item display
    lda #$00
    ldx #64                 ; 2 rows x 32 tiles
@status_loop:
    sta PPUDATA
    dex
    bne @status_loop

    ; --- Decode metatiles row by row ---
    ; PPU address is now at $2040 (start of map area)
    ; Each metatile row produces 2 rows of tiles (32 bytes each)
    ; Screen is 16 metatiles wide x 14 metatiles tall

    lda #$00
    sta map_row_counter     ; Current metatile row (0..13)

@row_loop:
    lda map_row_counter
    cmp #MAP_SCREEN_H       ; 14 rows
    bcc @row_ok
    jmp @rows_done
@row_ok:

    ; --- First tile row (top halves of metatiles) ---
    lda #$00
    sta map_col_counter

@top_tile_loop:
    lda map_col_counter
    cmp #MAP_SCREEN_W       ; 16 columns
    bcs @top_row_done

    ; Read metatile ID from screen data
    ; Offset = row * 16 + col
    lda map_row_counter
    asl a
    asl a
    asl a
    asl a                   ; * 16
    clc
    adc map_col_counter     ; A = row*16 + col
    tay
    lda (ptr_lo), y         ; A = metatile ID

    ; Look up metatile: each entry is 5 bytes (TL, TR, BL, BR, attr)
    ; Compute id * 5 = id * 4 + id
    tax
    stx temp_0              ; temp_0 = id
    txa
    asl a                   ; * 2
    asl a                   ; * 4
    clc
    adc temp_0              ; A = id * 5
    tax                     ; X = offset into metatile_table

    ; Write top-left tile
    lda metatile_table, x
    sta PPUDATA
    ; Write top-right tile
    lda metatile_table + 1, x
    sta PPUDATA

    inc map_col_counter
    jmp @top_tile_loop

@top_row_done:

    ; --- Second tile row (bottom halves of metatiles) ---
    lda #$00
    sta map_col_counter

@bottom_tile_loop:
    lda map_col_counter
    cmp #MAP_SCREEN_W
    bcs @bottom_row_done

    ; Read metatile ID again
    lda map_row_counter
    asl a
    asl a
    asl a
    asl a
    clc
    adc map_col_counter
    tay
    lda (ptr_lo), y         ; A = metatile ID

    ; Compute metatile offset (id * 5)
    tax
    stx temp_0
    txa
    asl a
    asl a
    clc
    adc temp_0              ; A = id * 5
    tax

    ; Write bottom-left tile
    lda metatile_table + 2, x
    sta PPUDATA
    ; Write bottom-right tile
    lda metatile_table + 3, x
    sta PPUDATA

    inc map_col_counter
    jmp @bottom_tile_loop

@bottom_row_done:
    inc map_row_counter
    jmp @row_loop

@rows_done:

    ; --- Write attribute table ---
    jsr map_write_attributes

    ; --- Reset scroll ---
    lda PPUSTATUS           ; Reset PPU address latch
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL
    sta scroll_x
    sta scroll_y

    ; --- Re-enable rendering ---
    lda ppu_mask_shadow
    sta PPUMASK

    rts
.endproc

; ============================================================================
; map_write_attributes - Write attribute table for current screen
; ============================================================================
; Reads palette bits from metatile byte 4 (bits 0-1) and packs them into
; NES attribute table format.
;
; NES attribute table: 64 bytes at $23C0
; Each byte controls a 4x4 tile (2x2 metatile) area:
;   bits 0-1: top-left metatile palette
;   bits 2-3: top-right metatile palette
;   bits 4-5: bottom-left metatile palette
;   bits 6-7: bottom-right metatile palette
; ============================================================================

.proc map_write_attributes
    ; Set PPU address to attribute table ($23C0)
    lda PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR

    ; 8 attribute rows x 8 attribute columns = 64 bytes
    lda #$00
    sta temp_2              ; attr_row (0..7)

@attr_row_loop:
    lda temp_2
    cmp #$08
    bcc @attr_row_ok
    jmp @attr_done
@attr_row_ok:

    lda #$00
    sta temp_3              ; attr_col (0..7)

@attr_col_loop:
    lda temp_3
    cmp #$08
    bcc @attr_col_ok
    jmp @attr_row_next
@attr_col_ok:

    ; Build attribute byte from 4 metatiles
    ; meta_row = attr_row * 2, meta_col = attr_col * 2
    lda #$00
    sta temp_1              ; attr_byte accumulator

    ; --- Top-left metatile palette (bits 0-1) ---
    lda temp_2
    asl a                   ; meta_row = attr_row * 2
    cmp #MAP_SCREEN_H
    bcs @tl_zero
    ; offset = meta_row * 16 + meta_col
    asl a
    asl a
    asl a
    asl a                   ; meta_row * 16
    sta temp_0
    lda temp_3
    asl a                   ; meta_col = attr_col * 2
    clc
    adc temp_0
    tay
    lda (ptr_lo), y         ; metatile ID
    jsr @get_palette
    jmp @tl_store
@tl_zero:
    lda #$00
@tl_store:
    sta temp_1

    ; --- Top-right metatile palette (bits 2-3) ---
    lda temp_2
    asl a
    cmp #MAP_SCREEN_H
    bcs @tr_zero
    asl a
    asl a
    asl a
    asl a
    sta temp_0
    lda temp_3
    asl a
    clc
    adc #$01
    clc
    adc temp_0
    tay
    lda (ptr_lo), y
    jsr @get_palette
    jmp @tr_store
@tr_zero:
    lda #$00
@tr_store:
    asl a
    asl a
    ora temp_1
    sta temp_1

    ; --- Bottom-left metatile palette (bits 4-5) ---
    lda temp_2
    asl a
    clc
    adc #$01
    cmp #MAP_SCREEN_H
    bcs @bl_zero
    asl a
    asl a
    asl a
    asl a
    sta temp_0
    lda temp_3
    asl a
    clc
    adc temp_0
    tay
    lda (ptr_lo), y
    jsr @get_palette
    jmp @bl_store
@bl_zero:
    lda #$00
@bl_store:
    asl a
    asl a
    asl a
    asl a
    ora temp_1
    sta temp_1

    ; --- Bottom-right metatile palette (bits 6-7) ---
    lda temp_2
    asl a
    clc
    adc #$01
    cmp #MAP_SCREEN_H
    bcs @br_zero
    asl a
    asl a
    asl a
    asl a
    sta temp_0
    lda temp_3
    asl a
    clc
    adc #$01
    clc
    adc temp_0
    tay
    lda (ptr_lo), y
    jsr @get_palette
    jmp @br_store
@br_zero:
    lda #$00
@br_store:
    .repeat 6
        asl a
    .endrepeat
    ora temp_1

    ; Write the attribute byte
    sta PPUDATA

    inc temp_3
    jmp @attr_col_loop

@attr_row_next:
    inc temp_2
    jmp @attr_row_loop

@attr_done:
    rts

; --- Helper: get palette from metatile ID ---
; Input: A = metatile ID
; Output: A = palette bits (0-3)
; Trashes: X
@get_palette:
    tax
    stx temp_0
    txa
    asl a
    asl a
    clc
    adc temp_0              ; A = id * 5
    tax
    lda metatile_table + 4, x
    and #$03
    rts

.endproc
