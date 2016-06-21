/* datafile.cc
 *
 * Implementation of class representing raw data recorded from either
 * MCS or Hidens arrays, in HDF5 file format.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include <sys/stat.h>
#include <iostream>
#include <typeinfo>

#include "include/datafile.h"

datafile::DataFile::DataFile(std::string name)
{
	filename_ = name;
	struct stat buf;
	if (stat(name.c_str(), &buf) == 0) {
		/* Open HDF5 file */
		new_file = false;
		try {
			file = H5::H5File(filename_, H5F_ACC_RDWR);
		} catch (H5::FileIException &e) {
			std::cerr << "Could not open HDF5 file" << std::endl;
			throw std::runtime_error("Could not open HDF5 file");
		}

		/* Open dataset */
		try {
			dataset = file.openDataSet("data");
		} catch (H5::FileIException &e) {
			std::cerr << "File must contain a dataset labeled 'data'" 
				<< std::endl;
			throw std::invalid_argument(
					"File must contain a dataset labeled 'data'");
		}
		dataspace = dataset.getSpace();

		/* Read required attributes */
		try {
			readSampleRate();
			readGain();
			readOffset();
			readDate();
			readArray();
			readDatasetSize();
		} catch ( ... ) {
			std::cerr << "File does not contain required dataset attributes" 
				<< std::endl;
			throw std::invalid_argument(
					"File does not contain required dataset attributes");
		}
	} else {
		/* File does not exist */
		new_file = true;
		throw std::runtime_error("Creating files is not yet supported");
	}
}

datafile::DataFile::~DataFile()
{
	file.close();
}

void datafile::DataFile::readSampleRate()
{
	readDatasetAttr("sample-rate", &sampleRate_);
}

void datafile::DataFile::readGain()
{
	readDatasetAttr("gain", &gain_);
}

void datafile::DataFile::readOffset()
{
	readDatasetAttr("offset", &offset_);
}

void datafile::DataFile::readDate()
{
	readDatasetStringAttr("date", date_);
}

void datafile::DataFile::readArray()
{
	readDatasetStringAttr("array", array_);
}

void datafile::DataFile::readDatasetSize()
{
	hsize_t dims[datafile::DATASET_RANK] = {0, 0};
	dataset.getSpace().getSimpleExtentDims(dims, nullptr);
	nchannels_ = dims[0];
	nsamples_ = dims[1];
	length_ = static_cast<double>(nsamples() / sampleRate());
}

void datafile::DataFile::readDatasetAttr(std::string name, void *buf)
{
	try {
		H5::Attribute attr = dataset.openAttribute(name);
		attr.read(attr.getDataType(), buf);
	} catch (H5::DataSetIException &e) {
		std::cerr << "DataSet exception accessing attr: " << name << std::endl;
		throw std::runtime_error("Dataset attribute access error");
	} catch (H5::AttributeIException &e) {
		std::cerr << "Attribute exception accessing attr: " << name << std::endl;
		throw std::runtime_error("Dataset attribute access error");
	}
}

void datafile::DataFile::readDatasetStringAttr(std::string name, std::string& s)
{
	try {
		H5::Attribute attr = dataset.openAttribute(name);
		hsize_t sz = attr.getStorageSize();
		char *buf = new char[sz + 1]();
		readDatasetAttr(name, buf);
		s.reserve(sz);
		s.replace(0, sz, buf);
		delete[] buf;
	} catch ( H5::DataSetIException &e ) {
		std::cerr << "DataSet exception accessing attr: " << name << std::endl;
		throw std::runtime_error("Dataset attribute access error");
	} catch ( H5::AttributeIException &e ) {
		std::cerr << "Attribute exception accessing attr: " << name << std::endl;
		throw std::runtime_error("Dataset attribute access error");
	} catch ( ... ) {
		std::cerr << "Exception accessing attr: " << name << std::endl;
		throw std::runtime_error("Dataset attribute access error");
	}
}

std::string datafile::DataFile::filename() const { return filename_; }
std::string datafile::DataFile::date() const { return date_; }
float datafile::DataFile::sampleRate() const { return sampleRate_; }
float datafile::DataFile::gain() const { return gain_; }
float datafile::DataFile::offset() const { return offset_; }
std::string datafile::DataFile::array() const { return array_; } 
size_t datafile::DataFile::nsamples() const { return nsamples_; }
size_t datafile::DataFile::nchannels() const { return nchannels_; }
double datafile::DataFile::length() const { return length_; }
H5::DataType datafile::DataFile::datatype() const { return dataset.getDataType(); };

void datafile::DataFile::data(size_t start, size_t end, arma::mat& out)
{
	_read_data(0, nchannels(), start, end, out);
}

void datafile::DataFile::data(size_t channel, size_t start, size_t end, arma::vec& out)
{
	_read_data_channel(channel, start, end, out);
}

void datafile::DataFile::data(size_t channel, size_t start, size_t end, arma::Col<short>& out)
{
	_read_data_channel(channel, start, end, out);
}

void datafile::DataFile::data(size_t startChan, size_t endChan,
		size_t start, size_t end, arma::mat& out)
{
	_read_data(startChan, endChan, start, end, out);
}

void datafile::DataFile::data(size_t start, size_t end, arma::Mat<short>& out)
{
	_read_data(0, nchannels(), start, end, out);
}

void datafile::DataFile::data(size_t startChan, size_t endChan,
		size_t start, size_t end, arma::Mat<short>& out)
{
	_read_data(startChan, endChan, start, end, out);
}

void datafile::DataFile::writeMeans(const arma::vec& means)
{
	const char name[] = "channel-means";
	if (dataset.attrExists(name))
		dataset.removeAttr(name);
	hsize_t dims[1] = {static_cast<hsize_t>(means.n_elem)};
	auto space = H5::DataSpace(1, dims);
	auto attr = dataset.createAttribute(name, 
			H5::PredType::IEEE_F64LE, space);
	attr.write(H5::PredType::IEEE_F64LE, means.memptr());
	attr.close();
}

arma::vec datafile::DataFile::readMeans()
{
	arma::vec ret;
	H5::Attribute attr;
	try {
		attr = dataset.openAttribute("channel-means");
	} catch (H5::AttributeIException& e) {
		return ret;
	}
	auto space = attr.getSpace();
	hsize_t dims[1] = {0};
	space.getSimpleExtentDims(dims);
	ret.set_size(dims[0]);
	attr.read(H5::PredType::IEEE_F64LE, ret.memptr());
	return ret;
}

