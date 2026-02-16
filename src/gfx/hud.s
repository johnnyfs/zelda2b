; ============================================================================
; gfx/hud.s - HUD (Heads-Up Display) System
; ============================================================================
; Manages the status bar occupying the top 2 tile rows (16 pixels) of the
; nametable. Displays:
;   - Hearts (left side): filled/empty based on player_hp / player_max_hp
;   - B-item box (center): placeholder item icon with frame
;   - Magic bottles (right side): filled/empty based on player_magic
;
; HUD uses BG palette 3 for all elements.
; The attribute table row 0 is set to palette 3 for the top-left and
; top-right quadrants covering the first 2 tile rows.
;
; Three entry points:
;   hud_init      - Full draw during init (rendering off, direct VRAM writes)
;   hud_update    - Per-frame check: dirty-flag driven PPU buffer updates
;   hud_draw_full - Queue full HUD redraw via PPU buffer (after screen load)
;
; This code runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "combat.inc"
.include "hud.inc"

.segment "PRG_FIXED"

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
    lda #$00
    sta hud_magic_cache         ; Magic not implemented yet, default 0
    sta hud_dirty

    ; --- Write HUD Row 0 to nametable $2000 ---
    lda PPUSTATUS               ; Reset PPU address latch
    lda #>HUD_ROW0_ADDR
    sta PPUADDR
    lda #<HUD_ROW0_ADDR
    sta PPUADDR

    ; Column 0: blank
    lda #HUD_TILE_BLANK
    sta PPUDATA

    ; Columns 1-8: hearts (filled or empty based on HP)
    ; player_hp is in half-hearts (PLAYER_MAX_HP=6 = 3 hearts)
    ; Each heart = 2 HP. So heart N is full if player_hp >= (N+1)*2,
    ; empty if player_hp < N*2+1, half... for simplicity, each tile = 1 heart
    ; Actually from combat.inc: PLAYER_MAX_HP = 6 (3 hearts), so 1 heart = 2 HP
    ; But the spec says "up to 8 hearts". Let's treat each tile as representing
    ; a pair of HP points. heart_count = player_max_hp / 2, filled = player_hp / 2
    ;
    ; Simpler: treat player_hp and player_max_hp as direct heart counts
    ; player_max_hp = 6 means 6 HP, display 3 hearts (each worth 2 HP)
    ; filled_hearts = (player_hp + 1) / 2  (round up)
    ; total_hearts = player_max_hp / 2

    ; For now, use a simple approach: total hearts = player_max_hp / 2
    ; filled hearts = player_hp / 2 (round up)
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

    ; Columns 9-13: blank spacing
    lda #HUD_TILE_BLANK
    ldx #$05                    ; 5 blanks (cols 9-13)
@space1:
    sta PPUDATA
    dex
    bne @space1

    ; Column 14-15: Item box top row (TL, TR)
    lda #HUD_TILE_BOX_TL
    sta PPUDATA
    lda #HUD_TILE_BOX_TR
    sta PPUDATA

    ; Columns 16-23: blank spacing
    lda #HUD_TILE_BLANK
    ldx #$08                    ; 8 blanks (cols 16-23)
@space2:
    sta PPUDATA
    dex
    bne @space2

    ; Columns 24-27: Magic bottles
    ldx #$00
@magic_loop:
    cpx #HUD_MAX_MAGIC
    bcs @magic_done
    ; For now, all magic bottles empty (magic system not yet implemented)
    lda #HUD_TILE_MAGIC_EMPTY
    sta PPUDATA
    inx
    jmp @magic_loop
@magic_done:

    ; Columns 28-31: blank
    lda #HUD_TILE_BLANK
    ldx #$04
@space3:
    sta PPUDATA
    dex
    bne @space3

    ; --- Write HUD Row 1 to nametable $2020 ---
    ; (PPU address auto-incremented to $2020 already since we wrote 32 bytes)
    ; Row 1: mostly blank, with item box bottom

    ; Columns 0-13: blank
    lda #HUD_TILE_BLANK
    ldx #14
@row1_space1:
    sta PPUDATA
    dex
    bne @row1_space1

    ; Column 14-15: Item box bottom row (BL, BR)
    lda #HUD_TILE_BOX_BL
    sta PPUDATA
    lda #HUD_TILE_BOX_BR
    sta PPUDATA

    ; Columns 16-31: blank
    lda #HUD_TILE_BLANK
    ldx #16
