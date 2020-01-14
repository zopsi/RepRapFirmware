#
#  Copyright (c) 2012 Arduino.  All right reserved.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

# Makefile for compiling libArduino
.SUFFIXES: .o .a .c .s

CHIP=__SAM4E8E__
VARIANT=Duet2CombinedFirmware
BINNAME=Duet2CombinedFirmware
TOOLCHAIN=gcc

#-------------------------------------------------------------------------------
# Path
#-------------------------------------------------------------------------------

# Output directories
OUTPUT_BIN = ../../../Duet2_RTOS

# Libraries
PROJECT_BASE_PATH = ../../..
WORKSPACE_BASE_PATH = ../../../..
CORENG_PATH = $(WORKSPACE_BASE_PATH)/CoreNG
FREERTOS_PATH = $(WORKSPACE_BASE_PATH)/FreeRTOS
RRFLIBRARIES_PATH = $(WORKSPACE_BASE_PATH)/RRFLibraries

VARIANT_BASE_PATH = $(PROJECT_BASE_PATH)/variants
VARIANT_PATH = $(VARIANT_BASE_PATH)/$(VARIANT)

#-------------------------------------------------------------------------------
# Files
#-------------------------------------------------------------------------------

#vpath %.h $(PROJECT_BASE_PATH) $(SYSTEM_PATH) $(VARIANT_PATH)

#VPATH+=$(PROJECT_BASE_PATH)

INCLUDES =
INCLUDES += -I$(CORENG_PATH)/cores/arduino
INCLUDES += -I$(CORENG_PATH)/libraries/Storage
INCLUDES += -I$(CORENG_PATH)/asf
INCLUDES += -I$(CORENG_PATH)/asf/common/utils
INCLUDES += -I$(CORENG_PATH)/asf/common/services/ioport
INCLUDES += -I$(CORENG_PATH)/asf/sam/drivers
INCLUDES += -I$(CORENG_PATH)/asf/sam/utils
INCLUDES += -I$(CORENG_PATH)/asf/sam/utils/cmsis/sam4e/include
INCLUDES += -I$(CORENG_PATH)/asf/sam/utils/header_files
INCLUDES += -I$(CORENG_PATH)/asf/sam/utils/preprocessor
INCLUDES += -I$(CORENG_PATH)/asf/thirdparty/CMSIS/Include
INCLUDES += -I$(CORENG_PATH)/variants/duetNG


#INCLUDES += -I$(WORKSPACE_BASE_PATH)/RRFLibraries/src/Math
#INCLUDES += -I$(WORKSPACE_BASE_PATH)/RRFLibraries/src/RTOSIface


#INCLUDES += -I$(ARM_GCC_TOOLCHAIN)/../include/c++/9.2.1

CINCLUDES += $(INCLUDES)
CINCLUDES += -I$(WORKSPACE_BASE_PATH)/RRFLibraries
CINCLUDES += -I$(WORKSPACE_BASE_PATH)/FreeRTOS
CINCLUDES += -I$(WORKSPACE_BASE_PATH)/CoreNG

CPPINCLUDES += $(INCLUDES)
CPPINCLUDES += -I$(CORENG_PATH)/libraries/Flash
CPPINCLUDES += -I$(CORENG_PATH)/libraries/SharedSpi
CPPINCLUDES += -I$(CORENG_PATH)/libraries/Wire
CPPINCLUDES += -I$(CORENG_PATH)/asf/common/services/clock
CPPINCLUDES += -I$(CORENG_PATH)/asf/sam/services/flash_efc
CPPINCLUDES += -I$(PROJECT_BASE_PATH)/src
CPPINCLUDES += -I$(PROJECT_BASE_PATH)/src/DuetNG
CPPINCLUDES += -I$(PROJECT_BASE_PATH)/src/Networking
CPPINCLUDES += -I$(WORKSPACE_BASE_PATH)/RRFLibraries/src
CPPINCLUDES += -I$(WORKSPACE_BASE_PATH)/FreeRTOS/src/include
CPPINCLUDES += -I$(WORKSPACE_BASE_PATH)/FreeRTOS/src/portable/GCC/ARM_CM4F
CPPINCLUDES += -I$(WORKSPACE_BASE_PATH)/DuetWiFiSocketServer/src/include
#CPPINCLUDES += -I$(WORKSPACE_BASE_PATH)/RRFLibraries/src/General

