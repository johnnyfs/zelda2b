; ============================================================================
; data/dialog_data.s - NPC Dialog Text Data
; ============================================================================
; String table with dialog text for all NPCs. Strings use tile indices
; directly (not ASCII). A custom encoding maps text to CHR tile indices:
;   $40-$59 = A-Z, $5A-$63 = 0-9, $64 = ':', $00 = space
;   $FF = end of string, $FE = page break (advance to next page)
;
; Text is stored as tile indices, NOT ASCII. The dialog engine reads
; these directly and writes them to the PPU nametable.
;
; Placed in PRG_FIXED_C for always-accessible data.
; ============================================================================

.include "dialog.inc"

.segment "PRG_FIXED_C"

; ============================================================================
; Helper macros for dialog text encoding
; ============================================================================
; Maps ASCII-like text to our tile indices

.define CHAR_A   $40
.define CHAR_B   $41
.define CHAR_C   $42
.define CHAR_D   $43
.define CHAR_E   $44
.define CHAR_F   $45
.define CHAR_G   $46
.define CHAR_H   $47
.define CHAR_I   $48
.define CHAR_J   $49
.define CHAR_K   $4A
.define CHAR_L   $4B
.define CHAR_M   $4C
.define CHAR_N   $4D
.define CHAR_O   $4E
.define CHAR_P   $4F
.define CHAR_Q   $50
.define CHAR_R   $51
.define CHAR_S   $52
.define CHAR_T   $53
.define CHAR_U   $54
.define CHAR_V   $55
.define CHAR_W   $56
.define CHAR_X   $57
.define CHAR_Y   $58
.define CHAR_Z   $59
.define CHAR_0   $5A
.define CHAR_1   $5B
.define CHAR_2   $5C
.define CHAR_3   $5D
.define CHAR_4   $5E
.define CHAR_5   $5F
.define CHAR_6   $60
.define CHAR_7   $61
.define CHAR_8   $62
.define CHAR_9   $63
.define CHAR_COL $64      ; Colon ':'
.define CHAR_SPC $00      ; Space
; CHAR_END ($FF) and CHAR_PG ($FE) are defined in dialog.inc

; ============================================================================
; Dialog String Table
; ============================================================================
; Each dialog is referenced by its index (0, 1, 2, ...).
; The pointer table maps dialog_id -> string address.

.export dialog_ptrs_lo
.export dialog_ptrs_hi
.export dialog_count

dialog_count = 6

dialog_ptrs_lo:
    .byte <dialog_0, <dialog_1, <dialog_2, <dialog_3, <dialog_4, <dialog_5

dialog_ptrs_hi:
    .byte >dialog_0, >dialog_1, >dialog_2, >dialog_3, >dialog_4, >dialog_5

; ============================================================================
; Dialog 0: Town Elder (village screen)
; "WELCOME TRAVELER         THIS LAND IS IN PERIL"
; Page 2: "THE PRINCESS SLEEPS      IN THE NORTH PALACE"
; ============================================================================
dialog_0:
    ; Line 1: "WELCOME TRAVELER"
    .byte CHAR_W, CHAR_E, CHAR_L, CHAR_C, CHAR_O, CHAR_M, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_R, CHAR_A, CHAR_V, CHAR_E, CHAR_L, CHAR_E, CHAR_R
    ; Pad to 28 chars
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Line 2: "THIS LAND IS IN PERIL"
    .byte CHAR_T, CHAR_H, CHAR_I, CHAR_S
    .byte CHAR_SPC
    .byte CHAR_L, CHAR_A, CHAR_N, CHAR_D
    .byte CHAR_SPC
    .byte CHAR_I, CHAR_S
    .byte CHAR_SPC
    .byte CHAR_I, CHAR_N
    .byte CHAR_SPC
    .byte CHAR_P, CHAR_E, CHAR_R, CHAR_I, CHAR_L
    ; Pad line 2
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Page break
    .byte CHAR_PG
    ; Page 2, Line 1: "THE PRINCESS SLEEPS"
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_P, CHAR_R, CHAR_I, CHAR_N, CHAR_C, CHAR_E, CHAR_S, CHAR_S
    .byte CHAR_SPC
    .byte CHAR_S, CHAR_L, CHAR_E, CHAR_E, CHAR_P, CHAR_S
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Page 2, Line 2: "IN THE NORTH PALACE"
    .byte CHAR_I, CHAR_N
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_N, CHAR_O, CHAR_R, CHAR_T, CHAR_H
    .byte CHAR_SPC
    .byte CHAR_P, CHAR_A, CHAR_L, CHAR_A, CHAR_C, CHAR_E
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_END

