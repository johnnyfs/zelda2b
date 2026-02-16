; ============================================================================
; data/chr_data.s - CHR ROM Data
; ============================================================================
; Includes binary CHR tile data into the appropriate CHR ROM bank segments.
; The MMC3 uses 1KB CHR banks, so each 4KB CHR file fills 4 consecutive
; 1KB bank segments, and each 8KB fills 8.
;
; Layout (initial):
;   CHR banks 0-3 ($0000-$0FFF): BG tiles (4KB)
;   CHR banks 4-7 ($1000-$1FFF): placeholder (to be replaced by sprite tiles)
;   CHR banks 8-11: Sprite tiles (4KB)
;   Remaining banks: filled by linker (fill = yes means zero-filled)
; ============================================================================

; --- BG Tiles: banks 0-3 (4KB = 4 x 1KB) ---
; bg_tiles.chr is 4096 bytes = 4 x 1KB banks

.segment "CHR_BANK_000"
    .incbin "../../assets/chr/bg_tiles.chr", $0000, $0400

.segment "CHR_BANK_001"
    .incbin "../../assets/chr/bg_tiles.chr", $0400, $0400

.segment "CHR_BANK_002"
    .incbin "../../assets/chr/bg_tiles.chr", $0800, $0400

.segment "CHR_BANK_003"
    .incbin "../../assets/chr/bg_tiles.chr", $0C00, $0400

; --- Sprite Tiles: banks 4-7 (4KB = 4 x 1KB) ---
; sprite_tiles.chr is 4096 bytes = 4 x 1KB banks
; These map to PPU $1000-$1FFF when CHR 1K banks 4-7 are selected

.segment "CHR_BANK_004"
    .incbin "../../assets/chr/sprite_tiles.chr", $0000, $0400

.segment "CHR_BANK_005"
    .incbin "../../assets/chr/sprite_tiles.chr", $0400, $0400

.segment "CHR_BANK_006"
    .incbin "../../assets/chr/sprite_tiles.chr", $0800, $0400

.segment "CHR_BANK_007"
    .incbin "../../assets/chr/sprite_tiles.chr", $0C00, $0400

; --- Additional sprite tile copies in banks 8-11 ---
; MMC3 CHR 1K registers select from the full CHR ROM, so we put
; sprite data in banks 8-11 as well (init_mmc3 maps these to $1000-$1FFF)

.segment "CHR_BANK_008"
    .incbin "../../assets/chr/sprite_tiles.chr", $0000, $0400

.segment "CHR_BANK_009"
    .incbin "../../assets/chr/sprite_tiles.chr", $0400, $0400

.segment "CHR_BANK_010"
    .incbin "../../assets/chr/sprite_tiles.chr", $0800, $0400

.segment "CHR_BANK_011"
    .incbin "../../assets/chr/sprite_tiles.chr", $0C00, $0400

; Remaining CHR banks (012-255) are left empty (zero-filled by linker).
; They will be populated as more tilesets are created.
