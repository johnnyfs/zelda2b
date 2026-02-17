# Zelda 2B - Tile Map Reference

## CHR Bank Layout

| File | Bank | Purpose | Tile Count |
|------|------|---------|------------|
| overworld_bg.chr | BG pattern table | Overworld background tiles | 32 / 256 |
| dungeon_bg.chr | BG pattern table | Dungeon background tiles | 13 / 256 |
| sprite_tiles.chr | Sprite pattern table | Player, enemies, items, effects | 47 / 256 |
| hud.chr | BG/Sprite | HUD elements | 13 / 256 |

## Overworld Background Tiles (overworld_bg.chr)

| Index | Hex | Name | Description |
|-------|-----|------|-------------|
| 0 | $00 | Empty | Blank tile |
| 1 | $01 | Grass | Basic grass ground |
| 2 | $02 | Grass 2 | Grass variant |
| 3 | $03 | Path | Dirt/path |
| 4 | $04 | Path Edge T | Path edge (top) |
| 5 | $05 | Water | Still water |
| 6 | $06 | Water 2 | Water animation frame 2 |
| 7 | $07 | Sand | Beach sand |
| 8 | $08 | Tree TL | Tree canopy top-left (16x16 metatile) |
| 9 | $09 | Tree TR | Tree canopy top-right |
| 10 | $0A | Tree BL | Tree trunk bottom-left |
| 11 | $0B | Tree BR | Tree trunk bottom-right |
| 12 | $0C | Bush | Small bush |
| 13 | $0D | Rock TL | Boulder top-left (16x16 metatile) |
| 14 | $0E | Rock TR | Boulder top-right |
| 15 | $0F | Flower | Decorative flower |
| 16 | $10 | House Wall | Brick wall pattern |
| 17 | $11 | House Roof | Roof tiles |
| 18 | $12 | Door | Door entrance |
| 19 | $13 | Window | Window |
| 20 | $14 | Cave Top | Cave entrance |
| 21 | $15 | Fence H | Horizontal fence |
| 22 | $16 | Fence V | Vertical fence |
| 23 | $17 | Stairs | Stairway |
| 24 | $18 | Cliff | Cliff edge |
| 25 | $19 | Bridge H | Horizontal bridge |
| 26 | $1A | Sign | Signpost |
| 27 | $1B | Chest | Treasure chest |
| 28 | $1C | Pot | Pot/jar |
| 29 | $1D | Tall Grass | Cuttable grass |
| 30 | $1E | Tombstone | Graveyard tombstone |
| 31 | $1F | Ladder | Ladder |

## Dungeon Background Tiles (dungeon_bg.chr)

| Index | Hex | Name | Description |
|-------|-----|------|-------------|
| 0 | $00 | Empty | Blank |
| 1 | $01 | Floor | Dungeon floor |
| 2 | $02 | Wall | Dungeon wall (center) |
| 3 | $03 | Wall Top | Wall top edge |
| 4 | $04 | Door | Dungeon door opening |
| 5 | $05 | Key Block | Locked block |
| 6 | $06 | Cracked Wall | Bombable wall |
| 7 | $07 | Torch | Wall torch |
| 8 | $08 | Pit | Floor pit/hole |
| 9 | $09 | Block | Pushable block |
| 10 | $0A | Switch | Floor switch |
| 11 | $0B | Spikes | Spike trap |
| 12 | $0C | Chest | Dungeon chest |

## Sprite Tiles (sprite_tiles.chr)

Source: link_sprites.chr (LA DX ripped, tiles 0-33) + sword tiles at $2D-$2E.
ROM includes this file via chr_data.s into CHR banks 4-7 and 8-11.
init_mmc3 maps CHR 1K banks 8-11 to PPU $1000-$1FFF (PPUCTRL_SPR_1000).

### Link Walk Sprites (16x16 metatiles, 4 tiles each: TL, TR, BL, BR)

| Index | Hex | Name | Description |
|-------|-----|------|-------------|
| 0-3 | $00-$03 | walk_down_1 | Link facing down, walk frame 1 |
| 4-7 | $04-$07 | walk_down_2 | Link facing down, walk frame 2 |
| 8-11 | $08-$0B | walk_up_1 | Link facing up, walk frame 1 |
| 12-15 | $0C-$0F | walk_up_2 | Link facing up, walk frame 2 |
| 16-19 | $10-$13 | walk_left_1 | Link facing left, walk frame 1 |
| 20-23 | $14-$17 | walk_left_2 | Link facing left, walk frame 2 |
| 24-27 | $18-$1B | walk_right_1 | Link facing right, walk frame 1 |
| 28-31 | $1C-$1F | walk_right_2 | Link facing right, walk frame 2 |

### Equipment & Effect Sprites

| Index | Hex | Name | Description |
|-------|-----|------|-------------|
| 32 | $20 | shield_front | Shield (front-facing) |
| 33 | $21 | shield_left | Shield (side-facing) |
| 34-44 | $22-$2C | (empty) | Reserved / unused |
| 45 | $2D | sword_vert | Sword blade (vertical) |
| 46 | $2E | sword_horiz | Sword blade (horizontal) |
| 47-255 | $2F-$FF | (empty) | Reserved for enemies, items, effects |

### Sprite Tile Table (player.s) Cross-Reference

Code indexes into sprite_tile_table as: `(player_dir * 2) + player_anim_frame`
Enums: DIR_UP=0, DIR_DOWN=1, DIR_LEFT=2, DIR_RIGHT=3

| Direction | Frame 0 | Frame 1 | Base Tile |
|-----------|---------|---------|-----------|
| UP | walk_up_1 | walk_up_2 | $08, $0C |
| DOWN | walk_down_1 | walk_down_2 | $00, $04 |
| LEFT | walk_left_1 | walk_left_2 | $10, $14 |
| RIGHT | walk_right_1 | walk_right_2 | $18, $1C |

Sword tiles: SWORD_TILE_VERT=$2D, SWORD_TILE_HORIZ=$2E (combat.inc)

## HUD Tiles (hud.chr)

| Index | Hex | Name | Description |
|-------|-----|------|-------------|
| 0 | $00 | Empty | Blank |
| 1 | $01 | Button A | A button indicator |
| 2 | $02 | Button B | B button indicator |
| 3 | $03 | Box TL | Item box frame top-left |
| 4 | $04 | Box TR | Item box frame top-right |
| 5 | $05 | Box BL | Item box frame bottom-left |
| 6 | $06 | Box BR | Item box frame bottom-right |
| 7 | $07 | Map Dot | Minimap cursor |
| 8 | $08 | Arrow R | Right arrow indicator |
| 9 | $09 | Heart Full | HUD heart (full) |
| 10 | $0A | Heart Empty | HUD heart (empty) |
| 11 | $0B | Magic Full | HUD magic bottle (full) |
| 12 | $0C | Magic Empty | HUD magic bottle (empty) |

## Color Index Convention

- **0**: Background/transparent
- **1**: Darkest shade (outlines, shadows)
- **2**: Medium shade (main color)
- **3**: Lightest shade (highlights)

## Metatile Notes

- Trees are 16x16 (4 tiles: TL=$08, TR=$09, BL=$0A, BR=$0B)
- Rocks are 16x16 (2 tiles: TL=$0D, TR=$0E)
- Link is 16x16 (4 tiles per direction per frame, 8 walk frames total)
- Link has separate tiles for all 4 directions (no H-flip sharing)
- Sword uses 2 tiles: vertical ($2D) and horizontal ($2E), flipped via OAM attributes
