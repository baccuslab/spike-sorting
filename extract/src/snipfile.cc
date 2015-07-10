/* snipfile.cc
 *
 * Class representing a file to which noise and random snippets
 * are written.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include <sys/stat.h>
#include <iostream>
#include <typeinfo>

#include "snipfile.h"

snipfile::SnipFile::SnipFile(std::string fname, const datafile::DataFile& source)
{
	filename_ = fname;
	struct stat buf;
	if (stat(filename_.c_str(), &buf) == 0) {
		std::cerr << "Snippet file already exists: " << filename_ << std::endl;
		throw std::invalid_argument("Snippet file already exists");
	}

	/* Create file, meta-data, groups and datasets */
	file = H5::H5File(filename_, H5F_ACC_EXCL);
	getSourceInfo(source);
}

snipfile::SnipFile::~SnipFile()
{
	file.close();
}

void snipfile::SnipFile::getSourceInfo(const datafile::DataFile& source)
{
	array_ = source.array();
	nchannels_ = source.nchannels();
	nsamples_ = source.nsamples();
	sourceFile_ = source.filename();
	sampleRate_ = source.sampleRate();
	date_ = source.date();
	time_ = source.time();
	gain_ = source.gain();
	offset_ = source.offset();
}

template<class T>
void snipfile::SnipFile::writeSnippets(const std::vector<arma::uvec>& idx,
		const std::vector<T>& snippets) 
{
	H5::DataType dtype;
	if (typeid(T).hash_code() == typeid(arma::Mat<uint8_t>).hash_code())
		dtype = H5::PredType::STD_U8LE;
	else 
		dtype = H5::PredType::STD_I16LE;
}

std::string snipfile::SnipFile::array() { return array_; }
size_t snipfile::SnipFile::nchannels() { return nchannels_; }
size_t snipfile::SnipFile::nsamples() { return nsamples_; }
std::string snipfile::SnipFile::sourceFile() { return sourceFile_; }
float snipfile::SnipFile::sampleRate() { return sampleRate_; }
std::string snipfile::SnipFile::date() { return date_; }
std::string snipfile::SnipFile::time() { return time_; }
float snipfile::SnipFile::gain() { return gain_; }
float snipfile::SnipFile::offset() { return offset_; }

