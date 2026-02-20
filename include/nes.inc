; ============================================================================
; nes.inc — NES Hardware Register Constants
; ============================================================================
; Standard NES memory-mapped I/O addresses.
; Include this file in any source that touches hardware.
; ============================================================================

; --- PPU Registers ---
PPUCTRL     = $2000     ; PPU control (write)
PPUMASK     = $2001     ; PPU mask (write)
PPUSTATUS   = $2002     ; PPU status (read)
OAMADDR     = $2003     ; OAM address (write)
OAMDATA     = $2004     ; OAM data (read/write)
PPUSCROLL   = $2005     ; PPU scroll (write x2)
PPUADDR     = $2006     ; PPU address (write x2)
PPUDATA     = $2007     ; PPU data (read/write)

; --- OAM DMA ---
OAMDMA      = $4014     ; OAM DMA register (write)

; --- APU Registers ---
SQ1_VOL     = $4000
SQ1_SWEEP   = $4001
SQ1_LO      = $4002
SQ1_HI      = $4003
SQ2_VOL     = $4004
SQ2_SWEEP   = $4005
SQ2_LO      = $4006
SQ2_HI      = $4007
TRI_LINEAR  = $4008
TRI_LO      = $400A
TRI_HI      = $400B
NOISE_VOL   = $400C
NOISE_LO    = $400E
NOISE_HI    = $400F
DMC_FREQ    = $4010
DMC_RAW     = $4011
DMC_START   = $4012
DMC_LEN     = $4013
SND_CHN     = $4015     ; APU status / channel enable
FRAME_CNT   = $4017     ; APU frame counter

; --- Controller ---
JOY1        = $4016     ; Controller 1 (read/write)
JOY2        = $4017     ; Controller 2 (read)

; --- Joypad Button Masks ---
BUTTON_A        = %10000000
BUTTON_B        = %01000000
BUTTON_SELECT   = %00100000
BUTTON_START    = %00010000
BUTTON_UP       = %00001000
BUTTON_DOWN     = %00000100
BUTTON_LEFT     = %00000010
BUTTON_RIGHT    = %00000001

; --- PPU Control Flags ---
PPUCTRL_NMI         = %10000000     ; Enable NMI on vblank
PPUCTRL_SPRITE_SIZE = %00100000     ; 0=8x8, 1=8x16
PPUCTRL_BG_TABLE    = %00010000     ; BG pattern table (0=$0000, 1=$1000)
PPUCTRL_SPR_TABLE   = %00001000     ; Sprite pattern table (0=$0000, 1=$1000)
PPUCTRL_VRAM_INC    = %00000100     ; VRAM addr inc (0=+1 across, 1=+32 down)
PPUCTRL_NAMETABLE   = %00000011     ; Base nametable (0-3)

; --- PPU Mask Flags ---
PPUMASK_BLUE        = %10000000     ; Emphasize blue
PPUMASK_GREEN       = %01000000     ; Emphasize green
PPUMASK_RED         = %00100000     ; Emphasize red
PPUMASK_SHOW_SPR    = %00010000     ; Show sprites
PPUMASK_SHOW_BG     = %00001000     ; Show background
PPUMASK_SHOW_SPR_L  = %00000100     ; Show sprites in leftmost 8px
PPUMASK_SHOW_BG_L   = %00000010     ; Show BG in leftmost 8px

; --- PPU Address Constants ---
NAMETABLE_0     = $2000
NAMETABLE_1     = $2400
NAMETABLE_2     = $2800
NAMETABLE_3     = $2C00
ATTR_TABLE_0    = $23C0
ATTR_TABLE_1    = $27C0
PALETTE_ADDR    = $3F00
PALETTE_SPR     = $3F10

; --- OAM Shadow Address ---
OAM_BUF         = $0200     ; 256 bytes of shadow OAM in RAM page 2

; --- Sprite attribute bits ---
SPR_FLIP_V      = %10000000
SPR_FLIP_H      = %01000000
SPR_PRIORITY    = %00100000     ; 0=in front of BG, 1=behind BG
SPR_PALETTE     = %00000011     ; Sprite palette (0-3)
