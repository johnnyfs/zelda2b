; ==========================================================
; Sound Effect Data — Zelda 2B
; 16 SFX for gameplay actions
; Format: channel_ctrl, freq_lo, freq_hi, duration_frames
; End marker: $FF
; ==========================================================

.segment "PRG_FIXED_C"

; ==========================================================
; 1. Sword Swing — Quick downward sweep (pulse channel)
; ==========================================================
.export sfx_sword_swing
sfx_sword_swing:
    .byte $8F, $80, $03, $02  ; High pitch, full volume
    .byte $8D, $C0, $02, $02  ; Sweep down
    .byte $8A, $00, $02, $02  ; Continue sweep
    .byte $87, $40, $01, $02  ; Fade out
    .byte $FF

; ==========================================================
; 2. Sword Hit — Impact sound (noise + pulse)
; ==========================================================
.export sfx_sword_hit
sfx_sword_hit:
    .byte $8E, $A0, $02, $02  ; Pulse: sharp attack
    .byte $3F, $05, $00, $02  ; Noise: short burst (mode 0, period 5)
    .byte $8A, $C0, $02, $02  ; Pulse: decay
    .byte $36, $06, $00, $02  ; Noise: tail
    .byte $85, $E0, $01, $02  ; Final fade
    .byte $FF

; ==========================================================
; 3. Enemy Hit — Similar to sword hit, different pitch
; ==========================================================
.export sfx_enemy_hit
sfx_enemy_hit:
    .byte $8D, $60, $02, $02  ; Pulse: mid-high attack
    .byte $3E, $07, $00, $02  ; Noise: medium burst
    .byte $89, $A0, $02, $02  ; Pulse: decay
    .byte $35, $08, $00, $02  ; Noise: fade
    .byte $84, $C0, $01, $02  ; Final fade
    .byte $FF

; ==========================================================
; 4. Enemy Die — Descending tone with noise
; ==========================================================
.export sfx_enemy_die
sfx_enemy_die:
    .byte $8E, $40, $03, $03  ; High pitch start
    .byte $8D, $80, $02, $02  ; Descend
    .byte $8B, $C0, $02, $02  ; Continue down
    .byte $89, $00, $01, $02  ; Lower
    .byte $3C, $06, $00, $03  ; Noise burst
    .byte $86, $40, $01, $02  ; Pulse fade
    .byte $38, $08, $00, $02  ; Noise fade
    .byte $83, $80, $01, $02  ; Final fade
    .byte $FF

; ==========================================================
; 5. Player Hurt — Low buzz with noise
; ==========================================================
.export sfx_player_hurt
sfx_player_hurt:
    .byte $8C, $00, $01, $03  ; Low buzz attack
    .byte $3D, $04, $00, $02  ; Noise impact
    .byte $8A, $20, $01, $02  ; Buzz continue
    .byte $39, $05, $00, $02  ; Noise fade
    .byte $87, $40, $01, $02  ; Buzz fade
    .byte $35, $07, $00, $02  ; Final noise
    .byte $84, $60, $01, $02  ; Final fade
    .byte $FF

; ==========================================================
; 6. Player Die — Long descending cascade
; ==========================================================
.export sfx_player_die
sfx_player_die:
    .byte $8F, $00, $04, $04  ; Very high start
    .byte $8E, $80, $03, $03  ; Descend
    .byte $8D, $00, $03, $03  ; Continue
    .byte $8C, $80, $02, $03  ; Lower
    .byte $8B, $00, $02, $03  ; Keep going
    .byte $8A, $80, $01, $03  ; Deeper
    .byte $89, $00, $01, $03  ; Almost done
    .byte $87, $80, $00, $03  ; Very low
    .byte $85, $00, $00, $03  ; Final fade
    .byte $82, $80, $00, $03  ; Silence
    .byte $FF

; ==========================================================
; 7. Item Pickup — Rising 3-note arpeggio
; ==========================================================
.export sfx_item_pickup
sfx_item_pickup:
    .byte $8E, $D0, $01, $04  ; Note 1 (mid)
    .byte $8E, $A8, $02, $04  ; Note 2 (higher)
    .byte $8E, $54, $03, $04  ; Note 3 (highest)
    .byte $8C, $54, $03, $03  ; Sustain with decay
    .byte $89, $54, $03, $02  ; Fade
    .byte $85, $54, $03, $02  ; Final fade
    .byte $FF

