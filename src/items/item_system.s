; ============================================================================
; items/item_system.s - Item Dispatch, Give, and Magic System
; ============================================================================
; Manages the player's item inventory, B-button dispatch, item acquisition,
; magic consumption, and visited screen tracking.
; ============================================================================

.include "nes.inc"
.include "globals.inc"
.include "enums.inc"
.include "inventory.inc"
.include "hud.inc"
.include "map.inc"
.include "bombs.inc"

.segment "PRG_FIXED"

; ============================================================================
; item_system_init - Initialize item system at game start
; ============================================================================
; Clears all items, gives starting equipment (sword + bombs).
; Initializes magic to 0, clears visited_screens, marks starting screen.
; ============================================================================

.proc item_system_init
    ; Clear all items
    ldx #(ITEM_COUNT - 1)
    lda #$00
@clear_items:
    sta player_items, x
    dex
    bpl @clear_items

    ; Give starting equipment
    lda #$01
    sta player_items + ITEM_SWORD

    lda #$03                    ; Start with 3 bombs
    sta player_items + ITEM_BOMB
    sta player_bombs            ; Sync with bomb system

    ; Set default B-item to bombs
    lda #ITEM_BOMB
    sta selected_b_item
    lda #$00
    sta b_item_cooldown

    ; Initialize keys/arrows
    lda #$00
    sta player_keys
    sta player_arrows

    ; Initialize magic
    lda #$00
    sta player_magic
    sta player_max_magic
    sta magic_bottles_count

    ; Clear visited screens bitmask
    ldx #7
    lda #$00
@clear_visited:
    sta visited_screens, x
    dex
    bpl @clear_visited

    ; Mark starting screen as visited
    jsr mark_current_screen_visited

    rts
.endproc

; ============================================================================
; item_use_b - Dispatch B-button item action
; ============================================================================
; Called when the player presses B during gameplay.
; Dispatches to the appropriate item handler based on selected_b_item.
; Each handler sets b_item_cooldown to prevent rapid-fire reuse.
;
; Clobbers: A, X, Y
; ============================================================================

; Cooldown values (in frames) for each item
B_COOLDOWN_BOMB     = 30        ; ~0.5 sec (bomb fuse takes time anyway)
B_COOLDOWN_BOW      = 12        ; Quick repeat
B_COOLDOWN_CANDLE   = 20
B_COOLDOWN_HOOKSHOT = 30
B_COOLDOWN_HAMMER   = 15
B_COOLDOWN_FLUTE    = 60        ; Long cooldown for warp
B_COOLDOWN_POTION   = 30
B_COOLDOWN_BOOMERANG = 20

.proc item_use_b
    lda selected_b_item

    cmp #ITEM_BOMB
    beq @use_bomb
    cmp #ITEM_BOW
    beq @use_bow
    cmp #ITEM_CANDLE
    beq @use_candle
    cmp #ITEM_HOOKSHOT
    beq @use_hookshot
    cmp #ITEM_HAMMER
    beq @use_hammer
    cmp #ITEM_FLUTE
    beq @use_flute
    cmp #ITEM_POTION
    beq @use_potion
    cmp #ITEM_BOOMERANG
    beq @use_boomerang

    ; Unknown or ITEM_NONE: do nothing
    rts

@use_bomb:
    ; Check if player has bombs
    lda player_bombs
    beq @done
    ; bomb_place is defined in bombs.s — handles decrement + spawn
    jsr bomb_place
    lda #B_COOLDOWN_BOMB
    sta b_item_cooldown
    jmp @done

@use_bow:
    ; Check if player has arrows
    lda player_arrows
    beq @done
    dec player_arrows
    ; Sync arrow count to player_items
    lda player_arrows
    sta player_items + ITEM_ARROW
    lda #B_COOLDOWN_BOW
    sta b_item_cooldown
    ; TODO: Spawn arrow projectile in player_dir direction
    lda #$01
    sta hud_dirty
    jmp @done

@use_candle:
    ; Uses magic
    lda #MAGIC_COST_CANDLE
    jsr magic_consume
    bcc @done               ; Not enough magic
    lda #B_COOLDOWN_CANDLE
    sta b_item_cooldown
    ; TODO: Spawn candle flame projectile in player_dir direction
    jmp @done

