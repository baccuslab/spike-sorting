/*! \file datafile.h
 *
 * Header file describing interface to raw recording data files, in 
 * HDF5 format.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_DATAFILE_H_
#define EXTRACT_DATAFILE_H_

#include <string>

#include <armadillo>
#include "H5Cpp.h"

/*! Contains main data and class for reading from a raw data file. */
namespace datafile {

const std::string EXTENSION = ".h5";		// File extension
const unsigned int DATASET_RANK = 2;		// Rank of "data" dataset
const unsigned int CHUNK_SIZE = 2000;		// HDF5 file chunk size, in _samples_
const unsigned int CHUNK_CACHE_SIZE = 5;	// Number of chunks HDF library should cache
const std::string DATE_FMT = "%Y-%m-%dT%H:%M:%S";

/*! Main class for interacting with data files. 
 * This class is used to load and read data recorded using the MCS
 * array system.
 */
class DataFile { 

	public:
		/*! Open an existing data file 
		 * \param name The name of the file to load
		 */
		DataFile(std::string name);
		DataFile(const DataFile& other) = delete;
		/*! Close the data file */
		virtual ~DataFile();

		/*! Return the file's name */
		std::string filename() const;

		/*! Return the date stored in the file */
		std::string date() const;

		/*! Return the data sample rate */
		float sampleRate() const;

		/*! Return the gain of the analog-digital conversion stage */
		float gain() const;

		/*! Return the voltage offset of the ADC stage */
		float offset() const;

		/*! Return the name of the array from which data was recorded. */
		std::string array() const;
		
		/*! Return the total number of samples in the file */
		size_t nsamples() const;

		/*! Return the total number of recording channels in the file */
		size_t nchannels() const;

		/*! Return the length of the recording, in seconds */
		double length() const;

		/*! Return the datatype of the stored voltage data */
		H5::DataType datatype() const;

		/*! Read data from the file
		 * \param start The sample from which to start loading.
		 * \param end The final sample to load.
		 * \param out The matrix into which data is written.
		 *
		 * This is an overloaded function. It loads data from all channels
		 * over the given sample range.
		 *
		 * Data is converted into true voltage values.
		 */
		void data(size_t start, size_t end, arma::mat& out);

		/*! Read data from the file
		 * \param channel The channel whose data should be loaded.
		 * \param start The sample from which to start loading.
		 * \param end The final sample to load.
		 * \param out The matrix into which data is written.
		 *
		 * This is an overloaded function. It loads data from the given
		 * channel only, over the given sample range.
		 *
		 * Data is converted into true voltage values.
		 */
		void data(size_t channel, size_t start, size_t end, arma::vec& out);

		/*! Read data from the file
		 * \param startChan The first channel to load.
		 * \param endChan The last channel to load.
		 * \param start The sample from which to start loading.
		 * \param end The final sample to load.
		 * \param out The matrix into which data is written.
		 *
		 * This is an overloaded function. It loads a subset of the data
		 * from a contiguous list of channels and samples.
		 *
		 * Data is converted into true voltage values.
		 */
		void data(size_t startChan, size_t endChan, size_t start, size_t end, 
				arma::mat& out);

		/*! Read data from the file
		 * \param channels A list of arbitrary channels to load
		 * \param start The first sample to load
		 * \param end The last sample to load.
		 * \param out The matrix into which data is written.
		 *
		 * This is an overloaded function. It reads data from an arbitrary,
		 * not necessarily contiguous, list of channels in the file, over
		 * the contiguous sample range.
		 *
		 * Data is converted into true voltage values.
		 */
		void data(const arma::uvec& channels, size_t start, size_t end,
				arma::mat& out);

		/*! Read data from the file
		 * \param start The first sample to load.
		 * \param end The last sample to load.
		 * \param out The matrix into which data is read.
		 *
		 * This is an overloaded function. It loads data from all channels
		 * over the contiguous sample range given. However, data is loaded
		 * as the raw values in which they are stored, and not converted
		 * into voltage units.
		 */
		void data(size_t start, size_t end, arma::Mat<short>& out);

		/*! Read data from the file
		 * \param start The first sample to load.
		 * \param end The last sample to load.
		 * \param out The matrix into which data is read.
		 *
		 * This is an overloaded function. It loads data from all channels
		 * over the contiguous sample range given. However, data is loaded
		 * as the raw values in which they are stored, and not converted
		 * into voltage units.
		 */
		void data(size_t channel, size_t start, size_t end, arma::Col<short>& out);

		/*! Read data from the file
		 * \param startChan The first channel to load.
		 * \param endChan The last channel to load.
		 * \param start The first sample to load.
		 * \param end The last sample to load.
		 * \param out The matrix into which data is read.
		 *
		 * This is an overloaded function. It loads data from the given contiguous
		 * subset of channels over the contiguous sample range given. However, 
		 * data is loaded as the raw values in which they are stored, and not 
		 * converted into voltage units.
		 */
		void data(size_t startChan, size_t endChan, size_t start, size_t end, 
				arma::Mat<short>& out);

		/*! Read data from the file
		 * \param channels An arbitrary list of channels to load
		 * \param start The first sample to load.
		 * \param end The last sample to load.
		 * \param out The matrix into which data is read.
		 *
		 * This is an overloaded function. It loads data from an arbitrary,
		 * not necessarily contiguous, set of channels over the contiguous 
		 * sample range given. However, data is loaded as the raw values in 
		 * which they are stored, and not converted into voltage units.
		 */
		void data(const arma::uvec& channels, size_t start, size_t end,
				arma::Mat<short>& out);

	protected:
		std::string filename_;
		std::string date_;
		float sampleRate_;
		float gain_;
		float offset_;
		std::string array_;
		size_t nsamples_;
		size_t nchannels_;
		double length_;

		H5::H5File file;
		H5::DataSpace dataspace;
		H5::DataType datatype_;
		H5::DSetCreatPropList props;
		H5::DataSet dataset;
		bool rdonly;

		void readSampleRate();
		void readGain();
		void readOffset();
		void readDate();
		void readArray();
		void readDatasetSize();
		void readDatasetAttr(std::string name, void *buf);
		void readDatasetStringAttr(std::string name, std::string& s);
		void computeCoords(const arma::uvec& channels, size_t start, 
				size_t end, arma::Mat<hsize_t> *coords, hsize_t *nelem);

		template<class T>
		void _read_data(const size_t, const size_t, const size_t, const size_t, T&);
		template<class T>
		void _read_data(const arma::uvec&, const size_t, const size_t, T&);
};
};

/* Implementation of templates, included in this compilation unit */
#include "datafile-templates.h"

#endif
