BUILD ?= debug

ASM = nasm
# Flags based on build type
ifeq ($(BUILD),debug)
	# `make`
	# Debug: Symbols (-g) and DWARF format for GDB
	# Default config
	ASMFLAGS = -f elf64 -g -F dwarf
	LDFLAGS = 
else
	# `make BUILD=release`
	# Release: No debug info
	# (NASM doesn't optimize much, but we strip symbols for release)
	ASMFLAGS = -f elf64
	LDFLAGS = -s
endif
LD = ld

SRC_DIR = src
BUILD_DIR = bin/$(BUILD)

SRC = $(SRC_DIR)/window.asm $(SRC_DIR)/x11.asm $(SRC_DIR)/auth.asm
OBJ = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(SRC))

TARGET = $(BUILD_DIR)/window

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# linker
# $@ will expand to the output file (object or binary)
# $^ will expand to all object files to be linked
$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^


# assemble each asm -> .o in BUILD_DIR
# what we're telling make, is to create any file ending in .o in the BUILD_DIR 
# we must look for the matching asm file in the SRC_DIR
# $< will expand to the source files to be assembled
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -rf bin/
