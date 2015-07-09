/* test.cc
 *
 * Simple program to test reading a data file.
 * 
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include <iostream>

#include <armadillo>

//#include "datafile.h"
#include "mcsfile.h"

int main(int argc, const char *argv[])
{
	mcsfile::McsFile f("./2015-01-27a.h5");
	std::cout << f.nchannels() << std::endl;
	std::cout << f.array() << std::endl;
	datafile::sampleMat out;
	f.data(0, 100, out);
	return 0;
}
