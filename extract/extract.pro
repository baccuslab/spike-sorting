######################################################################
# Automatically generated by qmake (3.0) Thu Jul 28 11:03:55 2016
######################################################################

TEMPLATE = app
DESTDIR = bin
TARGET = extract
VERSION = 0.5.0
INCLUDEPATH += . ./include \
	/usr/local/include
LIBS += -L/usr/local/lib -larmadillo -lhdf5_cpp -lhdf5

QT -= widgets core gui
CONFIG += c++11 debug_and_release
CONFIG -= app_bundle
QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.8

debug {
	DEFINES += DEBUG
}

# Input
HEADERS += include/extract.h \
           include/semaphore.h \
		   include/datafile.h \
		   include/snipfile.h \
		   include/hidensfile.h \
		   include/hidenssnipfile.h
SOURCES += src/extract.cc \
           src/main.cc \
           src/semaphore.cc \
		   src/datafile.cc \
		   src/snipfile.cc \
		   src/hidensfile.cc \
		   src/hidenssnipfile.cc
