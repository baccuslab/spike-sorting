/* extract.h
 *
 * Header file for library components to extract noise and spike
 * snippets from raw data files.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_EXTRACT_H_
#define EXTRACT_EXTRACT_H_

#include <vector>
#include <random>
#include <numeric>

#include <armadillo>

using sampleMat = arma::Mat<short>;

namespace extract {

/* Generate random samples without replacement on the interval [min, max).
 * Each vector in `out` is an independent resampling of the population
 */
void randsample(std::vector<arma::uvec>& out, size_t min, size_t max);

/* Mean-subtract each column of the given data */
void meanSubtract(sampleMat& data);

/* Compute thresholds independently for each colum of the given data.
 * The input `thresh` is the multiplier.
 */
arma::vec computeThresholds(const sampleMat& data, double thresh);

/* Return true if the given point of the data matrix is a local
 * maximum, using a boxcar filter to smooth the data first.
 */
bool isLocalMax(const sampleMat& data, size_t channel, 
		size_t sample, size_t winsz);

/* Extract noise snippets from the data */
void extractNoise(const sampleMat& data, const size_t& nrandom,
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips);

/* Extract spike snippets from the data */
void extractSpikes(const sampleMat& data, const arma::vec& thresholds,
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips);

};

#endif

