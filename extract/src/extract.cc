/* extract.cc
 *
 * Program for extracting spike and noise snippets from raw HDF5 data.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include <stdlib.h>
#include <getopt.h>
#include <sys/stat.h>

#include <algorithm>
#include <string>
#include <sstream>
#include <iostream>
#include <vector>

#include <armadillo>

#include "mcsfile.h"
#include "hidensfile.h"
#include "snipfile.h"

#define UL_PRE "\033[4m"
#define UL_POST "\033[0m"
#define DEFAULT_THRESHOLD 4.5;
#define VERSION_MAJOR 0
#define VERSION_MINOR 1
#define HIDENS_CHANNEL_MAX 127
#define HIDENS_CHANNEL_MIN 1
#define MCS_CHANNEL_MAX 64
#define MCS_CHANNEL_MIN 3

using sampleMat = arma::Mat<short>;

const char PROGRAM[] = "extract";
const char AUTHOR[] = "Benajmin Naecker";
const char AUTHOR_EMAIL[] = "bnaecker@stanford.edu";
const char YEAR[] = "2015";
const char USAGE[] = "\n\
 Usage: extract \t[-v | --version] [-h | --help]\n\
  \t\t\t[-t | --threshold " UL_PRE "threshold" UL_POST "]\n\
  \t\t\t[-c | --chan " UL_PRE "chan-list" UL_POST "]\n\
  \t\t\t[-o | --output " UL_PRE"name" UL_POST "]\n\
  \t\t\t" UL_PRE "recording-file" UL_POST "\n\n\
 Extract noise and spike snippets from the given recording file\n\n\
 Parameters:\n\
   " UL_PRE "threshold" UL_POST "\tThreshold multiplier for determining spike\n\
   \t\tsnippets. The threshold will be set independently for each channel, such\n\
   \t\tthat: " UL_PRE "threshold" UL_POST " * median(abs(v)). Default = DEFAULT_THRESHOLD\n\
   " UL_PRE "chan" UL_POST "\t\tA comma- or dash-separated list of channels from which\n\
   \t\tsnippets will be extracted. E.g., \"0,1,2,3\" will extract data only from\n\
   \t\tthe first 4 channels, while \"[0-4,8,10-]\" will extract data from the first\n\
   \t\t4 channels, the 9th, and channels 11 to the number of channels in the file.\n\
   \t\tFor MCS data files, the default is [3-63], and for Hidens files, the default\n\
   \t\tis [1-].\n\
   " UL_PRE "output" UL_POST "\tThe base-name for the output spike and random snippet\n\
   \t\tfiles. They will be named as: " UL_PRE "basename" UL_POST ".ssnp and "\
   UL_PRE "basename" UL_POST ".rsnp\n\n";

void print_usage_and_exit()
{
	std::cout << USAGE << std::endl;
	exit(EXIT_SUCCESS);
}

void print_version_and_exit()
{
	std::cout << PROGRAM << " version " << VERSION_MAJOR << "." << VERSION_MINOR << std::endl;
	std::cout << "(C) " << YEAR << " " << AUTHOR << " " << AUTHOR_EMAIL << std::endl;
	exit(EXIT_SUCCESS);
}

size_t channel_min(std::string array)
{
	if (array == "unknown" || array == "hidens") 
		return HIDENS_CHANNEL_MIN;
	return MCS_CHANNEL_MIN;
}

size_t channel_max(std::string array)
{
	if (array == "unknown" || array == "hidens") 
		return HIDENS_CHANNEL_MAX;
	return MCS_CHANNEL_MAX;
}

bool is_hidens(std::string array)
{
	return (array == "hidens");
}

H5::DataType get_array_dtype(std::string array)
{
	return (array == "hidens") ? H5::PredType::STD_U8LE : H5::PredType::STD_I16LE;
}

void parse_chan_list(std::string arg, arma::uvec& channels, 
		unsigned int max)
{
	/* Split the input string on ','. Each element is either a single channel
	 * or a dash-separated list of channels
	 */
	std::vector<std::string> ss;
	std::string tmp;
	for (auto& c : arg) {
		if (c == ',') {
			ss.push_back(tmp);
			tmp.erase();
		} else {
			tmp.append(1, c);
		}
	}
	if (!tmp.empty())
		ss.push_back(tmp);

	/* Parse each element. Singleton strings are expected to be integers,
	 * and are added directly. Others are dash-separated; the two ends are
	 * converted to ints, and then everything between is filled in.
	 */
	try { 
		for (auto& each : ss) {
			auto dash = each.find('-');
			if (dash == std::string::npos) {
				auto x = std::stoul(each);
				channels.resize(channels.n_elem + 1);
				channels(channels.n_elem - 1) = x;
			} else {
				size_t pos;
				unsigned long start;
				start = std::stoul(each, &pos);
				unsigned long end;
				if (each.back() == '-')
					end = max;
				else {
					auto tmp = std::stoul(each.substr(dash + 1));
					end = (tmp > max) ? max : tmp;
				}
				auto num = end - start;
				channels.resize(channels.n_elem + num);
				for (auto i = 0; i < num; i++)
					channels(channels.n_elem - i - 1) = start + i;
			}
		}
	} catch ( std::exception& e ) {
		std::cerr << "Invalid channel list: " << arg << std::endl;
		exit(EXIT_FAILURE);
	}
	std::sort(channels.begin(), channels.end());
	std::unique(channels.begin(), channels.end());
}

