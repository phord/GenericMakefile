########################################################################################
##### PROJECT SETTINGS ######
# The name of the executable to be created
# The libXXX.a extention will be added. Only XXX has to be specified.
# For executables a lowercase Camelcase style eg. testExecutable is recomended.
# For libraries a uppercase Camelcase style eg. JTimer is recomended.
# The produced library will be lowercase only per convention.
NAME = Test
# Link to library option.
## 0 = target is an executable.
TARGET_EXECUTABLE = 0
## 1 = target is a static library.
TARGET_STATIC_LIB = 1
## 2 = target is a shared library.
TARGET_SHARED_LIB = 2
export TYPE := $(TARGET_STATIC_LIB)
# Verbose option, to output compile and link commands. true = verbose output, flase = quiet.
export V := true
# Version macros
USE_GIT := true
USE_SVN := false
# enable #include "jversion.hpp" -> JVersion::$(NAME)::PrintVersion() support.
PRINTVERSION_HEADER := true
# The directory where the executable shall be created.
EXE_DIR = ./bin
# The directory where the static or shared library will be created.
LIB_DIR = ./lib
# The directory where a symbolic link to the latest target will be created.
# If no SYMBOLIC_LINK_DIR is specified no symbolic link is created.
# Always make shure to use the path with an appended '/'
SYMBOLIC_LINK_DIR = $(TARGET)/$(DIST_INFO)/
# Use this variable in combination with the SYMBOLIK_LINK_DIR.
# The delta variable specifies the relative path from the SYMBOLIC_LINK_DIR to the project root.
# Always make shure to use the path with an appended '/'
LIB_SYMLINK_DELTA = ../../
# Compiler used
CXX ?= g++
# Extension of source files used in the project.
SRC_EXT = cpp
# Path to the source directory, relative to the makefile.
SRC_PATH = ./src
# Add here sources which should be ignored for compiling. Use wildcard eg. *_test.cpp to ignore.
IGNORE_SOURCE  = ""
# Space-separated pkg-config libraries used by this project.
LIBS =
# General compiler flags
COMPILE_FLAGS = -std=c++0x -Wall -Wextra
# Additional release-specific flags.
RCOMPILE_FLAGS = -O2 -D NDEBUG
# Additional debug-specific flags.
DCOMPILE_FLAGS = -O0 -g3 -D DEBUG
# Default include directory. Used for installing a library or the printversion header.
DEFAULT_INCLUDE_DIR = ./include
# External include directory. Used for conventions or generally applicable headers.
EXTERNAL_INCLUDE_DIR =
# Add additional include paths.
INCLUDES = -I$(DEFAULT_INCLUDE_DIR) -I$(EXTERNAL_INCLUDE_DIR)
# General linker settings.
LINK_FLAGS =
# Additional release-specific linker settings.
RLINK_FLAGS =
# Additional debug-specific linker settings.
DLINK_FLAGS =
# Install path (bin/ or lib/ is appended automatically).
INSTALL_DIR = /usr/$(TARGET)
HEADER_DIR = /usr/include/tools
#### END PROJECT SETTINGS ####
########################################################################################
# Generally you should not need to edit anything below this line!

# Get linux version and/or distribution version
DIST_NAME:=$(shell lsb_release -a 2> /dev/null | sed -nre 's/Distributor ID:[ \t](.*)/\1/p')
DIST_VERSION:=$(shell lsb_release -a 2> /dev/null | sed -nre 's/Release:[ \t]([0-9].[0-9]).*/\1/p')
DIST_INFO:=$(DIST_NAME)-$(DIST_VERSION)

