# ============================================================================
# Zelda 2B - Makefile
# NES game targeting MMC3 mapper, built with ca65/ld65
# ============================================================================

# Tools
AS      := ca65
LD      := ld65
PYTHON  := python3
EMULATOR := fceux

# Directories
SRCDIR  := src
INCDIR  := include
CFGDIR  := config
BLDDIR  := build
ASSDIR  := assets
TSTDIR  := tests
TOOLDIR := tools

# Linker config
LDCFG   := $(CFGDIR)/mmc3.cfg

# Output
ROM     := $(BLDDIR)/zelda2b.nes
PREVIEW := $(BLDDIR)/preview.html

# Assembler flags
ASFLAGS := -I $(INCDIR) -I $(SRCDIR) -I $(SRCDIR)/audio --cpu 6502

# Source files (order matters for linking)
SOURCES := \
	$(SRCDIR)/header.s \
	$(SRCDIR)/vectors.s \
	$(SRCDIR)/ram.s \
	$(SRCDIR)/init.s \
	$(SRCDIR)/main.s \
	$(SRCDIR)/nmi.s \
	$(SRCDIR)/fixed_c.s \
	$(SRCDIR)/mmc3.s \
	$(SRCDIR)/gamepad.s \
	$(SRCDIR)/gfx/ppu.s \
	$(SRCDIR)/gfx/sprites.s \
	$(SRCDIR)/player/player.s \
	$(SRCDIR)/player/player_combat.s \
	$(SRCDIR)/enemies/enemy_common.s \
	$(SRCDIR)/enemies/enemy_types.s \
	$(SRCDIR)/items/pickups.s \
	$(SRCDIR)/map/map_vars.s \
	$(SRCDIR)/map/map_collision.s \
	$(SRCDIR)/map/map_engine.s \
	$(SRCDIR)/map/map_transition.s \
	$(SRCDIR)/data/palettes.s \
	$(SRCDIR)/data/test_screen.s \
	$(SRCDIR)/data/metatiles.s \
	$(SRCDIR)/data/map_screens.s \
	$(SRCDIR)/data/chr_data.s \
	$(SRCDIR)/audio/audio.s

# CHR data assets (binary files included by chr_data.s)
CHR_ASSETS := \
	$(ASSDIR)/chr/bg_tiles.chr \
	$(ASSDIR)/chr/sprite_tiles.chr

# Object files
OBJECTS := $(patsubst %.s,$(BLDDIR)/%.o,$(SOURCES))

# ============================================================================
# Default target: build the ROM
# ============================================================================
.PHONY: all clean run test preview

all: $(ROM)

# ============================================================================
# Link step: combine all objects into the final ROM
# ============================================================================
$(ROM): $(OBJECTS) $(LDCFG)
	@mkdir -p $(dir $@)
	$(LD) -C $(LDCFG) -o $@ $(OBJECTS)
	@echo "=== ROM built: $@ ==="
	@ls -la $@

# ============================================================================
# Assembly step: each .s file -> .o file
# ============================================================================
$(BLDDIR)/%.o: %.s $(wildcard $(INCDIR)/*.inc)
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

# CHR data assembly depends on the binary CHR assets
$(BLDDIR)/$(SRCDIR)/data/chr_data.o: $(SRCDIR)/data/chr_data.s $(CHR_ASSETS)
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

# ============================================================================
# Asset pipeline (future)
# ============================================================================
# PNG to CHR conversion (when we have real art):
# $(ASSDIR)/chr/%.chr: $(ASSDIR)/png/%.png
# 	$(PYTHON) $(TOOLDIR)/png2chr.py $< $@
#
# Map compilation (when we have a map editor):
# $(SRCDIR)/data/maps/%.s: $(ASSDIR)/maps/%.json
# 	$(PYTHON) $(TOOLDIR)/compile_map.py $< $@

# ============================================================================
# Run in emulator
# ============================================================================
run: $(ROM)
	$(EMULATOR) $(ROM) &

# ============================================================================
# Preview: generate playable HTML with embedded NES emulator
# ============================================================================
preview: $(ROM)
	@chmod +x $(TOOLDIR)/make_preview.sh
	$(TOOLDIR)/make_preview.sh $(ROM)
	@echo "=== Preview ready: $(PREVIEW) ==="

# ============================================================================
# Run tests (Mesen Lua test scripts)
# ============================================================================
test: $(ROM)
	@echo "=== Running boot test ==="
	@echo "(Requires Mesen emulator with Lua scripting support)"
	@echo "mesen --testrunner $(TSTDIR)/boot_test.lua $(ROM)"
	@echo "=== Test placeholder - install Mesen for automated testing ==="

# ============================================================================
# Clean build artifacts
# ============================================================================
clean:
	rm -rf $(BLDDIR)

# ============================================================================
# Debug: print variables
# ============================================================================
.PHONY: debug
debug:
	@echo "SOURCES: $(SOURCES)"
	@echo "OBJECTS: $(OBJECTS)"
	@echo "ROM:     $(ROM)"
