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
	writeAttributes();
}

snipfile::SnipFile::SnipFile(std::string fname) 
{
	/* open existing snippet file */
	filename_ = fname;
	struct stat buf;
	if (stat(filename_.c_str(), &buf) != 0) {
		std::cerr << "Snippet file does not exist: " << filename_ << std::endl;
		throw std::invalid_argument("Snippet file already exists");
	}

	file = H5::H5File(filename_, H5F_ACC_RDONLY);
	readAttributes();
	readChannels();
	readThresholds();
}

snipfile::SnipFile::~SnipFile()
{
	file.close();
}

void snipfile::SnipFile::writeAttributes()
{
	writeFileStringAttr("array", array());
	writeFileStringAttr("source-file", sourceFile());
	writeFileStringAttr("date", date());
	writeFileStringAttr("time", time());
	writeFileAttr("nsamples", H5::PredType::STD_U64LE, &nsamples_);
	writeFileAttr("gain", H5::PredType::IEEE_F32LE, &gain_);
	writeFileAttr("offset", H5::PredType::IEEE_F32LE, &offset_);
}

void snipfile::SnipFile::readAttributes()
{
	readFileStringAttr("array", array_);
	readFileStringAttr("source-file", sourceFile_);
	readFileStringAttr("date", date_);
	readFileStringAttr("time", time_);
	readFileAttr("nsamples", &nsamples_);
	readFileAttr("gain", &gain_);
	readFileAttr("offset", &offset_);
}

