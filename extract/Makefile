# Project structure
CWD = $(shell pwd)
PROGRAM = extract
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
LIB_DIR = lib
BIN_DIR = bin
VERSION = 0.4

# Command-line programs to use
CXX = g++
LINK = ln -sf

# General compilation flags
local_CXXFLAGS = $(CXXFLAGS) -I. -Iinclude -std=c++11 -m64
CXXFLAGS_RELEASE = -O3 -I.
CXXFLAGS_DEBUG = -O0 -g -Wall -Wextra -I. -DDEBUG
LIB_CXXFLAGS = -fPIC

# Source, include and object file name information
LIB_SOURCES = datafile.cc hidensfile.cc snipfile.cc hidenssnipfile.cc extract.cc
BIN_SOURCES = main.cc
SOURCES = $(LIB_SOURCES) $(BIN_SOURCES)
vpath %.cc $(SRC_DIR)
vpath %.h $(INCLUDE_DIR)
HEADERS = $(SOURCES:%.cc=%.h)
LIB_OBJECTS = $(LIB_SOURCES:%.cc=$(BUILD_DIR)/%.o)
LIB_DEBUG_OBJECTS = $(LIB_SOURCES:%.cc=$(BUILD_DIR)/%-debug.o)
OBJECTS = $(LIB_OBJECTS) $(BIN_SOURCES:%.cc=%.o)

# Flags and options for building shared library
LIB_BASE_NAME = extract
LIBS = -larmadillo -lhdf5_cpp -lhdf5
OS := $(shell uname -s)
ifeq ($(OS),Darwin)
	LIB_EXT = dylib
	LIB_NAME = lib$(LIB_BASE_NAME).$(VERSION).$(LIB_EXT)
	LIB_LDFLAGS = -dynamiclib -current_version $(VERSION) \
				  -compatibility_version $(VERSION) \
				  -install_name $(CWD)/$(LIB_DIR)/$(LIB_NAME)
	BIN_LDFLAGS = -rpath $(CWD)/$(LIB_DIR)
else
	# Assume linux
	LIB_EXT = so
	LIB_NAME = lib$(LIB_BASE_NAME).$(VERSION).$(LIB_EXT)
	LIB_LDFLAGS = -shared
	BIN_LDFLAGS = -Wl,-rpath=$(CWD)/$(LIB_DIR)
endif
LIB_LINK_NAME = lib$(LIB_BASE_NAME).$(LIB_EXT)
local_LDFLAGS = $(LDFLAGS) -L$(LIB_DIR) -l$(LIB_BASE_NAME)

# Rules
all: lib extract
	
debug: lib-debug extract-debug

extract: $(BUILD_DIR)/main.o lib
	@mkdir -p bin
	$(CXX) -o $(BIN_DIR)/$@ $< $(local_LDFLAGS) $(LIBS) $(BIN_LDFLAGS)

extract-debug: $(BUILD_DIR)/main-debug.o lib-debug
	@mkdir -p bin
	$(CXX) -o $(BIN_DIR)/$@ $< $(local_LDFLAGS) $(LIBS) $(BIN_LDFLAGS)

lib: $(LIB_OBJECTS)
	@mkdir -p lib
	$(CXX) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^ $(LIBS)
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

lib-debug: $(LIB_DEBUG_OBJECTS)
	@mkdir -p lib
	$(CXX) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^ $(LIBS)
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

$(BUILD_DIR)/main.o: $(SRC_DIR)/main.cc
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(local_CXXFLAGS) $(CXXFLAGS_RELEASE) $<

$(BUILD_DIR)/main-debug.o: $(SRC_DIR)/main.cc
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(local_CXXFLAGS) $(CXXFLAGS_DEBUG) $<

$(BUILD_DIR)/%.o: %.cc %.h
	@mkdir -p build
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(local_CXXFLAGS) $(CXXFLAGS_RELEASE) $<

$(BUILD_DIR)/%-debug.o: %.cc %.h
	@mkdir -p build
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(local_CXXFLAGS) $(CXXFLAGS_DEBUG) $<

clean:
	rm -f $(LIB_DIR)/* $(BUILD_DIR)/* $(BIN_DIR)/*

install:
	$(LINK) $(CWD)/$(BIN_DIR)/extract /usr/local/bin/extract
