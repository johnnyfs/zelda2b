; ============================================================================
; main.s - Main Game Loop
; ============================================================================
; The main loop waits for NMI (vblank), reads input, and dispatches to the
; current game state handler. Runs in the fixed bank.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"

.segment "PRG_FIXED"

; ============================================================================
; Main Loop
; ============================================================================

.proc main_loop

@loop:
    ; --- Wait for NMI to signal vblank ---
    ; The NMI handler sets nmi_ready to non-zero each frame.
    lda nmi_ready
    beq @loop               ; Spin until NMI fires

    ; --- Acknowledge NMI ---
    lda #$00
    sta nmi_ready

    ; --- Increment frame counter ---
    inc frame_counter

    ; --- Read gamepad input ---
    jsr read_gamepads

    ; --- Reset sprite allocation for this frame ---
    lda #$00
    sta oam_offset

    ; --- Dispatch to game state handler ---
    lda game_state

    cmp #GAME_STATE_TITLE
    beq @state_title

    cmp #GAME_STATE_GAMEPLAY
    beq @state_gameplay

    cmp #GAME_STATE_PAUSED
    beq @state_paused

    cmp #GAME_STATE_GAME_OVER
    beq @state_game_over

    ; Default: treat as gameplay
    jmp @state_gameplay

; --- State: Title Screen ---
@state_title:
    ; Placeholder: press START to go to GAMEPLAY
    lda pad1_pressed
    and #BUTTON_START
    beq @state_done
    lda #GAME_STATE_GAMEPLAY
    sta game_state
    jmp @state_done

; --- State: Gameplay ---
@state_gameplay:
    jsr player_update
    jmp @state_done

; --- State: Paused ---
@state_paused:
    ; Press START to unpause
    lda pad1_pressed
    and #BUTTON_START
    beq @state_done
    lda #GAME_STATE_GAMEPLAY
    sta game_state
    jmp @state_done

; --- State: Game Over ---
@state_game_over:
    ; Press START to go to title
    lda pad1_pressed
    and #BUTTON_START
    beq @state_done
    lda #GAME_STATE_TITLE
    sta game_state
    jmp @state_done

@state_done:
    ; --- Clear remaining OAM entries (hide unused sprites) ---
    jsr clear_remaining_oam

    ; --- Loop back ---
    jmp @loop
.endproc

; ============================================================================
; player_update - Handle player movement and animation
; ============================================================================
; Reads pad1_state and moves the player accordingly.
; Also draws the player sprite.
; ============================================================================

.proc player_update
    ; --- Check directional input ---
    lda pad1_state

    ; Check UP
    pha
    and #BUTTON_UP
    beq @not_up
    lda player_y
    sec
    sbc player_speed
    cmp #8                  ; Top boundary
    bcc @not_up
    sta player_y
    lda #DIR_UP
    sta player_dir
@not_up:

    ; Check DOWN
    pla
    pha
    and #BUTTON_DOWN
    beq @not_down
    lda player_y
    clc
    adc player_speed
    cmp #224                ; Bottom boundary
    bcs @not_down
    sta player_y
    lda #DIR_DOWN
    sta player_dir
@not_down:

    ; Check LEFT
    pla
    pha
    and #BUTTON_LEFT
    beq @not_left
    lda player_x
    sec
    sbc player_speed
    cmp #0
    beq @not_left
    sta player_x
    lda #DIR_LEFT
    sta player_dir
@not_left:

    ; Check RIGHT
    pla
    and #BUTTON_RIGHT
    beq @not_right
    lda player_x
    clc
    adc player_speed
    cmp #248                ; Right boundary
    bcs @not_right
    sta player_x
    lda #DIR_RIGHT
    sta player_dir
@not_right:

    ; --- Check START for pause ---
    lda pad1_pressed
    and #BUTTON_START
    beq @no_pause
    lda #GAME_STATE_PAUSED
    sta game_state
@no_pause:

    ; --- Draw player sprite (16x16 = 4 hardware sprites) ---
    ; Top-left sprite
    lda player_y
    ldx oam_offset
    sta $0200, x            ; Y position
    inx
    lda #$02                ; Tile index (placeholder player tile)
    sta $0200, x
    inx
    lda #$00                ; Attributes (palette 0, no flip)
    sta $0200, x
    inx
    lda player_x
    sta $0200, x            ; X position
    inx

    ; Top-right sprite
    lda player_y
    sta $0200, x            ; Y
    inx
    lda #$03                ; Tile index
    sta $0200, x
    inx
    lda #$00                ; Attributes
    sta $0200, x
    inx
    lda player_x
    clc
    adc #8
    sta $0200, x            ; X + 8
    inx

    ; Bottom-left sprite
    lda player_y
    clc
    adc #8
    sta $0200, x            ; Y + 8
    inx
    lda #$12                ; Tile index
    sta $0200, x
    inx
    lda #$00                ; Attributes
    sta $0200, x
    inx
    lda player_x
    sta $0200, x            ; X
    inx

    ; Bottom-right sprite
    lda player_y
    clc
    adc #8
    sta $0200, x            ; Y + 8
    inx
    lda #$13                ; Tile index
    sta $0200, x
    inx
    lda #$00                ; Attributes
    sta $0200, x
    inx
    lda player_x
    clc
    adc #8
    sta $0200, x            ; X + 8
    inx

    ; Update OAM offset
    stx oam_offset

    rts
.endproc

; ============================================================================
; clear_remaining_oam - Hide unused sprite slots
; ============================================================================
; Sets Y coordinate to $FF for all OAM entries from oam_offset to end.
; ============================================================================

.proc clear_remaining_oam
    ldx oam_offset
    lda #$FF
@loop:
    cpx #$00                ; Wrapped around = done (256 bytes)
    beq @done
    sta $0200, x            ; Set Y = $FF (offscreen)
    inx
    inx
    inx
    inx                     ; Next sprite (4 bytes each)
    bne @loop
@done:
    rts
.endproc
