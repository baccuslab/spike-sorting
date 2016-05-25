extract
=======

Extract is a command-line tool to extract noise and candidate spike
snippets from raw HDF5 recording files for spike sorting.

(C) 2015 Benjamin Naecker bnaecker@stanford.edu

Usage
-----

	./extract 	[ -v | --version ] [-h | --help ]
				[ -V | --verbose ]
				[ -t | --threshold <threshold> ]
				[ -a | --after <nafter> ]
				[ -b | --before <nbefore> ]
				[ -c | --chan <chanlist> ]
				[ -n | --nrandom <nrandom> ]
				<recording>

Parameters
----------

- `-v | --version` 
	- Display version info and exit
- `-h | --help` 
	- Display help and exit
- `-V | --verbose`
	- Display information about the progress of the extraction process.
- `-t | --threshold <threshold>` 
	- Candidate spikes are those sections of the data trace
which are above a threshold, set as `<threshold> * median(abs(v - mean(v)))`
- `-b | --before <nbefore>`
	- Number of samples before a spike peak to extract. Defaults to 6 for
MCS array data and 12 for HiDens array data.
- `-a | --after <nafter>`
	- Number of samples after a spike peak to extract. Defaults to 20 for
MCS array data and 40 for HiDens array data.
- `-c | --chan <chanlist>` 
	- A comma-separated and dash-separated list of channels from
which data is extracted. Dashes indicate a channel range, e.g., `0-4` extracts
data from channels `0` through `3`, and `1,2,3` extracts from exactly those channels.
These can be composed, e.g., `1,2,3,4-10`. Note that indexing is `0`-based and
intervals are half-open.
- `-n | --nrandom <nrandom>`
	- The number of random snippets to extract from each channel. Defaults to 5000.

Requirements and building
-------------------------

- C++11 or later
- [HDF5](http://www.hdfgroup.org) version 1.15 or higher
- [Armadillo C++ linear algebra libraries](http://arma.sourceforge.net), 
used to simplify data management
- GNU `make`
- [Doxygen](http://www.doxygen.org) for making documentation

The project comes with a custom Makefile that should work on Ubuntu Linux and OS X.
To build it, do this:

	$ cd /path/to/extract
	$ make # Makes the library and executable
	$ doxygen Doxyfile # Builds the HTML documentation

The Makefile assumes that the header files for the HDF5 and Armadillo libraries are
somewhere in the standard include list: `/usr/include`, `/usr/local/include`, etc.
Similarly, the dynamic libraries against which the program links must be in standard
library directories, such as `/usr/local/lib` or similar. This may not be true for
some Linux distributions, which often put HDF5 libraries in `/usr/lib/x86_64-linux-gnu/`.
This path, or any other, can be added using

	$ make LDFLAGS=-L/path/to/library/folder

By default, `extract` uses multi-threading to improve performance. This can be
disabled by compiling as follows:
	
	$ make CXXFLAGS=-DNOTHREAD

`extract` will also dynamically disable threading, and process a single channel at a
time, if the data file to be processed is larger than some fraction of the available
system physical memory. This fraction is a compile-time constant, and is defined in
`src/main.cc` as `CONSERVE_MEMORY_FRACTION`. This is used to prevent the huge slowdowns
that come with moving to swap space.

Library
-------

Part of the extract source code compiles into a shared library for reading from 
recording files or from snip files. At the moment, this is created at `./lib/libextract.so`
for Linux machines or `./lib/libextract.dylib` for OS X. Headers for these files
can be found in the `./include` directory.

This means that others writing `C` or `C++` applications, or any language that can
link directly with such code, can use these libraries to interface with the various
file formats.

The library includes tools to read and write raw HDF5 recording files, the HDF5 
snippet file formats, and to perform computations useful for extracting snippets,
such as computing thresholds and extracting spike and noise snippets from raw
data.

File format
-----------

For details of the raw data file, [see this link](https://github.com/baccuslab/spike-sorting/wiki/data-file-format).
For details about the snippet file, [see here](https://github.com/baccuslab/spike-sorting/wiki/snippet-file-format).

