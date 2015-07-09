#include "H5Cpp.h"

#include "include/datafile.h"

int main(int argc, const char *argv[])
{
	unsigned int maj, min, rel;
	H5::H5Library::getLibVersion(maj, min, rel);
	return 0;
}
