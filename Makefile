# --------------------------------------------------------------------------------
# CONTEXT: MSP430 CI/CD SETUP
# This Makefile uses conditional logic to switch toolchain paths
# based on the execution environment (Local Host vs. GitHub Actions/Docker).
# --------------------------------------------------------------------------------

# --- CONDITIONAL PATHS & TOOLCHAIN DEFINITION ---
# GITHUB_ACTIONS is automatically set to 'true' in the cloud environment.
MSPGCC_ROOT_DIR := /home/qwerty/Downloads/msp430-gcc-9.3.1.11_linux64
CONTAINER_BIN_DIR := /home/ubuntu/dev/tools/msp430-gcc/msp430-gcc-9.3.1.11_linux64/bin

# 1. Select the Compiler Path based on environment
ifeq ($(GITHUB_ACTIONS),true)
# CI/Docker: Use the path inside the container
CC = $(CONTAINER_BIN_DIR)/msp430-elf-gcc
else
# Local Host: Use the local absolute path
CC = $(MSPGCC_ROOT_DIR)/bin/msp430-elf-gcc
endif

# 2. Define the main compiler and system paths (These are constant for the file)
MSPGCC_BIN_DIR = $(MSPGCC_ROOT_DIR)/bin
MSPGCC_INCLUDE_DIR = /home/qwerty/Downloads/ccs2031/ccs/ccs_base/msp430/include_gcc
CONTAINER_INCLUDE_DIR := /home/ubuntu/dev/tools/msp430-gcc/msp430-gcc-9.3.1.11_linux64/include

# If running in the cloud (CI), use the container's path.
ifeq ($(GITHUB_ACTIONS),true)
INCLUDE_DIRS := $(CONTAINER_INCLUDE_DIR)
LIB_DIRS := $(CONTAINER_INCLUDE_DIR)
else
# If running locally (Host), use the local CCS path.
INCLUDE_DIRS := $(MSPGCC_INCLUDE_DIR)
LIB_DIRS := $(MSPGCC_INCLUDE_DIR)
endif
TI_CSS_DIR = /home/qwerty/Downloads/ccs2031/ccs
DEBUG_DRIVERS_DIR = $(TI_CSS_DIR)/ccs_base/DebugServer/drivers

# --------------------------------------------------------------------------------
# FILES AND DIRECTORIES (Standard)
# --------------------------------------------------------------------------------
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = $(BUILD_DIR)/bin

RM = rm
DEBUG = LD_LIBRARY_PATH=$(DEBUG_DRIVERS_DIR) $(DEBUG_BIN_DIR)/mspdebug

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

# --------------------------------------------------------------------------------
# BUILD RULES (Core Logic)
# --------------------------------------------------------------------------------

## Linking
$(TARGET): $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CC) $(LDFLAGS) $^ -o $@

## Compiling
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $^

# --------------------------------------------------------------------------------
# PHONY TARGETS (Utility Commands)
# --------------------------------------------------------------------------------

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
