; ============================================================================
; main.s - Main Game Loop
; ============================================================================
; The main loop waits for NMI (vblank), reads input, and dispatches to the
; current game state handler. Runs in the fixed bank.
;
; Player movement and drawing handled by player/player.s module.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "map.inc"
.include "combat.inc"
.include "bombs.inc"
.include "hud.inc"
.include "warps.inc"
.include "inventory.inc"
.include "shop.inc"

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

    cmp #GAME_STATE_INVENTORY
    beq @state_inventory

    cmp #GAME_STATE_MAP_SCREEN
    beq @state_map_screen

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
    ; Player movement, animation, collision, and sprite drawing
    jsr player_update

    ; Update and draw enemies
    jsr enemy_update
    jsr enemy_draw

    ; Update and draw pickups
    jsr pickup_update
    jsr pickup_draw

    ; Update and draw bombs
    jsr bomb_update
    jsr bomb_draw

    ; Update HUD (checks for HP/magic changes, queues PPU buffer writes)
    jsr hud_update

    ; Update shop system (purchase logic when in a shop screen)
    jsr shop_update

    ; Draw shop sprites (shopkeeper + items on floor)
    jsr shop_draw_items

    ; Check for cave warp (door tile warps)
    jsr warp_check
    cmp #$01                ; Did a warp occur?
    bne @no_warp
    jmp @state_done         ; Warp already loaded screen + HUD, skip transition
@no_warp:

    ; Check for screen edge transition
    jsr map_check_transition
    cmp #$01                ; Did a transition occur?
    bne @no_transition
    jsr hud_draw_full       ; Redraw HUD after screen load overwrote it
    jsr mark_current_screen_visited  ; Track visited screens for minimap
@no_transition:

    jmp @state_done

; --- State: Paused ---
@state_paused:
    ; Draw player sprite so it remains visible while paused
    jsr player_draw
    ; Press START to unpause
    lda pad1_pressed
    and #BUTTON_START
    beq @state_done
    lda #GAME_STATE_GAMEPLAY
    sta game_state
    jmp @state_done

; --- State: Inventory ---
@state_inventory:
    jsr inventory_update
    jmp @state_done

; --- State: Map Screen ---
@state_map_screen:
    jsr map_screen_update
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
