########################################################################################
##### PROJECT SETTINGS ######
# The name of the executable to be created
# The libXXX.a extention will be added. Only XXX has to be specified.
# For executables a lowercase Camelcase style eg. testExecutable is recomended.
# For libraries a uppercase Camelcase style eg. JTimer is recomended.
# The produced library will be lowercase only per convention.
NAME = Test
# Link to library option. One of: TARGET_EXECUTABLE  TARGET_STATIC_LIB  TARGET_SHARED_LIB
export TYPE = $(TARGET_STATIC_LIB)
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

include generic.make