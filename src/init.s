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
.include "audio.inc"

.segment "PRG_FIXED"

; ============================================================================
; Reset Handler - Entry point on power-on/reset
; ============================================================================

.proc reset_handler
    ; ----- Disable interrupts and decimal mode -----
    sei                     ; Disable IRQ
    cld                     ; Clear decimal mode (not used on NES but good practice)

    ; ----- Disable PPU rendering -----
    lda #$00
    sta PPUCTRL             ; Disable NMI
    sta PPUMASK             ; Disable rendering
    sta $4010               ; Disable DMC IRQ

    ; ----- Disable APU frame counter IRQ -----
    lda #$40
    sta $4017               ; Disable APU frame IRQ

    ; ----- Set up stack pointer -----
    ldx #$FF
    txs

    ; ----- Wait for first vblank -----
    ; PPU needs time to warm up. Wait for PPUSTATUS bit 7.
@wait_vblank1:
    bit PPUSTATUS
    bpl @wait_vblank1

    ; ----- Clear RAM during vblank wait -----
    ; Zero out $0000-$07FF (all internal RAM)
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

    ; ----- Clear OAM buffer (set all sprite Y to $FF = offscreen) -----
    lda #$FF
    ldx #$00
@clear_oam:
    sta $0200, x            ; OAM shadow buffer
    inx
    bne @clear_oam

    ; ----- Wait for second vblank -----
@wait_vblank2:
    bit PPUSTATUS
    bpl @wait_vblank2

    ; ----- PPU is now ready -----

    ; ----- Initialize MMC3 mapper -----
    jsr init_mmc3

    ; ----- Initialize game state -----
    lda #GAME_STATE_GAMEPLAY
    sta game_state

    ; Initialize player position (center of screen)
    lda #120                ; X = 120
    sta player_x
    lda #112                ; Y = 112
    sta player_y
    lda #DIR_DOWN
    sta player_dir
    lda #1
    sta player_speed

    ; ----- Load initial palettes -----
    jsr ppu_load_palette

    ; ----- Clear first nametable -----
    jsr ppu_clear_nametable

    ; ----- Write a test message to the screen -----
    ; Write "ZELDA 2B" at row 13, column 12 (roughly center)
    ; Nametable address = $2000 + (row * 32) + col = $2000 + (13*32) + 12 = $21AC
    lda PPUSTATUS           ; Reset PPU address latch
    lda #$21
    sta PPUADDR
    lda #$AC
    sta PPUADDR
    ; Write tile indices for "ZELDA 2B" using our CHR font (ASCII - $20 offset)
    ; Z=5A-20=3A, E=45-20=25, L=4C-20=2C, D=44-20=24, A=41-20=21
    ; space=00, 2=32-20=12, B=42-20=22
    ldx #$00
@write_title:
    lda title_text, x
    beq @title_done
    sta PPUDATA
    inx
    jmp @write_title
@title_done:

    ; ----- Set initial scroll position -----
    lda PPUSTATUS           ; Reset address latch
    lda #$00
    sta PPUSCROLL           ; X scroll = 0
    sta PPUSCROLL           ; Y scroll = 0
    sta scroll_x
    sta scroll_y

    ; ----- Initialize audio system -----
    jsr audio_init          ; Set up FamiStudio engine with music + SFX data

    ; ----- Enable PPU rendering -----
    lda #PPUCTRL_NMI_ON | PPUCTRL_BG_0000 | PPUCTRL_SPR_1000
    sta PPUCTRL
    sta ppu_ctrl_shadow

    lda #PPUMASK_RENDER_ON
    sta PPUMASK
    sta ppu_mask_shadow

    ; ----- Jump to main loop -----
    jmp main_loop
.endproc

; ============================================================================
; Title text data (tile indices for our font: ASCII code - $20)
; ============================================================================

title_text:
    .byte $3A, $25, $2C, $24, $21, $00, $12, $22  ; "ZELDA 2B"
    .byte 0                                         ; null terminator
