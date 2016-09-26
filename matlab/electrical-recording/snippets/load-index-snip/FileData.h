//
// Random access to file data
//
template<class T>
class RandAccessFilePtr {
private:
	FILE *fp;
	long dataBegin,dataEnd;
public:
	// exception classes
	class Range { };
	class ReInitialize { };

	RandAccessFilePtr(FILE *fptr,long nsamp);
	RandAccessFilePtr() {dataBegin = 0;}
	void setup(FILE *fptr,long nsamp);
	
	void getblock(vectlr<T>&);		// Also, >> is defined below
	void getblock(mtrxlr<T>&);
	long nsamples() const {return (dataEnd-dataBegin)/sizeof(T);}
};

template<class T>
RandAccessFilePtr<T>::RandAccessFilePtr(FILE *fptr,long nsamp)
{
	dataBegin = 0;
	setup(fptr,nsamp);
}

template<class T>
void RandAccessFilePtr<T>::setup(FILE *fptr,long nsamp)
{
/*
	if (dataBegin != 0) {
		errormsg("error (RandAccessFilePtr::setup): trying to reinitialize");
		throw ReInitialize();
	}
*/
	fp = fptr;
	dataBegin = ftell(fp);
	dataEnd = nsamp*sizeof(T) + dataBegin;
}

template<class T>
void RandAccessFilePtr<T>::getblock(vectlr<T> &v)
{
	long beg = dataBegin + v.left*sizeof(T);
	long end = beg + v.size()*sizeof(T);
	if (beg < 0 || end > dataEnd) {
		errormsg("error (RandAccessFilePtr::getblock(vectlr)): range error");
		throw Range();
	}
	fseek(fp,beg,SEEK_SET);
	fread(v.begin(),sizeof(T),v.size(),fp);
	if (ferror(fp)) {
		errormsg("error (RandAccessFilePtr::getblock(vectlr)): unknown read error");
		throw FileErr();
	}
}

template<class T>
void RandAccessFilePtr<T>::getblock(mtrxlr<T> &m)
{
	// m is responsible for knowing the # of channels
	// Data on disk is stored in column-order, while memory is row-order,
	// so have to transpose
	long beg = dataBegin + m.left()*m.height()*sizeof(T);
	long end = beg + m.size()*sizeof(T);
	if (beg < 0 || end > dataEnd) {
		THMessage("error (RandAccessFilePtr::getblock(mtrxlr)): range error");
		throw Range();
	}
	fseek(fp,beg,SEEK_SET);
	// Define a matrix that is the transpose of m
	mtrxlr<T> mtemp(m.left(),m.right(),m.rowmin(),m.rowmax());
	fread(mtemp.begin(),sizeof(T),mtemp.size(),fp);
	if (ferror(fp)) {
		THMessage("error (RandAccessFilePtr::getblock(mtrxlr)): unknown read error");
		throw FileErr();
	}
	long i,j;
	for (i = m.rowmin(); i <= m.rowmax(); i++)
		for (j = m.left(); j <= m.right(); j++)
			m[i][j] = mtemp[j][i];
}

template<class T>
RandAccessFilePtr<T>& operator>>(RandAccessFilePtr<T> &rafp,vectlr<T> &v)
{
	rafp.getblock(v);
	return rafp;
}

template<class T>
RandAccessFilePtr<T>& operator>>(RandAccessFilePtr<T> &rafp,mtrxlr<T> &m)
{
	rafp.getblock(m);
	return rafp;
}




//
// Class DataWindow
// Sequential access to file data
// There is one problem with this class: because of the way the data
// is stored on disk, getting it into a smart form for mtrxlr requires
// a transposition operation, which in some cases takes most of the time.
// See ScanWindow for an alternative
//
template<class T>
class DataWindow {
private:
	mtrxlr<T> m,mload;
	long nscans;
	long leftbuff,rightbuff;
	bool firstcall;
public:
	DataWindow() {leftbuff = rightbuff = 0; firstcall = true;}
	DataWindow(long nscns,long rmin,long rmax,long width,long lbuff = 0,long rbuff = 0);
	void resize(long nscns,long rmin,long rmax,long width,long lbuff = 0,long rbuff = 0);
	
	bool atEnd() {return !(m.right() < nscans-1);}
	long left() const {return m.left()+leftbuff;}
	long right() const {return m.right()-rightbuff;}
	long width() const {return m.width()-leftbuff-rightbuff;}
	mtrxlr<T> data() const {return m;}

	void read(FilePtr&);
};


template<class T>
DataWindow<T>::DataWindow(long nscns,long rmin,long rmax,long width,long lbuff,long rbuff)
{
	nscans = nscns;
	leftbuff = lbuff;
	rightbuff = rbuff;
	firstcall = true;
	if (leftbuff + rightbuff < nscans) {
		m.resize(rmin,rmax,0,min(width+lbuff+rbuff,nscns)-1);
		mload.resize(0,width-1,rmin,rmax);	// Transposed matrix
	}
}