void parse_command_line(int argc, char **argv, 
		double& thresh, std::string& chan_arg, std::string& output, 
		std::string& filename)
{
	if (argc == 1)
		print_usage_and_exit();

	/* Parse options */
	struct option options[] = {
		{ "threshold", 	required_argument, 	nullptr, 't' },
		{ "help", 		no_argument, 		nullptr, 'h' },
		{ "version", 	no_argument, 		nullptr, 'v' },
		{ "chan", 		required_argument, 	nullptr, 'c' },
		{ nullptr, 		0, 					nullptr, 0 	 }
	};
	int opt;
	while ( (opt = getopt_long(argc, argv, "t:hhvc:", options, nullptr)) != -1 ) {
		switch (opt) {
			case 'h':
				print_usage_and_exit();
			case 'v':
				print_version_and_exit();
			case 't':
				try {
					thresh = std::stof(std::string(optarg));
				} catch ( ... ) {
					std::cerr << "Invalid threshold: " << optarg << std::endl;
					exit(EXIT_FAILURE);
				}
				break;
			case 'c':
				chan_arg = std::string(optarg);
				break;
			case 'o':
				output = std::string(optarg);
				break;
		}
	}
	argv += optind;
	argc -= optind;
	if (argc == 0)
		print_usage_and_exit();
	filename = std::string(argv[0]);
	
	if (output.empty()) {
		size_t pos = filename.rfind(".");
		output = filename.substr(0, pos);
		std::string output_name = output + snipfile::FILE_EXTENSION;
		struct stat buf;
		if (stat(output_name.c_str(), &buf) == 0) {
			std::cerr << "Output file already exists: " + output_name << std::endl;
			exit(EXIT_FAILURE);
		}
	}
}

std::string get_array(std::string filename)
{
	return datafile::DataFile(filename).array();
}

void randsample(std::vector<arma::uvec>& out, size_t min, size_t max)
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

arma::vec compute_thresholds(const sampleMat& data, double thresh)
{
	return thresh * arma::conv_to<arma::vec>::from(arma::median(arma::abs(data), 0));
}

bool is_local_max(const sampleMat& data, size_t channel, size_t sample, size_t n)
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

