; ============================================================================
; gfx/hud.s - HUD (Heads-Up Display) System
; ============================================================================
; Manages the status bar occupying the top 2 tile rows (16 pixels) of the
; nametable. Displays:
;   - Hearts (left side): filled/empty based on player_hp / player_max_hp
;   - B-item box (center-left): 2x2 item box with B button indicator
;   - A-item box (center-right): 2x2 item box with A button indicator
;   - Magic bottles (right side): filled/empty based on player_magic
;
; HUD uses BG palette 3 for all elements.
; The attribute table row 0 is set to palette 3 for the top-left and
; top-right quadrants covering the first 2 tile rows.
;
; Four entry points:
;   hud_init       - Full draw during init (rendering off, direct VRAM writes)
;   hud_update     - Per-frame check: dirty-flag driven PPU buffer updates
;   hud_draw_full  - Queue full HUD redraw via PPU buffer (after screen load)
;   hud_write_vram - Write 64 HUD tiles to PPUDATA (caller sets PPUADDR)
;
; This code runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"
.include "hud.inc"
.include "inventory.inc"
.include "shop.inc"

.segment "PRG_FIXED"

; ============================================================================
; hud_write_vram - Write 64 HUD tiles directly to PPUDATA
; ============================================================================
; Writes exactly 64 bytes (2 rows x 32 tiles) of HUD content to PPUDATA.
; The caller must have already set the PPU address to $2000 via PPUADDR.
; This routine does NOT set PPUADDR itself.
;
; Used by both hud_init (during initialization) and map_load_screen
; (during screen transitions) to avoid blanking the HUD.
;
; Clobbers: A, X, Y
; ============================================================================

.proc hud_write_vram
    ; ---- Row 0: $2000-$201F (32 tiles) ----
    ; Layout: [blank][hearts x8][blank x2][B][TL][TR][blank][A][TL][TR][blank x2][magic x4][blank x4]

    ; Column 0: blank
    lda #HUD_TILE_BLANK
    sta PPUDATA

    ; Columns 1-8: hearts (filled or empty based on HP)
    ; total hearts = player_max_hp / 2
    ; filled hearts = (player_hp + 1) / 2  (round up)
    lda player_max_hp
    lsr a                       ; A = max hearts displayed
    sta temp_1                  ; temp_1 = total hearts to draw

    lda player_hp
    clc
    adc #$01                    ; Round up: (hp+1)/2
    lsr a
    sta temp_0                  ; temp_0 = filled hearts

    ldx #$00                    ; Heart index (0..7)
@heart_loop:
    cpx #HUD_MAX_HEARTS
    bcs @hearts_done

    cpx temp_1                  ; Past total hearts?
    bcs @heart_blank

    cpx temp_0                  ; Past filled hearts?
    bcs @heart_empty

    ; Filled heart
    lda #HUD_TILE_HEART_FULL
    jmp @heart_write
@heart_empty:
    lda #HUD_TILE_HEART_EMPTY
    jmp @heart_write
@heart_blank:
    lda #HUD_TILE_BLANK
@heart_write:
    sta PPUDATA
    inx
    jmp @heart_loop
@hearts_done:

    ; Columns 9-10: blank spacing
    lda #HUD_TILE_BLANK
    sta PPUDATA
    sta PPUDATA

    ; Column 11: B button indicator
    lda #HUD_TILE_BUTTON_B
    sta PPUDATA

    ; Columns 12-13: Item box top row (TL, TR) for B-item
    lda #HUD_TILE_BOX_TL
    sta PPUDATA
    lda #HUD_TILE_BOX_TR
    sta PPUDATA

    ; Column 14: blank
    lda #HUD_TILE_BLANK
    sta PPUDATA

    ; Column 15: A button indicator
    lda #HUD_TILE_BUTTON_A
    sta PPUDATA

    ; Columns 16-17: Item box top row (TL, TR) for A-item
    lda #HUD_TILE_BOX_TL
    sta PPUDATA
    lda #HUD_TILE_BOX_TR
    sta PPUDATA

    ; Columns 18-19: blank spacing
    lda #HUD_TILE_BLANK
    sta PPUDATA
    sta PPUDATA

    ; Columns 20-23: Magic bottles (filled/empty based on magic_bottles_count & player_magic)
    ; Each bottle = 8 magic points. Filled if player_magic >= (bottle_index+1)*8
    lda magic_bottles_count
    sta temp_2                  ; temp_2 = total bottles owned

    ldx #$00                    ; Bottle index (0..3)
