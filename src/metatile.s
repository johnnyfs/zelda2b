; ============================================================================
; metatile.s — Metatile Rendering System
; ============================================================================
; A metatile is a 16x16 pixel block made of four 8x8 hardware tiles.
; The overworld is composed of metatiles on a 16x15 grid (NES nametable
; is 32x30 tiles = 16x15 metatiles, with 2 bottom rows for HUD).
;
; Each metatile definition is 4 bytes: TL, TR, BL, BR tile indices.
; Plus 1 byte for the attribute (2-bit palette selector).
;
; Metatile data format (5 bytes per metatile type):
;   Byte 0: Top-left tile
;   Byte 1: Top-right tile
;   Byte 2: Bottom-left tile
;   Byte 3: Bottom-right tile
;   Byte 4: Attribute (bits 0-1 = palette, bits 2-7 = collision flags)
;
; Public API:
;   metatile_draw     — Draw a single metatile via PPU buffer
;                       Input: A=metatile_id, X=metatile_col (0-15), Y=metatile_row (0-14)
;   metatile_fill_screen — Fill visible nametable with one metatile
;                       Input: A=metatile_id
; ============================================================================

.include "nes.inc"
.include "globals.inc"

.import ppu_buf_put

.export metatile_draw, metatile_fill_screen
.export metatile_data

.segment "PRG_FIXED_C"

; ============================================================================
; Metatile definitions — programmer art (placeholder)
; ============================================================================
; Each entry: TL, TR, BL, BR, attributes
; Using tile indices that will be in CHR — for now these reference
; our programmer-art tiles (solid colored squares)
; ============================================================================

; Programmer art tile indices in CHR:
; Tile $00 = empty/black
; Tile $01 = solid white
; Tile $02 = solid green (grass)
; Tile $03 = solid brown (wall/rock)
; Tile $04 = solid blue (water)
; Tile $05 = checkerboard (path)
; Tile $06 = solid gray (stone floor)
; Tile $07 = solid dark green (tree)

; Metatile types
MT_GRASS    = 0
MT_WALL     = 1
MT_WATER    = 2
MT_PATH     = 3
MT_FLOOR    = 4
MT_TREE     = 5
MT_DOOR     = 6
MT_BLACK    = 7

.export MT_GRASS, MT_WALL, MT_WATER, MT_PATH, MT_FLOOR, MT_TREE, MT_DOOR, MT_BLACK

metatile_data:
    ; MT_GRASS (0): green square
    .byte $02, $02, $02, $02, %00000000  ; palette 0
    ; MT_WALL (1): brown square
    .byte $03, $03, $03, $03, %00000101  ; palette 1, solid collision
    ; MT_WATER (2): blue square
    .byte $04, $04, $04, $04, %00001010  ; palette 2, water collision
    ; MT_PATH (3): checkerboard
    .byte $05, $05, $05, $05, %00000000  ; palette 0
    ; MT_FLOOR (4): gray square
    .byte $06, $06, $06, $06, %00000100  ; palette 1
    ; MT_TREE (5): dark green
    .byte $07, $07, $07, $07, %00001001  ; palette 2, solid collision
    ; MT_DOOR (6): dark with white center
    .byte $00, $01, $00, $01, %00001100  ; palette 3, door flag
    ; MT_BLACK (7): empty
    .byte $00, $00, $00, $00, %00000000  ; palette 0

