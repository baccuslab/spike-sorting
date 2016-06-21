/* extract.cc
 *
 * Library components to extract noise and spike snippets from raw data.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "extract.h"
#include "snipfile.h"
# include "semaphore.h"

#include <random>	// random_device, etc
#include <thread>
#include <mutex>
#include <future>
#include <numeric>	// accumulate

using Lock = std::lock_guard<std::mutex>;

void extract::extract(Semaphore& sem, datafile::DataFile* file, std::mutex& file_lock,
		size_t channel, double thresh,
		size_t nrandom_snippets, int nbefore, int nafter, double& mean, double& threshold, 
		arma::uvec& noise_idx, 
		arma::Mat<short>& noise_snips, std::mutex& noise_lock,
		arma::uvec& spike_idx, 
		arma::Mat<short>& spike_snips, std::mutex& spike_lock)
{

	/* Wait for access to one of the processor cores */
	sem.wait();

	/* Read all data from channel */
	arma::Col<short> data;
	{
		Lock lg(file_lock);
		try {
			file->data(channel, 0, file->nsamples(), data);
		} catch ( ... ) {
			sem.signal();
			throw;
		}
	}

	/* Extract noise */
	{ 
		Lock lg(noise_lock);
		try {
			extractNoiseFromChannel(data, nrandom_snippets, nbefore, nafter, 
					noise_idx, noise_snips);
		} catch ( ... ) {
			sem.signal();
			throw;
		}
	}

	/* Compute channel mean, and subtract from data
	 * NOTE: std::accumulate is used to compute the mean as a double, without
	 * calling std::conv_to<double> on the whole array and duplicating it in
	 * memory.
	 */
	mean = std::accumulate(data.begin(), data.end(), 0.0);
	mean /= data.n_elem;
	data -= static_cast<short>(mean);

	/* Compute channel threshold */
	threshold = thresh * static_cast<double>(arma::median(arma::abs(data)));

	/* Extract spike snippets */
	{
		Lock lg(spike_lock);
		try {
			extractSpikesFromSingleChannel(data, threshold, nbefore, nafter, 
					spike_idx, spike_snips);
		} catch ( ... ) {
			sem.signal();
			throw;
		}
	}
	sem.signal();
}

void extract::randsample(arma::uvec& out, size_t min, size_t max)
{
	if (out.n_elem > (max - min))
		throw std::logic_error("Number of requested elems must be less than (max - min)");
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> dist(min, max - 1);
	for (arma::uword i = 0; i < out.n_elem; i++)
		out(i) = dist(gen);
}

bool extract::isLocalMax(const sampleMat& data, size_t channel, 
		size_t sample, size_t n)
{
	/* Compute box-car average of samples in data(i, j) of size n,
	 * and return true if mid-point is a local maximum.
	 */
	arma::vec tmp(n);
	for (decltype(n) k = 0; k < n; k++) {
		tmp(k) = arma::accu(arma::conv_to<arma::vec>::from(
				data(arma::span(sample - n + k + 1, 
				sample + k), channel))) / n;
	}
	auto mid = std::floor(double(n) / 2);
	return (arma::all(tmp(arma::span(0, mid - 1)) < tmp(mid)) && 
			arma::all(tmp(arma::span(mid + 1, n - 1)) <= tmp(mid)));
}

void extract::extractNoiseFromChannel(const arma::Col<short>& data, 
		const size_t& nrandom_snippets, const int& nbefore, const int& nafter,
		arma::uvec& idx, sampleMat& snips)
{
	auto nsamples_per_snip = nbefore + nafter + 1;
	idx.set_size(nrandom_snippets);
	randsample(idx, nbefore, data.n_elem - nafter);
	snips.set_size(nsamples_per_snip, nrandom_snippets);
	for (auto s = decltype(nrandom_snippets){0}; s < nrandom_snippets; s++) {
		auto& start = idx.at(s);
		snips(arma::span::all, s) = data(arma::span(start - nbefore, start + nafter));
	}
}

void extract::extractSpikesFromSingleChannel(const arma::Col<short>& data,
		double thresh, int nbefore, int nafter, arma::uvec& idx, sampleMat& snips)
{
	auto nsamples_per_snip = nbefore + nafter + 1;
	auto nsamples = data.n_elem;

	snips.set_size(nsamples_per_snip, snipfile::DEFAULT_NUM_SNIPPETS);
	idx.set_size(snipfile::DEFAULT_NUM_SNIPPETS);
	size_t snip_num = 0;

	arma::uword i = 0;
	while (i < nsamples - nafter) {
		if (data(i) > thresh) {
			if (extract::isLocalMax(data, 0, i, snipfile::WINDOW_SIZE)) {
				if (snip_num >= snips.n_cols) {
					snips.resize(snips.n_rows, 2 * snips.n_cols);
					idx.resize(2 * idx.n_rows);
				}
				idx(snip_num) = i;
				snips(arma::span::all, snip_num) = data(arma::span(i - nbefore, i + nafter));
				snip_num++;
			}
		}
		i += 1;
	}
	snips.resize(snips.n_rows, snip_num);
	idx.resize(snip_num);
}

