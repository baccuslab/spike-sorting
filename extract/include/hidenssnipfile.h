/* hidenssnipfile.h
 *
 * Header describing subclass of SnipFile which provides accesss to metadata
 * specific to the Hidens array, specifically, the configuration.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#ifndef EXTRACT_HIDENSSNIPFILE_H_
#define EXTRACT_HIDENSSNIPFILE_H_

#include <typeinfo>

#include "snipfile.h"
#include "hidensfile.h"

namespace hidenssnipfile {
class HidensSnipFile : public snipfile::SnipFile {

	public:
		HidensSnipFile(const std::string& name, const hidensfile::HidensFile& source);
		HidensSnipFile(const std::string& name); // existing file
		HidensSnipFile(const HidensSnipFile& other) = delete;
		virtual ~HidensSnipFile();

		arma::Col<uint32_t> xpos() const, ypos() const;
		arma::Col<uint16_t> x() const, y() const;
		arma::Col<uint8_t> label() const;
		arma::Col<int32_t> connectedChannels() const;

	private:
		arma::Col<uint32_t> xpos_, ypos_;
		arma::Col<uint16_t> x_, y_;
		arma::Col<uint8_t> label_;
		arma::Col<int32_t> connectedChannels_;

		void copyConfiguration(const hidensfile::HidensFile& source);
		void readConfiguration();
		void writeConfiguration();

		template<class T>
		void readConfigDataset(const H5::DataSet& dset, T& out);
		template<class T>
		void writeConfigDataset(const H5::DataSet& dset, T& out);
};
};

template<class T>
void hidenssnipfile::HidensSnipFile::readConfigDataset(const H5::DataSet& dset, T& out)
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
	else if (typeid(T).hash_code() == typeid(arma::Col<char>).hash_code()) {
		auto strtype = H5::StrType(H5::PredType::C_S1, 1);
		strtype.setStrpad(H5T_STR_NULLPAD);
		dtype = strtype;
	} else if (typeid(T).hash_code() == typeid(arma::Col<int32_t>).hash_code())
		dtype = H5::PredType::STD_I32LE;
	dset.read(out.memptr(), dtype, memspace, space);
}

template<class T>
void hidenssnipfile::HidensSnipFile::writeConfigDataset(const H5::DataSet& dset, T& out)
{
	H5::DataSpace space = dset.getSpace();
	hsize_t dims[1] = {0};
	space.getSimpleExtentDims(dims);
	auto sz = dims[0];
	hsize_t offset[1] = {0};
	hsize_t count[1] = {sz};
	space.selectHyperslab(H5S_SELECT_SET, count, offset);

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
	dset.write(out.memptr(), dtype);
}

#endif