; ============================================================================
; metatile_draw — Draw one metatile to nametable via PPU buffer
; ============================================================================
; Input: A = metatile ID, X = column (0-15), Y = row (0-14)
; Nametable address = $2000 + (row * 2 * 32) + (col * 2)
;                   = $2000 + (row * 64) + (col * 2)
; ============================================================================
.proc metatile_draw
    ; Save metatile ID
    sta tmp3

    ; Calculate metatile data pointer
    ; offset = metatile_id * 5
    lda tmp3
    asl                     ; *2
    asl                     ; *4
    clc
    adc tmp3                ; *5
    clc
    adc #<metatile_data
    sta ptr0
    lda #>metatile_data
    adc #0
    sta ptr0_hi

    ; Calculate nametable address
    ; Top-left = $2000 + row*64 + col*2
    tya                     ; A = row
    ; Multiply row by 64: shift left 6 times
    ; row * 64 = row * 32 * 2
    asl                     ; *2
    asl                     ; *4
    asl                     ; *8
    asl                     ; *16
    asl                     ; *32
    sta tmp0                ; Low byte of row*32
    lda #0
    rol                     ; Carry from the shifts into high byte
    sta tmp1                ; High byte partial

    ; Now double: row*64
    asl tmp0
    rol tmp1

    ; Add col*2
    txa
    asl                     ; col * 2
    clc
    adc tmp0
    sta tmp0
    lda tmp1
    adc #0
    sta tmp1

    ; Add base nametable $2000
    lda tmp1
    clc
    adc #$20
    sta tmp1

    ; Now tmp1:tmp0 = PPU address of top-left tile

    ; --- Write top-left tile ---
    ldy #0
    lda (ptr0), y           ; TL tile
    ldx tmp1                ; addr high
    ldy tmp0                ; addr low
    jsr ppu_buf_put

    ; --- Write top-right tile (addr + 1) ---
    ldy #1
    lda (ptr0), y           ; TR tile
    ldx tmp1
    ldy tmp0
    iny                     ; addr + 1
    jsr ppu_buf_put

    ; --- Write bottom-left tile (addr + 32) ---
    lda tmp0
    clc
    adc #32
    sta tmp2                ; bottom row addr low
    lda tmp1
    adc #0
    pha                     ; Save bottom row addr high

    ldy #2
    lda (ptr0), y           ; BL tile
    pla
    tax                     ; addr high
    ldy tmp2                ; addr low
    jsr ppu_buf_put

    ; --- Write bottom-right tile (addr + 33) ---
    lda tmp0
    clc
    adc #33
    sta tmp2
    lda tmp1
    adc #0
    pha

    ldy #3
    lda (ptr0), y           ; BR tile
    pla
    tax
    ldy tmp2
    jsr ppu_buf_put

    rts
.endproc

; ============================================================================
; metatile_fill_screen — Fill entire visible screen with one metatile
; ============================================================================
; Input: A = metatile ID
; Note: This writes directly to PPU (rendering must be off).
; Used for initial screen setup, not during gameplay.
; ============================================================================
.proc metatile_fill_screen
    sta tmp3                ; Save metatile ID

    ; Calculate data pointer
    lda tmp3
    asl
    asl
    clc
    adc tmp3                ; *5
    clc
    adc #<metatile_data
    sta ptr0
    lda #>metatile_data
    adc #0
    sta ptr0_hi

    ; Get tile indices
    ldy #0
    lda (ptr0), y
    sta tmp0                ; TL
    iny
    lda (ptr0), y
    sta tmp1                ; TR

    ; Set PPU address to start of nametable 0
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; Fill 30 rows of 32 tiles (960 bytes)
    ; Each row pair: TL TR TL TR... then BL BR BL BR...
    ldx #15                 ; 15 metatile rows
@row_loop:
    ; Top half of metatile row (32 tiles)
    ldy #16                 ; 16 metatile columns
@top_loop:
    lda tmp0
    sta PPUDATA             ; TL
    lda tmp1
    sta PPUDATA             ; TR
    dey
    bne @top_loop

    ; Bottom half of metatile row
    ; Re-read BL/BR from metatile data
    pha
    ldy #2
    lda (ptr0), y
    sta tmp2                ; BL
    ldy #3
    lda (ptr0), y
    pha                     ; BR on stack

    ldy #16
@bottom_loop:
    lda tmp2
    sta PPUDATA             ; BL
    pla                     ; BR
    sta PPUDATA
    pha                     ; Keep BR on stack for loop
    dey
    bne @bottom_loop
    pla                     ; Clean stack
    pla                     ; Clean stack

    dex
    bne @row_loop

    rts
.endproc