@magic_loop:
    cpx #HUD_MAX_MAGIC
    bcs @magic_done

    cpx temp_2                  ; Past owned bottles?
    bcs @magic_blank

    ; Calculate threshold: (X+1) * 8
    ; If player_magic >= threshold, bottle is full
    txa
    clc
    adc #$01                    ; A = bottle_index + 1
    asl a                       ; *2
    asl a                       ; *4
    asl a                       ; *8 = threshold
    sta temp_3                  ; temp_3 = threshold

    lda player_magic
    cmp temp_3
    bcs @magic_full             ; player_magic >= threshold -> full
    ; Otherwise empty (but owned)
    lda #HUD_TILE_MAGIC_EMPTY
    jmp @magic_write
@magic_full:
    lda #HUD_TILE_MAGIC_FULL
    jmp @magic_write
@magic_blank:
    lda #HUD_TILE_BLANK
@magic_write:
    sta PPUDATA
    inx
    jmp @magic_loop
@magic_done:

    ; Column 24: Rupee icon
    lda #HUD_TILE_RUPEE
    sta PPUDATA

    ; Columns 25-26: Rupee count as 2-digit number (tens, ones)
    ; Read player_rupees_lo (0-255), display as decimal tens+ones (capped at 99 display)
    lda player_rupees_lo
    cmp #100                    ; Cap display at 99
    bcc @rupee_ok
    lda #99
@rupee_ok:
    ; Divide A by 10 to get tens digit
    ; Simple repeated subtraction
    ldy #$00                    ; Y = tens digit
@div10:
    cmp #10
    bcc @div10_done
    sec
    sbc #10
    iny
    jmp @div10
@div10_done:
    ; A = ones digit, Y = tens digit
    sta temp_3                  ; Save ones digit

    ; Write tens digit tile
    tya
    clc
    adc #HUD_TILE_DIGIT_0
    sta PPUDATA

    ; Write ones digit tile
    lda temp_3
    clc
    adc #HUD_TILE_DIGIT_0
    sta PPUDATA

    ; Columns 27-31: blank (5 tiles to fill row)
    lda #HUD_TILE_BLANK
    ldx #$05
@space_end_r0:
    sta PPUDATA
    dex
    bne @space_end_r0

    ; ---- Row 1: $2020-$203F (32 tiles) ----
    ; Layout: [blank x11][blank][BL][BR][blank][blank][BL][BR][blank x14]

    ; Columns 0-10: blank (11 tiles)
    lda #HUD_TILE_BLANK
    ldx #11
@row1_space1:
    sta PPUDATA
    dex
    bne @row1_space1

    ; Column 11: blank (under B button label)
    lda #HUD_TILE_BLANK
    sta PPUDATA

    ; Columns 12-13: Item box bottom row (BL, BR) for B-item
    lda #HUD_TILE_BOX_BL
    sta PPUDATA
    lda #HUD_TILE_BOX_BR
    sta PPUDATA

    ; Column 14: blank
    lda #HUD_TILE_BLANK
    sta PPUDATA

    ; Column 15: blank (under A button label)
    lda #HUD_TILE_BLANK
    sta PPUDATA

    ; Columns 16-17: Item box bottom row (BL, BR) for A-item
    lda #HUD_TILE_BOX_BL
    sta PPUDATA
    lda #HUD_TILE_BOX_BR
    sta PPUDATA

    ; Columns 18-31: blank (14 tiles)
    lda #HUD_TILE_BLANK
    ldx #14