# ifneq ($(wildcard /etc/*-release),)
#                      get all dist info              extract dist name                     replace spaces with hyphens   add if OS is 32 or 64 bit
# 	DIST_INFO:=$(shell cat /etc/*-release | sed -nre 's/DISTRIB_DESCRIPTION=\"(.*)\"/\1/p' | sed -nre 's/ /-/p' | sed -nre 's/(.*)/\1_`uname -m`/p')
# else
# 	DIST_NAME:=$(shell lsb_release -a 2> /dev/null | sed -nre 's/Distributor ID:[ \t](.*)/\1/p')
# 	DIST_VERSION:=$(shell lsb_release -a 2> /dev/null | sed -nre 's/Release:[ \t]([0-9].[0-9]).*/\1/p')
# 	DIST_INFO:=$(DIST_NAME)-$(DIST_VERSION)
# endif

# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
print-%: ; @echo $*=$($*)

# Shell used in this makefile
# bash is used for 'echo -en'
SHELL = /bin/bash

# Clear built-in rules
.SUFFIXES:
# Programs for installation
INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

# Append pkg-config specific libraries if needed
ifneq ($(LIBS),)
	COMPILE_FLAGS += $(shell pkg-config --cflags $(LIBS))
	LINK_FLAGS += $(shell pkg-config --libs $(LIBS))
endif

# Use -fPIC flag for library types.
ifneq ($(TYPE), $(TARGET_EXECUTABLE))
	COMPILE_FLAGS += -fPIC
endif

#	ADD_BUILD_INFO_COMMAND= ld --defsym	VERSION_PATCH_REF=$(VERSION_PATCH) -o $(word 1, $(OBJECTS)2) $(word 1, $(OBJECTS)) -lc
# checks if target is binary or library and sets paths and commands accordingly
ifeq ($(TYPE), $(TARGET_EXECUTABLE))
	# ${TARGET_EXECUTABLE}
	TARGET=$(EXE_DIR)
	TARGET_NAME := $(NAME)
	LINK_COMMAND = $(CMD_PREFIX)$(CXX) $(BUILD_NUMBER_LDFLAGS) $(OBJECTS) $(LDFLAGS) -o $@
else ifeq ($(TYPE), $(TARGET_STATIC_LIB))
	# ${TARGET_STATIC_LIB}
	TARGET=$(LIB_DIR)
	TARGET_NAME := lib$(shell echo $(NAME)|tr [:upper:] [:lower:]).a
	LINK_COMMAND = cp $(word 1, $(OBJECTS)) $(word 1, $(OBJECTS:.o=tmp.o));\
				   mv $(word 1, $(OBJECTS)) $(word 1, $(OBJECTS:.o=orig.o));\
				   ld -r $(BUILD_NUMBER_LDFLAGS) $(LDFLAGS)\
				   $(word 1, $(OBJECTS:.o=tmp.o)) -o $(word 1, $(OBJECTS));\
				   rm $(word 1, $(OBJECTS:.o=tmp.o));\
				   ar -rs $(TARGET_PATH)/$(TARGET_NAME) $(OBJECTS);\
				   mv $(word 1, $(OBJECTS:.o=orig.o)) $(word 1, $(OBJECTS))
else
	# ${TARGET_SHARED_LIB}
	TARGET=$(LIB_DIR)
	TARGET_NAME := lib$(shell echo $(NAME)|tr [:upper:] [:lower:]).so
	LINK_COMMAND = $(CMD_PREFIX)$(CXX) -shared $(BUILD_NUMBER_LDFLAGS) $(OBJECTS) $(LDFLAGS) -o $@
endif

# Set verbose flag.
export CMD_PREFIX := @
ifeq ($(V),true)
	CMD_PREFIX :=
endif

# Combine compiler and linker flags.
release: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(RCOMPILE_FLAGS)
release: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(RLINK_FLAGS)
debug: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(DCOMPILE_FLAGS)
debug: export LDFLAGS := $(LDFLAGS) $(LINK_FLAGS) $(DLINK_FLAGS)

# Build and output paths
release: export BUILD_PATH := build/release
release: export TARGET_PATH := $(TARGET)/release
debug: export BUILD_PATH := build/debug
debug: export TARGET_PATH := $(TARGET)/debug
install: export TARGET_PATH := $(TARGET)/release

