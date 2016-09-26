/* main.cc
 *
 * Entry point for the extract command-line tool
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include <getopt.h> 		// for getopt_long
#include <sys/stat.h>		// for stat(2)

#include <algorithm>		// min, max, unique, sort
#include <numeric>			// iota
#include <string>
#include <iostream>
#include <cstdio>			// printf
#include <vector>
#include <mutex>			// mutex, lock_guard
#include <thread>			// std::async
#include <future>			// std::future

#include <armadillo>		// matrices/vectors holding data in memory

#include "snipfile.h"		// implements snippet file API
#include "hidensfile.h"		// hidens-specific raw file (includes array configuration)
#include "hidenssnipfile.h"	// hidens-specific snippet file API
#include "extract.h"		// routines to perform snippet extraction
#include "semaphore.h"		// basic counting semaphore (restricts number of running threads)

#define UL_PRE "\033[4m"
#define UL_POST "\033[0m"
#define ERR_COLOR "\033[31m"
#define DEFAULT_COLOR "\033[39m"
#define DEFAULT_THRESHOLD 4.5
#define DEFAULT_THRESH_STR "4.5"
#define VERSION_MAJOR 0
#define VERSION_MINOR 6
#define HIDENS_CHANNEL_MAX 127
#define HIDENS_CHANNEL_MIN 0
#define MCS_CHANNEL_MAX 64
#define MCS_CHANNEL_MIN 4

/* Type alias for data stored in memory from data files */
using sampleMat = arma::Mat<short>;

const char PROGRAM[] = "extract";
const char AUTHOR[] = "Benajmin Naecker";
const char AUTHOR_EMAIL[] = "bnaecker@stanford.edu";
const char YEAR[] = "2015";
const char SHORT_DESCRIPTION[] = "Candidate spike-snippet extraction program";
const char USAGE[] = "\n\
 Usage: extract [-v | --version] [-h | --help]\n\
  \t\t[-V | --verbose]\n\
  \t\t[-N | --nthreads " UL_PRE "nthreads" UL_POST "]\n\
  \t\t[-t | --threshold " UL_PRE "threshold" UL_POST "]\n\
  \t\t[-b | --before " UL_PRE "nbefore" UL_POST "]\n\
  \t\t[-a | --after " UL_PRE "nafter" UL_POST "]\n\
  \t\t[-n | --nrandom " UL_PRE "nrandom" UL_POST "]\n\
  \t\t[-c | --chan " UL_PRE "chan-list" UL_POST "]\n\
  \t\t" UL_PRE "recording-file1" UL_POST " [ " UL_PRE "recording-file2" UL_POST "... ]\n\n\
 Extract noise and spike snippets from the given recording file\n\n\
 Parameters:\n\n\
   " UL_PRE "verbose" UL_POST "\tPrint progress of snippet extraction.\n\n\
   " UL_PRE "nthreads" UL_POST "\tNumber of threads to use. Defaults to the number\n\
   \t\tof logical CPU cores on the current machine. The program processes channels in\n\
   \t\tparallel, one in each thread. Thus this argument can be used to limit the memory\n\
   \t\tusage of the program as well: the file size divided by the number of channels will\n\
   \t\tgive the amount of memory used in each thread.\n\n\
   " UL_PRE "threshold" UL_POST "\tThreshold multiplier for determining spike\n\
   \t\tsnippets. The threshold will be set independently for each channel, such\n\
   \t\tthat: " UL_PRE "threshold" UL_POST " * median(abs(v)). Default = %0.1f\n\n\
   " UL_PRE "nbefore" UL_POST "\tNumber of samples before a spike peak to extract.\n\
   \t\tDefaults to %zu for MCS arrays and %zu for HiDens arrays.\n\n\
   " UL_PRE "nafter" UL_POST "\tNumber of samples after a spike peak to extract.\n\
   \t\tDefaults to %zu for MCS arrays and %zu for HiDens arrays.\n\n\
   " UL_PRE "nrandom" UL_POST "\tThe number of random snippets to extract.\n\n\
   " UL_PRE "chan" UL_POST "\t\tA comma- or dash-separated list of channels from which\n\
   \t\tsnippets will be extracted. E.g., \"0,1,2,3\" will extract data only from\n\
   \t\tthe first 4 channels, while \"0-4,8,10-\" will extract data from the first\n\
   \t\t4 channels, the 9th, and channels 11 to the number of channels in the file.\n\
   \t\tFor MCS data files, the default is \"4-64\", and for Hidens files, the default\n\
   \t\tis all channels. Note that ranges are half-open, so that the range specified as\n\
   \t\t\"3-15\" will collect channels 4 through 14, inclusive, but not channel 15. Also\n\
   \t\tnote that indexing is 0-based.\n\n";

