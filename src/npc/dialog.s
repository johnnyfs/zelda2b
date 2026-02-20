; ============================================================================
; npc/dialog.s - NPC Dialog Engine and NPC Entity System
; ============================================================================
; Implements:
;   - Dialog box rendering (typewriter effect, 2-line text box at screen bottom)
;   - Dialog state machine (drawing, waiting, closing)
;   - NPC spawn/draw/interaction system
;   - A-button proximity trigger (opens dialog when near NPC)
;
; Dialog box occupies nametable rows 26-27 (bottom of visible area).
; Text is rendered via PPU buffer writes (max ~30 bytes per frame).
; Font tiles are already in bg_tiles.chr at $40+ (A-Z) and $5A+ (0-9).
;
; This code runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "dialog.inc"
.include "combat.inc"
.include "hud.inc"
.include "audio.inc"
.include "map.inc"

; Import dialog data tables (from dialog_data.s in PRG_FIXED_C)
.import dialog_ptrs_lo
.import dialog_ptrs_hi
.import dialog_count
.import npc_screen_table_lo
.import npc_screen_table_hi

.segment "PRG_FIXED_C"

; ============================================================================
; dialog_init - Clear all dialog and NPC state
; ============================================================================
; Called once from reset_handler at game start.
; Clobbers: A
; ============================================================================

.proc dialog_init
    lda #DIALOG_SUBSTATE_IDLE
    sta dialog_state
    lda #$00
    sta dialog_id
    sta dialog_ptr_lo
    sta dialog_ptr_hi
    sta dialog_char_timer
    sta dialog_line
    sta dialog_col
    sta dialog_page
    sta npc_count
    rts
.endproc

; ============================================================================
; dialog_open - Open a dialog box and start displaying text
; ============================================================================
; Input: A = dialog_id (index into dialog string table)
; Sets game state to GAME_STATE_DIALOG and begins typewriter rendering.
; Clobbers: A, X, Y
; ============================================================================

.proc dialog_open
    ; Save dialog ID
    sta dialog_id

    ; Look up string pointer from dialog table
    tax
    lda dialog_ptrs_lo, x
    sta dialog_ptr_lo
    lda dialog_ptrs_hi, x
    sta dialog_ptr_hi

    ; Initialize dialog state
    lda #DIALOG_SUBSTATE_DRAWING
    sta dialog_state
    lda #$00
    sta dialog_line
    sta dialog_col
    sta dialog_page
    lda #DIALOG_CHAR_DELAY
    sta dialog_char_timer

    ; Switch game state to dialog mode
    lda #GAME_STATE_DIALOG
    sta game_state

    ; Draw the dialog box border/background via PPU buffer
    ; We'll draw 2 rows of blank tiles to clear the dialog area first
    jsr dialog_draw_box

    ; Play a cursor/open SFX
    lda #SFX_MENU_CURSOR
    ldx #SFX_CHAN_UI
    jsr audio_play_sfx

    rts
.endproc

; ============================================================================
; dialog_draw_box - Queue the dialog box background tiles to PPU buffer
; ============================================================================
; Clears nametable rows 26-27 with border pattern.
; Format: top border row, then 2 text rows with side borders.
; Since we only have 2 rows, we use a simple approach:
;   Row 26: border tiles framing the text area
;   Row 27: border tiles framing the text area
;
; Clobbers: A, X, Y
; ============================================================================

.proc dialog_draw_box
    ; Queue row 26: clear with blank tiles (text line 1)
    ldx ppu_buffer_len

    ; PPU addr for row 26
    lda #DIALOG_ROW0_ADDR_HI
    sta ppu_buffer, x
    inx
    lda #DIALOG_ROW0_ADDR_LO
    sta ppu_buffer, x
    inx
    ; Length: 32 tiles (full row)
    lda #32
    sta ppu_buffer, x
    inx

    ; Write 32 blank tiles (clear the row)
    ldy #32
