/* extract.cc
 *
 * Library components to extract noise and spike snippets from raw data.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "extract.h"
#include "snipfile.h"

void extract::randsample(std::vector<arma::uvec>& out, size_t min, size_t max)
{
	size_t min_size = arma::datum::inf;
	for (auto& each : out) {
		if ( each.n_elem < min )
			min = each.n_elem;
	}

	if ( min_size > (max - min))
		throw std::logic_error(
				"Number of requested elems must be less than (max - min)");
	/* Create uniform distribution on [max, min) */
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> dist(0, max - min - 1);

	/* Shuffle each column (channel) independently, draw value from it */
	std::vector<size_t> pop(max - min);
	std::iota(pop.begin(), pop.end(), min);
	for (auto c = 0; c < out.size(); c++) {
		auto& v = out.at(c);
		for (auto i = 0; i < v.n_elem; i++) {
			auto idx = dist(gen);
			std::swap(pop[i], pop[idx]);
			v(i) = pop[idx];
		}
	}
}

void extract::meanSubtract(sampleMat& data)
{
	for (auto i = 0; i < data.n_cols; i++)
		data.col(i) -= arma::mean(arma::conv_to<arma::vec>::from(data.col(i)));
}

arma::vec extract::computeThresholds(const sampleMat& data, double thresh)
{
	return thresh * arma::conv_to<arma::vec>::from(arma::median(arma::abs(data)));
}

bool extract::isLocalMax(const sampleMat& data, size_t channel, 
		size_t sample, size_t n)
{
	/* Compute box-car average of samples in data(i, j) of size n,
	 * and return true if mid-point is a local maximum.
	 */
	arma::vec tmp(n);
	auto mid = std::floor(n / 2);
	for (auto k = 0; k < n; k++)
		tmp(k) = arma::accu(data(
				arma::span(sample - n + k + 1, sample + k), channel)) / n;
	return (arma::all(tmp(arma::span(0, mid - 1)) < tmp(mid)) && 
			arma::all(tmp(arma::span(mid, n - 1)) <= tmp(mid)));
}

void extract::extractNoise(const sampleMat& data, const size_t& nrandom_snippets,
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips)
{
	/* Create random indices into each channel */
	auto nsamples_per_snip = snipfile::NUM_SAMPLES_BEFORE + 
		snipfile::NUM_SAMPLES_AFTER + 1;
	auto nsamples = data.n_rows, nchannels = data.n_cols;
	for (auto& each : idx)
		each.set_size(nrandom_snippets);
	randsample(idx, snipfile::NUM_SAMPLES_BEFORE, 
			nsamples - snipfile::NUM_SAMPLES_AFTER);

#ifdef DEBUG
	std::cout << "Extracting noise snippets" << std::endl;
#endif

	/* Extract snippets at those random indices */
	for (auto c = 0; c < nchannels; c++) {

#ifdef DEBUG
		std::cout << " Channel " << c << std::endl;
#endif

		auto& snip_mat = snips.at(c);
		snip_mat.set_size(nsamples_per_snip, nrandom_snippets);
		auto& ix = idx.at(c);
		for (auto s = 0; s < nrandom_snippets; s++) {
			auto& start = ix.at(s);
			snip_mat(arma::span::all, s) = data(
					arma::span(start - snipfile::NUM_SAMPLES_BEFORE,
					start + snipfile::NUM_SAMPLES_AFTER), c);
		}
	}
}

void extract::extractSpikes(const sampleMat& data, const arma::vec& thresholds, 
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips)
{
	auto nsamples_per_snip = snipfile::NUM_SAMPLES_BEFORE + 
		snipfile::NUM_SAMPLES_AFTER + 1;
	auto nsamples = data.n_rows, nchannels = data.n_cols;

#ifdef DEBUG
	std::cout << "Extracting spike snippets" << std::endl;
#endif 

	for (auto c = 0; c < nchannels; c++) {
		auto& idx_vec = idx.at(c);
		auto& snip_mat = snips.at(c);
		auto& thresh = thresholds(c);
		snip_mat.set_size(nsamples_per_snip, snipfile::DEFAULT_NUM_SNIPPETS);
		idx_vec.set_size(snipfile::DEFAULT_NUM_SNIPPETS);
		size_t snip_num = 0;

		/* Find snippets */
		arma::uword i = snipfile::NUM_SAMPLES_BEFORE;
		while (i < nsamples - snipfile::NUM_SAMPLES_AFTER + 1) {
			if (data(i, c) > thresh) {
				if (isLocalMax(data, c, i, snipfile::WINDOW_SIZE)) {
					if (snip_num >= snip_mat.n_cols) {
						snip_mat.resize(snip_mat.n_rows, 2 * snip_mat.n_cols);
						idx_vec.resize(2 * snip_mat.n_cols);
					}
					idx_vec(snip_num) = i;
					snip_mat(arma::span::all, snip_num) = data(
							arma::span(i - snipfile::NUM_SAMPLES_BEFORE,
							i + snipfile::NUM_SAMPLES_AFTER), c);
					snip_num++;
					i += snipfile::WINDOW_SIZE;
				} else
					i++;
			} else
				i++;
		}
		snip_mat.resize(snip_mat.n_rows, snip_num);
		idx_vec.resize(snip_num);

#ifdef DEBUG
		std::cout << " Channel " << c << ": " << snip_num << " snippets" << std::endl;
#endif

	}
}

