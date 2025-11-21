#blink 3: main.c led.c
# msp430-elf-gcc -I /home/qwerty/Downloads/ccs2031/ccs/ccs_base/msp430/include_gcc -mmcu=msp430g2553 -L /home/qwerty/Downloads/ccs2031/ccs/ccs_base/msp430/include_gcc -Og -g -Wall led.c main.c -o blink2

#Directories:
TOOLS_DIR = ${TOOLS_PATH}
MSPGCC_ROOT_DIR = $(TOOLS_DIR)/msp430-gcc
MSPGCC_BIN_DIR = $(MSPGCC_ROOT_DIR)/bin
MSPGCC_INCLUDE_DIR = $(MSPGCC_ROOT_DIR)/include_gcc
INCLUDE_DIRS = $(MSPGCC_INCLUDE_DIR)
LIB_DIRS = $(MSPGCC_INCLUDE_DIR)
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin
TI_CSS_DIR = /home/qwerty/Downloads/ccs2031/ccs
DEBUG_BIN_DIR = $(TI_CSS_DIR)/ccs_base/DebugServer/bin
DEBUG_DRIVERS_DIR = $(TI_CSS_DIR)/ccs_base/DebugServer/drivers

#Toolchain:
CC = $(MSPGCC_BIN_DIR)/msp430-elf-gcc
RM = rm
DEBUG = LD_LIBRARY_PATH=$(DEBUG_DRIVERS_DIR) $(DEBUG_BIN_DIR)/mspdebug

CPPCHECK = cppcheck

#Files:
TARGET = $(BIN_DIR)/blink4
SOURCES = main.c \
led.c
OBJECT_NAMES = $(SOURCES:.c=.o)
OBJECTS = $(patsubst %,$(OBJ_DIR)/%,$(OBJECT_NAMES))

# Flags
MCU = msp430g2553
WFLAGS = -Wall -Wextra -Werror -Wshadow
CFLAGS = -mmcu=$(MCU) $(WFLAGS) $(addprefix -I,$(INCLUDE_DIRS)) -Og -g
LDFLAGS = -mmcu=$(MCU) $(addprefix -L,$(LIB_DIRS))

# Build
## Linking
$(TARGET): $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CC) $(LDFLAGS) $^ -o $@

## Compiling
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $^

# Phonies
.PHONY: all clean flash cppcheck

all: $(TARGET)

clean:
	$(RM) -r $(BUILD_DIR)

flash: $(TARGET)
	$(DEBUG) tilib "prog $(TARGET)"

cppcheck:
	@$(CPPCHECK) --quiet --enable=all --error-exitcode=1 \
                --inline-suppr \
        $(addprefix -I,$(INCLUDE_DIRS)) \
        $(SOURCES) \
        -i external/printf
