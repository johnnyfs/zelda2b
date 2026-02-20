# ============================================================================
# Zelda 2B — Makefile
# NES ROM targeting MMC3 (Mapper 4), built with ca65/ld65
# ============================================================================

# Tools
AS      := ca65
LD      := ld65
PYTHON  := python3

# Directories
SRCDIR  := src
INCDIR  := include
CFGDIR  := config
BLDDIR  := build

# Linker config
LDCFG   := $(CFGDIR)/mmc3.cfg

# Output
ROM     := $(BLDDIR)/zelda2b.nes

# Assembler flags
ASFLAGS := -I $(INCDIR) --cpu 6502

# Source files (order matters for linking)
SOURCES := \
	$(SRCDIR)/header.s \
	$(SRCDIR)/vectors.s \
	$(SRCDIR)/init.s

# Object files
OBJECTS := $(patsubst %.s,$(BLDDIR)/%.o,$(SOURCES))

# ============================================================================
# Default target
# ============================================================================
.PHONY: all clean

all: $(ROM)
	@echo "=== ROM built: $(ROM) ==="
	@ls -la $(ROM)
	@echo "=== Expected: 524304 bytes (16 header + 256KB PRG + 256KB CHR) ==="

# ============================================================================
# Link
# ============================================================================
$(ROM): $(OBJECTS) $(LDCFG)
	@mkdir -p $(dir $@)
	$(LD) -C $(LDCFG) -o $@ $(OBJECTS)

# ============================================================================
# Assemble
# ============================================================================
$(BLDDIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

# ============================================================================
# Clean
# ============================================================================
clean:
	rm -rf $(BLDDIR)