# Find all source files in the source directory, sorted by most
# recently modified
SOURCES = $(shell find $(SRC_PATH) -name '*.$(SRC_EXT)' -not -name $(IGNORE_SOURCE) -printf '%T@\t%p\n' \
		  | sort -k 1nr | cut -f2-)

# fallback in case the above fails
rwildcard = $(foreach d, $(wildcard $1*), $(call rwildcard,$d/,$2) \
						$(filter $(subst *,%,$2), $d))
ifeq ($(SOURCES),)
	SOURCES := $(call rwildcard, $(SRC_PATH), *.$(SRC_EXT))
endif

# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS = $(SOURCES:$(SRC_PATH)/%.$(SRC_EXT)=$(BUILD_PATH)/%.o)

# Set the dependency files that will be used to add header dependencies
DEPS = $(OBJECTS:.o=.d)

# Macros for timing compilation
TIME_FILE = $(dir $@).$(notdir $@)_time
START_TIME = date '+%s' > $(TIME_FILE)
END_TIME = read st < $(TIME_FILE) ; \
	$(RM) $(TIME_FILE) ; \
	st=$$((`date '+%s'` - $$st - 86400)) ; \
	echo `date -u -d @$$st '+%H:%M:%S'`

BUILD_NUMBER := $(shell if [ -a ".version" ]; then cat .version; else echo 0; fi)
override BUILD_NUMBER := $$(($(BUILD_NUMBER)+1))

# Version macros
ifeq ($(USE_GIT), true)
	# If this isn't a git repo or the repo has no tags, git describe will return non-zero
	ifeq ($(shell git describe > /dev/null 2>&1 ; echo $$?), 0)
	# Additinal build number information
		USE_VERSION := true
		VERSION := $(shell git describe --tags --long --always | \
			sed 's/v\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)-\?.*-\([0-9]*\)-\(.*\)/\1 \2 \3 \4 \5/g')
		VERSION_MAJOR    := $(word 1, $(VERSION))
		VERSION_MINOR    := $(word 2, $(VERSION))
		VERSION_PATCH    := $(word 3, $(VERSION))
		VERSION_REVISION := $(word 4, $(VERSION))
		VERSION_HASH     := $(word 5, $(VERSION))
		VERSION_STRING   := "$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(VERSION_REVISION)-$(VERSION_HASH)"

		ifeq ($(TYPE), $(TARGET_STATIC_LIB))
			BUILD_NUMBER_LDFLAGS  = --defsym $(TARGET_NAME:.a=)_VERSION_MAJOR_REF=$(VERSION_MAJOR)
			BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_MINOR_REF=$(VERSION_MINOR)
			BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_PATCH_REF=$(VERSION_PATCH)
			BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_REVISION_REF=$(VERSION_REVISION)
		else
			BUILD_NUMBER_LDFLAGS  = -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_MAJOR_REF=$(VERSION_MAJOR)
			BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_MINOR_REF=$(VERSION_MINOR)
			BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_PATCH_REF=$(VERSION_PATCH)
			BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_REVISION_REF=$(VERSION_REVISION)
		endif

		override CXXFLAGS := $(CXXFLAGS) \
			-D VERSION_MAJOR=$(VERSION_MAJOR) \
			-D VERSION_MINOR=$(VERSION_MINOR) \
			-D VERSION_PATCH=$(VERSION_PATCH) \
			-D VERSION_REVISION=$(VERSION_REVISION)
	endif
