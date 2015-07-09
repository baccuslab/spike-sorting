# Command-line programs to use
CC = h5c++
LINK = ln -sf

# General compilation and linking flags
CXXFLAGS = -I. -Iinclude -std=c++11
CXXFLAGS_RELEASE = -O3 -I.
CXXFLAGS_DEBUG = -O0 -g -Wall -Wextra -I.
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
LIB_BASE_NAME = datafile
LIB_NAME = lib$(LIB_BASE_NAME).$(VERSION).$(LIB_EXT)
LIB_LINK_NAME = lib$(LIB_BASE_NAME).$(LIB_EXT)

# Rules
all: lib extract test
	
debug: lib-debug extract-debug

extract: lib $(BUILD_DIR)/extract.o
	$(CC) -o $(BIN_DIR)/$@ $(BUILD_DIR)/$@.o $(LIB_DIR)/$(LIB_LINK_NAME)

extract-debug: lib-debug $(BUILD_DIR)/extract-debug.o
	$(CC) -o $(BIN_DIR)/$@ $(BUILD_DIR)/$@.o $(LIB_DIR)/$(LIB_LINK_NAME)

$(BUILD_DIR)/extract.o: $(SRC_DIR)/extract.cc $(INCLUDE_DIR)/extract.h
	$(CC) -c -o $@ $(CXXFLAGS) $(CXXFLAGS_RELEASE) $(SRC_DIR)/$(*F).cc

$(BUILD_DIR)/extract-debug.o: $(SRC_DIR)/extract.cc $(INCLUDE_DIR)/extract.h
	$(CC) -c -o $@ $(CXXFLAGS) $(CXXFLAGS_DEBUG) $(SRC_DIR)/$(*F).cc

lib: $(BUILD_DIR)/datafile.o $(BUILD_DIR)/mcsfile.o $(BUILD_DIR)/hidensfile.o
	$(CC) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^ $(LDFLAGS)
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

lib-debug: $(BUILD_DIR)/datafile-debug.o $(BUILD_DIR)/mcsfile-debug.o \
			$(BUILD_DIR)/hidensfile-debug.o
	$(CC) $(LIB_LDFLAGS) -o $(LIB_DIR)/$(LIB_NAME) $^ $(LDFLAGS)
	$(LINK) $(CWD)/$(LIB_DIR)/$(LIB_NAME) $(CWD)/$(LIB_DIR)/$(LIB_LINK_NAME)

$(BUILD_DIR)/datafile.o: $(SRC_DIR)/datafile.cc $(INCLUDE_DIR)/datafile.h
	$(CC) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_RELEASE) $(SRC_DIR)/$(<F)

$(BUILD_DIR)/datafile-debug.o: $(SRC_DIR)/datafile.cc $(INCLUDE_DIR)/datafile.h
	$(CC) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_DEBUG) $(SRC_DIR)/$(<F)

$(BUILD_DIR)/mcsfile.o: $(SRC_DIR)/mcsfile.cc $(INCLUDE_DIR)/mcsfile.h
	$(CC) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_RELEASE) $(SRC_DIR)/$(<F)

$(BUILD_DIR)/mcsfile-debug.o: $(SRC_DIR)/mcsfile.cc $(INCLUDE_DIR)/mcsfile.h
	$(CC) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_DEBUG) $(SRC_DIR)/$(<F)

$(BUILD_DIR)/hidensfile.o: $(SRC_DIR)/hidensfile.cc $(INCLUDE_DIR)/hidensfile.h
	$(CC) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_RELEASE) $(SRC_DIR)/$(<F)

$(BUILD_DIR)/hidensfile-debug.o: $(SRC_DIR)/hidensfile.cc $(INCLUDE_DIR)/datafile.h
	$(CC) -c -o $@ $(LIB_CXXFLAGS) $(CXXFLAGS) $(CXXFLAGS_DEBUG) $(SRC_DIR)/$(<F)

test: $(BUILD_DIR)/test.o

$(BUILD_DIR)/test.o: lib $(SRC_DIR)/test.cc
	$(CC) -c -o $@ $(CXXFLAGS) $(CXXFLAGS_RELEASE) $(SRC_DIR)/$(*F).cc
	$(CC) -o $(BIN_DIR)/$(*F) -L$(LIB_DIR) -l$(LIB_BASE_NAME) -larmadillo $@

clean:
	rm -f $(LIB_DIR)/* $(BUILD_DIR)/* $(BIN_DIR)/*

