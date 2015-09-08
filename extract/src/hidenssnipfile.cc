/* hidenssnipfile.cc
 *
 * Implementation of subclass of SnipFile which supports interaction with
 * the configuration information of a file recorded using the Hidens array.
 * 
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "hidenssnipfile.h"

hidenssnipfile::HidensSnipFile::HidensSnipFile(const std::string& name)
	: snipfile::SnipFile(name)
{
	readConfiguration();
}

hidenssnipfile::HidensSnipFile::HidensSnipFile(const std::string& name,
		const hidensfile::HidensFile& source,
		const size_t nbefore, const size_t nafter)
	: snipfile::SnipFile(name, source, nbefore, nafter)
{
	copyConfiguration(source);
}

hidenssnipfile::HidensSnipFile::~HidensSnipFile()
{
	file.close();
}

arma::Col<uint32_t> hidenssnipfile::HidensSnipFile::xpos() const { return xpos_; }
arma::Col<uint32_t> hidenssnipfile::HidensSnipFile::ypos() const { return ypos_; }
arma::Col<uint16_t> hidenssnipfile::HidensSnipFile::x() const { return x_; }
arma::Col<uint16_t> hidenssnipfile::HidensSnipFile::y() const { return y_; }
arma::Col<uint8_t> hidenssnipfile::HidensSnipFile::label() const { return label_; }
arma::Col<int32_t> hidenssnipfile::HidensSnipFile::connectedChannels() const
{
	return connectedChannels_;
}

void hidenssnipfile::HidensSnipFile::copyConfiguration(const 
		hidensfile::HidensFile& source)
{

	/* Read values from source file */
	xpos_ = source.xpos();
	ypos_ = source.ypos();
	x_ = source.x();
	y_ = source.y();
	label_ = source.label();
	connectedChannels_ = source.connectedChannels();

	/* Create group in dst file for configuration */
	auto configGroup = file.createGroup("configuration");

	/* Initialize dataspaces, same for each set */
	hsize_t rank = 1;
	hsize_t dims[1] = {x_.n_elem};
	auto space = H5::DataSpace(rank, dims);

	/* Create datasets and write them */
	auto xposDset = configGroup.createDataSet("xpos", 
			H5::PredType::STD_U32LE, space);
	writeConfigDataset(xposDset, xpos_);
	auto yposDset = configGroup.createDataSet("ypos", 
			H5::PredType::STD_U32LE, space);
	writeConfigDataset(yposDset, ypos_);
	auto xDset = configGroup.createDataSet("x", 
			H5::PredType::STD_U16LE, space);
	writeConfigDataset(xDset, x_);
	auto yDset = configGroup.createDataSet("y", 
			H5::PredType::STD_U16LE, space);
	writeConfigDataset(yDset, y_);
	auto strtype = H5::StrType(H5::PredType::C_S1, 1);
	strtype.setStrpad(H5T_STR_NULLPAD);
	auto labelDset = configGroup.createDataSet("label", 
			strtype, space);
	writeConfigDataset(labelDset, label_);
	auto channelDset = configGroup.createDataSet("channels", 
			H5::PredType::STD_I32LE, space);
	writeConfigDataset(channelDset, connectedChannels_);
}

void hidenssnipfile::HidensSnipFile::readConfiguration()
{
	auto configGroup = file.openGroup("configuration");
	auto xposDataset = configGroup.openDataSet("xpos");
	readConfigDataset(xposDataset, xpos_);
	auto yposDataset = configGroup.openDataSet("ypos");
	readConfigDataset(yposDataset, ypos_);
	auto xDataset = configGroup.openDataSet("x");
	readConfigDataset(xDataset, x_);
	auto yDataset = configGroup.openDataSet("y");
	readConfigDataset(yDataset, y_);
	auto labelDataset = configGroup.openDataSet("label");
	readConfigDataset(labelDataset, label_);
	auto channelDataset = configGroup.openDataSet("extracted-channels");
	readConfigDataset(channelDataset, connectedChannels_);
}

