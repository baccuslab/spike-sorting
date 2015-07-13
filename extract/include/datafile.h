/* datafile.h
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

namespace datafile {

const std::string EXTENSION = ".h5";		// File extension
const unsigned int DATASET_RANK = 2;		// Rank of "data" dataset
const unsigned int CHUNK_SIZE = 2000;		// HDF5 file chunk size, in _samples_
const unsigned int CHUNK_CACHE_SIZE = 5;	// Number of chunks HDF library should cache
const std::string DATE_FMT = "%a, %b %d, %Y";
const std::string TIME_FMT = "%I:%M:%S %p";

class DataFile { 

	public:
		DataFile(std::string name);
		DataFile(const DataFile& other) = delete;
		virtual ~DataFile();

		std::string filename() const;
		std::string date() const;	// Date of recording
		std::string time() const;	// Time of recording
		float sampleRate() const;	// Sample rate of data
		float gain() const;			// ADC gain
		float offset() const;		// ADC offset
		std::string array() const;	// Array type
		size_t nsamples() const;
		size_t nchannels() const;
		double length() const;
		H5::DataType datatype() const;

		void data(size_t start, size_t end, arma::mat& out);
		void data(size_t channel, size_t start, size_t end, arma::vec& out);
		void data(size_t startChan, size_t endChan, size_t start, size_t end, 
				arma::mat& out);
		void data(const arma::uvec& channels, size_t start, size_t end,
				arma::mat& out);

		void data(size_t start, size_t end, arma::Mat<short>& out);
		void data(size_t channel, size_t start, size_t end, arma::Col<short>& out);
		void data(size_t startChan, size_t endChan, size_t start, size_t end, 
				arma::Mat<short>& out);
		void data(const arma::uvec& channels, size_t start, size_t end,
				arma::Mat<short>& out);

	protected:
		std::string filename_;
		std::string date_;
		std::string time_;
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
		void readTime();
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
#include "datafile.tc"

#endif
