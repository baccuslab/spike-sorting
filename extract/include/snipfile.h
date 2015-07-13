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
#include <vector>

#include <armadillo>
#include "H5Cpp.h"

#include "datafile.h"

namespace snipfile {
const std::string FILE_EXTENSION(".snip");
const size_t NUM_RANDOM_SNIPPETS = 5000;
const size_t NUM_SAMPLES_BEFORE = 10;
const size_t NUM_SAMPLES_AFTER = 25;
const size_t DEFAULT_NUM_SNIPPETS = 1000;
const size_t WINDOW_SIZE = 3;
const size_t SNIP_DATASET_RANK = 2;
const size_t IDX_DATASET_RANK = 1;

class SnipFile {
	public:
		SnipFile(std::string filename, const datafile::DataFile& source);
		SnipFile(const SnipFile& other) = delete;
		~SnipFile();

		void setChannels(const arma::uvec& channels);
		void setThresholds(const arma::vec& thresh);
		void writeSpikeSnips(const std::vector<arma::uvec>& idx,
				const std::vector<arma::Mat<short> >& snips);
		void writeNoiseSnips(const std::vector<arma::uvec>& idx,
				const std::vector<arma::Mat<short> >& snips);

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

		arma::uvec channels();
		arma::vec thresholds();

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
		arma::uvec channels_;
		arma::vec thresholds_;

		/* HDF components */
		H5::H5File file;
		std::vector<H5::Group> channelGroups;
		std::vector<H5::DataSet> spikeDatasets;
		std::vector<H5::DataSet> noiseDatasets;
		std::vector<H5::DataSet> spikeIdxDatasets;
		std::vector<H5::DataSet> noiseIdxDatasets;
		H5::DataType dstType;

		void getSourceInfo(const datafile::DataFile& source);
		void writeSnips(const std::string& type, 
				const std::vector<arma::uvec>& idx,
				const std::vector<arma::Mat<short> >& snips);
		void writeAttributes();
		void writeFileStringAttr(const std::string& name, const std::string& value);
		void writeFileAttr(const std::string& name, const H5::DataType& type,
				const void* buf);
		void writeChannels(const arma::uvec& channels);
};
};

#endif

