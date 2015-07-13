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

void snipfile::SnipFile::setChannels(const arma::uvec& channels)
{
	channels_ = channels;
	nchannels_ = channels.n_elem;
	if (channelGroups.size() == 0) {
		for (auto& c : channels) {
			std::string buf(32, '\0');
			std::snprintf(&buf[0], buf.size(), "channel-%03llu", c);
			channelGroups.push_back(file.createGroup(buf.c_str()));
		}
	}
	writeChannels(channels_);
}

arma::uvec snipfile::SnipFile::channels() { return channels_; }

void snipfile::SnipFile::setThresholds(const arma::vec& thresh)
{
	thresholds_ =  thresh;
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

void snipfile::SnipFile::writeChannels(const arma::uvec& channels)
{
	H5::DataType type(H5::PredType::STD_U64LE);
	writeFileAttr("nchannels", type, &channels.n_elem);
	hsize_t dims[1] = {channels.n_elem};
	H5::DataSpace space(1, dims);
	H5::DataSet set = file.createDataSet("channels", type, space);
	set.write(channels.memptr(), type);
}

