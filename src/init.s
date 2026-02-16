; ============================================================================
; init.s - NES Initialization / Reset Handler
; ============================================================================
; Full hardware initialization sequence executed on power-on and reset.
; This code runs in the fixed bank (PRG_FIXED).
; ============================================================================

.include "nes.inc"
.include "mmc3.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"
.include "audio.inc"

.segment "PRG_FIXED"

; ============================================================================
; Reset Handler - Entry point on power-on/reset
; ============================================================================

.proc reset_handler
    sei
    cld
    lda #$00
    sta PPUCTRL
    sta PPUMASK
    sta $4010
    lda #$40
    sta $4017
    ldx #$FF
    txs

@wait_vblank1:
    bit PPUSTATUS
    bpl @wait_vblank1

    lda #$00
    ldx #$00
@clear_ram:
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne @clear_ram

    lda #$FF
    ldx #$00
@clear_oam:
    sta $0200, x
    inx
    bne @clear_oam

@wait_vblank2:
    bit PPUSTATUS
    bpl @wait_vblank2

    ; ----- Initialize MMC3 mapper -----
    jsr init_mmc3

    ; ----- Initialize game state -----
    lda #GAME_STATE_GAMEPLAY
    sta game_state

    ; ----- Initialize player (via player module) -----
    jsr player_init

    ; ----- Load palettes -----
    jsr ppu_load_palette

    ; ----- Load test screen nametable -----
    jsr load_test_screen

    ; ----- Set initial scroll position -----
    lda #$00
    sta scroll_x
    sta scroll_y

    ; ----- Set up PPU shadow registers before map_init -----
    ; map_init disables rendering, writes nametable, then restores from shadows
    lda #PPUCTRL_NMI_ON | PPUCTRL_BG_0000 | PPUCTRL_SPR_1000
    sta PPUCTRL
    sta ppu_ctrl_shadow

    lda #PPUMASK_RENDER_ON
    sta ppu_mask_shadow         ; Save desired mask; map_init will enable rendering

    ; ----- Initialize map engine (loads starting screen) -----
    jsr map_init

    ; ----- Jump to main loop -----
    jmp main_loop
.endproc
