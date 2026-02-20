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
.include "map.inc"
.include "combat.inc"
.include "bombs.inc"
.include "hud.inc"
.include "inventory.inc"
.include "dialog.inc"

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

    ; ----- Start in TITLE state -----
    lda #GAME_STATE_TITLE
    sta game_state

    ; ----- Initialize player (will be used when gameplay starts) -----
    jsr player_init

    ; ----- Load initial palettes -----
    jsr ppu_load_palette

    ; ----- Set PPU shadow registers -----
    lda #PPUMASK_RENDER_ON
    sta ppu_mask_shadow

    ; ----- Initialize audio system -----
    jsr audio_init          ; Set up FamiStudio engine with music + SFX data

    ; ----- Initialize dialog system (needed for NPC data structures) -----
    jsr dialog_init

    ; ----- Show title screen -----
    jsr title_screen_init   ; Draw "ZELDA 2B" / "PRESS START" on black bg

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