void extract_noise(const sampleMat& data,
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips)
{
	/* Create random indices into each channel */
	auto nsamples_per_snip = snipfile::NUM_SAMPLES_BEFORE + 
		snipfile::NUM_SAMPLES_AFTER;
	auto nsamples = data.n_rows, nchannels = data.n_cols;
	for (auto& each : idx)
		each.set_size(snipfile::NUM_RANDOM_SNIPPETS);
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
		snip_mat.set_size(nsamples_per_snip, snipfile::NUM_RANDOM_SNIPPETS);
		auto& ix = idx.at(c);
		for (auto s = 0; s < snipfile::NUM_RANDOM_SNIPPETS; s++) {
			auto& start = ix.at(s);
			snip_mat(arma::span::all, s) = data(
					arma::span(start - snipfile::NUM_SAMPLES_BEFORE,
					start + snipfile::NUM_SAMPLES_AFTER - 1), c);
		}
	}
}

void extract_spikes(const sampleMat& data, const arma::vec& thresholds, 
		std::vector<arma::uvec>& idx, std::vector<sampleMat>& snips)
{
	auto nsamples_per_snip = snipfile::NUM_SAMPLES_BEFORE + 
		snipfile::NUM_SAMPLES_AFTER;
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
		while (i < nsamples - snipfile::NUM_SAMPLES_AFTER) {
			if (data(i, c) > thresh) {
				if (is_local_max(data, c, i, snipfile::WINDOW_SIZE)) {
					if (snip_num >= snip_mat.n_cols) {
						snip_mat.resize(snip_mat.n_rows, 2 * snip_mat.n_cols);
						idx_vec.resize(2 * snip_mat.n_cols);
					}
					idx_vec(snip_num) = i;
					snip_mat(arma::span::all, snip_num) = data(
							arma::span(i - snipfile::NUM_SAMPLES_BEFORE,
							i + snipfile::NUM_SAMPLES_AFTER - 1), c);
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

bool sequential_channels(const arma::uvec& channels)
{
	if (channels.n_elem == 1)
		return true;
	return arma::any(channels(arma::span(1, channels.n_elem - 1)) -
			channels(arma::span(0, channels.n_elem - 2)) > 1);
}

int main(int argc, char *argv[])
{	
	/* Parse input and get the array type */
	auto thresh = DEFAULT_THRESHOLD;
	std::string chan_arg, output, filename;
	parse_command_line(argc, argv, thresh, chan_arg, output, filename);
	std::string array = get_array(filename);

	/* Get channels based on input */
	arma::uvec channels;
	if (chan_arg.empty()) {
		auto min = channel_min(array), max = channel_max(array);
		channels.set_size(max - min);
		for (auto& each : channels)
			each = min++;
	} else
		parse_chan_list(chan_arg, channels, channel_max(array));

	/* Open the data file and read all data */
#ifdef DEBUG
	std::cout << "Loading data from channels: " << std::endl << channels;
#endif
	datafile::DataFile file(filename);
	sampleMat data;
	if (sequential_channels(channels))
		file.data(channels, 0, file.nsamples(), data);
	else
		file.data(channels.min(), channels.max(), 
				0, file.nsamples(), data);
	snipfile::SnipFile snip_file(
			output + snipfile::FILE_EXTENSION, file);

	/* Compute thresholds */
#ifdef DEBUG
	std::cout << "Computing thresholds" << std::endl;
#endif
	auto thresholds = compute_thresholds(data, thresh);

	/* Find noise and spike snippets */
	auto nchannels = channels.size();
	std::vector<arma::uvec> spike_idx(nchannels), noise_idx(nchannels);
	std::vector<sampleMat> spike_snips(nchannels), noise_snips(nchannels);
	extract_noise(data, noise_idx, noise_snips);
	extract_spikes(data, thresholds, spike_idx, spike_snips);

	/* Write snippets to disk */
	snip_file.setChannels(channels);
	snip_file.setThresholds(thresholds);
	snip_file.writeSpikeSnips(spike_idx, spike_snips);
	snip_file.writeNoiseSnips(noise_idx, noise_snips);
	
	return 0;
}

