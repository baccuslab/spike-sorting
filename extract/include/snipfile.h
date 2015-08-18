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
		SnipFile(std::string filename, const datafile::DataFile& source); // New file
		SnipFile(std::string filename);	// Existing file
		SnipFile(const SnipFile& other) = delete;
		virtual ~SnipFile();

		void setChannels(const arma::uvec& channels);
		void setThresholds(const arma::vec& thresh);
		void writeSpikeSnips(const std::vector<arma::uvec>& idx,
				const std::vector<arma::Mat<short> >& snips);
		void writeNoiseSnips(const std::vector<arma::uvec>& idx,
				const std::vector<arma::Mat<short> >& snips);

		void spikeSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::Mat<short> >& snips);
		void noiseSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::Mat<short> >& snips);
		void spikeSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::mat>& snips);
		void noiseSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::mat>& snips);

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

		arma::uvec channels();
		arma::vec thresholds();

	protected:

		std::string filename_;
		std::string array_;
		std::string sourceFile_;
		float sampleRate_;
		std::string date_;
		float gain_;
		float offset_;
		size_t nchannels_;
		size_t nsamples_;
		size_t samplesBefore_ = -NUM_SAMPLES_BEFORE;
		size_t samplesAfter_ = NUM_SAMPLES_AFTER;
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
		void readAttributes();
		void writeFileStringAttr(const std::string& name, const std::string& value);
		void writeFileAttr(const std::string& name, const H5::DataType& type,
				const void* buf);
		void readFileStringAttr(const std::string& name, std::string& value);
		void readFileAttr(const std::string& name, void *buf);
		void writeChannels(const arma::uvec& channels);
		void readChannels();
		void writeThresholds(const arma::vec& thresholds);
		void readThresholds();
		void snips(const std::string& type, std::vector<arma::uvec>& idx,
				std::vector<arma::Mat<short> >& snips);
};
};

#endif