else ifeq ($(USE_SVN), true)
	USE_VERSION := true
	IS_TRUNK := $(shell svn info | sed -nr 's/URL:.*\/trunk.*/true/p')
	ifeq ($(IS_TRUNK), true)
		# write REVISION information.
		VERSION_REVISION := $(shell svn info | sed -nr 's/Revision:[ \t]([0-9]*)/\1/p')
		ifeq ($(TYPE), $(TARGET_STATIC_LIB))
			BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_REVISION_REF=$(VERSION_REVISION)
		else
			BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_REVISION_REF=$(VERSION_REVISION)
		endif
		override CXXFLAGS := $(CXXFLAGS) -D VERSION_REVISION=$(VERSION_REVISION)
	else
		# write V_tag major, v_tag_minor, rev and build
		VERSION_MAJOR    := $(shell svn info | sed -n "/URL:/s/.*\///p" | sed -nr "s/([0-9]{0,4})\.([0-9]{0,4})\.*(.*)/\1/p")
		VERSION_MINOR    := $(shell svn info | sed -n "/URL:/s/.*\///p" | sed -nr "s/([0-9]{0,4})\.([0-9]{0,4})\.*(.*)/\2/p")
		VERSION_PATCH    := $(shell svn info | sed -n "/URL:/s/.*\///p" | sed -nr "s/([0-9]{0,4})\.([0-9]{0,4})\.*(.*)/\3/p")
		VERSION_REVISION := $(shell svn info | sed -nr 's/Revision:[ \t]([0-9]*)/\1/p')
		# VERSION_HASH     :=
		# VERSION_STRING   := "$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(VERSION_REVISION)-$(VERSION_HASH)"
		ifeq ($(TYPE), $(TARGET_STATIC_LIB))
			BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_MAJOR_REF=$(VERSION_MAJOR)
			BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_MINOR_REF=$(VERSION_MINOR)
			ifneq ($(VERSION_PATCH),)
				BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_PATCH_REF=$(VERSION_PATCH)
			endif
			BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_VERSION_REVISION_REF=$(VERSION_REVISION)
		else
			BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_MAJOR_REF=$(VERSION_MAJOR)
			BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_MINOR_REF=$(VERSION_MINOR)
			ifneq ($(VERSION_PATCH),)
				BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_PATCH_REF=$(VERSION_PATCH)
			endif
			BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_VERSION_REVISION_REF=$(VERSION_REVISION)
		endif
	endif
endif

# no matter what, always add BUILD_NUMBER and BUILD_DATE information.
ifeq ($(TYPE), $(TARGET_STATIC_LIB))
	BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_BUILD_NUMBER_REF=$(BUILD_NUMBER)
	BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_BUILD_DAY_REF=$(shell date '+%-d')
	BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_BUILD_MONTH_REF=$(shell date '+%-m')
	BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_BUILD_YEAR_REF=$(shell date '+%-y')
	BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_BUILD_HOUR_REF=$(shell date '+%-H')
	BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_BUILD_MIN_REF=$(shell date '+%-M')
	BUILD_NUMBER_LDFLAGS += --defsym $(TARGET_NAME:.a=)_BUILD_SEC_REF=$(shell date '+%-S')
else
	BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_BUILD_NUMBER_REF=$(BUILD_NUMBER)
	BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_BUILD_DAY_REF=$(shell date '+%-d')
	BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_BUILD_MONTH_REF=$(shell date '+%-m')
	BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_BUILD_YEAR_REF=$(shell date '+%-y')
	BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_BUILD_HOUR_REF=$(shell date '+%-H')
	BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_BUILD_MIN_REF=$(shell date '+%-M')
	BUILD_NUMBER_LDFLAGS += -Xlinker --defsym -Xlinker $(TARGET_NAME)_BUILD_SEC_REF=$(shell date '+%-S')
endif

override CXXFLAGS := $(CXXFLAGS) -D BUILD_NUMBER=$(BUILD_NUMBER) \
								 -D BUILD_DAY=$(shell date '+%-d') \
								 -D BUILD_MONTH=$(shell date '+%-m') \
								 -D BUILD_YEAR=$(shell date '+%-y') \
								 -D BUILD_HOUR=$(shell date '+%-H') \
								 -D BUILD_MIN=$(shell date '+%-M') \
								 -D BUILD_SEC=$(shell date '+%-S')

# Debug build for gdb debugging
.PHONY: debug
debug: dirs
ifeq ($(USE_VERSION), true)
	@echo -e $(A_BOLD)"Beginning debug build v$(VERSION_STRING) #$(BUILD_NUMBER)"$(A_NORMAL)
