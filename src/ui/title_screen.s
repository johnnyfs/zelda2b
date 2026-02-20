; ============================================================================
; ui/title_screen.s - Title Screen Display
; ============================================================================
; Displays "ZELDA 2B" and "PRESS START" on a black background.
; Waits for START button press, then transitions to gameplay.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"
.include "combat.inc"
.include "bombs.inc"
.include "hud.inc"
.include "inventory.inc"

.segment "PRG_FIXED"

; Font tile encoding (same as dialog system)
FONT_Z = $59
FONT_E = $44
FONT_L = $4B
FONT_D = $43
FONT_A = $40
FONT_2 = $5C
FONT_B = $41
FONT_P = $4F
FONT_R = $51
FONT_S = $52
FONT_T = $53
FONT_U = $54
FONT_SPACE = $00

; ============================================================================
; title_screen_init - Set up the title screen display
; ============================================================================
; Disables rendering, clears nametable, draws title text, re-enables.
; Call this when entering GAME_STATE_TITLE.
; ============================================================================

.proc title_screen_init
    ; Disable rendering
    lda #$00
    sta PPUMASK

    ; Clear nametable 0
    lda PPUSTATUS           ; Reset PPU latch
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; Write 960 bytes of blank tiles (30 rows x 32 columns)
    lda #$00
    ldx #$00
    ldy #$04                ; 4 x 256 = 1024 (slightly more than 960, that's fine)
@clear_loop:
    sta PPUDATA
    inx
    bne @clear_loop
    dey
    bne @clear_loop

    ; Clear attribute table (64 bytes, all palette 3 for white text)
    lda PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR
    lda #%11111111          ; All palette 3
    ldx #$40                ; 64 bytes
@attr_loop:
    sta PPUDATA
    dex
    bne @attr_loop

    ; --- Draw "ZELDA 2B" at row 8, centered ---
    ; Row 8, column 12 = address $2000 + 8*32 + 12 = $210C
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$0C
    sta PPUADDR

    lda #FONT_Z
    sta PPUDATA
    lda #FONT_E
    sta PPUDATA
    lda #FONT_L
    sta PPUDATA
    lda #FONT_D
    sta PPUDATA
    lda #FONT_A
    sta PPUDATA
    lda #FONT_SPACE
    sta PPUDATA
    lda #FONT_2
    sta PPUDATA
    lda #FONT_B
    sta PPUDATA

    ; --- Draw "PRESS START" at row 16, centered ---
    ; Row 16, column 11 = $2000 + 16*32 + 11 = $220B
    lda PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$0B
    sta PPUADDR

    lda #FONT_P
    sta PPUDATA
    lda #FONT_R
    sta PPUDATA
    lda #FONT_E
    sta PPUDATA
    lda #FONT_S
    sta PPUDATA
    lda #FONT_S
    sta PPUDATA
    lda #FONT_SPACE
    sta PPUDATA
    lda #FONT_S
    sta PPUDATA
    lda #FONT_T
    sta PPUDATA
    lda #FONT_A
    sta PPUDATA
    lda #FONT_R
    sta PPUDATA
    lda #FONT_T
    sta PPUDATA

    ; Reset scroll
    lda PPUSTATUS
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL
    sta scroll_x
    sta scroll_y

    ; Re-enable rendering
    lda ppu_mask_shadow
    sta PPUMASK

    rts
.endproc

; ============================================================================
; title_screen_to_gameplay - Transition from title to gameplay
; ============================================================================
; Loads the starting screen, initializes all systems, starts gameplay.
; ============================================================================

.proc title_screen_to_gameplay
    ; Set game state to gameplay
    lda #GAME_STATE_GAMEPLAY
    sta game_state

    ; Reload the starting screen (map_init re-enables rendering)
    jsr map_init

    ; Re-init combat and spawns
    jsr combat_init
    jsr pickup_init
    jsr bomb_init
    jsr item_system_init
    jsr inventory_init
    jsr enemy_spawn_screen

    ; Re-draw HUD
    lda #$00
    sta PPUMASK
    jsr hud_init
    lda PPUSTATUS
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL
    lda ppu_mask_shadow
    sta PPUMASK

    ; Start overworld music
    lda #$00
    jsr audio_play_song

    rts
.endproc
