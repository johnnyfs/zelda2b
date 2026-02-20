; ============================================================================
; main.s — Main Game Loop + State Machine
; ============================================================================
; After hardware init, the main loop runs at ~60fps:
;   1. Wait for NMI (vblank sync)
;   2. Read gamepad
;   3. Dispatch to current game state handler
;   4. Draw sprites
;   5. Loop
;
; Tech demo: Shows a grass-filled screen with a player sprite that moves
; with the D-pad. Proves: NMI, PPU buffer, OAM DMA, gamepad, metatile
; renderer, sprite system all work.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "audio.inc"

.import gamepad_read
.import sprite_clear, sprite_put
.import ppu_buf_reset
.import metatile_fill_screen
.import mmc3_init
.import audio_init, audio_update, audio_play_sfx

.export main_init, main_loop

; --- Player state (zero page) ---
.segment "ZEROPAGE"
player_x:       .res 1     ; Player X pixel position
player_y:       .res 1     ; Player Y pixel position
player_dir:     .res 1     ; Facing direction (0=down, 1=up, 2=right, 3=left)

.segment "PRG_FIXED"

; ============================================================================
; main_init — One-time setup after hardware boot
; ============================================================================
; PPU rendering and NMI are OFF when this runs. All PPU writes are direct.
; ============================================================================
.proc main_init
    ; Initialize MMC3
    jsr mmc3_init

    ; Initialize audio
    jsr audio_init

    ; Set initial game state
    lda #GAME_STATE_PLAY
    sta game_state

    ; --- Load palettes (direct PPU write, rendering is off) ---
    bit PPUSTATUS           ; Reset PPU latch
    lda #>PALETTE_ADDR
    sta PPUADDR
    lda #<PALETTE_ADDR
    sta PPUADDR

    ; BG Palette 0: black, green, dark-green, white
    lda #$0F                ; Black
    sta PPUDATA
    lda #$2A                ; Green
    sta PPUDATA
    lda #$1A                ; Dark green
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; BG Palette 1: black, brown, orange, white
    lda #$0F
    sta PPUDATA
    lda #$17                ; Brown
    sta PPUDATA
    lda #$27                ; Orange
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; BG Palette 2: black, blue, light-blue, white
    lda #$0F
    sta PPUDATA
    lda #$12                ; Blue
    sta PPUDATA
    lda #$21                ; Light blue
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; BG Palette 3: black, gray, dark-gray, white
    lda #$0F
    sta PPUDATA
    lda #$10                ; Gray
    sta PPUDATA
    lda #$00                ; Dark gray
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; Sprite Palette 0: transparent, green, red, white (player)
    lda #$0F
    sta PPUDATA
    lda #$2A                ; Green
    sta PPUDATA
    lda #$16                ; Red
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; Sprite Palette 1: transparent, blue, dark-blue, white (items)
    lda #$0F
    sta PPUDATA
    lda #$12                ; Blue
    sta PPUDATA
    lda #$02                ; Dark blue
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; Sprite Palette 2: transparent, red, dark-red, white (enemies)
    lda #$0F
    sta PPUDATA
    lda #$16                ; Red
    sta PPUDATA
    lda #$06                ; Dark red
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; Sprite Palette 3: transparent, yellow, orange, white (effects)
    lda #$0F
    sta PPUDATA
    lda #$28                ; Yellow
    sta PPUDATA
    lda #$27                ; Orange
    sta PPUDATA
    lda #$30                ; White
    sta PPUDATA

    ; --- Fill screen with grass metatile (direct PPU write) ---
    lda #0                  ; MT_GRASS
    jsr metatile_fill_screen

    ; --- Draw walls directly to PPU for test room ---
    ; We write wall tiles directly since rendering is off
    jsr draw_test_room

    ; --- Set up attribute table for the test room ---
    ; For now, all palette 0 (grass default)
    ; Attribute table at $23C0, 64 bytes
    bit PPUSTATUS
    lda #>ATTR_TABLE_0
    sta PPUADDR
    lda #<ATTR_TABLE_0
    sta PPUADDR
    ldx #64
    lda #$00                ; All palette 0
@attr_loop:
    sta PPUDATA
    dex
    bne @attr_loop

    ; --- Initialize player ---
    lda #120                ; Center X
    sta player_x
    lda #112                ; Center Y
    sta player_y
    lda #0                  ; Facing down
    sta player_dir

    ; --- Reset scroll ---
    lda #0
    sta scroll_x
    sta scroll_y

    ; --- Clear OAM ---
    jsr sprite_clear

    ; --- Enable NMI + set pattern tables ---
    ; BG pattern table 0, sprite pattern table 1 ($1000)
    lda #PPUCTRL_NMI | PPUCTRL_SPR_TABLE
    sta PPUCTRL
    sta nmi_ctrl

    ; --- Enable rendering ---
    lda #PPUMASK_SHOW_BG | PPUMASK_SHOW_SPR | PPUMASK_SHOW_BG_L | PPUMASK_SHOW_SPR_L
    sta PPUMASK
    sta nmi_mask

    rts
.endproc

; ============================================================================
; draw_test_room — Draw wall borders directly to nametable (PPU off)
; ============================================================================
; Draws a border of wall tiles around the screen edge.
; Wall metatile uses tile $03 for all 4 corners.
; ============================================================================
.proc draw_test_room
    ; --- Top wall: row 0 (nametable rows 0-1, 32 tiles each) ---
    ; Row 0: nametable addr $2000
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR
    ldx #32
    lda #$03                ; Wall tile