else
	@echo -e $(A_BOLD)"Beginning debug build #$(BUILD_NUMBER)"$(A_NORMAL)
endif
	@$(START_TIME)
	@$(MAKE) target --no-print-directory
	@echo -en $(FG_B_GREEN)"\tTotal time: "
	@$(END_TIME)
	@echo -en $(FG_DEFAULT)

# Standard, non-optimized release build
.PHONY: release
release: dirs
ifeq ($(USE_VERSION), true)
	@echo -e $(A_BOLD)"Beginning release build v$(VERSION_STRING) #$(BUILD_NUMBER)"$(A_NORMAL)
else
	@echo -e $(A_BOLD)"Beginning release build #$(BUILD_NUMBER)"$(A_NORMAL)
endif
	@$(START_TIME)
	@$(MAKE) target --no-print-directory
	@echo -en $(FG_B_GREEN)"\tTotal time: "
	@$(END_TIME)
	@echo -en $(FG_DEFAULT)

# Make both targets debug and release.
.PHONY: all
all:
	$(MAKE) debug --no-print-directory
	$(MAKE) release --no-print-directory

# Create the directories used in the build
.PHONY: dirs
dirs: printversion
	@echo -en $(A_BOLD)"Creating directories"$(A_NORMAL)
	@mkdir -p $(dir $(OBJECTS))
	@mkdir -p $(TARGET_PATH)
	@mkdir -p $(TARGET_PATH)
	@echo " -" done

# Installs to the set path
.PHONY: install
install:
	mkdir -p $(HEADER_DIR)
	@echo -e $(FG_B_CYAN)"Installing to $(INSTALL_DIR)/$(TARGET_NAME)"$(FG_DEFAULT)
	@$(INSTALL_PROGRAM) $(TARGET_PATH)/$(TARGET_NAME) $(INSTALL_DIR)
	@echo -e $(FG_B_CYAN)"Installing header to $(HEADER_DIR)/$(shell echo $(NAME)|tr [:upper:] [:lower:])"$(FG_DEFAULT)
	@$(INSTALL_PROGRAM) $(DEFAULT_INCLUDE_DIR)/$(shell echo $(NAME)|tr [:upper:] [:lower:]).hpp $(HEADER_DIR)/
	@echo "Done."

# Uninstalls the program
.PHONY: uninstall
uninstall:
	@echo -e $(FG_B_RED)"Removing $(INSTALL_DIR)/$(TARGET_NAME)"$(FG_DEFAULT)
	@$(RM) $(INSTALL_DIR)/$(TARGET_NAME)
	@echo -e $(FG_B_RED)"Removing $(HEADER_DIR)/$(NAME)"$(FG_DEFAULT)
	@$(RM) $(HEADER_DIR)/$(NAME).hpp


ARGC=$(words $(MAKECMDGOALS))
# Removes all build files
.PHONY: clean
clean:
	@echo -e $(FG_B_RED)"Deleting $(TARGET_NAME) symlink"
	@$(RM) $(SYMBOLIC_LINK_DIR)/$(TARGET_NAME)
	@echo -e "Remove $(SYMBOLIC_LINK_DIR) if empty"
	@rmdir -p --ignore-fail-on-non-empty $(SYMBOLIC_LINK_DIR) 2> /dev/null || true;
	@echo "Deleting directories"
	@$(RM) -rv build
	@$(RM) -rv $(EXE_DIR)
	@$(RM) -rv $(LIB_DIR)
	@rm -vf $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo -e "Remove $(DEFAULT_INCLUDE_DIR) if empty"
	@rmdir -p --ignore-fail-on-non-empty $(DEFAULT_INCLUDE_DIR) 2> /dev/null || true;
	@echo -en $(FG_DEFAULT)
# If there is a second argument specified, make sure to generate the version header.
ifeq ($(ARGC), 2)
	@$(MAKE) printversion --no-print-directory