@row1_space2:
    sta PPUDATA
    dex
    bne @row1_space2

    ; --- Set attribute table for HUD rows ---
    ; The top row of the attribute table ($23C0) covers tile rows 0-3.
    ; We need palette 3 for the top half (tile rows 0-1 = HUD).
    ; Bottom half (tile rows 2-3) = first metatile row, uses map palette.
    ; The map engine already writes the attribute table, but we need to
    ; override the TL/TR quadrants (bits 0-1, 2-3) of attr row 0 to palette 3.
    ;
    ; Actually, the map engine handles this in map_write_attributes - it
    ; sets palette 0 for the status bar region. We need to override that.
    ; We'll write attr row 0 (8 bytes at $23C0) with palette 3 for top
    ; quadrants and whatever the map wants for bottom quadrants.
    ;
    ; For simplicity during init, set all 8 bytes of attr row 0 to have
    ; palette 3 in the top quadrants. Bottom quadrants will be set by the
    ; map engine. Since we run AFTER map_init, we can just patch the top bits.
    ;
    ; Attribute byte layout:
    ;   bits 0-1: TL quadrant (tile rows 0-1, cols 0-1 of 4x4 group)
    ;   bits 2-3: TR quadrant (tile rows 0-1, cols 2-3)
    ;   bits 4-5: BL quadrant (tile rows 2-3, cols 0-1)
    ;   bits 6-7: BR quadrant (tile rows 2-3, cols 2-3)
    ;
    ; For HUD palette 3 in top quadrants: bits 0-1 = 11, bits 2-3 = 11
    ; = %00001111 OR'd with whatever bottom quadrants have.
    ;
    ; Read-modify-write isn't possible on PPU, so just set full palette 3
    ; for the entire first attribute row (all quadrants). The bottom quadrants
    ; cover metatile row 0 which will use palette 3 too (acceptable tradeoff).

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
    ; Magic check placeholder (for future magic system)
    ; lda player_magic
    ; cmp hud_magic_cache
    ; beq @no_magic_change
    ; sta hud_magic_cache
    ; jsr hud_queue_magic
    ; @no_magic_change:

    rts
.endproc

; ============================================================================
; hud_queue_hearts - Queue heart tiles into PPU write buffer
; ============================================================================
; Builds a buffer entry to update nametable row 0, columns 1-8 with the
; current heart states.
; Uses ppu_buffer_write to enqueue.
; Clobbers: A, X, Y
; ============================================================================

.proc hud_queue_hearts
    ; Build heart tile data in a local buffer (on the RAM buffer area)
    ; We'll write directly to the PPU buffer since we need it inline

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
; Queues both row 0 and attribute data via the PPU buffer.
; For screen transitions, the map engine already writes the nametable
; with blank status bar tiles, so we just need to overwrite row 0.
; Clobbers: A, X, Y
; ============================================================================

.proc hud_draw_full
    ; Queue hearts
    jsr hud_queue_hearts

    ; Queue item box (row 0, cols 14-15)
    ldx ppu_buffer_len

    lda #$20                    ; PPU addr high
    sta ppu_buffer, x
    inx
    lda #$0E                    ; PPU addr low (col 14)
    sta ppu_buffer, x
    inx
    lda #$02                    ; 2 bytes
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_TL
    sta ppu_buffer, x
    inx
    lda #HUD_TILE_BOX_TR
    sta ppu_buffer, x
    inx

    ; Queue magic bottles (row 0, cols 24-27)
    lda #$20                    ; PPU addr high
    sta ppu_buffer, x
    inx
    lda #$18                    ; PPU addr low (col 24)
    sta ppu_buffer, x
    inx
    lda #HUD_MAX_MAGIC          ; 4 bytes
    sta ppu_buffer, x
    inx

    ldy #$00
@magic_loop:
    cpy #HUD_MAX_MAGIC
    bcs @magic_done
    lda #HUD_TILE_MAGIC_EMPTY   ; All empty for now
    sta ppu_buffer, x
    inx
    iny
    jmp @magic_loop
@magic_done:

    ; Queue item box row 1 (row 1, cols 14-15)
    lda #$20                    ; PPU addr high
    sta ppu_buffer, x
    inx
    lda #$2E                    ; PPU addr low ($2020 + 14 = $202E)
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