LIBS = -lsupc++ -lRRFLibraries -lFreeRTOS -lCoreNG

#-------------------------------------------------------------------------------
ifdef DEBUG
include debug.mk
else
include release.mk
endif

#-------------------------------------------------------------------------------
# Tools
#-------------------------------------------------------------------------------

include $(TOOLCHAIN).mk
CFLAGS += -c -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -nostdlib -Wundef -Wdouble-promotion -fsingle-precision-constant "-Wa,-ahl=$*.s"
CFLAGS += -std=gnu99
CFLAGS += -DRTOS
CFLAGS += -DDUET_NG

CPPFLAGS += -c -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -fno-threadsafe-statics -fno-rtti -fexceptions -nostdlib -Wundef -Wdouble-promotion -fsingle-precision-constant "-Wa,-ahl=$*.s"
CPPFLAGS += -std=gnu++17
CPPFLAGS += -DRTOS
CPPFLAGS += -DDUET_NG
CPPFLAGS += -D_XOPEN_SOURCE

#-------------------------------------------------------------------------------
ifdef DEBUG
OUTPUT_OBJ=debug
OUTPUT_LIB_POSTFIX=dbg
else
OUTPUT_OBJ=release
OUTPUT_LIB_POSTFIX=rel
endif

OUTPUT_ELF= $(BINNAME).elf
OUTPUT_PATH=$(OUTPUT_OBJ)_$(VARIANT)

LDFLAGS += -static -L"$(FREERTOS_PATH)/SAM4E" -L"$(CORENG_PATH)/SAM4E8E" -L"$(RRFLIBRARIES_PATH)/SAM4E_RTOS" -Os --specs=nano.specs -Wl,--gc-sections -Wl,--fatal-warnings -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -T"$(CORENG_PATH)/variants/duetNG/linker_scripts/gcc/flash.ld" -Wl,-Map,"$(OUTPUT_PATH)/$(BINNAME).map"

#-------------------------------------------------------------------------------
# C source files and objects
#-------------------------------------------------------------------------------

# Make does not offer a recursive wildcard function
# from https://stackoverflow.com/a/12959694:
rwildcard=$(wildcard $1$2)$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
C_SRC := $(call rwildcard,$(PROJECT_BASE_PATH)/src/,*.c)
#C_SRC=$(wildcard $(PROJECT_BASE_PATH)/*.c)

# during development, remove some files
C_OBJ_FILTER=
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet3_V06%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Linux%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet3_V05%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet3_V03%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Alligator%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/SAME70xpld%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Pccb%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Networking/LwipEthernet%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/DuetM%
C_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/RADDS%

C_SRC_TEMP := $(filter-out $(C_OBJ_FILTER), $(C_SRC))
C_OBJ_TEMP = $(patsubst %.c, %.o, $(notdir $(C_SRC_TEMP)))

C_SRC_PATHS := $(sort $(dir $(C_SRC_TEMP)))
C_OBJ=$(C_OBJ_TEMP)

#-------------------------------------------------------------------------------
# CPP source files and objects
#-------------------------------------------------------------------------------
#CPP_SRC=$(wildcard $(PROJECT_BASE_PATH)/*.cpp)
CPP_SRC := $(call rwildcard,$(PROJECT_BASE_PATH)/src/,*.cpp)

# during development, remove some files
CPP_OBJ_FILTER= 
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet3_V06%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Linux%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet3_V05%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet3_V03%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Alligator%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/SAME70xpld%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Duet/%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Pccb%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/Networking/LwipEthernet%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/DuetM%
CPP_OBJ_FILTER += $(PROJECT_BASE_PATH)/src/RADDS%

CPP_SRC_TEMP := $(filter-out $(CPP_OBJ_FILTER), $(CPP_SRC))
CPP_OBJ_TEMP = $(patsubst %.cpp, %.o, $(notdir $(CPP_SRC_TEMP)))

CPP_SRC_PATHS := $(sort $(dir $(CPP_SRC_TEMP)))
CPP_OBJ=$(CPP_OBJ_TEMP)

INCLUDES_TEMP = $(addprefix -I,$(CPP_SRC_PATHS)) $(addprefix -I,$(C_SRC_PATHS))
# we can not include the folders as includes due to the string.h -> this will mess-up #include <cstring>
#INCLUDES += $(sort $(dir $(INCLUDES_TEMP)))