template<class T>
void DataWindow<T>::resize(long nscns,long rmin,long rmax,long width,long lbuff,long rbuff)
{
	nscans = nscns;
	leftbuff = lbuff;
	rightbuff = rbuff;
	firstcall = true;
	if (leftbuff + rightbuff < nscans) {
		m.resize(rmin,rmax,0,min(width+lbuff+rbuff,nscns)-1);
		mload.resize(0,width-1,rmin,rmax);	// Transposed matrix
	}
}

template<class T>
void DataWindow<T>::read(FilePtr &fp)
{
	long i,j;
	if (firstcall) {
		firstcall = false;
		mtrxlr<T> mtemp(m.left(),m.right(),m.rowmin(),m.rowmax());	// Transpose of m
		fread(mtemp.begin(),sizeof(T),mtemp.size(),fp);
		if (ferror(fp)) {
			THMessage("error (operator>>(FilePtr&,DataWindow&)): unknown read error");
			throw FileErr();
		}
		for (i = m.rowmin(); i <= m.rowmax(); i++)
			for (j = m.left(); j <= m.right(); j++)
				m[i][j] = mtemp[j][i];
		return;
	}
	if (m.right() + width() < nscans) {		// Won't hit eof
		mtrxlr<T> rightwing(m,m.rowmin(),m.rowmax(),right()-leftbuff+1,m.right());
		m.shiftleft(right()+1-leftbuff);
		copydata(rightwing,m);
	}
	else {	// We'll hit eof, so resize to make flush
		mtrxlr<T> rightwing(m.rowmin(),m.rowmax(),right()-leftbuff+1,m.right());
		copydata(m,rightwing);
		m.resize(m.rowmin(),m.rowmax(),right()-leftbuff+1,nscans-1);
		copydata(rightwing,m);
	}
	fread(mload.begin(),sizeof(T),width()*m.height(),fp);
	for (i = m.rowmin(); i <= m.rowmax(); i++)
		for (j = 0; j < width(); j++)
			m[i][j+left()+rightbuff] = mload[j][i];
}

template <class T>
FilePtr& operator>>(FilePtr &fp,DataWindow<T> &dw)
{
	dw.read(fp);
	return fp;
}


//
// Class ScanWindow
// This is the recommended approach for sequential access to data
//
//const long nil = 0;

template <class T>
class ScanWindow {
private:
	T* data;
	long numCh,width;
	long currscan,nscans;
	long leftbuff,rightbuff;
	long sumsize;			// Will always be leftbuff+width+rightbuff
	bool firstcall;
public:
	ScanWindow();
	ScanWindow(long nscns,long nCh,long wdth,long lbuff = 0,long rbuff = 0);
	void resize(long nscns,long nCh,long wdth,long lbuff = 0,long rbuff = 0);
	~ScanWindow();
	

	bool atEnd() const {return (currscan+sumsize >= nscans);}
	SkipPtr<T> fullmem(long i);	// To access the ith channel data (zero-offset)
	SkipPtr<T> window(long i);	// window stays inside window, fullmem gives full range in memory
	long windowwidth() const {return width;}
	long index(T* vsp) const {return currscan+long(vsp-data)/numCh;}

	//friend FilePtr& operator>>(FilePtr &fp,ScanWindow<T> &sw);
	void read(FilePtr &fp);
	void advance();
};

template<class T>
ScanWindow<T>::ScanWindow()
{
	leftbuff = rightbuff = width = sumsize = 0;
	numCh = currscan = nscans = 0;
	firstcall = true;
	data = nil;
}

template<class T>
ScanWindow<T>::ScanWindow(long nscns,long nCh,long wdth,long lbuff,long rbuff)
{
	data = 0;
	resize(nscns,nCh,wdth,lbuff,rbuff);
}

template<class T>
void ScanWindow<T>::resize(long nscns,long nCh,long wdth,long lbuff,long rbuff)
{
	nscans = nscns;
	numCh = nCh;
	leftbuff = lbuff;
	rightbuff = rbuff;
	firstcall = true;
	width = wdth;
	if (leftbuff+rightbuff+width > nscans)
		width = nscans-leftbuff-rightbuff;
	currscan = -width;
	if (width < 0) {
		width = leftbuff = rightbuff = 0;
		currscan = nscans;					// So atEnd will return true
	}
	sumsize = width+leftbuff+rightbuff; 	// A commonly used quantity
	if (data != 0)
		delete[] data;
	data = new T[sumsize*numCh];
	if (!data) {
		THMessage("ScanWindow<T> constructor/resize: out of memory");
		exit(1);
	}
}

template<class T>
ScanWindow<T>::~ScanWindow()
{
	delete[] data;
}

