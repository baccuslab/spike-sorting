/* snipfile.h
 *
 * Class representing a file to which noise and random snippets
 * are written.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_SNIPFILE_H_
#define EXTRACT_SNIPFILE_H_

#include <string>

#include <armadillo>
#include "H5Cpp.h"

#include "datafile.h"

namespace snipfile {
const std::string SPIKE_FILE_EXTENSION(".ssnp");
const std::string NOISE_FILE_EXTENSION(".rsnp");
const size_t NUM_RANDOM_SNIPPETS = 5000;
const size_t NUM_SAMPLES_BEFORE = 10;
const size_t NUM_SAMPLES_AFTER = 25;
const size_t DEFAULT_NUM_SNIPPETS = 1000;
const size_t WINDOW_SIZE = 3;

class SnipFile {
	public:
		SnipFile(std::string filename, const datafile::DataFile& source);
		SnipFile(const SnipFile& other) = delete;
		~SnipFile();

		template<class T> void writeSnippets(const std::vector<arma::uvec>& indices, 
				const std::vector<T>& snippets);

		H5::DataType dtype();
		std::string filename();
		std::string array();
		std::string sourceFile();
		size_t nchannels();
		size_t nsamples();
		float gain();
		float offset();
		float sampleRate();
		std::string date();
		std::string time();

	private:
		std::string filename_;
		std::string array_;
		std::string sourceFile_;
		float sampleRate_;
		std::string date_;
		std::string time_;
		float gain_;
		float offset_;
		size_t nchannels_;
		size_t nsamples_;
		H5::H5File file;
		std::vector<H5::Group> channelGroups;
		std::vector<H5::DataSet> snipDatasets;
		std::vector<H5::DataSet> idxDatasets;

		void getSourceInfo(const datafile::DataFile& source);

};
};

#endif

