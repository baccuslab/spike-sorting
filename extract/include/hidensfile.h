/* hidensfile.h
 *
 * Class representing data recorded from Hidens arrays.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_HIDENSFILE_H_
#define EXTRACT_HIDENSFILE_H_

#include "datafile.h"

namespace hidensfile {
using sampleMat = arma::Mat<uint8_t>;
using sampleVec = arma::Col<uint8_t>;

class HidensFile : public datafile::DataFile {

	public:
		HidensFile(std::string name);
		HidensFile(const HidensFile& other) = delete;
		virtual ~HidensFile();

		virtual void data(size_t start, size_t end, sampleMat& out);
		virtual void data(size_t channel, size_t start, size_t end, sampleVec& out);

};
};

#endif

