extract
=======

Extract is a command-line tool to extract noise and candidate spike
snippets from raw HDF5 recording files for spike sorting.

(C) 2015 Benjamin Naecker bnaecker@stanford.edu

Usage
-----

	./extract 	[ -v | --version ] [-h | --help ]
				[ -t | --threshold <threshold> ]
				[ -c | --chan <chanlist> ]
				[ -n | --nrandom <nrandom> ]
				[ -o | --output <name> ]
				<recording>

Parameters
----------

- `-v | --version` 
	- Display version info and exit
- `-h | --help` 
	- Display help and exit
- `-t | --threshold <threshold>` 
	- Candidate spikes are those sections of the data trace
which are above a threshold, set as `<threshold> * median(abs(v - mean(v)))`
- `-c | --chan <chanlist>` 
	- A comma-separated and dash-separated list of channels from
which data is extracted. Dashes indicate a channel range, e.g., `0-4` extracts
data from channels `0` through `3`, and `1,2,3` extracts from exactly those channels.
These can be composed, e.g., `1,2,3,4-10`. Note that indexing is `0`-based and
intervals are half-open.
- `-n | --nrandom <nrandom>`
	- The number of random snippets to extract from each channel. Defaults to 5000.
- `-o | --output <basename>` 
	- A base name for the output file. Snippets will be saved to
`<basename>.snip`.

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
Check out the header files [`./include/datafile.h`](https://github.com/baccuslab/spike-sorting/tree/master/extract/include/datafile.h), [`./include/snipfile.h`](https://github.com/baccuslab/spike-sorting/extract/tree/master/include/snipfile.h), and [`./include/extract.h`](https://github.com/baccuslab/spike-sorting/spike-sorting/tree/master/include/extract.h) for a description
of the public API for the library used to access and manipulate these files. 
Real documentation for the API is forthcoming...

