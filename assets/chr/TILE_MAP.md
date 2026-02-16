# Zelda 2B - Tile Map Reference

## CHR Bank Layout

| File | Bank | Purpose | Tile Count |
|------|------|---------|------------|
| overworld_bg.chr | BG pattern table | Overworld background tiles | 32 / 256 |
| dungeon_bg.chr | BG pattern table | Dungeon background tiles | 13 / 256 |
| sprites.chr | Sprite pattern table | Player, enemies, items, effects | 34 / 256 |
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

## Sprite Tiles (sprites.chr)

| Index | Hex | Name | Description |
|-------|-----|------|-------------|
| 0 | $00 | Empty | Blank |
| 1-4 | $01-$04 | Link Down | Link facing down (TL,TR,BL,BR) |
| 5-8 | $05-$08 | Link Up | Link facing up (TL,TR,BL,BR) |
| 9-12 | $09-$0C | Link Right | Link facing right (TL,TR,BL,BR) |
| 13-14 | $0D-$0E | Link Walk | Walk animation legs (BL,BR alt) |
| 15 | $0F | Octorok | Enemy: Octorok |
| 16 | $10 | Moblin | Enemy: Moblin |
| 17 | $11 | Keese | Enemy: Bat/Keese |
| 18 | $12 | Zol | Enemy: Slime blob |
| 19 | $13 | Heart Full | Full heart |
| 20 | $14 | Heart Empty | Empty heart container |
| 21 | $15 | Magic Full | Full magic bottle |
| 22 | $16 | Magic Empty | Empty magic bottle |
| 23 | $17 | Rupee | Currency |
| 24 | $18 | Key | Dungeon key |
| 25 | $19 | Bomb | Bomb |
| 26 | $1A | Sword | Sword |
| 27 | $1B | Shield | Shield |
| 28 | $1C | Arrow | Arrow projectile |
| 29 | $1D | Feather | Roc's Feather |
| 30 | $1E | Sparkle 1 | Effect: sparkle frame 1 |
| 31 | $1F | Sparkle 2 | Effect: sparkle frame 2 |
| 32 | $20 | Explosion | Effect: explosion |
| 33 | $21 | Shadow | Sprite shadow |

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
- Link is 16x16 (4 tiles per direction per frame)
- Link facing left = Link facing right, H-flipped via OAM attribute bit
