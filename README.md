spike-sorting
=============

Repository of spike-sorting applications and related tools and libraries.
(C) 2015 Baccus Lab

matlab
------

Contains source for Matlab GUI sorting application, and C++ source for some
compiled mex-functions used by the sorting application

##### Compiling c++ soure
Include all the names of the source codes in the list `compile_mex.m` matlab code:

    source_codes = {'AutoCorr.cpp', 'CrossCorr.cpp'};
  
Run the following command in the `spike-sorting/matlab` folder to compile c++ source 
codes into mex-functions in the command line:

    ./installmexfiles

extract
-------

Contains source code for C++ application to extract spike and noise snippets
from raw data HDF5 files.

Making extract requires armadillo, a C++ linear algebra library. If you have homebrew, you can get
armadillo by  
```bash
brew install homebrew/science/armadillo 
```

You will also need the HDF5 libraries, if you don't already have them. You can get these by
$ brew install homebrew/science/hdf5

To install extract,
-------
$ cd /path/to/extract/  
$ mkdir build lib bin 
$ make  
$ make install # optional  

wiki
----

See the [Wiki](https://github.com/baccuslab/spike-sorting/wiki) for more info
