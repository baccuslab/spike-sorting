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

using sampleMat = arma::mat;
using sampleVec = arma::vec;

class DataFile { 

	public:
		DataFile(std::string name);
		DataFile(const DataFile& other) = delete;
		virtual ~DataFile();

		std::string filename();
		std::string date();		// Date of recording
		std::string time();		// Time of recording
		float sampleRate();		// Sample rate of data
		float gain();			// ADC gain
		float offset();			// ADC offset
		std::string array();	// Array type

		size_t nsamples();
		size_t nchannels();
		double length();

		virtual void data(
				size_t start, size_t end, arma::mat& out) { };
		virtual void data(
				size_t channel, size_t start, size_t end, arma::vec& out) { };
		virtual void data(
				size_t start, size_t end, arma::Mat<int16_t>& data) { };
		virtual void data(
				size_t channel, size_t start, size_t end, arma::Col<int16_t>& data) { };
		virtual void data(
				size_t start, size_t end, arma::Mat<uint8_t>& data) { };
		virtual void data(
				size_t channel, size_t start, size_t end, arma::Col<uint8_t>& data) { };

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
		H5::DataType datatype;
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
};
};

#endif
