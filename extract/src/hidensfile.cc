/* hidensfile.cc
 *
 * Impelementation of subclass of DataFile which reads configuration data
 * from files recorded using Hidens arrays.
 *
 * (C) 2015 Benjamin Naecker bnaecker@stanford.edu
 */

#include "hidensfile.h"

hidensfile::HidensFile::HidensFile(std::string name) : datafile::DataFile(name) 
{
	if (rdonly)
		readConfiguration();
	//else
		// not yet supported
}

hidensfile::HidensFile::~HidensFile()
{
	file.close();
}

arma::Col<uint32_t> hidensfile::HidensFile::xpos() const { return xpos_; }
arma::Col<uint32_t> hidensfile::HidensFile::ypos() const { return ypos_; }
arma::Col<uint16_t> hidensfile::HidensFile::x() const { return x_; }
arma::Col<uint16_t> hidensfile::HidensFile::y() const { return y_; }
arma::Col<uint8_t> hidensfile::HidensFile::label() const { return label_; }
arma::Col<int32_t> hidensfile::HidensFile::connectedChannels() const 
{ 
	return connectedChannels_; 
}

void hidensfile::HidensFile::readConfiguration()
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
	auto channelDataset = configGroup.openDataSet("channels");
	readConfigDataset(channelDataset, connectedChannels_);
}

