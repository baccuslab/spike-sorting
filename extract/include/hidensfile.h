/*! \file hidensfile.h
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

/*! Namespace for classes to interact with recordings from HiDens arrays. */
namespace hidensfile {

/*! Class to read from a single HiDens data file.
 *
 * The HidensFile class is a subclass of DataFile, and adds a few extra bells
 * and whistles specific to recordings from the HiDens arrays. Specifically,
 * it adds functionality for reading electrode configurations.
 */
class HidensFile : public datafile::DataFile {

	public:

		/*! Construct a file.
		 * \param name The name of the file.
		 */
		HidensFile(std::string name);
		HidensFile(const HidensFile& other) = delete;

		/*! Destroy the file */
		virtual ~HidensFile();

		/*! Returns the x- or y-positions of the electrode configuration.
		 * This returns the true micron values of each electrode in the
		 * configuration recorded in the file.
		 */
		arma::Col<uint32_t> xpos() const, ypos() const;

		/*! Return the x- or y-index of the electrode configuration. */
		arma::Col<uint16_t> x() const, y() const;

		/*! Return a text label associated with each electrode */
		arma::Col<uint8_t> label() const;

		/*! Return the linear index of the electrode connected to each channel.
		 * This returns an array whose length is always 126. Element `i` gives
		 * the actual electrode from which channel `i` recorded data, if it
		 * was connected, and -1 otherwise.
		 */
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

