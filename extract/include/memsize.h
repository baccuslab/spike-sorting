/*! \file memsize.h
 * Header file exporting a function to approximate the amount of 
 * available memory on a system.
 */

#ifndef _MEMSIZE_H_
#define _MEMSIZE_H_

#if defined __linux__

#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/resource.h>

uint64_t get_available_mem() {
	size_t pagesz = sysconf(_SC_PAGE_SIZE);
	size_t npages = sysconf(_SC_PHYS_PAGES);
	return pagesz * npages;
}


#elif defined __APPLE__

#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/sysctl.h>

uint64_t get_available_mem() {
	size_t pagesz = sysconf(_SC_PAGE_SIZE);
	uint64_t mem = 0;
	size_t len = sizeof(mem);
	sysctlbyname("hw.memsize", &mem, &len, NULL, 0);
	return mem;
}

#else
#error "Unsupported OS"
#endif

#include <string>
#include <sys/stat.h>


/*! Return true if the size of the given file, which must exist,
 * is larger than `frac` fraction of the available system physical memory.
 */
bool should_conserve_mem(const std::string& filename, double frac) {
	struct stat buf;
	if (stat(filename.c_str(), &buf) != 0) {
		return false;
	}
	return (buf.st_size > (static_cast<double>(get_available_mem()) * frac));
}

#endif

