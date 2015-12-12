/*! \file semaphore.cc
 *
 * Implementation of the Semaphore class.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "semaphore.h"

Semaphore::Semaphore(int n)
	: count(n)
{
}

Semaphore::~Semaphore() 
{
}

void Semaphore::wait()
{
	std::lock_guard<std::mutex> lg(lock);
	if (count == 0)
		cv.wait(lock, [this] { return count > 0; });
	count -= 1;
	return;
}

void Semaphore::signal()
{
	{
		std::lock_guard<std::mutex> lg(lock);
		count += 1;
	}
	cv.notify_all();
}

