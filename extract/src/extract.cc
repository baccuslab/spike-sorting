/* extract.cc
 *
 * Library components to extract noise and spike snippets from raw data.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "extract.h"
#include "snipfile.h"

#ifdef WITH_THREADS
#include "semaphore.h"
#include <thread>
#endif

#include <future>

void extract::randsample(std::vector<arma::uvec>& out, size_t min, size_t max)
{
	size_t min_size = arma::datum::inf;
	for (auto& each : out) {
		if (each.n_elem < min_size)
			min_size = each.n_elem;
	}
	if (min_size > (max - min))
		throw std::logic_error(
				"Number of requested elems must be less than (max - min)");

	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> dist(min, max - 1);
	for (decltype(out.size()) c = 0; c < out.size(); c++) {
		auto& v = out.at(c);
		for (arma::uword i = 0; i < v.n_elem; i++)
			v(i) = dist(gen);
	}
}

double _mean_subtract(const sampleMat& data, size_t col, Semaphore& sem)
{
	sem.wait();
	auto mean = arma::mean(arma::conv_to<arma::vec>::from(data.col(col)));
	sem.signal();
	return mean;
}

arma::vec extract::meanSubtract(sampleMat& data)
{
	arma::vec means(data.n_cols, arma::fill::zeros);
#ifdef WITH_THREADS
	std::vector<std::future<double> > futs(data.n_cols);
	Semaphore sem(std::thread::hardware_concurrency());
	for (auto i = decltype(data.n_cols){0}; i < data.n_cols; i++)
		futs[i] = std::async(std::launch::async, _mean_subtract, 
				std::ref(data), i, std::ref(sem));
	for (auto i = decltype(data.n_cols){0}; i < data.n_cols; i++) {
		means(i) = futs[i].get();
		data.col(i) -= means(i);
	}
#else
	for (auto i = decltype(data.n_cols){0}; i < data.n_cols; i++) {
		means(i) = arma::mean(arma::conv_to<arma::vec>::from(data.col(i)));
		data.col(i) -= means(i);
	}
#endif
	return means;
}

double _compute_median(const sampleMat& data, size_t col, Semaphore& sem)
{
	sem.wait();
	auto median = arma::median(arma::abs(data.col(col)));
	sem.signal();
	return median;
}

arma::vec extract::computeThresholds(const sampleMat& data, double thresh)
{
#ifdef WITH_THREADS
	arma::vec thresholds(data.n_cols, arma::fill::zeros);
	std::vector<std::future<double> > futs(data.n_cols);
	Semaphore sem(std::thread::hardware_concurrency());
	for (auto i = decltype(data.n_cols){0}; i < data.n_cols; i++)
		futs[i] = std::async(std::launch::async, _compute_median,
				std::ref(data), i, std::ref(sem));
	for (auto i = decltype(data.n_cols){0}; i < data.n_cols; i++)
		thresholds(i) = thresh * futs[i].get();
	return thresholds;
#else
	return thresh * arma::conv_to<arma::vec>::from(arma::median(arma::abs(data)));
#endif
}

bool extract::isLocalMax(const sampleMat& data, size_t channel, 
		size_t sample, size_t n)
{
	/* Compute box-car average of samples in data(i, j) of size n,
	 * and return true if mid-point is a local maximum.
	 */
	arma::vec tmp(n);
	auto mid = std::floor(n / 2);
	for (decltype(n) k = 0; k < n; k++)
		tmp(k) = arma::accu(data(
				arma::span(sample - n + k + 1, sample + k), channel)) / n;
	return (arma::all(tmp(arma::span(0, mid - 1)) < tmp(mid)) && 
			arma::all(tmp(arma::span(mid, n - 1)) <= tmp(mid)));
}

void extract::extractNoise(const sampleMat& data, const size_t& nrandom_snippets,
		const int& nbefore, const int& nafter, std::vector<arma::uvec>& idx, 
		std::vector<sampleMat>& snips, bool verbose)
{
	/* Create random indices into each channel */
	auto nsamples_per_snip = nbefore + nafter + 1;
	auto nsamples = data.n_rows, nchannels = data.n_cols;
	for (auto& each : idx)
		each.set_size(nrandom_snippets);
	randsample(idx, nbefore, nsamples - nafter);

	/* Extract snippets at those random indices */
	for (decltype(nchannels) c = 0; c < nchannels; c++) {
		auto& snip_mat = snips.at(c);
		snip_mat.set_size(nsamples_per_snip, nrandom_snippets);
		auto& ix = idx.at(c);
		for (auto s = decltype(nrandom_snippets){0}; s < nrandom_snippets; s++) {
			auto& start = ix.at(s);
			snip_mat(arma::span::all, s) = data(
					arma::span(start - nbefore, start + nafter), c);
		}
	}
}

void _extract_from_channel(const sampleMat& data, size_t chan, double thresh,
		int nbefore, int nafter, arma::uvec& idx, sampleMat& snips)
{
	auto nsamples_per_snip = nbefore + nafter + 1;
	auto nsamples = data.n_rows, nchannels = data.n_cols;

	snips.set_size(nsamples_per_snip, snipfile::DEFAULT_NUM_SNIPPETS);
	idx.set_size(snipfile::DEFAULT_NUM_SNIPPETS);
	size_t snip_num = 0;

	arma::uword i = 0;
	while (i < nsamples - nafter) {
		if (data(i, chan) > thresh) {
			if (extract::isLocalMax(data, chan, i, snipfile::WINDOW_SIZE)) {
				if (snip_num >= snips.n_cols) {
					snips.resize(snips.n_rows, 2 * snips.n_cols);
					idx.resize(2 * idx.n_rows);
				}
				idx(snip_num) = i;
				snips(arma::span::all, snip_num) = data(
						arma::span(i - nbefore, i + nafter), chan);
				snip_num++;
			}
		}
		i += 1;
	}
	snips.resize(snips.n_rows, snip_num);
	idx.resize(snip_num);
}

void extract::extractSpikes(const sampleMat& data, const arma::vec& thresholds, 
		const int& nbefore, const int& nafter,
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips, bool verbose)
{
	auto nsamples_per_snip = nbefore + nafter + 1;
	auto nsamples = data.n_rows, nchannels = data.n_cols;

#ifdef WITH_THREADS
	std::vector<std::future<void> > futs(data.n_cols);
#endif

	for (decltype(nchannels) c = 0; c < nchannels; c++) {

#ifdef WITH_THREADS
		futs[c] = std::async(std::launch::async, _extract_from_channel,
				std::ref(data), c, thresholds(c), nbefore, nafter,
				std::ref(idx.at(c)), std::ref(snips.at(c)));
#else

		if (verbose)
			std::cout << "  Channel: " << c;

		_extract_from_channel(data, c, thresholds(c), nbefore, nafter,
				idx.at(c), snips.at(c));
		if (verbose)
			std::cout << " (" << idx.at(c).size() << " snippets)" << std::endl;

#endif

	}

#ifdef WITH_THREADS
	for (decltype(nchannels) c = 0; c < nchannels; c++) {
		futs[c].wait();
		if (verbose)
			std::cout << "  Channel " << c << ": (" << idx.at(c).size() 
				<< " snippets)" << std::endl;
	}
#endif
}