endif

# Main rule, checks the executable and symlinks to the output.
target: $(TARGET_PATH)/$(TARGET_NAME)
ifneq ($(SYMBOLIC_LINK_DIR), )
	@echo -e "Creating symlink:"$(FG_B_CYAN) "$(SYMBOLIC_LINK_DIR)$(TARGET_NAME) -> $<"$(FG_DEFAULT)
	@$(RM) -f $(SYMBOLIC_LINK_DIR)/$(TARGET_NAME)
	@if [ ! -d $(SYMBOLIC_LINK_DIR) ]; then mkdir -p $(SYMBOLIC_LINK_DIR); fi
	@ln -s $(LIB_SYMLINK_DELTA)$(TARGET_PATH)/$(TARGET_NAME) $(shell echo $(SYMBOLIC_LINK_DIR))$(TARGET_NAME)
else
	@echo -e "Creating no symlink:"$(FG_B_CYAN) "SYMBOLIC_LINK_DIR is undefined "$(FG_DEFAULT)
endif

# Display build binaries
.PHONY: show
show:
ifneq (, $(wildcard $(SYMBOLIC_LINK_DIR)$(TARGET_NAME)))
	@echo "===================================================================================================="
	@printf "  Build Date: %02d." 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_BUILD_DAY_REF/\1/p')
	@printf               "%02d." 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_BUILD_MONTH_REF/\1/p')
	@printf               "%02d " 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_BUILD_YEAR_REF/\1/p')
	@printf               "%02d:" 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_BUILD_HOUR_REF/\1/p')
	@printf               "%02d:" 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_BUILD_MIN_REF/\1/p')
	@printf               "%02d\n" 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_BUILD_SEC_REF/\1/p')