@top0:
    sta PPUDATA
    dex
    bne @top0
    ; Row 1: nametable addr $2020
    ldx #32
@top1:
    sta PPUDATA             ; PPU auto-increments
    dex
    bne @top1

    ; --- Bottom wall: row 14 (nametable rows 28-29) ---
    ; Row 28: addr $2000 + 28*32 = $2000 + $0380 = $2380
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$80
    sta PPUADDR
    ldx #32
    lda #$03
@bot0:
    sta PPUDATA
    dex
    bne @bot0
    ; Row 29:
    ldx #32
@bot1:
    sta PPUDATA
    dex
    bne @bot1

    ; --- Left wall: column 0-1, rows 2-27 ---
    ; Each row we write 2 tiles at the start
    ; Row n starts at $2000 + n*32
    lda #2                  ; Start at row 2
    sta tmp0
@left_loop:
    ; Calculate address: $2000 + row*32
    lda tmp0
    ; row * 32 = row << 5
    lda #0
    sta tmp2                ; addr high partial
    lda tmp0
    asl                     ; *2
    asl                     ; *4
    asl                     ; *8
    asl                     ; *16
    asl                     ; *32
    sta tmp1                ; addr low
    lda #0
    rol                     ; carry into high
    clc
    adc #$20                ; + $2000
    sta tmp2

    bit PPUSTATUS
    lda tmp2
    sta PPUADDR
    lda tmp1
    sta PPUADDR
    lda #$03                ; Wall tile
    sta PPUDATA
    sta PPUDATA             ; 2 tiles wide

    inc tmp0
    lda tmp0
    cmp #28                 ; Rows 2-27
    bne @left_loop

    ; --- Right wall: column 30-31, rows 2-27 ---
    lda #2
    sta tmp0
@right_loop:
    lda #0
    sta tmp2
    lda tmp0
    asl
    asl
    asl
    asl
    asl
    sta tmp1
    lda #0
    rol
    clc
    adc #$20
    sta tmp2

    ; Column 30 = offset +30 from row start
    lda tmp1
    clc
    adc #30
    sta tmp1
    lda tmp2
    adc #0
    sta tmp2

    bit PPUSTATUS
    lda tmp2
    sta PPUADDR
    lda tmp1
    sta PPUADDR
    lda #$03                ; Wall tile
    sta PPUDATA
    sta PPUDATA             ; 2 tiles wide

    inc tmp0
    lda tmp0
    cmp #28
    bne @right_loop

    rts
.endproc

; ============================================================================
; main_loop — Runs every frame (~60fps)
; ============================================================================
.proc main_loop
@loop:
    jsr wait_nmi
    jsr ppu_buf_reset
    jsr gamepad_read
    jsr sprite_clear

    ; --- Dispatch on game state ---
    lda game_state
    cmp #GAME_STATE_PLAY
    beq @play
    ; Other states would go here (title, pause, gameover)
    jmp @draw_done

@play:
    jsr state_play

@draw_done:
    jsr audio_update
@draw_done:
    jmp @loop
.endproc

; ============================================================================
; wait_nmi — Spin until NMI fires
; ============================================================================
.proc wait_nmi
    lda #0
    sta nmi_ready
@wait:
    lda nmi_ready
    beq @wait
    rts
.endproc

; ============================================================================
; state_play — Main gameplay state
; ============================================================================
.proc state_play
    ; --- Player movement ---
    ; Check D-pad and move player

    lda gamepad
    and #BUTTON_UP
    beq @no_up
    lda player_y
    sec
    sbc #2                  ; Speed = 2 pixels/frame
    cmp #17                 ; Top wall boundary (2 metatile rows = 32px, but Y is 1-indexed)
    bcc @no_up
    sta player_y
    lda #1                  ; Face up
    sta player_dir
@no_up:

    lda gamepad
    and #BUTTON_DOWN
    beq @no_down
    lda player_y
    clc
    adc #2
    cmp #212                ; Bottom wall boundary (row 14*16=224, minus sprite height)
    bcs @no_down
    sta player_y
    lda #0                  ; Face down
    sta player_dir
@no_down:

    lda gamepad
    and #BUTTON_LEFT
    beq @no_left
    lda player_x
    sec
    sbc #2
    cmp #17                 ; Left wall boundary
    bcc @no_left
    sta player_x
    lda #3                  ; Face left
    sta player_dir
@no_left:

    lda gamepad
    and #BUTTON_RIGHT
    beq @no_right
    lda player_x
    clc
    adc #2
    cmp #237                ; Right wall boundary (col 15*16=240, minus sprite)
    bcs @no_right
    sta player_x
    lda #2                  ; Face right
    sta player_dir
@no_right:

    ; --- Draw player sprite ---
    ; Select tile based on direction
    lda player_dir
    cmp #1
    beq @face_up
    cmp #2
    beq @face_right
    cmp #3
    beq @face_left

    ; Default: face down
    lda #$01                ; Down sprite tile
    jmp @do_sprite

@face_up:
    lda #$02
    jmp @do_sprite

@face_right:
    lda #$03
    ldx #0                  ; No flip
    stx tmp0
    jmp @do_draw

@face_left:
    lda #$03                ; Same as right, H-flipped
    ldx #SPR_FLIP_H
    stx tmp0
    jmp @do_draw

@do_sprite:
    ldx #0
    stx tmp0                ; No flip (attributes = 0)

@do_draw:
    ; A = tile, tmp0 = attributes
    ldx player_x
    ldy player_y
    jsr sprite_put

    rts
.endproc