@use_hookshot:
    lda #MAGIC_COST_HOOKSHOT
    jsr magic_consume
    bcc @done
    lda #B_COOLDOWN_HOOKSHOT
    sta b_item_cooldown
    ; TODO: Spawn hookshot projectile in player_dir direction
    jmp @done

@use_hammer:
    ; Hammer is free to use (melee)
    lda #B_COOLDOWN_HAMMER
    sta b_item_cooldown
    ; TODO: Hammer ground-pound effect (break rocks, stun enemies)
    jmp @done

@use_flute:
    ; Check if player owns flute
    lda player_items + ITEM_FLUTE
    beq @done
    lda #B_COOLDOWN_FLUTE
    sta b_item_cooldown
    ; TODO: Flute warp/summon effect
    jmp @done

@use_boomerang:
    ; Check if player owns boomerang
    lda player_items + ITEM_BOOMERANG
    beq @done
    lda #B_COOLDOWN_BOOMERANG
    sta b_item_cooldown
    ; TODO: Spawn boomerang projectile that returns to player
    jmp @done

@use_potion:
    ; Restore magic to full
    lda player_items + ITEM_POTION
    beq @done               ; No potions
    dec player_items + ITEM_POTION
    lda player_max_magic
    sta player_magic
    lda #B_COOLDOWN_POTION
    sta b_item_cooldown
    lda #$01
    sta hud_dirty

@done:
    rts
.endproc

; ============================================================================
; item_give - Give an item to the player
; ============================================================================
; Input: A = ITEM_xxx ID to give
; For countable items (keys, arrows, bombs, potions), increments count.
; For unique items, sets ownership to 1.
; Clobbers: A, X
; ============================================================================

.proc item_give
    tax                     ; X = item ID

    ; Handle countable items with caps
    cpx #ITEM_KEY
    beq @give_key
    cpx #ITEM_ARROW
    beq @give_arrow
    cpx #ITEM_BOMB
    beq @give_bomb
    cpx #ITEM_POTION
    beq @give_potion

    ; Unique item: just set to 1
    lda #$01
    sta player_items, x
    rts

@give_key:
    lda player_keys
    cmp #MAX_KEYS
    bcs @at_max
    inc player_keys
    lda player_keys
    sta player_items + ITEM_KEY
    rts

@give_arrow:
    lda player_arrows
    cmp #MAX_ARROWS
    bcs @at_max
    inc player_arrows
    lda player_arrows
    sta player_items + ITEM_ARROW
    rts

@give_bomb:
    lda player_bombs
    cmp #MAX_BOMBS_INV
    bcs @at_max
    inc player_bombs
    lda player_bombs
    sta player_items + ITEM_BOMB
    rts

@give_potion:
    lda player_items + ITEM_POTION
    cmp #MAX_POTIONS
    bcs @at_max
    inc player_items + ITEM_POTION
    rts

@at_max:
    rts
.endproc

; ============================================================================
; magic_consume - Attempt to consume magic points
; ============================================================================
; Input: A = magic cost
; Output: Carry set = success (magic consumed), carry clear = failure
; Clobbers: A
; ============================================================================

.proc magic_consume
    sta temp_0              ; save cost
    lda player_magic
    cmp temp_0
    bcc @fail               ; Not enough magic

    ; Subtract cost
    sec
    sbc temp_0
    sta player_magic

    ; Mark HUD dirty
    lda #$01
    sta hud_dirty

    sec                     ; Success
    rts

@fail:
    clc                     ; Failure
    rts
.endproc

; ============================================================================
; mark_current_screen_visited - Mark current screen in visited bitmask
; ============================================================================
; Uses current_screen_id to set the corresponding bit in visited_screens.
; Clobbers: A, X, Y
; ============================================================================

.proc mark_current_screen_visited
    lda current_screen_id

    ; byte_index = screen_id / 8
    pha
    lsr
    lsr
    lsr
    tay                     ; Y = byte index

    ; bit_index = screen_id & 7
    pla
    and #$07
    tax
    lda bit_mask_table, x   ; Get bit mask

    ; OR into visited_screens byte
    ora visited_screens, y
    sta visited_screens, y

    rts
.endproc

; ============================================================================
; Bit mask lookup table
; ============================================================================
bit_mask_table:
    .byte $01, $02, $04, $08, $10, $20, $40, $80