vpath %.cpp $(CPP_SRC_PATHS)
#vpath %.hpp $(CPP_SRC_PATHS)
vpath %.c $(C_SRC_PATHS)
#vpath %.h $(C_SRC_PATHS) $(CPP_SRC_PATHS)

#-------------------------------------------------------------------------------
# Assembler source files and objects
#-------------------------------------------------------------------------------
A_SRC=$(wildcard $(PROJECT_BASE_PATH)/*.s)

A_OBJ_TEMP=$(patsubst %.s, %.o, $(notdir $(A_SRC)))

# during development, remove some files
A_OBJ_FILTER=

A_OBJ=$(filter-out $(A_OBJ_FILTER), $(A_OBJ_TEMP))

#-------------------------------------------------------------------------------
# Rules
#-------------------------------------------------------------------------------
all: $(VARIANT)

$(VARIANT): create_output $(OUTPUT_ELF)

.PHONY: create_output
create_output:
	@echo ------------------------------------------------------------------------------------
	@echo -------------------------
	@echo --- Preparing variant $(VARIANT) files in $(OUTPUT_PATH) $(OUTPUT_BIN)
	@echo -------------------------
	@echo $(INCLUDES)
	@echo -------------------------
	@echo $(C_SRC)
	@echo -------------------------
	@echo $(C_SRC_PATHS)
	@echo -------------------------
	@echo $(C_OBJ)
	@echo -------------------------
	@echo $(addprefix $(OUTPUT_PATH)/, $(C_OBJ))
	@echo -------------------------
	@echo $(CPP_SRC)
	@echo -------------------------
	@echo $(CPP_OBJ)
	@echo -------------------------
	@echo $(addprefix $(OUTPUT_PATH)/, $(CPP_OBJ))
	@echo -------------------------
	@echo $(A_SRC)
	@echo -------------------------

	-@mkdir -p $(OUTPUT_PATH) 1>NUL 2>&1
	@echo ------------------------------------------------------------------------------------

$(addprefix $(OUTPUT_PATH)/,$(C_OBJ)): $(OUTPUT_PATH)/%.o: %.c
#	@"$(CC)" -v -c $(CFLAGS) $< -o $@
	@"$(CC)" -c $(CFLAGS) $< -o $@

$(addprefix $(OUTPUT_PATH)/,$(CPP_OBJ)): $(OUTPUT_PATH)/%.o: %.cpp
#	@"$(CC)" -c $(CPPFLAGS) $< -o $@
	@"$(CC)" -xc++ -c $(CPPFLAGS) $< -o $@

$(addprefix $(OUTPUT_PATH)/,$(A_OBJ)): $(OUTPUT_PATH)/%.o: %.s
	@"$(AS)" -c $(ASFLAGS) $< -o $@

$(OUTPUT_ELF): $(addprefix $(OUTPUT_PATH)/, $(C_OBJ)) $(addprefix $(OUTPUT_PATH)/, $(CPP_OBJ)) $(addprefix $(OUTPUT_PATH)/, $(A_OBJ))
	@mkdir -p $(OUTPUT_BIN)
	@"$(CC)" $(LDFLAGS) -o "$(OUTPUT_BIN)/$@" -mthumb -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handler -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -Wl,--warn-unresolved-symbols -Wl,--start-group "$(CORENG_PATH)/variants/duetNG/build_gcc/release_duetNG/syscalls.o" $^ $(LIBS) -Wl,--end-group -lm
	@"$(OC)" -O binary "$(OUTPUT_BIN)/$@" "$(OUTPUT_BIN)/$(BINNAME).bin"
	@$(PROJECT_BASE_PATH)/Tools/crc32appender/linux-x86_64/crc32appender "$(OUTPUT_BIN)/$(BINNAME).bin"
#	@"$(NM)" "$(OUTPUT_BIN)/$@" > "$(OUTPUT_BIN)/$@.txt"


.PHONY: clean
clean:
	@echo ------------------------------------------------------------------------------------
	@echo --- Cleaning $(VARIANT) files [$(OUTPUT_PATH)$(SEP)*.o]
	-@$(RM) $(OUTPUT_PATH) 1>NUL 2>&1
	-@$(RM) $(OUTPUT_BIN)/$(OUTPUT_BIN_NAME) 1>NUL 2>&1
	@echo ------------------------------------------------------------------------------------