@clear_r0:
    lda #DIALOG_TILE_BLANK
    sta ppu_buffer, x
    inx
    dey
    bne @clear_r0

    stx ppu_buffer_len

    ; Queue row 27: clear with blank tiles (text line 2)
    ldx ppu_buffer_len

    lda #DIALOG_ROW1_ADDR_HI
    sta ppu_buffer, x
    inx
    lda #DIALOG_ROW1_ADDR_LO
    sta ppu_buffer, x
    inx
    lda #32
    sta ppu_buffer, x
    inx

    ldy #32
@clear_r1:
    lda #DIALOG_TILE_BLANK
    sta ppu_buffer, x
    inx
    dey
    bne @clear_r1

    stx ppu_buffer_len

    rts
.endproc

; ============================================================================
; dialog_update - Per-frame update during GAME_STATE_DIALOG
; ============================================================================
; Called from main loop when game_state == GAME_STATE_DIALOG.
; Handles:
;   - Typewriter text rendering (queues chars to PPU buffer)
;   - A button: advance page or close dialog
;   - B button: speed up text
;
; Clobbers: A, X, Y
; ============================================================================

.proc dialog_update
    ; Draw player sprite so Link remains visible during dialog
    jsr player_draw

    ; Draw NPC sprites too
    jsr npc_draw

    ; Draw enemies (so they remain visible)
    jsr enemy_draw

    ; Check dialog sub-state
    lda dialog_state

    cmp #DIALOG_SUBSTATE_DRAWING
    beq @state_drawing

    cmp #DIALOG_SUBSTATE_WAITING
    bne @not_waiting
    jmp @state_waiting
@not_waiting:

    cmp #DIALOG_SUBSTATE_CLOSING
    bne @not_closing
    jmp @state_closing
@not_closing:

    ; Unknown state - close dialog as safety
    jmp dialog_close

; --- DRAWING: Typewriter effect, render one char at a time ---
@state_drawing:
    ; Decrement char timer
    dec dialog_char_timer
    bne @drawing_check_fast
    jmp @draw_next_char

@drawing_check_fast:
    ; If B held, use fast timing
    lda pad1_state
    and #BUTTON_B
    beq @drawing_done          ; B not held, wait for timer

    ; B held: check if timer is already <= DIALOG_CHAR_FAST
    lda dialog_char_timer
    cmp #DIALOG_CHAR_FAST
    bcc @draw_next_char         ; Timer already expired, draw now
    beq @draw_next_char
    jmp @drawing_done           ; Still waiting even with fast

@draw_next_char:
    ; Reset timer
    lda pad1_state
    and #BUTTON_B
    bne @use_fast_timer
    lda #DIALOG_CHAR_DELAY
    jmp @set_timer
@use_fast_timer:
    lda #DIALOG_CHAR_FAST
@set_timer:
    sta dialog_char_timer

    ; Read next character from dialog string
    ldy #$00
    lda (dialog_ptr_lo), y

    ; Check for end of dialog ($FF)
    cmp #CHAR_END
    beq @text_done

    ; Check for page break ($FE)
    cmp #CHAR_PG
    beq @page_break

    ; Normal character - queue it to PPU buffer
    sta temp_3                  ; Save the tile index

    ; Calculate PPU address for current line/col
    ; Row 26 + dialog_line, column = DIALOG_TEXT_COL + dialog_col
    jsr dialog_calc_ppu_addr    ; Sets temp_0 = addr_hi, temp_1 = addr_lo

    ; Queue single-char PPU buffer write
    ldx ppu_buffer_len
    lda temp_0
    sta ppu_buffer, x
    inx
    lda temp_1
    sta ppu_buffer, x
    inx
    lda #$01                    ; 1 byte
    sta ppu_buffer, x
    inx
    lda temp_3                  ; Tile index
    sta ppu_buffer, x
    inx
    stx ppu_buffer_len

    ; Advance position
    inc dialog_col
    lda dialog_col
    cmp #DIALOG_TEXT_WIDTH
    bcc @advance_ptr            ; Still on same line

    ; Line full - move to next line
    lda #$00
    sta dialog_col
    inc dialog_line
    lda dialog_line
    cmp #DIALOG_TEXT_LINES
    bcc @advance_ptr            ; Still have lines

    ; All lines full for this page - wait for player input
    lda #DIALOG_SUBSTATE_WAITING
    sta dialog_state
    jmp @advance_ptr

