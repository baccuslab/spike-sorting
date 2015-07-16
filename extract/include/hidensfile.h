/* hidensfile.h
 *
 * Header file describing subclass of datafile, which allows reading of
 * extra metadata contained in recordings from Hidens arrays, specifically
 * the configuration.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_HIDENSFILE_H_
#define EXTRACT_HIDENSFILE_H_

#include <typeinfo>

#include "datafile.h"

namespace hidensfile {
class HidensFile : public datafile::DataFile {

	public:
		HidensFile(std::string name);
		HidensFile(const HidensFile& other) = delete;
		virtual ~HidensFile();

		arma::Col<uint32_t> xpos() const, ypos() const;
		arma::Col<uint16_t> x() const, y() const;
		arma::Col<uint8_t> label() const;
		arma::Col<int32_t> connectedChannels() const;

	private:
		arma::Col<uint32_t> xpos_, ypos_;
		arma::Col<uint16_t> x_, y_;
		arma::Col<uint8_t> label_;
		arma::Col<int32_t> connectedChannels_;

		void readConfiguration();

		template<class T>
		void readConfigDataset(const H5::DataSet& dset, T& out);
};
};

template<class T>
void hidensfile::HidensFile::readConfigDataset(const H5::DataSet& dset, T& out)
{
	H5::DataSpace space = dset.getSpace();
	hsize_t dims[1] = {0};
	space.getSimpleExtentDims(dims);
	auto sz = dims[0];
	hsize_t offset[1] = {0};
	hsize_t count[1] = {sz};
	space.selectHyperslab(H5S_SELECT_SET, count, offset);

	auto memspace = H5::DataSpace(1, dims);
	memspace.selectHyperslab(H5S_SELECT_SET, count, offset);
	out.set_size(sz);
	H5::DataType dtype;
	if (typeid(T).hash_code() == typeid(arma::Col<uint32_t>).hash_code())
		dtype = H5::PredType::STD_U32LE;
	else if (typeid(T).hash_code() == typeid(arma::Col<uint16_t>).hash_code())
		dtype = H5::PredType::STD_U16LE;
	else if (typeid(T).hash_code() == typeid(arma::Col<uint8_t>).hash_code()) {
		auto strtype = H5::StrType(H5::PredType::C_S1, 1);
		strtype.setStrpad(H5T_STR_NULLPAD);
		dtype = strtype;
	} else if (typeid(T).hash_code() == typeid(arma::Col<int32_t>).hash_code())
		dtype = H5::PredType::STD_I32LE;
	dset.read(out.memptr(), dtype, memspace, space);
}

#endif