void print_usage_and_exit()
{
	printf(USAGE, DEFAULT_THRESHOLD, snipfile::NUM_SAMPLES_BEFORE, 
			hidenssnipfile::NUM_SAMPLES_BEFORE, snipfile::NUM_SAMPLES_AFTER,
			hidenssnipfile::NUM_SAMPLES_AFTER);
	exit(EXIT_SUCCESS);
}

void print_version_and_exit()
{
	std::cout << PROGRAM << " version " << VERSION_MAJOR << "." << VERSION_MINOR << std::endl;
	std::cout << SHORT_DESCRIPTION << std::endl;
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
				for (decltype(num) i = 0; i < num; i++)
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

void parse_command_line(int argc, char **argv, size_t& nthreads,
		double& thresh, size_t& nrandom_snippets, int& nbefore, int& nafter,
		bool& verbose, std::string& chan_arg, 
		std::vector<std::string>& filenames)
{
	if (argc == 1)
		print_usage_and_exit();

	/* Parse options */
	struct option options[] = {
		{ "verbose", 	no_argument,		nullptr, 'V' },
		{ "nthreads",	required_argument,	nullptr, 'N' },
		{ "threshold", 	required_argument, 	nullptr, 't' },
		{ "before", 	required_argument, 	nullptr, 'b' },
		{ "after", 		required_argument, 	nullptr, 'a' },
		{ "help", 		no_argument, 		nullptr, 'h' },
		{ "version", 	no_argument, 		nullptr, 'v' },
		{ "chan", 		required_argument, 	nullptr, 'c' },
		{ "nrandom", 	required_argument,  nullptr, 'n' },
		{ nullptr, 		0, 					nullptr, 0 	 }
	};
	int opt;
	while ( (opt = getopt_long(argc, argv, "hvt:c:n:V", options, nullptr)) != -1 ) {
		switch (opt) {
			case 'h':
				print_usage_and_exit();
			case 'v':
				print_version_and_exit();
			case 'V':
				verbose = true;
				break;
			case 'N':
				try {
					size_t tmp_nthreads = std::stoul(std::string(optarg));
					if ( (tmp_nthreads >= 1) && (tmp_nthreads <= std::thread::hardware_concurrency()) )
						nthreads = tmp_nthreads;
				} catch ( ... ) {
					std::cerr << "Number of desired threads must be a positive integer" 
						<< std::endl;
					exit(EXIT_FAILURE);
				}
				break;
			case 't':
				try {
					thresh = std::stof(std::string(optarg));
				} catch ( ... ) {
					std::cerr << "Invalid threshold: " << optarg << std::endl;
					exit(EXIT_FAILURE);
				}
				break;
			case 'b':
				try {
					nbefore = std::stoi(std::string(optarg));
				} catch ( ... ) {
					std::cerr << "Samples before must be given as an integer" 
						<< std::endl;
					exit(EXIT_FAILURE);
				}
				break;
			case 'a':
				try {
					nafter = std::stoi(std::string(optarg));
				} catch ( ... ) {
					std::cerr << "Samples after must be given as an integer" 
						<< std::endl;
					exit(EXIT_FAILURE);
				}
				break;
			case 'c':
				chan_arg = std::string(optarg);
				break;
			case 'n':
				try {
					nrandom_snippets = std::stoul(std::string(optarg));
				} catch ( ... ) {
					std::cerr << "Random snippets must be a positive number" << std::endl;
					exit(EXIT_FAILURE);
				}
				break;
		}
	}
	argv += optind;
	argc -= optind;
	if (argc == 0) {
		std::cerr << "Must specify one or more data files to extract" << std::endl;
	}
	for (auto i = 0; i < argc; i++)
		filenames.push_back(std::string(argv[i]));
}

std::string get_array(std::string filename)
{
	return datafile::DataFile(filename).array();
}

bool sequential_channels(const arma::uvec& channels)
{
	if (channels.n_elem == 1)
		return true;
	return !arma::any(channels(arma::span(1, channels.n_elem - 1)) -
			channels(arma::span(0, channels.n_elem - 2)) > 1);
}

void verify_channels(arma::uvec& channels, const datafile::DataFile* file)
{
	arma::uvec file_channels(file->nchannels(), arma::fill::zeros);
	std::iota(file_channels.begin(), file_channels.end(), 0);
	arma::uvec valid_channels(file_channels.n_elem, arma::fill::zeros);
	size_t nelem = 0;
	for (auto i = decltype(channels.n_elem){0}; i < channels.n_elem; i++) {
		if (arma::any(file_channels == channels(i))) {
			valid_channels(nelem) = channels(i);
			nelem++;
		}
	}
	valid_channels.resize(nelem);
	channels = valid_channels;
}

void verify_snippet_offsets(const std::string& array, int& nbefore, int& nafter)
{
	if (nbefore <= 0) {
		nbefore = ((array == "hidens") ? hidenssnipfile::NUM_SAMPLES_BEFORE :
				snipfile::NUM_SAMPLES_BEFORE);
	}
	if (nafter <= 0) {
		nafter = ((array == "hidens") ? hidenssnipfile::NUM_SAMPLES_AFTER :
				snipfile::NUM_SAMPLES_AFTER);
	}
}

std::string create_snipfile_name(const std::string& name)
{
	auto pos = name.rfind(".");
	if (pos == std::string::npos)
		return name + snipfile::FILE_EXTENSION;
	return name.substr(0, pos) + snipfile::FILE_EXTENSION;
}

int main(int argc, char *argv[])
{	
	/* Parse input */
	auto thresh = DEFAULT_THRESHOLD;
	auto nrandom_snippets = snipfile::NUM_RANDOM_SNIPPETS;
	std::string chan_arg;
	std::vector<std::string> filenames;
	bool verbose = false;
	int nbefore = -1, nafter = -1;
	size_t nthreads = std::thread::hardware_concurrency();
	parse_command_line(argc, argv, nthreads, thresh, nrandom_snippets, 
			nbefore, nafter, verbose, chan_arg, filenames);

	for (auto& filename : filenames) {

		/* Verify that data file exists and snippet file doesn't */
		struct stat buf;
		if (stat(filename.c_str(), &buf) != 0) {
			std::cerr << "The data file " << UL_PRE << filename 
				<< UL_POST << " does not exist, skipping." << std::endl;
			continue;
		}
		std::string snipfile_name = create_snipfile_name(filename);
		if (stat(snipfile_name.c_str(), &buf) == 0) {
			std::cerr << "The snippet file " << UL_PRE << snipfile_name
				<< UL_POST << " already exists, skipping data file" << std::endl;
			continue;
		}

		/* Notify */
		if (verbose)
			std::cout << "Processing data file: " << UL_PRE << filename 
					<< UL_POST << std::endl;

		/* Get MEA array type */
		std::string array = get_array(filename);

		/* Verify the number of samples before/after a spike peak, based on array. */
		verify_snippet_offsets(array, nbefore, nafter);

		/* Get channels based on input */
		arma::uvec channels;
		if (chan_arg.empty()) {
			auto min = channel_min(array), max = channel_max(array);
			channels.set_size(max - min);
			std::iota(channels.begin(), channels.end(), min);
		} else {
			parse_chan_list(chan_arg, channels, channel_max(array));
		}

		/* Open the file and verify the channels requested */
		datafile::DataFile *file;
		if (array == "hidens")
			file = dynamic_cast<datafile::DataFile*>(new hidensfile::HidensFile(filename));
		else
			file = new datafile::DataFile(filename);
		if (!file) {
			std::cerr << "Could not cast Hidens file to base datafile" << std::endl;
			exit(EXIT_FAILURE);
		}
		verify_channels(channels, file);

		/* Create data structures to hold snippet extraction information */
		auto nchannels = channels.size();
		arma::vec means(nchannels), thresholds(nchannels);
		std::vector<arma::uvec> spike_idx(nchannels), noise_idx(nchannels);
		std::vector<sampleMat> spike_snips(nchannels), noise_snips(nchannels);

		/* Semaphore restricts number of running threads */
		Semaphore sem(nthreads);

		/* Locks synchronizing access across all threads to:
		 * 	- HDF5 data file
		 * 	- Noise snippet std::vector
		 * 	- Spike snippet std::vector
		 */
		std::mutex file_lock, noise_lock, spike_lock;

		/* Run extraction for each channel in separate thread
		 * NOTE:
		 * The reference wrappers around many of the arguments are required.
		 * This is because std::async and its ilk usually copy arguments, but
		 * the reference wrappers are essentially pointers. This is also why
		 * the mutexes above are required.
		 */
		std::vector<std::future<void>> futures(nchannels);
		for (size_t chan = 0; chan < nchannels; chan++) {
			futures[chan] = std::async(std::launch::async, extract::extract,
					std::ref(sem), file, std::ref(file_lock), channels(chan), thresh,
					nrandom_snippets, nbefore, nafter,
					std::ref(means(chan)), std::ref(thresholds(chan)),
					std::ref(noise_idx.at(chan)), std::ref(noise_snips.at(chan)), 
					std::ref(noise_lock),
					std::ref(spike_idx.at(chan)), std::ref(spike_snips.at(chan)),
					std::ref(spike_lock));

		}

		/* Wait for all to finish and notify */
		for (decltype(nchannels) i = 0; i < nchannels; i++) {
			try {
				futures[i].get(); // throws any exception from extract::extract
				if (verbose) {
					std::cout << "\r Extracting channel " << channels(i) << " ("
						<< i + 1 << " / " << nchannels << ")";
					std::cout.flush();
				}
			} catch (std::logic_error& e) {
				std::cerr << std::endl << ERR_COLOR << " Error reading raw data from channel " 
					<< channels(i) << ": " << e.what() << DEFAULT_COLOR << std::endl; 
			} catch ( ... ) {
				std::cerr << std::endl << ERR_COLOR 
					<< "Unexpected error extracting from channel " 
					<< channels(i) << std::endl;
			}
		}

		/* Write means into original data file */
		file->writeMeans(means);

		/* Create snippet file */
		snipfile::SnipFile *snip_file;
		if (array == "hidens") {
			snip_file = dynamic_cast<hidenssnipfile::HidensSnipFile*>(
					new hidenssnipfile::HidensSnipFile(snipfile_name, 
						*dynamic_cast<hidensfile::HidensFile*>(file),
					nbefore, nafter));
			if (!snip_file) {
				std::cerr << "Could not cast HiDens snippet-file to base SnipFile object"
					<< std::endl;
				exit(EXIT_FAILURE);
			}
		}
		else {
			snip_file = new snipfile::SnipFile(snipfile_name, 
					*file, nbefore, nafter);
		}

		/* Write snippets to disk */
		if (verbose) {
			std::cout << std::endl << " Writing snippet file ... ";
			std::cout.flush();
		}
		snip_file->setChannels(channels);
		snip_file->setThresholds(thresholds);
		snip_file->writeSpikeSnips(spike_idx, spike_snips);
		snip_file->writeNoiseSnips(noise_idx, noise_snips);

		/* Cleanup */
		delete file;
		delete snip_file;

		if (verbose)
			std::cout << "done.\nFinished processing file: " << UL_PRE << filename 
				<< UL_POST << std::endl;
	}
	return 0;
}