@advance_ptr:
    ; Advance dialog string pointer
    inc dialog_ptr_lo
    bne @drawing_done
    inc dialog_ptr_hi
@drawing_done:
    ; If A pressed while drawing, skip to end of page
    lda pad1_pressed
    and #BUTTON_A
    beq @really_done
    jsr dialog_skip_to_end
@really_done:
    rts

@page_break:
    ; Page break: go to waiting state
    lda #DIALOG_SUBSTATE_WAITING
    sta dialog_state
    ; Advance past the page break character
    inc dialog_ptr_lo
    bne @pb_done
    inc dialog_ptr_hi
@pb_done:
    rts

@text_done:
    ; End of dialog text - wait for final A press
    lda #DIALOG_SUBSTATE_WAITING
    sta dialog_state
    rts

; --- WAITING: Show full page, wait for A to advance/close ---
@state_waiting:
    lda pad1_pressed
    and #BUTTON_A
    beq @waiting_done

    ; A pressed - check if there's more text
    ldy #$00
    lda (dialog_ptr_lo), y

    cmp #CHAR_END
    beq @close_now              ; No more text, close dialog

    ; More text available - advance to next page
    lda #$00
    sta dialog_line
    sta dialog_col
    inc dialog_page

    lda #DIALOG_SUBSTATE_DRAWING
    sta dialog_state

    ; Clear the dialog box for new page
    jsr dialog_draw_box

    ; Play cursor SFX
    lda #SFX_MENU_CURSOR
    ldx #SFX_CHAN_UI
    jsr audio_play_sfx

@waiting_done:
    rts

@close_now:
    jmp dialog_close

; --- CLOSING: Restore gameplay ---
@state_closing:
    jmp dialog_close
.endproc

; ============================================================================
; dialog_skip_to_end - Skip remaining characters to end of current page
; ============================================================================
; Fast-forwards the dialog pointer to the next page break or end marker,
; rendering all remaining characters for the current page at once.
; Clobbers: A, X, Y
; ============================================================================

.proc dialog_skip_to_end
@loop:
    ldy #$00
    lda (dialog_ptr_lo), y

    ; End of dialog?
    cmp #CHAR_END
    beq @done

    ; Page break?
    cmp #CHAR_PG
    beq @at_page_break

    ; Normal char - write it to the correct position
    sta temp_3

    ; Check if we're still within display bounds
    lda dialog_line
    cmp #DIALOG_TEXT_LINES
    bcs @skip_write             ; Past visible lines, just advance pointer

    jsr dialog_calc_ppu_addr

    ldx ppu_buffer_len
    ; Safety check: don't overflow the 96-byte PPU buffer
    cpx #88
    bcs @done                   ; Buffer nearly full, stop

    lda temp_0
    sta ppu_buffer, x
    inx
    lda temp_1
    sta ppu_buffer, x
    inx
    lda #$01
    sta ppu_buffer, x
    inx
    lda temp_3
    sta ppu_buffer, x
    inx
    stx ppu_buffer_len

@skip_write:
    ; Advance position
    inc dialog_col
    lda dialog_col
    cmp #DIALOG_TEXT_WIDTH
    bcc @advance
    lda #$00
    sta dialog_col
    inc dialog_line

@advance:
    ; Advance pointer
    inc dialog_ptr_lo
    bne @loop
    inc dialog_ptr_hi
    jmp @loop

@at_page_break:
    ; At a page break - go to waiting state
    lda #DIALOG_SUBSTATE_WAITING
    sta dialog_state
    ; Advance past the PG character
    inc dialog_ptr_lo
    bne @done
    inc dialog_ptr_hi
@done:
    lda #DIALOG_SUBSTATE_WAITING
    sta dialog_state
    rts
.endproc

; ============================================================================
; dialog_calc_ppu_addr - Calculate PPU address for current line/col
; ============================================================================
; Uses dialog_line (0 or 1) and dialog_col (0-27) to compute the
; nametable address for the next character.
; Output: temp_0 = addr high byte, temp_1 = addr low byte
; Clobbers: A
; ============================================================================

