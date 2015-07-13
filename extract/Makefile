# Command-line programs to use
CXX = h5c++
LINK = ln -sf

# General compilation and linking flags
CXXFLAGS = -I. -Iinclude -std=c++11
CXXFLAGS_RELEASE = -O3 -I.
CXXFLAGS_DEBUG = -O0 -g -Wall -Wextra -I. -DDEBUG
LIB_CXXFLAGS = -fPIC

# Project structure
CWD = $(shell pwd)
PROGRAM = extract
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
LIB_DIR = lib
BIN_DIR = bin
VERSION = 0.1

# File names for library
LIB_SOURCES = datafile.cc snipfile.cc # mcsfile.cc hidensfile.cc
BIN_SOURCES = test.cc extract.cc
SOURCES = $(LIB_SOURCES) $(BIN_SOURCES)
vpath %.cc $(SRC_DIR)
vpath %.h $(INCLUDE_DIR)
HEADERS = $(SOURCES:%.cc=%.h)
LIB_OBJECTS = $(LIB_SOURCES:%.cc=$(BUILD_DIR)/%.o)
LIB_DEBUG_OBJECTS = $(LIB_SOURCES:%.cc=$(BUILD_DIR)/%-debug.o)
OBJECTS = $(LIB_OBJECTS) $(BIN_SOURCES:%.cc=%.o)

# Platform-specific compliation and linking flags
OS := $(shell uname -s)
ifeq ($(OS),Darwin)
	LIB_EXT = dylib
	LIB_LDFLAGS = -dynamiclib -current_version $(VERSION) -compatibility_version $(VERSION)
else
	# Assume linux
	LIB_EXT = so
	LIB_LDFLAGS = -shared
endif
LIB_BASE_NAME = extractfiles
LIB_NAME = lib$(LIB_BASE_NAME).$(VERSION).$(LIB_EXT)
LIB_LINK_NAME = lib$(LIB_BASE_NAME).$(LIB_EXT)
LDFLAGS = -L./lib -l$(LIB_BASE_NAME)

# Rules
all: lib extract test
	
debug: lib-debug extract-debug

extract: lib $(BUILD_DIR)/extract.o
	$(CXX) -o $(BIN_DIR)/$@ $(CXXFLAGS) $(CXXFLAGS_RELEASE) $(BUILD_DIR)/$@.o $(LDFLAGS) 

extract-debug: lib-debug $(BUILD_DIR)/extract-debug.o
	$(CXX) -o $(BIN_DIR)/$@ $(CXXFLAGS) $(CXXFLAGS_DEBUG) $(BUILD_DIR)/$@.o $(LDFLAGS)

test: lib $(BUILD_DIR)/test.o
	$(CXX) -o $(BIN_DIR)/$@ $(BUILD_DIR)/$@.o $(LDFLAGS)

lib: $(LIB_OBJECTS)
	$(CXX) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

lib-debug: $(LIB_DEBUG_OBJECTS)
	$(CXX) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

$(BUILD_DIR)/test.o: test.cc
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_RELEASE) $<

$(BUILD_DIR)/%.o: %.cc %.h
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_RELEASE) $<

$(BUILD_DIR)/%-debug.o: %.cc %.h
	$(CXX) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_DEBUG) $<

clean:
	rm -f $(LIB_DIR)/* $(BUILD_DIR)/* $(BIN_DIR)/*

