/*! \file snipfile.h
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

/*! Namespace for files that are the output of extract. */
namespace snipfile {

/*! The number of random snippets per channel */
const size_t NUM_RANDOM_SNIPPETS = 5000;

/*! The number of samples before a local maximum to take for each snippet */
const size_t NUM_SAMPLES_BEFORE = 6;

/*! The number of samples after a local maximum to take for each snippet */
const size_t NUM_SAMPLES_AFTER = 20;

/*! The size of boxcar filter to use when considering local maxima. */
const size_t WINDOW_SIZE = 3;

const std::string FILE_EXTENSION(".snip");
const size_t DEFAULT_NUM_SNIPPETS = 1000;
const size_t SNIP_DATASET_RANK = 2;
const size_t IDX_DATASET_RANK = 1;

/*! A class representing the output of extract.
 *
 * The SnipFile class represents the output of extract. It is an HDF5 file
 * with one group for each processed channel, where each group contains 
 * noise snippets and any extracted spike snippets. Each channel group has
 * four datasets:
 * 	- 'noise-idx' - The indices of random snippets for this channel.
 * 	- 'noise-snippets' - The actual random snippets for this channel.
 * 	- 'spike-idx' - The indices of each extract spike snippet.
 * 	- 'spike-snippets' - The actual extracted candidate spikes.
 */
class SnipFile {

	public:
		/*! Construct a new snippet file.
		 * \param filename The name of the newly created file.
		 * \param source The original DataFile object from which raw data
		 * will be extracted. This is used to copy file metadata.
		 */
		SnipFile(std::string filename, const datafile::DataFile& source,
				const size_t nbefore = snipfile::NUM_SAMPLES_BEFORE, 
				const size_t nafter = snipfile::NUM_SAMPLES_AFTER);

		/*! Open an existing snippet file.
		 * \param filename The name of the snippet file to load.
		 */
		SnipFile(std::string filename);	// Existing file

		SnipFile(const SnipFile& other) = delete;

		/*! Destroy a snippet file object */
		virtual ~SnipFile();

		/*! Set the array of channels from which data has been extracted */
		void setChannels(const arma::uvec& channels);

		/*! Set the thresholds for each channel */
		void setThresholds(const arma::vec& thresh);

		/*! Write the extracted spike snippets to disk
		 * \param idx The indices into the raw data of the peak of each 
		 * extracted snippet. There is one array of indices for each channel.
		 * \param snips The actual extracted spike snippets, one matrix for each
		 * channel. The matrix is stored with shape (snippet_size, nsnippets)
		 */
		void writeSpikeSnips(const std::vector<arma::uvec>& idx,
				const std::vector<arma::Mat<short> >& snips);

		/*! Write the extracted noise snippets to disk
		 * \param idx The indices into the raw data of start of each
		 * extracted snippet. There is one array of indices for each channel.
		 * \param snips The actual extracted noise snippets, one matrix for each
		 * channel. The matrix is stored with shape (snippet_size, nsnippets)
		 */
		void writeNoiseSnips(const std::vector<arma::uvec>& idx,
				const std::vector<arma::Mat<short> >& snips);

		/*! Return the extracted spike snippets in the file and their indices
		 * \param idx Array of arrays, each of which is filled with the indices
		 * into the raw data file of the peak of each extracted snippet.
		 * \param snips Array of matrices, each of which is filled with the 
		 * true snippet value stored in the file.
		 *
		 * This is an overloaded function. Data will be returned as the true
		 * values stored in the file, not converted into voltages.
		 */
		void spikeSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::Mat<short> >& snips);

		/*! Return the extracted noise snippets in the file and their indices
		 * \param idx Array of arrays, each of which is filled with the indices
		 * into the raw data file of the extracted noise snippets.
		 * \param snips Array of matrices, each of which is filled with the 
		 * true snippet value stored in the file.
		 *
		 * This is an overloaded function. Data will be returned as the true
		 * values stored in the file, not converted into voltages.
		 */
		void noiseSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::Mat<short> >& snips);

		/*! Return the extracted spike snippets in the file and their indices
		 * \param idx Array of arrays, each of which is filled with the indices
		 * into the raw data file of the peak of each extracted snippet.
		 * \param snips Array of matrices, each of which is filled with the 
		 * true snippet value stored in the file.
		 *
		 * This is an overloaded function. Data will be converted into true
		 * voltage values, using the stored gain and offset.
		 */
		void spikeSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::mat>& snips);

		/*! Return the extracted noise snippets in the file and their indices
		 * \param idx Array of arrays, each of which is filled with the indices
		 * into the raw data file of the extracted noise snippets.
		 * \param snips Array of matrices, each of which is filled with the 
		 * true snippet value stored in the file.
		 *
		 * This is an overloaded function. Data will be converted into true
		 * voltage values, using the stored gain and offset.
		 */
		void noiseSnips(std::vector<arma::uvec>& idx,
				std::vector<arma::mat>& snips);

		/*! Return the type of the raw data stored in the array */
		H5::DataType dtype();

		/*! Return the file's name */
		std::string filename();

		/*! Return the array on which data was recorded. */
		std::string array();

		/*! Return the name of the source data file from which data was extracted */
		std::string sourceFile();

		/*! Return the number of channels from which data is extracted */
		size_t nchannels();

		/*! Return the total number of samples in the original data file. */
		size_t nsamples();

		/*! Return the gain of the analog-digital conversion used to acquire
		 * the raw data.
		 */
		float gain();

		/*! Return the voltage offset of the analog-digital conversion 
		 * used to acquire the raw data.
		 */
		float offset();

		/*! Return the sample rate in Hertz of the raw data */
		float sampleRate();

		/*! Return the date on which the raw data was recorded. */
		std::string date();

		/*! Return the list of channels from which data was extracted */
		arma::uvec channels();

		/*! Return the thresholds used when extracting from each channel */
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
		size_t samplesBefore_;
		size_t samplesAfter_;
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

