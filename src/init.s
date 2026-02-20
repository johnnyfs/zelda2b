; ============================================================================
; init.s — Hardware Initialization + Main Entry Point
; ============================================================================
; Standard NES boot sequence:
;   1. Disable IRQ, set stack pointer
;   2. Disable PPU rendering + NMI
;   3. Wait two vblanks (PPU warmup)
;   4. Clear RAM
;   5. Set up a background color and enable rendering
;   6. Enter infinite main loop
; ============================================================================

; --- PPU registers ---
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007

; --- Palette address ---
PALETTE_ADDR = $3F00

.export reset, nmi, irq

.segment "ZEROPAGE"
nmi_ready:  .res 1          ; NMI sets this; main loop waits on it

.segment "PRG_FIXED_C"
; Placeholder — fixed bank $C000-$DFFF, will hold core engine code later
.byte $00

.segment "PRG_FIXED"

; ============================================================================
; reset — entry point after power-on / reset
; ============================================================================
.proc reset
    sei                     ; Disable IRQs
    cld                     ; Clear decimal mode (not used on NES, but safe)

    ; Disable PPU
    lda #$00
    sta PPUCTRL             ; Disable NMI
    sta PPUMASK             ; Disable rendering

    ; Set up stack
    ldx #$FF
    txs

    ; --- First vblank wait (PPU warmup) ---
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; --- Clear RAM ($0000-$07FF) ---
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

    ; --- Second vblank wait ---
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; --- Load a background color into palette ---
    ; Write to PPU palette: address $3F00 = universal BG color
    bit PPUSTATUS           ; Reset PPU address latch
    lda #>PALETTE_ADDR
    sta PPUADDR
    lda #<PALETTE_ADDR
    sta PPUADDR
    lda #$12                ; Medium blue — our "blue screen of life"
    sta PPUDATA

    ; --- Enable NMI + set BG pattern table ---
    lda #%10000000          ; NMI on vblank, BG pattern table 0
    sta PPUCTRL

    ; --- Enable rendering (BG only for now) ---
    lda #%00001000          ; Show background
    sta PPUMASK

    ; --- Fall into main loop ---
    ; (For scaffold, just spin waiting for NMI forever)
@main_loop:
    lda nmi_ready
    beq @main_loop
    lda #$00
    sta nmi_ready
    jmp @main_loop
.endproc

; ============================================================================
; nmi — NMI handler (vblank interrupt)
; ============================================================================
.proc nmi
    pha                     ; Save A
    lda #$01
    sta nmi_ready           ; Signal main loop
    pla                     ; Restore A
    rti
.endproc

; ============================================================================
; irq — IRQ handler (unused for now)
; ============================================================================
.proc irq
    rti
.endproc
