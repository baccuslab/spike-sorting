/*! \file datafile-templates.h
 * Includes template function definitions used in the DataFile class.
 */

/* A set of templated functions that return the HDF5 data type corresponding
 * to the Armadillo matrix or vector into which data is to be read
 */
template<class ElemType,
	typename std::enable_if<std::is_same<ElemType, double>::value>::type* = nullptr>
H5::PredType data_type() {
	return H5::PredType::IEEE_F64LE;
}

template<class ElemType,
	typename std::enable_if<std::is_same<ElemType, short>::value>::type* = nullptr>
H5::PredType data_type() {
	return H5::PredType::STD_I16LE;
}

template<class ElemType,
	typename std::enable_if<std::is_same<ElemType, uint8_t>::value>::type* = nullptr>
H5::PredType data_type() {
	return H5::PredType::STD_U8LE;
}

template<class ElemType,
	typename std::enable_if<std::is_same<ElemType, int8_t>::value>::type* = nullptr>
H5::PredType data_type() {
	return H5::PredType::STD_I8LE;
}

template<class ElemType,
	typename std::enable_if<std::is_same<ElemType, float>::value>::type* = nullptr>
H5::PredType data_type() {
	return H5::PredType::IEEE_F32LE;
}
/* Template used to read multiple contiguous channels into memory at once */
template<class T>
void datafile::DataFile::_read_data(
		const size_t startChan, const size_t endChan, 
		const size_t start, const size_t end, arma::Mat<T>& out)
{
	/* Verify input and resize return array */
	if (end <= start) {
		std::cerr << "Requested sample range is invalid: Samples" 
			<< start << " - " << end << std::endl;
		throw std::logic_error("Requested sample range invalid");
	}
	size_t nreqSamples = end - start;
	if (endChan <= startChan) {
		std::cerr << "Requested sample range is invalid: Channels " 
			<< startChan << " - " << endChan << std::endl;
		throw std::logic_error("Requested sample range invalid");
	}
	size_t nreqChannels = endChan - startChan;
	out.set_size(nreqSamples, nreqChannels);

	/* Select hyperslab from the file */
	hsize_t spaceOffset[datafile::DATASET_RANK] = {startChan, start};
	hsize_t spaceCount[datafile::DATASET_RANK] = {nreqChannels, nreqSamples};
	dataspace.selectHyperslab(H5S_SELECT_SET, spaceCount, spaceOffset);
	if (!dataspace.selectValid()) {
		std::cerr << "Dataset selection invalid" << std::endl;
		std::cerr << "Offset: (, "<< startChan << ", " << start << ")" << std::endl;
		std::cerr << "Count: (" << nreqChannels << ", " << nreqSamples << ")" << std::endl;
		throw std::logic_error("Dataset selection invalid");
	}

	/* Define memory dataspace */
	hsize_t mdims[datafile::DATASET_RANK] = {nreqChannels, nreqSamples};
	H5::DataSpace mspace(datafile::DATASET_RANK, mdims);
	hsize_t moffset[datafile::DATASET_RANK] = {0, 0};
	hsize_t mcount[datafile::DATASET_RANK] = {nreqChannels, nreqSamples};
	mspace.selectHyperslab(H5S_SELECT_SET, mcount, moffset);
	if (!mspace.selectValid()) {
		std::cerr << "Memory dataspace selection invalid" << std::endl;
		std::cerr << "Count: (" << nreqSamples << ", " << nreqChannels << ")" << std::endl;
		throw std::logic_error("Memory dataspace selection invalid");
	}

	/* Get datatype of memory data space and read */
	H5::DataType dtype = data_type<T>();
	dataset.read(out.memptr(), dtype, mspace, dataspace);
}

/* Template function to read single data channel into memory. */
template<class T>
void datafile::DataFile::_read_data_channel(const size_t channel,
		const size_t start, const size_t end, arma::Col<T>& out)
{
	/* Verify input and resize return array */
	if (end <= start) {
		std::cerr << "Requested sample range is invalid: Samples" 
			<< start << " - " << end << std::endl;
		throw std::logic_error("Requested sample range invalid");
	}

	size_t nreqSamples = end - start;
	out.set_size(nreqSamples);

	/* Select hyperslab from the file */
	hsize_t spaceOffset[datafile::DATASET_RANK] = {channel, start};
	hsize_t spaceCount[datafile::DATASET_RANK] = {1, nreqSamples};
	dataspace.selectHyperslab(H5S_SELECT_SET, spaceCount, spaceOffset);
	if (!dataspace.selectValid()) {
		std::cerr << "Dataset selection invalid" << std::endl;
		std::cerr << "Offset: (, "<< channel << ", " << start << ")" << std::endl;
		std::cerr << "Count: (" << 1 << ", " << nreqSamples << ")" << std::endl;
		throw std::logic_error("Dataset selection invalid");
	}

	/* Define memory dataspace */
	hsize_t mdims[datafile::DATASET_RANK] = {1, nreqSamples};
	H5::DataSpace mspace(datafile::DATASET_RANK, mdims);
	hsize_t moffset[datafile::DATASET_RANK] = {0, 0};
	hsize_t mcount[datafile::DATASET_RANK] = {1, nreqSamples};
	mspace.selectHyperslab(H5S_SELECT_SET, mcount, moffset);
	if (!mspace.selectValid()) {
		std::cerr << "Memory dataspace selection invalid" << std::endl;
		std::cerr << "Count: (" << nreqSamples << ", " << 1 << ")" << std::endl;
		throw std::logic_error("Memory dataspace selection invalid");
	}

	/* Get datatype of memory data space and read */
	H5::DataType dtype = data_type<T>();
	dataset.read(out.memptr(), dtype, mspace, dataspace);
}