ifeq ($(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/.*VERSION_MAJOR_REF.*/true/p'),true)
	@printf "  vMajor:   %4d\n" 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_VERSION_MAJOR_REF/\1/p')
endif
ifeq ($(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/.*VERSION_MINOR_REF.*/true/p'),true)
	@printf "  vMinor:   %4d\n" 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_VERSION_MINOR_REF/\1/p')
endif
	@printf "  Build:    %4d\n" 0x$(shell objdump -t $(SYMBOLIC_LINK_DIR)$(TARGET_NAME) | grep REF | sed -nr 's/([0-9abcdef]*).*[0-9abcdef]*[ \t]{1}lib'$(NAME)'_BUILD_NUMBER_REF/\1/p')
	@echo
	@tree -Chf $(TARGET)
	@echo "===================================================================================================="
endif

# Removes the build number file .version.
reset:
	@echo -e $(FG_B_RED)Removing the version information. Next build will be "#1."$(FG_DEFAULT)
	@$(RM) -v .version

# Displays an overview of the supported functions implemented in this makefile.
help:
	@echo Supported make flags are:
	@echo "  "clean "  "- removes all compiled or generated data
	@echo "  "release - builds an optimized release build of the project
	@echo "  "debug "  "- builds an gdb debuggable build of this project
	@echo "  "all "    "- builds both, debug and release
	@echo "  "reset "  "- resets build number
	@echo "  "show "   "- display build results \(SYMBOLIC_LINK_DIR=/path to object,TARGET_NAME=obj \(e.g. libModeladfsm.so\),NAME=model \(e.g. adfsm\)\)
	@echo "  "help "   "- shows this overview

# Link the executable
$(TARGET_PATH)/$(TARGET_NAME): $(OBJECTS)
	@echo -e $(FG_B_MAGENTA)$(A_BOLD)"Linking: $@"$(FG_DEFAULT)$(A_NORMAL)
	@$(START_TIME)
	@$(LINK_COMMAND)
	@echo -en $(FG_B_GREEN)"\tLink time: "
	@$(END_TIME)
	@echo -en $(FG_DEFAULT)
	@echo $(BUILD_NUMBER) > .version

# Add dependency files, if they exist
-include $(DEPS)

# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
$(BUILD_PATH)/%.o: $(SRC_PATH)/%.$(SRC_EXT)
	@echo -e $(FG_B_YELLOW)$(A_BOLD)"Compiling: $< -> $@" $(FG_DEFAULT)$(A_NORMAL)
	@$(START_TIME)
	$(CMD_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@
	@echo -en $(FG_B_GREEN) "\tCompile time: "
	@$(END_TIME)
	@echo -en $(FG_DEFAULT)

# COLOR INFO
# Attributes
A_NORMAL     = "\e[00m"
A_BOLD       = "\e[01m"
A_UNDERLINE  = "\e[04m"
A_BLINK      = "\e[05m"
A_INVERT     = "\e[07m"
A_HIDDEN     = "\e[08m"

# Foreground Colorsm
FG_BLACK     = "\e[30m"
FG_RED       = "\e[31m"
FG_GREEN     = "\e[32m"
FG_YELLOW    = "\e[33m"
FG_BLUE      = "\e[34m"
FG_MAGENTA   = "\e[35m"
FG_CYAN      = "\e[36m"
FG_WHITE     = "\e[37m"
FG_DEFAULT   = "\e[39m"
FG_B_BLACK   = "\e[90m"
FG_B_RED     = "\e[91m"
FG_B_GREEN   = "\e[92m"
FG_B_YELLOW  = "\e[93m"
FG_B_BLUE    = "\e[94m"
FG_B_MAGENTA = "\e[95m"
FG_B_CYAN    = "\e[96m"
FG_B_WHITE   = "\e[97m"

# Background Colors
BG_BLACK     = "\e40m"
BG_RED       = "\e41m"
BG_GREEN     = "\e42m"
BG_YELLOW    = "\e43m"
BG_BLUE      = "\e44m"
BG_MAGENTA   = "\e45m"
BG_CYAN      = "\e46m"
BG_WHITE     = "\e47m"
BG_DEFAULT   = "\e49m"
BG_B_BLACK   = "\e100m"
BG_B_RED     = "\e101m"
BG_B_GREEN   = "\e102m"
BG_B_YELLOW  = "\e103m"
BG_B_BLUE    = "\e104m"
BG_B_MAGENTA = "\e105m"
BG_B_CYAN    = "\e106m"
BG_B_WHITE   = "\e107m"

printversion:
ifeq ($(PRINTVERSION_HEADER), true)
	@if [ ! -d $(DEFAULT_INCLUDE_DIR) ]; then mkdir -p $(DEFAULT_INCLUDE_DIR); fi
ifeq ($(shell if [ -a "$(DEFAULT_INCLUDE_DIR)/jversion.hpp" ]; then echo true; else echo false; fi), false)
	@echo -en $(A_BOLD)"Creating version header"$(A_NORMAL)
	@echo "#pragma once" > $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "#include <cstdio>" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "namespace JVersion" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "{" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "    class $(shell echo $(NAME) | sed -nre 's/(.).*/\U\1/p')$(shell echo $(NAME) | sed -nre 's/.(.*)/\1/p')" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "    {" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "    public:" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "        static void PrintVersion()" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "        {" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            std::printf("\""Version information of $(TARGET_NAME)\n"\"");" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            #ifdef BUILD_YEAR" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            std::printf("\""  Build Date:    %02d.%02d.20%d - %02d:%02d:%02d\n"\""," >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "                        BUILD_DAY, BUILD_MONTH, BUILD_YEAR," >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "                        BUILD_HOUR, BUILD_MIN, BUILD_SEC);" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            #endif" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            #ifdef VERSION_MAJOR" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            std::printf("\""  Build Version: v%d.%d.%d\n"\"", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            #endif" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            #ifdef BUILD_NUMBER" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            std::printf("\""  Build:         %d\n"\"", BUILD_NUMBER);" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "            #endif" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "        }" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "    };" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo "}" >> $(DEFAULT_INCLUDE_DIR)/jversion.hpp
	@echo " -" done
endif
endif