@row1_space2:
    sta PPUDATA
    dex
    bne @row1_space2

    rts
.endproc

; ============================================================================
; hud_init - Write initial HUD tiles to nametable (rendering must be off)
; ============================================================================
; Called from reset_handler after map_init. Rendering is briefly disabled
; by the caller (map_load_screen already handles this).
; Writes the full HUD directly to PPU VRAM.
; Clobbers: A, X, Y
; ============================================================================

.proc hud_init
    ; --- Initialize HUD state ---
    lda player_hp
    sta hud_hp_cache
    lda player_magic
    sta hud_magic_cache
    lda player_rupees_lo
    sta hud_rupee_cache
    lda #$00
    sta hud_dirty

    ; --- Set PPU address to nametable row 0 ($2000) ---
    lda PPUSTATUS               ; Reset PPU address latch
    lda #>HUD_ROW0_ADDR
    sta PPUADDR
    lda #<HUD_ROW0_ADDR
    sta PPUADDR

    ; --- Write 64 HUD tiles (2 rows) ---
    jsr hud_write_vram

    ; --- Set attribute table for HUD rows ---
    ; The top row of the attribute table ($23C0) covers tile rows 0-3.
    ; We need palette 3 for the top half (tile rows 0-1 = HUD).
    ; The map engine now correctly sets HUD_PALETTE for status bar quadrants
    ; in map_write_attributes, but during init we write the attribute table
    ; directly to ensure the HUD is visible on the first frame.
    ;
    ; Attribute byte layout:
    ;   bits 0-1: TL quadrant (tile rows 0-1, cols 0-1 of 4x4 group)
    ;   bits 2-3: TR quadrant (tile rows 0-1, cols 2-3)
    ;   bits 4-5: BL quadrant (tile rows 2-3, cols 0-1)
    ;   bits 6-7: BR quadrant (tile rows 2-3, cols 2-3)
    ;
    ; For HUD palette 3 in top quadrants: bits 0-1 = 11, bits 2-3 = 11
    ; = %00001111. We set all quadrants to palette 3 (acceptable tradeoff
    ; since the bottom quadrants cover metatile row 0).

    lda PPUSTATUS
    lda #>PPU_ATTR_TABLE_0      ; $23
    sta PPUADDR
    lda #<PPU_ATTR_TABLE_0      ; $C0
    sta PPUADDR

    lda #%11111111              ; All quadrants = palette 3
    ldx #$08                    ; 8 bytes in first attribute row
@attr_loop:
    sta PPUDATA
    dex
    bne @attr_loop

    rts
.endproc

; ============================================================================
; hud_update - Check for HP/magic changes and queue VRAM updates
; ============================================================================
; Called every frame from the gameplay state in the main loop.
; Compares current player_hp against cached value. If changed, queues
; a PPU buffer write to update the heart tiles during next NMI.
; Clobbers: A, X, Y
; ============================================================================

.proc hud_update
    ; --- Check if HP changed ---
    lda player_hp
    cmp hud_hp_cache
    beq @no_hp_change

    ; HP changed - update cache and queue heart redraw
    sta hud_hp_cache
    jsr hud_queue_hearts

@no_hp_change:
    ; --- Check if magic changed ---
    lda player_magic
    cmp hud_magic_cache
    beq @no_magic_change

    ; Magic changed - update cache and queue bottle redraw
    sta hud_magic_cache
    jsr hud_queue_magic

@no_magic_change:
    ; --- Check if rupees changed ---
    lda player_rupees_lo
    cmp hud_rupee_cache
    beq @no_rupee_change

    ; Rupees changed - update cache and queue rupee redraw
    sta hud_rupee_cache
    jsr hud_queue_rupees

@no_rupee_change:
    rts
.endproc

; ============================================================================
; hud_queue_hearts - Queue heart tiles into PPU write buffer
; ============================================================================
; Builds a buffer entry to update nametable row 0, columns 1-8 with the
; current heart states.
; Clobbers: A, X, Y
; ============================================================================

