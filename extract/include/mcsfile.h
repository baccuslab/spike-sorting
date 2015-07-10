/* mcsfile.h
 *
 * Header for class representing HDF file storing data
 * recording on MCS arrays.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_MCSFILE_H_
#define EXTRACT_MCSFILE_H_

#include "datafile.h"

namespace mcsfile {
const unsigned int FILE_TYPE = 2;
const unsigned int FILE_VERSION = 1;
const unsigned int NUM_CHANNELS = 64;
const float SAMPLE_RATE = 10000;
const std::string ROOM_STRING("recorded in d239");

using sampleMat = arma::Mat<int16_t>;
using sampleVec = arma::Col<int16_t>;

class McsFile : public datafile::DataFile {
	public:
		McsFile(std::string name);
		McsFile(const McsFile& other) = delete;
		virtual ~McsFile();

		virtual void data(size_t start, size_t end, sampleMat& out);
		virtual void data(size_t channel, size_t start, size_t end, sampleVec& out);
		//virtual void data(size_t start, size_t end, datafile::sampleMat& out);
		//virtual void data(size_t channel, size_t start, size_t end, datafile::sampleVec& out);
};
};

#endif

