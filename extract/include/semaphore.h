/*! \file semaphore.h
 *
 * Implementation of a semaphore class, used when running extract in a 
 * multi-threaded environment to prevent cache thrashing.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef _SEMAPHORE_H_
#define _SEMAPHORE_H_

#include <mutex>
#include <condition_variable>

/*! Basic semaphore class.
 *
 * A semaphore is a thread-synchronization primitive, which protects a
 * fixed number of identical resources. Client code calls wait() when
 * wishing to acquire one of those resources, which will efficiently block
 * the calling thread until it is available. When finished with the resource,
 * the client code must call signal(). 
 *
 * The resource being protected in this case is threads. The most time-consuming
 * computation performed by the extract program is the computation of thresholds,
 * which are based on the median of a data channel. This requires sorting 
 * roughly half of the samples, and because each channel is independent, this 
 * sorting can happen in parallel for different channels. 
 *
 * However, because the thread's work is CPU bound, running more threads than 
 * there are processors is terribly inefficient. the scheduler will dutifully 
 * schedule time for those threads on any available processor, which is probably
 * _not_ the processor on which the work was previously running, meaning the 
 * cache is completely cold. These cache misses are expensive, and just slow down
 * the overall computation anyway. 
 *
 * This class is used by the extract routines to restrict the number of parallel
 * computations to the number of processors/cores on the machine.
 */
class Semaphore {
	public:
		/*! Construct a Semaphore.
		 * \param count The number of resources to protect.
		 */
		Semaphore(int count = 0);

		/*! Destroy a Semaphore */
		~Semaphore();

		/*! Wait for a resource to become available.
		 *
		 * This call will block the calling thread efficiently until the
		 * resource becomes available.
		 */
		void wait();

		/*! Signal that you are done with the resource. */
		void signal();

		Semaphore(const Semaphore& other) = delete;
		Semaphore(Semaphore&& other) = delete;
		Semaphore& operator=(const Semaphore& other) = delete;

	private:
		int count;
		std::mutex lock;
		std::condition_variable_any cv;
};

#endif