void snipfile::SnipFile::getSourceInfo(const datafile::DataFile& source)
{
	array_ = source.array();
	nsamples_ = source.nsamples();
	sourceFile_ = source.filename();
	sampleRate_ = source.sampleRate();
	date_ = source.date();
	time_ = source.time();
	gain_ = source.gain();
	offset_ = source.offset();
	dstType = source.datatype();
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
arma::uvec snipfile::SnipFile::channels() { return channels_; }
arma::vec snipfile::SnipFile::thresholds() { return thresholds_; }

void snipfile::SnipFile::setChannels(const arma::uvec& channels)
{
	channels_ = channels;
	nchannels_ = channels.n_elem;
	if (channelGroups.size() == 0) {
		std::string buf(32, '\0');
		for (auto& c : channels) {
			std::snprintf(&buf[0], buf.size(), "channel-%03llu", c);
			channelGroups.push_back(file.createGroup(buf.c_str()));
		}
	}
	writeChannels(channels_);
}

void snipfile::SnipFile::setThresholds(const arma::vec& thresh)
{
	thresholds_ =  thresh;
	writeThresholds(thresh);
}

void snipfile::SnipFile::writeSpikeSnips(const std::vector<arma::uvec> &idx,
		const std::vector<arma::Mat<short> >& snips)
{
	writeSnips("spike", idx, snips);
}

void snipfile::SnipFile::writeNoiseSnips(const std::vector<arma::uvec> &idx,
		const std::vector<arma::Mat<short> >& snips)
{
	writeSnips("noise", idx, snips);
}

void snipfile::SnipFile::writeSnips(const std::string& type, 
		const std::vector<arma::uvec>& idx, const std::vector<arma::Mat<short> >& snips)
{
	for (auto i = 0; i < nchannels_; i++) {
		/* Create data{space,set} for each channel's spike snippets and indices */
		auto& grp = channelGroups[i];
		hsize_t idxDims[snipfile::IDX_DATASET_RANK] = {idx.at(i).n_elem};
		H5::DataSpace idxSpace(snipfile::IDX_DATASET_RANK, idxDims);
		hsize_t snipDims[snipfile::SNIP_DATASET_RANK] = {
				snips.at(i).n_cols, snips.at(i).n_rows};
		H5::DataSpace snipSpace(snipfile::SNIP_DATASET_RANK, snipDims);
		H5::DataSet snipSet = grp.createDataSet(type + "-snippets", dstType,
				snipSpace);
		H5::DataSet idxSet = grp.createDataSet(type + "-idx", H5::PredType::STD_U64LE,
				idxSpace);
		spikeDatasets.push_back(snipSet);
		spikeIdxDatasets.push_back(idxSet);

		/* Write the datasets */
		snipSet.write(snips.at(i).memptr(), dstType);
		idxSet.write(idx.at(i).memptr(), H5::PredType::STD_U64LE);
	}
}

void snipfile::SnipFile::writeFileStringAttr(const std::string& name,
		const std::string& value)
{
	H5::StrType type(0, value.length());
	H5::DataSpace space(H5S_SCALAR);
	file.createAttribute(name, type, space);
	H5::Attribute attr = file.openAttribute(name);
	attr.write(type, value.c_str());
}

void snipfile::SnipFile::writeFileAttr(const std::string& name,
		const H5::DataType& dtype, const void* buf)
{
	H5::DataType type(dtype);
	H5::DataSpace space(H5S_SCALAR);
	file.createAttribute(name, type, space);
	H5::Attribute attr = file.openAttribute(name);
	attr.write(type, buf);
}

void snipfile::SnipFile::readFileStringAttr(const std::string& name,
		std::string& value)
{
	auto attr = file.openAttribute(name);
	auto sz = attr.getStorageSize();
	char *buf = new char[sz + 1];
	readFileAttr(name, buf);
	value.replace(0, sz, buf);
	delete[] buf;
}

void snipfile::SnipFile::readFileAttr(const std::string& name,
		void *buf)
{
	auto attr = file.openAttribute(name);
	attr.read(attr.getDataType(), buf);
}

void snipfile::SnipFile::writeChannels(const arma::uvec& channels)
{
	H5::DataType type(H5::PredType::STD_U64LE);
	writeFileAttr("nchannels", type, &channels.n_elem);
	hsize_t dims[1] = {channels.n_elem};
	H5::DataSpace space(1, dims);
	H5::DataSet set = file.createDataSet("channels", type, space);
	set.write(channels.memptr(), type);
}

void snipfile::SnipFile::readChannels()
{
	auto chanSet = file.openDataSet("channels");
	auto chanSpace = chanSet.getSpace();
	hsize_t dims[1] = {0};
	chanSpace.getSimpleExtentDims(dims);
	channels_.set_size(dims[0]);
	chanSet.read(channels_.memptr(), H5::PredType::STD_U64LE, H5::DataSpace::ALL);
}

void snipfile::SnipFile::writeThresholds(const arma::vec& thresholds)
{
	H5::DataType type(H5::PredType::IEEE_F64LE);
	hsize_t dims[1] = {thresholds.n_elem};
	H5::DataSpace space(1, dims);
	H5::DataSet set = file.createDataSet("thresholds", type, space);
	set.write(thresholds.memptr(), type);
}

void snipfile::SnipFile::readThresholds()
{
	auto threshSet = file.openDataSet("thresholds");
	auto threshSpace = threshSet.getSpace();
	hsize_t dims[1] = {0};
	threshSpace.getSimpleExtentDims(dims);
	thresholds_.set_size(dims[0]);
	threshSet.read(thresholds_.memptr(), H5::PredType::IEEE_F64LE, H5::DataSpace::ALL);
}

void snipfile::SnipFile::spikeSnips(std::vector<arma::uvec>& idx, 
		std::vector<arma::Mat<short> >& snippets)
{
	snips("spike", idx, snippets);
}

void snipfile::SnipFile::noiseSnips(std::vector<arma::uvec>& idx, 
		std::vector<arma::Mat<short> >& snippets)
{
	snips("spike", idx, snippets);
}

void snipfile::SnipFile::spikeSnips(std::vector<arma::uvec>& idx,
		std::vector<arma::mat>& snippets)
{
	std::vector<arma::Mat<short> > tmp;
	spikeSnips(idx, tmp);
	snippets.resize(tmp.size());
	for (auto i = 0; i < tmp.size(); i++)
		snippets[i] = gain() * arma::conv_to<arma::mat>::from(tmp[i]) + offset();
}

void snipfile::SnipFile::noiseSnips(std::vector<arma::uvec>& idx,
		std::vector<arma::mat>& snippets)
{
	std::vector<arma::Mat<short> > tmp;
	noiseSnips(idx, tmp);
	snippets.resize(tmp.size());
	for (auto i = 0; i < tmp.size(); i++)
		snippets[i] = gain() * arma::conv_to<arma::mat>::from(tmp[i]) + offset();
}

void snipfile::SnipFile::snips(const std::string& type, 
		std::vector<arma::uvec>& idx, std::vector<arma::Mat<short> >& snips)
{
	snips.resize(nchannels());
	idx.resize(nchannels());
	std::string buf(32, '\0');
	for (auto c = 0; c < nchannels(); c++) {
		auto grpName = std::snprintf(&buf[0], buf.size(), "channel-%03llu", c);
		H5::Group grp;
		try {
			grp = file.openGroup(buf);
		} catch (H5::GroupIException &e) {
			std::cerr << "Channel group does not exist: " << buf << std::endl;
		}
		
		/* Read indices */
		auto tmpIdxSet = grp.openDataSet(type + "-idx");
		auto idxSpace = tmpIdxSet.getSpace();
		hsize_t idxDims[1] = {0};
		idxSpace.getSimpleExtentDims(idxDims);
		auto nsnip = idxDims[0];
		auto& idxVec = idx.at(c);
		idxVec.set_size(nsnip);
		tmpIdxSet.read(idxVec.memptr(), H5::PredType::STD_U64LE, H5::DataSpace::ALL);
		
		/* Read snippets */
		auto tmpSnipSet = grp.openDataSet(type + "-snippets");
		auto snipSpace = tmpSnipSet.getSpace();
		hsize_t snipDims[2] = {0, 0};
		snipSpace.getSimpleExtentDims(snipDims);
		auto& snipMat = snips.at(c);
		snipMat.set_size(nsnip, snipDims[1]);
		tmpSnipSet.read(snipMat.memptr(), H5::PredType::STD_I16LE, H5::DataSpace::ALL);
	}
}