.proc hud_queue_hearts
    ; Calculate filled/total hearts
    lda player_max_hp
    lsr a
    sta temp_1                  ; total hearts

    lda player_hp
    clc
    adc #$01
    lsr a
    sta temp_0                  ; filled hearts

    ; Build the 8 heart tiles into ppu_buffer directly
    ; Format: [addr_hi, addr_lo, length, data...]
    ldx ppu_buffer_len

    ; PPU address: $2001 (row 0, column 1)
    lda #$20
    sta ppu_buffer, x
    inx
    lda #$01
    sta ppu_buffer, x
    inx

    ; Length: 8 bytes (HUD_MAX_HEARTS tiles)
    lda #HUD_MAX_HEARTS
    sta ppu_buffer, x
    inx

    ; Write heart tile data
    ldy #$00                    ; Heart index
@heart_loop:
    cpy #HUD_MAX_HEARTS
    bcs @hearts_done

    cpy temp_1                  ; Past total hearts?
    bcs @blank

    cpy temp_0                  ; Past filled hearts?
    bcs @empty

    lda #HUD_TILE_HEART_FULL
    jmp @store
@empty:
    lda #HUD_TILE_HEART_EMPTY
    jmp @store
@blank:
    lda #HUD_TILE_BLANK
@store:
    sta ppu_buffer, x
    inx
    iny
    jmp @heart_loop

@hearts_done:
    stx ppu_buffer_len

    rts
.endproc

; ============================================================================
; hud_draw_full - Queue full HUD redraw via PPU buffer
; ============================================================================
; Called after screen transitions to restore the HUD.
; Queues hearts, item boxes, magic, and attribute table data via PPU buffer.
; Clobbers: A, X, Y
; ============================================================================

.proc hud_draw_full
    ; Queue hearts (row 0, cols 1-8)
    jsr hud_queue_hearts

    ; Queue B-item area (row 0, cols 11-13: B-button, TL, TR)
    ldx ppu_buffer_len

    lda #$20                    ; PPU addr high
    sta ppu_buffer, x
    inx
    lda #$0B                    ; PPU addr low (col 11)
    sta ppu_buffer, x
    inx
    lda #$03                    ; 3 bytes
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BUTTON_B
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_TL
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_TR
    sta ppu_buffer, x
    inx

    ; Queue A-item area (row 0, cols 15-17: A-button, TL, TR)
    lda #$20                    ; PPU addr high
    sta ppu_buffer, x
    inx
    lda #$0F                    ; PPU addr low (col 15)
    sta ppu_buffer, x
    inx
    lda #$03                    ; 3 bytes
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BUTTON_A
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_TL
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_TR
    sta ppu_buffer, x
    inx

    ; Queue magic bottles and rupee display via dedicated routines
    stx ppu_buffer_len
    jsr hud_queue_magic
    jsr hud_queue_rupees
    ldx ppu_buffer_len

    ; Queue B-item box row 1 (row 1, cols 12-13: BL, BR)
    lda #$20                    ; PPU addr high
    sta ppu_buffer, x
    inx
    lda #$2C                    ; PPU addr low ($2020 + 12 = $202C)
    sta ppu_buffer, x
    inx
    lda #$02                    ; 2 bytes
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_BL
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_BR
    sta ppu_buffer, x
    inx

    ; Queue A-item box row 1 (row 1, cols 16-17: BL, BR)
    lda #$20                    ; PPU addr high
    sta ppu_buffer, x
    inx
    lda #$30                    ; PPU addr low ($2020 + 16 = $2030)
    sta ppu_buffer, x
    inx
    lda #$02                    ; 2 bytes
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_BL
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_BR
    sta ppu_buffer, x
    inx

    stx ppu_buffer_len

    ; Queue attribute table override for row 0
    ; Set palette 3 for HUD area (first 8 attribute bytes)
    ldx ppu_buffer_len

    lda #$23                    ; PPU addr high ($23C0)
    sta ppu_buffer, x
    inx
    lda #$C0                    ; PPU addr low
    sta ppu_buffer, x
    inx
    lda #$08                    ; 8 bytes
    sta ppu_buffer, x
    inx

    lda #%11111111              ; All quadrants palette 3
    ldy #$08