template<class T>
inline SkipPtr<T> ScanWindow<T>::fullmem(long i)
{
	return SkipPtr<T>(data+i,data+i+sumsize*numCh,numCh);
}

template<class T>
inline SkipPtr<T> ScanWindow<T>::window(long i)
{
	return SkipPtr<T>(data+i+leftbuff*numCh,data+i+(leftbuff+width)*numCh,numCh);
}


template<class T>
void ScanWindow<T>::read(FilePtr &fp)
{
	if (firstcall) {
		firstcall = false;
		fread(data+width*numCh,sizeof(T),(leftbuff+rightbuff)*numCh,fp);
		if (ferror(fp)) {
			THMessage("error (operator>>(FilePtr&,ScanWindow&): read error1");
			throw FileErr();
		}
	}
	copy(data+width*numCh,data+sumsize*numCh,data);
	currscan += width;
	if (currscan + width + rightbuff >= nscans) {	// Will we go beyond end of file?
		width = nscans-currscan-leftbuff-rightbuff;
		sumsize = width+leftbuff+rightbuff;
	}
	fread(data+(leftbuff+rightbuff)*numCh,sizeof(T),width*numCh,fp);
	if (ferror(fp)) {
		THMessage("error (operator>>(FilePtr&,ScanWindow&): read error2");
		throw FileErr();
	}
}


template<class T>
void ScanWindow<T>::advance()
{
	currscan+=width;
}

template<class T>
FilePtr& operator>>(FilePtr &fp,ScanWindow<T> &sw)
{
	sw.read(fp);
	return fp;
}

//
// Class BlockWindow

template <class T>
class BlockWindow {
private:
	T* data;
	long numCh,width;
	long currscan,nscans;
	long leftbuff,rightbuff;
	long sumsize;			// Will always be leftbuff+width+rightbuff
	bool firstcall;
public:
	BlockWindow();
 	BlockWindow(long nscns,long nCh,long wdth,long lbuff = 0,long rbuff = 0);
	void resize(long nscns,long nCh,long wdth,long lbuff = 0,long rbuff = 0);
	~BlockWindow();
	

	bool atEnd() const {return (currscan+sumsize >= nscans);}
	int16 *datastart();	
	long windowwidth() const {return width;}
	long index(T* vsp) const {
		ldiv_t scandata=div(long(vsp-(data+leftbuff)),width); //Remove effects of chan number
		ldiv_t scanwin=div(scandata.rem-rightbuff,width); //Remove effects of win #
		return long(1+currscan+scanwin.rem);
	}

	//friend FilePtr& operator>>(FilePtr &fp, BlockWindow<T> &sw);
	void read(FilePtr &fp);
	void advance();
};

template<class T>
BlockWindow<T>::BlockWindow()
{
	leftbuff = rightbuff = width = sumsize = 0;
	numCh = currscan = nscans = 0;
	firstcall = true;
	data = nil;
}

template<class T>
BlockWindow<T>::BlockWindow(long nscns,long nCh,long wdth,long lbuff,long rbuff)
{
	data = 0;
	resize(nscns,nCh,wdth,lbuff,rbuff);
}

template<class T>
void BlockWindow<T>::resize(long nscns,long nCh,long wdth,long lbuff,long rbuff)
{
	nscans = nscns;
	numCh = nCh;
	leftbuff = lbuff;
	rightbuff = rbuff;
	firstcall = true;
	width = wdth;
	if (width > nscans)
		width = nscans;
	currscan = -width;
	if (width < 0) {
		width = leftbuff = rightbuff = 0;
		currscan = nscans;					// So atEnd will return true
	}
	sumsize = width+leftbuff+rightbuff; 	// A commonly used quantity
	if (data != 0)
		delete[] data;
	data = new T[sumsize*numCh];
	if (!data) {
		THMessage(" BlockWindow<T> constructor/resize: out of memory");
		exit(1);
	}
}

template<class T>
BlockWindow<T>::~BlockWindow()
{
	delete[] data;
}

template<class T>
inline int16 *BlockWindow<T>::datastart()
{
	return data;
}


template<class T>
void BlockWindow<T>::read(FilePtr &fp)
{
	currscan += width;
	if (currscan + width + rightbuff >= nscans) {	// Will we go beyond end of file?
		width = nscans;
		sumsize = width+leftbuff+rightbuff;
	}
	fread(data+(leftbuff+rightbuff),sizeof(T),width*numCh,fp);
	if (ferror(fp)) {
		THMessage("error (operator>>(FilePtr&,BlockWindow&): read error2");
		throw FileErr();
	}
}


template<class T>
void BlockWindow<T>::advance()
{
	currscan+=width;
}

template<class T>
FilePtr& operator>>(FilePtr &fp,BlockWindow<T> &sw)
{
	sw.read(fp);
	return fp;
}