; ============================================================================
; Dialog 1: Wise Woman (shop hint)
; "BOMBS ARE USEFUL         IN THE CAVES BELOW"
; ============================================================================
dialog_1:
    ; Line 1: "BOMBS ARE USEFUL"
    .byte CHAR_B, CHAR_O, CHAR_M, CHAR_B, CHAR_S
    .byte CHAR_SPC
    .byte CHAR_A, CHAR_R, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_U, CHAR_S, CHAR_E, CHAR_F, CHAR_U, CHAR_L
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Line 2: "IN THE CAVES BELOW"
    .byte CHAR_I, CHAR_N
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_C, CHAR_A, CHAR_V, CHAR_E, CHAR_S
    .byte CHAR_SPC
    .byte CHAR_B, CHAR_E, CHAR_L, CHAR_O, CHAR_W
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_END

; ============================================================================
; Dialog 2: Guard
; "BEWARE THE MONSTERS      THEY GROW STRONGER"
; Page 2: "EAST OF THE RIVER"
; ============================================================================
dialog_2:
    ; Line 1: "BEWARE THE MONSTERS"
    .byte CHAR_B, CHAR_E, CHAR_W, CHAR_A, CHAR_R, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_M, CHAR_O, CHAR_N, CHAR_S, CHAR_T, CHAR_E, CHAR_R, CHAR_S
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Line 2: "THEY GROW STRONGER"
    .byte CHAR_T, CHAR_H, CHAR_E, CHAR_Y
    .byte CHAR_SPC
    .byte CHAR_G, CHAR_R, CHAR_O, CHAR_W
    .byte CHAR_SPC
    .byte CHAR_S, CHAR_T, CHAR_R, CHAR_O, CHAR_N, CHAR_G, CHAR_E, CHAR_R
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Page break
    .byte CHAR_PG
    ; Page 2, Line 1: "EAST OF THE RIVER"
    .byte CHAR_E, CHAR_A, CHAR_S, CHAR_T
    .byte CHAR_SPC
    .byte CHAR_O, CHAR_F
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_R, CHAR_I, CHAR_V, CHAR_E, CHAR_R
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Page 2, Line 2: empty (pad 28 spaces)
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_END

; ============================================================================
; Dialog 3: Healer
; "YOU LOOK TIRED           REST HERE A WHILE"
; ============================================================================
dialog_3:
    ; Line 1: "YOU LOOK TIRED"
    .byte CHAR_Y, CHAR_O, CHAR_U
    .byte CHAR_SPC
    .byte CHAR_L, CHAR_O, CHAR_O, CHAR_K
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_I, CHAR_R, CHAR_E, CHAR_D
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC
    ; Line 2: "REST HERE A WHILE"
    .byte CHAR_R, CHAR_E, CHAR_S, CHAR_T
    .byte CHAR_SPC
    .byte CHAR_H, CHAR_E, CHAR_R, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_A
    .byte CHAR_SPC
    .byte CHAR_W, CHAR_H, CHAR_I, CHAR_L, CHAR_E
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_END

; ============================================================================
; Dialog 4: Zelda Lore NPC
; "LONG AGO THE HERO        SEALED THE DARK ONE"
; Page 2: "BUT EVIL RETURNS         FIND THE 6 PALACES"
; ============================================================================
dialog_4:
    ; Line 1: "LONG AGO THE HERO"
    .byte CHAR_L, CHAR_O, CHAR_N, CHAR_G
    .byte CHAR_SPC
    .byte CHAR_A, CHAR_G, CHAR_O
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_H, CHAR_E, CHAR_R, CHAR_O
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Line 2: "SEALED THE DARK ONE"
    .byte CHAR_S, CHAR_E, CHAR_A, CHAR_L, CHAR_E, CHAR_D
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_D, CHAR_A, CHAR_R, CHAR_K
    .byte CHAR_SPC
    .byte CHAR_O, CHAR_N, CHAR_E
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Page break
    .byte CHAR_PG
    ; Page 2, Line 1: "BUT EVIL RETURNS"
    .byte CHAR_B, CHAR_U, CHAR_T
    .byte CHAR_SPC
    .byte CHAR_E, CHAR_V, CHAR_I, CHAR_L
    .byte CHAR_SPC
    .byte CHAR_R, CHAR_E, CHAR_T, CHAR_U, CHAR_R, CHAR_N, CHAR_S
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Page 2, Line 2: "FIND THE 6 PALACES"
    .byte CHAR_F, CHAR_I, CHAR_N, CHAR_D
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_H, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_6
    .byte CHAR_SPC
    .byte CHAR_P, CHAR_A, CHAR_L, CHAR_A, CHAR_C, CHAR_E, CHAR_S
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_END