@attr_loop:
    sta ppu_buffer, x
    inx
    dey
    bne @attr_loop

    stx ppu_buffer_len

    rts
.endproc

; ============================================================================
; hud_queue_magic - Queue magic bottle tiles into PPU write buffer
; ============================================================================
; Builds a buffer entry to update nametable row 0, columns 20-23 with the
; current magic bottle states (filled/empty based on magic_bottles_count
; and player_magic). Each bottle = 8 magic points.
; Clobbers: A, X, Y
; ============================================================================

.proc hud_queue_magic
    ldx ppu_buffer_len

    ; PPU address: $2014 (row 0, column 20)
    lda #$20
    sta ppu_buffer, x
    inx
    lda #$14
    sta ppu_buffer, x
    inx

    ; Length: 4 bytes (HUD_MAX_MAGIC bottles)
    lda #HUD_MAX_MAGIC
    sta ppu_buffer, x
    inx

    ; Determine bottle states
    lda magic_bottles_count
    sta temp_2                  ; total owned bottles

    ldy #$00                    ; Bottle index
@bottle_loop:
    cpy #HUD_MAX_MAGIC
    bcs @bottles_done

    cpy temp_2                  ; Past owned bottles?
    bcs @bottle_blank

    ; Calculate threshold: (Y+1) * 8
    tya
    clc
    adc #$01
    asl a                       ; *2
    asl a                       ; *4
    asl a                       ; *8
    sta temp_3

    lda player_magic
    cmp temp_3
    bcs @bottle_full

    lda #HUD_TILE_MAGIC_EMPTY
    jmp @bottle_store
@bottle_full:
    lda #HUD_TILE_MAGIC_FULL
    jmp @bottle_store
@bottle_blank:
    lda #HUD_TILE_BLANK
@bottle_store:
    sta ppu_buffer, x
    inx
    iny
    jmp @bottle_loop

@bottles_done:
    stx ppu_buffer_len
    rts
.endproc

; ============================================================================
; hud_queue_rupees - Queue rupee icon + 2-digit count into PPU write buffer
; ============================================================================
; Builds a buffer entry to update nametable row 0, columns 24-26 with
; the rupee icon and current rupee count (low byte, 0-99 display).
; Clobbers: A, X, Y
; ============================================================================

.proc hud_queue_rupees
    ldx ppu_buffer_len

    ; PPU address: $2018 (row 0, column 24)
    lda #$20
    sta ppu_buffer, x
    inx
    lda #$18
    sta ppu_buffer, x
    inx

    ; Length: 3 bytes (icon + tens + ones)
    lda #$03
    sta ppu_buffer, x
    inx

    ; Rupee icon
    lda #HUD_TILE_RUPEE
    sta ppu_buffer, x
    inx

    ; Read rupee count, cap at 99 for 2-digit display
    lda player_rupees_lo
    cmp #100
    bcc @rupee_cap_ok
    lda #99
@rupee_cap_ok:
    ; Divide by 10 using repeated subtraction
    ldy #$00                    ; Y = tens digit
@div10:
    cmp #10
    bcc @div10_done
    sec
    sbc #10
    iny
    jmp @div10
@div10_done:
    ; A = ones digit, Y = tens digit
    sta temp_3                  ; Save ones

    ; Tens digit tile
    tya
    clc
    adc #HUD_TILE_DIGIT_0
    sta ppu_buffer, x
    inx

    ; Ones digit tile
    lda temp_3
    clc
    adc #HUD_TILE_DIGIT_0
    sta ppu_buffer, x
    inx

    stx ppu_buffer_len
    rts
.endproc
