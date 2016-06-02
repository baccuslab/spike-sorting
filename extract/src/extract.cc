/* extract.cc
 *
 * Library components to extract noise and spike snippets from raw data.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "extract.h"
#include "snipfile.h"

#ifdef WITH_THREADS
# include "semaphore.h"
# include <thread>
# include <mutex>
# include <future>
#endif


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

#ifdef WITH_THREADS
double _mean_subtract(const sampleMat& data, size_t col, Semaphore& sem)
{
	sem.wait();
	auto mean = arma::mean(arma::conv_to<arma::vec>::from(data.col(col)));
	sem.signal();
	return mean;
}
#endif

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

#ifdef WITH_THREADS
double _compute_median(const sampleMat& data, size_t col, Semaphore& sem)
{
	sem.wait();
	auto median = arma::median(arma::abs(data.col(col)));
	sem.signal();
	return median;
}
#endif

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

double extract::computeThreshold(const arma::Col<short>& data, double thresh)
{
	return thresh * arma::median(arma::abs(data));
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

void extract::extractNoise(const sampleMat& data, const size_t& nrandom_snippets,
		const int& nbefore, const int& nafter, std::vector<arma::uvec>& idx, 
		std::vector<sampleMat>& snips, bool /* verbose */)
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

void extract::extractSpikesFromChannel(const sampleMat& data, size_t chan, double thresh,
		int nbefore, int nafter, arma::uvec& idx, sampleMat& snips)
{
	auto nsamples_per_snip = nbefore + nafter + 1;
	auto nsamples = data.n_rows;

	snips.set_size(nsamples_per_snip, snipfile::DEFAULT_NUM_SNIPPETS);
	idx.set_size(snipfile::DEFAULT_NUM_SNIPPETS);
	size_t snip_num = 0;

	arma::uword i = 0;
	while (i < nsamples - nafter - 1) {
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

#ifdef WITH_THREADS
void _extract_from_channel_multi(const sampleMat& data, size_t chan,
		double thresh, int nbefore, int nafter, arma::uvec& idx, sampleMat& snips,
		bool verbose, Semaphore& sem, std::mutex& oslock)
{
	sem.wait();
	extract::extractSpikesFromChannel(data, chan, thresh, nbefore, nafter, idx, snips);
	sem.signal();
	std::lock_guard<std::mutex> lock(oslock);
	std::cout << "  Channel " << chan << ": " << idx.size() 
		<< " snippets" << std::endl;
}
#endif

void extract::extractSpikes(const sampleMat& data, const arma::vec& thresholds, 
		const int& nbefore, const int& nafter,
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips, bool verbose)
{
	auto nchannels = data.n_cols;

#ifdef WITH_THREADS
	std::vector<std::future<void> > futs(data.n_cols);
	Semaphore sem(std::thread::hardware_concurrency());
	std::mutex oslock;
#endif

	for (decltype(nchannels) c = 0; c < nchannels; c++) {
#ifdef WITH_THREADS
		futs[c] = std::async(std::launch::async, _extract_from_channel_multi,
				std::ref(data), c, thresholds(c), nbefore, nafter,
				std::ref(idx.at(c)), std::ref(snips.at(c)), verbose, 
				std::ref(sem), std::ref(oslock));
#else
		if (verbose)
			std::cout << "  Channel: " << c;

		extractSpikesFromChannel(data, c, thresholds(c), nbefore, nafter,
				idx.at(c), snips.at(c));
		if (verbose)
			std::cout << "  Channel " << c << ": " idx.at(c).size() 
				<< " snippets" << std::endl;
#endif

	}

#ifdef WITH_THREADS
	for (decltype(nchannels) c = 0; c < nchannels; c++)
		futs[c].wait();
#endif
}