; ============================================================================
; Dialog 5: Merchant hint
; "I SELL FINE GOODS         PRESS A TO BUY"
; ============================================================================
dialog_5:
    ; Line 1: "I SELL FINE GOODS"
    .byte CHAR_I
    .byte CHAR_SPC
    .byte CHAR_S, CHAR_E, CHAR_L, CHAR_L
    .byte CHAR_SPC
    .byte CHAR_F, CHAR_I, CHAR_N, CHAR_E
    .byte CHAR_SPC
    .byte CHAR_G, CHAR_O, CHAR_O, CHAR_D, CHAR_S
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    ; Line 2: "PRESS A TO BUY"
    .byte CHAR_P, CHAR_R, CHAR_E, CHAR_S, CHAR_S
    .byte CHAR_SPC
    .byte CHAR_A
    .byte CHAR_SPC
    .byte CHAR_T, CHAR_O
    .byte CHAR_SPC
    .byte CHAR_B, CHAR_U, CHAR_Y
    ; Pad
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC, CHAR_SPC
    .byte CHAR_SPC, CHAR_SPC
    .byte CHAR_END

; ============================================================================
; NPC Spawn Tables (per-screen NPC placement)
; ============================================================================
; For each screen, define how many NPCs and their data.
; Format: count, then for each NPC: x, y, tile, dialog_id
; Screen 0 (starting area): 1 NPC - elder near center path
; Screen 4 (village): 2 NPCs - guard and healer

.export npc_screen_table_lo
.export npc_screen_table_hi

npc_screen_table_lo:
    .byte <npc_screen_0, <npc_screen_1, <npc_screen_2
    .byte <npc_screen_3, <npc_screen_4, <npc_screen_5
    .byte <npc_screen_6, <npc_screen_7

npc_screen_table_hi:
    .byte >npc_screen_0, >npc_screen_1, >npc_screen_2
    .byte >npc_screen_3, >npc_screen_4, >npc_screen_5
    .byte >npc_screen_6, >npc_screen_7

; Screen 0: 1 NPC (town elder near the crossroads)
npc_screen_0:
    .byte 1                             ; NPC count
    ; NPC 0: Elder - x=48, y=80, tile=$23, dialog_id=0
    .byte 48, 80, $23, 0

; Screen 1: 1 NPC (wise woman in the forest clearing)
npc_screen_1:
    .byte 1
    ; NPC 0: Wise Woman - x=128, y=64, tile=$23, dialog_id=1
    .byte 128, 64, $23, 1

; Screen 2: 0 NPCs (lake area)
npc_screen_2:
    .byte 0

; Screen 3: 0 NPCs (caves area)
npc_screen_3:
    .byte 0

; Screen 4: 2 NPCs (village)
npc_screen_4:
    .byte 2
    ; NPC 0: Guard - x=64, y=112, tile=$23, dialog_id=2
    .byte 64, 112, $23, 2
    ; NPC 1: Lore NPC - x=176, y=112, tile=$23, dialog_id=4
    .byte 176, 112, $23, 4

; Screen 5: 0 NPCs (southern lake)
npc_screen_5:
    .byte 0

; Screen 6: 1 NPC (cave A - healer)
npc_screen_6:
    .byte 1
    ; NPC 0: Healer - x=128, y=80, tile=$23, dialog_id=3
    .byte 128, 80, $23, 3

; Screen 7: 0 NPCs (cave B)
npc_screen_7:
    .byte 0
