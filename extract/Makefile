# Project structure
CWD = $(shell pwd)
PROGRAM = extract
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
LIB_DIR = lib
BIN_DIR = bin
VERSION = 0.2

# Command-line programs to use
CXX = g++
LINK = ln -sf

# General compilation flags
CXXFLAGS = -I. -Iinclude -std=c++11
CXXFLAGS_RELEASE = -O3 -I.
CXXFLAGS_DEBUG = -O0 -g -Wall -Wextra -I. -DDEBUG
LIB_CXXFLAGS = -fPIC

# Source, include and object file name information
LIB_SOURCES = datafile.cc snipfile.cc
BIN_SOURCES = test.cc extract.cc
SOURCES = $(LIB_SOURCES) $(BIN_SOURCES)
vpath %.cc $(SRC_DIR)
vpath %.h $(INCLUDE_DIR)
HEADERS = $(SOURCES:%.cc=%.h)
LIB_OBJECTS = $(LIB_SOURCES:%.cc=$(BUILD_DIR)/%.o)
LIB_DEBUG_OBJECTS = $(LIB_SOURCES:%.cc=$(BUILD_DIR)/%-debug.o)
OBJECTS = $(LIB_OBJECTS) $(BIN_SOURCES:%.cc=%.o)

# Flags and options for building shared library
LIB_BASE_NAME = extractfiles
LIBS = -lhdf5_cpp -lhdf5
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
LDFLAGS = -L$(LIB_DIR) -l$(LIB_BASE_NAME)

# Rules
all: lib extract test
	
debug: lib-debug extract-debug

extract: lib $(BUILD_DIR)/extract.o
	$(CXX) -o $(BIN_DIR)/$@ $(BUILD_DIR)/$@.o $(LDFLAGS) $(LIBS)

extract-debug: lib-debug $(BUILD_DIR)/extract-debug.o
	$(CXX) -o $(BIN_DIR)/$@ $(BUILD_DIR)/$@.o $(LDFLAGS) $(LIBS)

test: lib $(BUILD_DIR)/test.o
	$(CXX) -o $(BIN_DIR)/$@ $(BUILD_DIR)/$@.o $(LDFLAGS) $(LIB)

lib: $(LIB_OBJECTS)
	$(CXX) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^ $(LIBS)
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

lib-debug: $(LIB_DEBUG_OBJECTS)
	$(CXX) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^ $(LIBS)
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

$(BUILD_DIR)/test.o: test.cc
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_RELEASE) $<

$(BUILD_DIR)/%.o: %.cc %.h
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_RELEASE) $<

$(BUILD_DIR)/%-debug.o: %.cc %.h
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_DEBUG) $<

clean:
	rm -f $(LIB_DIR)/* $(BUILD_DIR)/* $(BIN_DIR)/*