; ==========================================================
; 8. Heart Pickup — Quick happy blip
; ==========================================================
.export sfx_heart_pickup
sfx_heart_pickup:
    .byte $8F, $A8, $02, $03  ; Bright high note
    .byte $8D, $A8, $02, $02  ; Slight decay
    .byte $89, $A8, $02, $02  ; Fade
    .byte $FF

; ==========================================================
; 9. Rupee Pickup — Two-tone chime
; ==========================================================
.export sfx_rupee_pickup
sfx_rupee_pickup:
    .byte $8E, $E8, $01, $03  ; First tone (mid)
    .byte $8E, $A8, $02, $03  ; Second tone (higher)
    .byte $8B, $A8, $02, $02  ; Decay
    .byte $87, $A8, $02, $02  ; Fade
    .byte $FF

; ==========================================================
; 10. Menu Cursor — Short click/blip
; ==========================================================
.export sfx_menu_cursor
sfx_menu_cursor:
    .byte $8C, $C0, $02, $02  ; Sharp short blip
    .byte $88, $C0, $02, $01  ; Quick fade
    .byte $FF

; ==========================================================
; 11. Menu Select — Confirming tone
; ==========================================================
.export sfx_menu_select
sfx_menu_select:
    .byte $8E, $54, $03, $03  ; High confirming tone
    .byte $8C, $54, $03, $02  ; Slight decay
    .byte $89, $54, $03, $02  ; Fade out
    .byte $FF

; ==========================================================
; 12. Door Open — Low rumble (noise + triangle)
; ==========================================================
.export sfx_door_open
sfx_door_open:
    .byte $3D, $02, $00, $03  ; Noise: low rumble start
    .byte $81, $00, $01, $03  ; Triangle: bass support
    .byte $3B, $03, $00, $02  ; Noise: continue
    .byte $81, $20, $01, $02  ; Triangle: slight variation
    .byte $38, $04, $00, $02  ; Noise: fade
    .byte $81, $40, $01, $02  ; Triangle: fade
    .byte $35, $06, $00, $02  ; Final noise fade
    .byte $FF

; ==========================================================
; 13. Bomb Explode — Noise burst + low triangle
; ==========================================================
.export sfx_bomb_explode
sfx_bomb_explode:
    .byte $3F, $01, $00, $04  ; Noise: massive burst
    .byte $81, $00, $00, $03  ; Triangle: deep bass
    .byte $3E, $02, $00, $03  ; Noise: continue
    .byte $81, $40, $00, $02  ; Triangle: rumble
    .byte $3C, $03, $00, $02  ; Noise: decay
    .byte $81, $80, $00, $02  ; Triangle: fade
    .byte $39, $04, $00, $02  ; Noise: more decay
    .byte $81, $C0, $00, $02  ; Triangle: fade more
    .byte $35, $06, $00, $02  ; Noise: final fade
    .byte $FF

; ==========================================================
; 14. Spell Cast — Rising shimmer (pulse sweep up)
; ==========================================================
.export sfx_spell_cast
sfx_spell_cast:
    .byte $8A, $00, $01, $02  ; Start low
    .byte $8B, $80, $01, $02  ; Rise
    .byte $8C, $00, $02, $02  ; Keep rising
    .byte $8D, $80, $02, $02  ; Higher
    .byte $8E, $00, $03, $02  ; Peak
    .byte $8C, $00, $03, $02  ; Shimmer down
    .byte $89, $00, $03, $02  ; Fade
    .byte $85, $00, $03, $02  ; Final fade
    .byte $FF

; ==========================================================
; 15. Text Blip — Tiny tick for typewriter effect
; ==========================================================
.export sfx_text_blip
sfx_text_blip:
    .byte $88, $E0, $02, $01  ; Very short blip
    .byte $FF

; ==========================================================
; 16. Fanfare — Victory jingle (short melody)
; ==========================================================
.export sfx_fanfare
sfx_fanfare:
    .byte $8F, $FE, $01, $05  ; Note 1
    .byte $8F, $FE, $01, $05  ; Repeat for emphasis
    .byte $8F, $FE, $01, $05  ; Third time
    .byte $8F, $A8, $02, $06  ; Higher note, longer
    .byte $8E, $A8, $02, $03  ; Slight decay
    .byte $8C, $D0, $01, $05  ; Lower note
    .byte $8F, $54, $03, $08  ; High triumphant note
    .byte $8D, $54, $03, $04  ; Sustain with decay
    .byte $8A, $54, $03, $03  ; Fade
    .byte $87, $54, $03, $03  ; Final fade
    .byte $FF
