; ============================================================================
; nes.inc - NES Hardware Register Definitions
; ============================================================================
; All hardware registers for the NES PPU, APU, and I/O
; ============================================================================

.ifndef NES_INC
NES_INC = 1

; ============================================================================
; PPU Registers ($2000-$2007)
; ============================================================================

PPUCTRL     = $2000     ; PPU Control Register 1
PPUMASK     = $2001     ; PPU Control Register 2 (mask/rendering)
PPUSTATUS   = $2002     ; PPU Status Register
OAMADDR     = $2003     ; OAM Address
OAMDATA     = $2004     ; OAM Data
PPUSCROLL   = $2005     ; PPU Scroll Position
PPUADDR     = $2006     ; PPU Address
PPUDATA     = $2007     ; PPU Data

; ============================================================================
; PPUCTRL bit constants ($2000)
; ============================================================================

PPUCTRL_NAMETABLE_0     = %00000000  ; Base nametable $2000
PPUCTRL_NAMETABLE_1     = %00000001  ; Base nametable $2400
PPUCTRL_NAMETABLE_2     = %00000010  ; Base nametable $2800
PPUCTRL_NAMETABLE_3     = %00000011  ; Base nametable $2C00
PPUCTRL_INC_1           = %00000000  ; VRAM increment 1 (going across)
PPUCTRL_INC_32          = %00000100  ; VRAM increment 32 (going down)
PPUCTRL_SPR_0000        = %00000000  ; Sprite pattern table $0000
PPUCTRL_SPR_1000        = %00001000  ; Sprite pattern table $1000
PPUCTRL_BG_0000         = %00000000  ; BG pattern table $0000
PPUCTRL_BG_1000         = %00010000  ; BG pattern table $1000
PPUCTRL_SPR_8X8         = %00000000  ; 8x8 sprites
PPUCTRL_SPR_8X16        = %00100000  ; 8x16 sprites
PPUCTRL_NMI_OFF         = %00000000  ; NMI disabled
PPUCTRL_NMI_ON          = %10000000  ; NMI enabled

; ============================================================================
; PPUMASK bit constants ($2001)
; ============================================================================

PPUMASK_GREYSCALE       = %00000001  ; Greyscale mode
PPUMASK_BG_LEFT         = %00000010  ; Show BG in leftmost 8 pixels
PPUMASK_SPR_LEFT        = %00000100  ; Show sprites in leftmost 8 pixels
PPUMASK_BG_ON           = %00001000  ; Show background
PPUMASK_SPR_ON          = %00010000  ; Show sprites
PPUMASK_EMPHASIZE_R     = %00100000  ; Emphasize red
PPUMASK_EMPHASIZE_G     = %01000000  ; Emphasize green
PPUMASK_EMPHASIZE_B     = %10000000  ; Emphasize blue

; Combined rendering masks
PPUMASK_RENDER_OFF      = %00000000
PPUMASK_RENDER_ON       = PPUMASK_BG_ON | PPUMASK_SPR_ON | PPUMASK_BG_LEFT | PPUMASK_SPR_LEFT

; ============================================================================
; PPUSTATUS bit constants ($2002)
; ============================================================================

PPUSTATUS_OVERFLOW      = %00100000  ; Sprite overflow
PPUSTATUS_SPR0HIT       = %01000000  ; Sprite 0 hit
PPUSTATUS_VBLANK        = %10000000  ; Vertical blank

; ============================================================================
; OAM DMA Register
; ============================================================================

OAMDMA      = $4014     ; OAM DMA (write page address to trigger DMA)

; ============================================================================
; APU Registers ($4000-$4017)
; ============================================================================

; Pulse 1 channel
APU_PULSE1_CTRL     = $4000  ; Duty, envelope
APU_PULSE1_SWEEP    = $4001  ; Sweep unit
APU_PULSE1_TIMER_LO = $4002  ; Timer low
APU_PULSE1_TIMER_HI = $4003  ; Timer high, length counter

; Pulse 2 channel
APU_PULSE2_CTRL     = $4004  ; Duty, envelope
APU_PULSE2_SWEEP    = $4005  ; Sweep unit
APU_PULSE2_TIMER_LO = $4006  ; Timer low
APU_PULSE2_TIMER_HI = $4007  ; Timer high, length counter

; Triangle channel
APU_TRI_CTRL        = $4008  ; Linear counter
APU_TRI_TIMER_LO    = $400A  ; Timer low
APU_TRI_TIMER_HI    = $400B  ; Timer high, length counter

; Noise channel
APU_NOISE_CTRL      = $400C  ; Envelope
APU_NOISE_PERIOD    = $400E  ; Period, mode
APU_NOISE_LENGTH    = $400F  ; Length counter

; DMC channel
APU_DMC_CTRL        = $4010  ; Flags, rate
APU_DMC_DIRECT      = $4011  ; Direct load
APU_DMC_ADDR        = $4012  ; Sample address
APU_DMC_LENGTH      = $4013  ; Sample length

; APU control
APU_STATUS          = $4015  ; Channel enable, status
APU_FRAME_COUNTER   = $4017  ; Frame counter mode

; ============================================================================
; Controller Registers
; ============================================================================

JOYPAD1     = $4016     ; Controller 1 (read/write)
JOYPAD2     = $4017     ; Controller 2 (read only)

; ============================================================================
; Controller Button Bit Constants
; ============================================================================

BUTTON_A        = %10000000
BUTTON_B        = %01000000
BUTTON_SELECT   = %00100000
BUTTON_START    = %00010000
BUTTON_UP       = %00001000
BUTTON_DOWN     = %00000100
BUTTON_LEFT     = %00000010
BUTTON_RIGHT    = %00000001

; ============================================================================
; PPU Address Constants
; ============================================================================

PPU_NAMETABLE_0     = $2000
PPU_NAMETABLE_1     = $2400
PPU_NAMETABLE_2     = $2800
PPU_NAMETABLE_3     = $2C00
PPU_ATTR_TABLE_0    = $23C0
PPU_ATTR_TABLE_1    = $27C0
PPU_ATTR_TABLE_2    = $2BC0
PPU_ATTR_TABLE_3    = $2FC0
PPU_PALETTES        = $3F00
PPU_BG_PALETTE_0    = $3F00
PPU_BG_PALETTE_1    = $3F04
PPU_BG_PALETTE_2    = $3F08
PPU_BG_PALETTE_3    = $3F0C
PPU_SPR_PALETTE_0   = $3F10
PPU_SPR_PALETTE_1   = $3F14
PPU_SPR_PALETTE_2   = $3F18
PPU_SPR_PALETTE_3   = $3F1C

; ============================================================================
; OAM Sprite attribute bits
; ============================================================================

OAM_PALETTE_0       = %00000000
OAM_PALETTE_1       = %00000001
OAM_PALETTE_2       = %00000010
OAM_PALETTE_3       = %00000011
OAM_BEHIND_BG       = %00100000
OAM_FLIP_H          = %01000000
OAM_FLIP_V          = %10000000

.endif ; NES_INC
