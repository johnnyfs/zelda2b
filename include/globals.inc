; ============================================================================
; globals.inc — Shared Zero-Page and RAM Declarations
; ============================================================================
; All global game state variables. Imported by modules that need them.
; Defined in src/globals.s (actual storage allocation).
; ============================================================================

; --- NMI / Frame Sync ---
.globalzp nmi_ready          ; Frame sync flag: NMI sets to 1, main loop clears
.globalzp frame_counter      ; 8-bit frame counter (wraps 0-255)
.globalzp nmi_ctrl           ; Shadow of PPUCTRL (written during NMI)
.globalzp nmi_mask           ; Shadow of PPUMASK (written during NMI)
.globalzp scroll_x           ; Horizontal scroll position
.globalzp scroll_y           ; Vertical scroll position

; --- Gamepad ---
.globalzp gamepad            ; Current frame button state
.globalzp gamepad_prev       ; Previous frame button state
.globalzp gamepad_press      ; Newly pressed this frame (gamepad AND NOT gamepad_prev)

; --- PPU Buffer ---
; The PPU buffer is a queue of (addr_hi, addr_lo, data) triples.
; Max 32 writes per frame (~96 bytes). Flushed by NMI handler.
.global ppu_buf_hi           ; PPU address high bytes (RAM)
.global ppu_buf_lo           ; PPU address low bytes (RAM)
.global ppu_buf_data         ; PPU data bytes (RAM)
.globalzp ppu_buf_len        ; Number of queued writes (0 = empty)

; --- OAM ---
.global oam_buf              ; 256-byte OAM shadow buffer at $0200
.globalzp sprite_count       ; Number of sprites written this frame (0-64)

; --- Game State ---
.globalzp game_state         ; Current game state ID
.globalzp game_state_prev    ; Previous game state (for transitions)

; --- Temp / Scratch ---
.globalzp tmp0               ; General-purpose temp
.globalzp tmp1
.globalzp tmp2
.globalzp tmp3
.globalzp ptr0               ; 16-bit pointer (lo/hi pair)
.globalzp ptr0_hi
.globalzp ptr1               ; 16-bit pointer (lo/hi pair)
.globalzp ptr1_hi

; --- MMC3 ---
.globalzp mmc3_bank_select   ; Shadow of current MMC3 bank select register
.globalzp current_prg_bank   ; Currently loaded PRG bank at $8000

; --- Game State Constants ---
GAME_STATE_TITLE    = 0
GAME_STATE_PLAY     = 1
GAME_STATE_PAUSE    = 2
GAME_STATE_GAMEOVER = 3
GAME_STATE_DIALOG   = 4
