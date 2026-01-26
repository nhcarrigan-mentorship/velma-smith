ASM = nasm
ASMFLAGS = -f elf64 -g -F dwarf
LD = ld
LDFLAGS =

SRC_DIR = src
BUILD_DIR = bin

SRC = $(SRC_DIR)/window.asm $(SRC_DIR)/x11.asm
OBJ = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(SRC))

TARGET = $(BUILD_DIR)/window

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# linker

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^


# assemble each asm -> .o in BUILD_DIR

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJ) $(TARGET)