.proc dialog_calc_ppu_addr
    ; Base address: row 26 = $2340, row 27 = $2360
    lda dialog_line
    beq @line_0
    ; Line 1: row 27 = $2360
    lda #DIALOG_ROW1_ADDR_HI
    sta temp_0
    lda #DIALOG_ROW1_ADDR_LO
    clc
    adc #DIALOG_TEXT_COL
    clc
    adc dialog_col
    sta temp_1
    rts

@line_0:
    ; Line 0: row 26 = $2340
    lda #DIALOG_ROW0_ADDR_HI
    sta temp_0
    lda #DIALOG_ROW0_ADDR_LO
    clc
    adc #DIALOG_TEXT_COL
    clc
    adc dialog_col
    sta temp_1
    rts
.endproc

; ============================================================================
; dialog_close - Close dialog box and return to gameplay
; ============================================================================
; Clears the dialog box area from the nametable (restores blank tiles)
; and transitions back to GAME_STATE_GAMEPLAY.
; Clobbers: A, X, Y
; ============================================================================

.proc dialog_close
    ; Clear dialog state
    lda #DIALOG_SUBSTATE_IDLE
    sta dialog_state

    ; Queue blank tiles over the dialog box area to clear it
    ; Row 26
    ldx ppu_buffer_len

    lda #DIALOG_ROW0_ADDR_HI
    sta ppu_buffer, x
    inx
    lda #DIALOG_ROW0_ADDR_LO
    sta ppu_buffer, x
    inx
    lda #32
    sta ppu_buffer, x
    inx

    ldy #32
@clear_r0:
    lda #DIALOG_TILE_BLANK
    sta ppu_buffer, x
    inx
    dey
    bne @clear_r0

    stx ppu_buffer_len

    ; Row 27
    ldx ppu_buffer_len

    lda #DIALOG_ROW1_ADDR_HI
    sta ppu_buffer, x
    inx
    lda #DIALOG_ROW1_ADDR_LO
    sta ppu_buffer, x
    inx
    lda #32
    sta ppu_buffer, x
    inx

    ldy #32
@clear_r1:
    lda #DIALOG_TILE_BLANK
    sta ppu_buffer, x
    inx
    dey
    bne @clear_r1

    stx ppu_buffer_len

    ; Return to gameplay
    lda #GAME_STATE_GAMEPLAY
    sta game_state

    rts
.endproc

; ============================================================================
; NPC System
; ============================================================================

; ============================================================================
; npc_init - Clear all NPC slots
; ============================================================================
; Called from reset_handler or when loading a new screen.
; Clobbers: A, X
; ============================================================================

.proc npc_init
    lda #$00
    sta npc_count
    ldx #MAX_NPCS - 1
@loop:
    sta npc_x, x
    sta npc_y, x
    sta npc_tile, x
    sta npc_dialog_id, x
    dex
    bpl @loop
    rts
.endproc

; ============================================================================
; npc_spawn_screen - Spawn NPCs for the current screen
; ============================================================================
; Reads NPC data from the per-screen tables in dialog_data.s.
; Uses current_screen_id to index into npc_screen_table.
; Clobbers: A, X, Y
; ============================================================================

.proc npc_spawn_screen
    ; First, clear existing NPCs
    jsr npc_init

    ; Get pointer to NPC data for this screen
    lda current_screen_id
    tax
    lda npc_screen_table_lo, x
    sta ptr_lo
    lda npc_screen_table_hi, x
    sta ptr_hi

    ; Read NPC count
    ldy #$00
    lda (ptr_lo), y
    sta npc_count
    beq @done                   ; No NPCs on this screen

    ; Clamp to MAX_NPCS
    cmp #MAX_NPCS
    bcc @count_ok
    lda #MAX_NPCS
    sta npc_count
@count_ok:

    ; Read NPC data: for each NPC, 4 bytes (x, y, tile, dialog_id)
    iny                         ; Y = 1, pointing past count byte
    ldx #$00                    ; NPC slot index

