/*! \file extract.h
 *
 * Header file for library components to extract noise and spike
 * snippets from raw data files.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_EXTRACT_H_
#define EXTRACT_EXTRACT_H_

#include <armadillo>

#include "datafile.h"
#include "semaphore.h"

/*! Type alias for standard samples of data from an MCS file */
using sampleMat = arma::Mat<short>;

/*! Contains routines for performing actual snippet extraction. */
namespace extract {

/* Generate random samples with replacement on the interval [min, max).
 * Each vector in `out` is an independent resampling of the population
 */
/*! Generates random samples with replacement on the interval [min, max).
 * \param out An armadillo vector which is loaded with an 
 * independent resample of the population.
 * \param min The minimum value of the range of the random sample
 * \param max The maximum value of the range of the random sample
 */
void randsample(arma::uvec& out, size_t min, size_t max);

/*! Return true if the given data sample is a local maximum
 * \param data The full matrix of data
 * \param channel Which channel to consider
 * \param sample The actual sample number
 * \param winsz The size of the smoothing window to apply.
 *
 * This function applies a boxcar filter to the data around
 * the given sample, and returns true if the given sample is
 * greater than the other values within that boxcar's size.
 */
bool isLocalMax(const sampleMat& data, size_t channel, 
		size_t sample, size_t winsz);


/* Extract noise and spike snippets from the data.
 * 
 * This routine does the following:
 * 	1. Load data from the given channel.
 * 	2. Compute the data mean and use it to center the data.
 * 	3. Compute the channel's threshold.
 * 	4. Extract random indices and snippets as noise.
 * 	5. Extract threshold-crossings as candidate spike snippets.
 *
 * \param sem A semaphore used to restrict the maximum number of background threads
 * running at once. Because much of work is CPU-bound, having more threads than logical
 * cores is counter-productive.
 * \param file The raw data file.
 * \param file_lock A mutex synchronizing access to the data file. The HDF5 library is
 * not thread-safe, even for read-only access to files.
 * \param channel The actual channel number being extracted.
 * \param thresh The multiplier used to compute the channel's actual threshold.
 * \param nrandom_snippets Number of noise snippets to extract.
 * \param nbefore Number of samples before a local maximum to consider as a candidate spike.
 * \param nafter Number of samples after a local maximum to consider as a candidate spike.
 * \param mean The channel mean (computed in this routine and overwritten)
 * \param threshold The channel threshold (computed in this routine and overwritten)
 * \param noise_idx Vector into which indices of the noise snippets are written.
 * \param noise_snips Matrix into which the actual noise snippets are written.
 * \param noise_lock Mutex synchronizing access to the array storing the noise snippets.
 * \param spike_idx Vector into which indices of the spike snippets are written.
 * \param spike_snips Matrix into which the actual spike snippets are written.
 * \param spike_lock Mutex synchronizing access to the array storing the spike snippets.
 */
void extract(Semaphore& sem, datafile::DataFile* file, std::mutex& file_lock, 
		size_t channel, double thresh,
		size_t nrandom_snippets, int nbefore, int nafter, double& mean, double& threshold, 
		arma::uvec& noise_idx, arma::Mat<short>& noise_snips, 
		std::mutex& noise_lock,
		arma::uvec& spike_idx, 
		arma::Mat<short>& spike_snips, std::mutex& spike_lock);

/*! Extract noise snippets from the given channel */
void extractNoiseFromChannel(const arma::Col<short>& data, 
		const size_t& nrandom_snippets, const int& nbefore, const int& nafter,
		arma::uvec& idx, sampleMat& snips);

/*! Extract spike snippets from the given channel */
void extractSpikesFromSingleChannel(const arma::Col<short>& data, double thresh,
		int nbefore, int nafter, arma::uvec& idx, sampleMat& snips);
};

#endif

