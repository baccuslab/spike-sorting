/*! \file extract.h
 *
 * Header file for library components to extract noise and spike
 * snippets from raw data files.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_EXTRACT_H_
#define EXTRACT_EXTRACT_H_

#ifndef NOTHREAD
#define WITH_THREADS
#endif

#include <vector>
#include <random>
#include <numeric>

#include <armadillo>

/*! Type alias for standard samples of data from an MCS file */
using sampleMat = arma::Mat<short>;

/*! Contains routines for performing actual snippet extraction. */
namespace extract {

/* Generate random samples with replacement on the interval [min, max).
 * Each vector in `out` is an independent resampling of the population
 */
/*! Generates random samples with replacement on the interval [min, max).
 * \param out A vector of vectors, each of which is loaded with an 
 * independent resample of the population.
 * \param min The minimum value of the range of the random sample
 * \param max The maximum value of the range of the random sample
 */
void randsample(std::vector<arma::uvec>& out, size_t min, size_t max);

/*! Subtract the mean from each column of data, and return them */
arma::vec meanSubtract(sampleMat& data);

/*! Compute the threshold value for each data column.
 * \param data The matrix storing raw data.
 * \param thresh The threshold multiplier.
 *
 * The threshold is actually computed as:
 *
 * t = thresh * median(abs(meanSubtract(data)))
 */
arma::vec computeThresholds(const sampleMat& data, double thresh);

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

/*! Extract all noise snippets from the data
 * \param data The data matrix
 * \param nrandom The number of random snippets to extract.
 * \param nbefore Number of samples before random index peak to extract.
 * \param nafter Number of samples after random index peak to extract.
 * \param idx The vector of indices of the random snippets
 * \param snips The arrays of actual snippets.
 *
 * Noise snippets are simply random sections of the raw data.
 * This function chooses `nrandom` random points in the file,
 * and fills the output array `idx` with those indices, and 
 * the output array `snips` with the raw data at those times.
 */
void extractNoise(const sampleMat& data, const size_t& nrandom,
		const int& nbefore, const int& nafter,
		std::vector<arma::uvec>& idx, 
		std::vector<sampleMat>& snips);

/*! Extract all spikes from the raw data.
 * \param data The data matrix from which to extract.
 * \param thresholds An array of thresholds for each channel.
 * \param nbefore Number of samples before a spike peak to extract.
 * \param nafter Number of samples after a spike peak to extract.
 * \param idx Array filled with indices of each extract snippet.
 * \param snips The extracted snippets for each channel.
 *
 * After computing thresholds, this function extracts small sections
 * of the raw data file that are:
 *
 * 	- Above the threshold and
 * 	- A local maximum
 *
 * A small number of samples before and slightly larger number of 
 * samples after this peak value is extracted from the file and 
 * considered a candidate spike, or snippet.
 *
 * The output array's contain one element for each channel.
 */
void extractSpikes(const sampleMat& data, const arma::vec& thresholds,
		const int& nbefore, const int& nafter,
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips);

};

#endif

