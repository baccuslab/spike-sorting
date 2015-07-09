/* datafile.cc
 *
 * Implementation of class representing raw data recorded from either
 * MCS or Hidens arrays, in HDF5 file format.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include <sys/stat.h>
#include <iostream>

#include "include/datafile.h"

datafile::DataFile::DataFile(std::string name)
{
	filename_ = name;
	struct stat buf;
	if (stat(name.c_str(), &buf) == 0) {
		/* File exists */
		rdonly = true;

		/* Open HDF5 file */
		try {
			file = H5::H5File(filename_, H5F_ACC_RDONLY);
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
			readTime();
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
		rdonly = false;
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

void datafile::DataFile::readTime()
{
	readDatasetStringAttr("time", time_);
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
		char *buf = new char[sz];
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

std::string datafile::DataFile::filename() { return filename_; }
std::string datafile::DataFile::date() { return date_; }
std::string datafile::DataFile::time() { return time_; }
float datafile::DataFile::sampleRate() { return sampleRate_; }
float datafile::DataFile::gain() { return gain_; }
float datafile::DataFile::offset() { return offset_; }
std::string datafile::DataFile::array() { return array_; } 
size_t datafile::DataFile::nsamples() { return nsamples_; }
size_t datafile::DataFile::nchannels() { return nchannels_; }
double datafile::DataFile::length() { return length_; }