@load_loop:
    cpx npc_count
    bcs @done

    ; Read X position
    lda (ptr_lo), y
    sta npc_x, x
    iny

    ; Read Y position
    lda (ptr_lo), y
    sta npc_y, x
    iny

    ; Read sprite tile
    lda (ptr_lo), y
    sta npc_tile, x
    iny

    ; Read dialog ID
    lda (ptr_lo), y
    sta npc_dialog_id, x
    iny

    inx
    jmp @load_loop

@done:
    rts
.endproc

; ============================================================================
; npc_draw - Draw all active NPC sprites
; ============================================================================
; Renders each NPC as a 2x2 (16x16) metatile sprite, similar to
; enemy drawing. Uses the alloc_sprite interface via temp vars.
; Clobbers: A, X, Y
; ============================================================================

.proc npc_draw
    ldx #$00                    ; NPC index

@loop:
    cpx npc_count
    bcs @done

    ; Save X (NPC index) on stack since we clobber it in OAM writes
    txa
    pha

    ; Get NPC position and tile
    lda npc_y, x
    sta temp_0                  ; Y position for sprite
    lda npc_tile, x
    sta temp_1                  ; Base tile index
    lda #OAM_PALETTE_2          ; Use sprite palette 2 for NPCs
    sta temp_2                  ; Attributes
    lda npc_x, x
    sta temp_3                  ; X position

    ; Draw as 2x2 metatile sprite (4 sprites: TL, TR, BL, BR)
    ; Top-left
    jsr alloc_sprite

    ; Top-right: tile+1, x+8
    lda temp_0                  ; Restore Y
    sta temp_0
    inc temp_1                  ; tile + 1
    lda temp_3
    clc
    adc #$08
    sta temp_3                  ; x + 8
    jsr alloc_sprite

    ; Bottom-left: tile+2, original x, y+8
    pla                         ; Restore NPC index
    pha                         ; Re-push it
    tax
    lda npc_y, x
    clc
    adc #$08
    sta temp_0                  ; y + 8
    lda npc_tile, x
    clc
    adc #$02
    sta temp_1                  ; tile + 2
    lda #OAM_PALETTE_2
    sta temp_2
    lda npc_x, x
    sta temp_3                  ; original x
    jsr alloc_sprite

    ; Bottom-right: tile+3, x+8, y+8
    inc temp_1                  ; tile + 3
    lda temp_3
    clc
    adc #$08
    sta temp_3                  ; x + 8
    jsr alloc_sprite

    ; Restore NPC index and advance
    pla
    tax
    inx
    jmp @loop

@done:
    rts
.endproc

; ============================================================================
; npc_check_interact - Check if player presses A near an NPC
; ============================================================================
; Called from the gameplay state in main loop (before combat_update).
; If player is within NPC_INTERACT_RANGE of any NPC and presses A,
; opens the dialog for that NPC.
;
; Returns: carry set if dialog was opened (suppress combat A-press)
;          carry clear if no interaction
; Clobbers: A, X, Y
; ============================================================================

.proc npc_check_interact
    ; Only trigger on A press
    lda pad1_pressed
    and #BUTTON_A
    beq @no_interact

    ; Check each NPC slot
    ldx #$00
@loop:
    cpx npc_count
    bcs @no_interact

    ; Check X distance: |player_x - npc_x|
    lda player_x
    sec
    sbc npc_x, x
    bpl @x_pos
    ; Negative: negate
    eor #$FF
    clc
    adc #$01
@x_pos:
    cmp #NPC_INTERACT_RANGE
    bcs @next                   ; Too far in X

    ; Check Y distance: |player_y - npc_y|
    lda player_y
    sec
    sbc npc_y, x
    bpl @y_pos
    eor #$FF
    clc
    adc #$01
@y_pos:
    cmp #NPC_INTERACT_RANGE
    bcs @next                   ; Too far in Y

    ; In range! Open dialog for this NPC
    lda npc_dialog_id, x
    jsr dialog_open
    sec                         ; Signal: dialog opened
    rts

@next:
    inx
    jmp @loop

@no_interact:
    clc                         ; No interaction
    rts
.endproc
