// vectlr and mtrxlr are (essentially) template versions of Numerical Recipes
// definitions, with constructors and destructors.
//
// Copy constructors and operator= DO NOT copy the data, only the pointers. To copy the
// data, explicitly call copydata(source,dest) with a pre-allocated dest object.
// This convention eliminates wasted cycles.
//
// By default, bounds are not checked on []. If you want to check bounds, define
// CHECKBOUNDS before including this file. This is a good thing to do
// for debugging your program. Comment out the definition for faster performance.
//
// Lots more operators could be defined, but I prefer the minimalist approach.
// These types handle basically everything involving memory & indexing,
// usually the major source of hard-to-find bugs.
//
// The function THMessage has to be defined externally.
//
// Class SkipPtr offers a "smart pointer" which has an increment which
// you set on construction, and allows bounds-checking through the CHECKBOUNDS
// precompiler flag.
// SkipPtr offers an alternative method for dealing with matrices, if you just
// want to focus on a single row or column. In particular, there is never the need for a
// transpose operation if you do everything with SkipPtrs. 
//
// There are a few utility functions defined at the end of the file.
//
// Tim Holy, August 4, 1998.
// revised: August 21, 1998. (TH)
// class SkipPtr added Jan 11, 1999 (TH).

#include <iostream.h>
#include <vector>
//#include <iostream>

#ifndef NUMERTYPES
#define NUMERTYPES 1
#define UNDERRUN 0

extern void THMessage(char *msg);

// Numerical constants
const float PI = 3.1415927;

//
// Fixed-size numerical types
//
typedef char				int8;
typedef unsigned char		uint8;
typedef uint8				uchar;
typedef short				int16;
typedef unsigned short		uint16;
typedef long				int32;
typedef unsigned long		uint32;
typedef float				float32;
//typedef short double		float64;

//
// Class vectlr
//
template<class T>
class vectlr {
private:
	long leftd,rightd;
	T *data;
	bool alloc;				// A flag to keep track of whether
							// this object has data memory allocated
	
public:
	class NoMem {};			// exception class: no memory
	class OverWrite {};		// exception class: tried to overwrite object
	class BadRange {};		// exception class: leftd > rightd
	class BadIndex {};		// exception class: subscript out of bounds
							//    (checked only when CHECKBOUNDS is defined)

	// Construction, allocation, and destruction
	vectlr(long l,long r) {data = 0; alloc = false; allocate(l,r);}
	vectlr(long l,long r,T *d) {
		leftd = l;
		rightd = r;
		data = d;			// Does not copy the data!
		alloc = false;
	}
	vectlr(const vectlr<T> &vlr) {
		leftd = vlr.leftd;
		rightd = vlr.rightd;
		data = vlr.data;
		alloc = false;
	}
	vectlr(const vectlr<T> &vlr,long l,long r) {
#ifdef CHECKBOUNDS
		if (l < vlr.leftd || r > vlr.rightd) {
			THMessage("error (vectlr::vectlr): Bad indices on subvector");
			throw BadIndex();
		}
#endif
		leftd = l;
		rightd = r;
		if (r < l)
			data = 0;
		else
			data = vlr.data;
		alloc = false;
	}
	vectlr() {data = 0; alloc = false; leftd = 0; rightd = -1;}
	void allocate(long l,long r) {
		if (!alloc) {
			leftd = l;
			rightd = r;
			if (rightd >= leftd) {
				data = new T[r-l+1+UNDERRUN];
				if (!data) {
					THMessage("error (vectlr::allocate): No memory");
					throw NoMem();
				}
				data -= l-UNDERRUN;
				alloc = true;
			}
			else {
				data = 0;
				alloc = false;
			}
		}
		else {
			THMessage("error (vectlr::allocate): Overwriting data");
			throw OverWrite();
		}
	}
	void resize(long l,long r) {
		clear();
		allocate(l,r);
	}
	void clear() {if (alloc) delete[] (data+leftd-UNDERRUN); data = 0; alloc = false; leftd = 0; rightd = -1;}
	~vectlr() {clear();}
	vectlr<T>& operator=(const vectlr<T> &v) {
		if (this != &v) {		// Beware of v = v
			clear();
			leftd = v.leftd;
			rightd = v.rightd;
			data = v.data;
			alloc = false;
		}
		return *this;
	}
	vectlr<T> operator()(long l,long r) {
		return vectlr<T>(*this,l,r);
	}
	
	// Index manipulation & element access
	void shiftfirst(long l) {
		data += leftd - l;
		rightd += l - leftd;
		leftd = l;
	}
	T* unit_offset() {				// For convenient access to NR
		return data + leftd - 1;
	}
	T& operator[](long i) {
#ifdef CHECKBOUNDS
		if (i < leftd || i > rightd) {
			THMessage("error (vectlr::operator[]): Bad index");
			throw BadIndex();
		}
#endif
		return data[i];
	}
	const T& operator[](long i) const {
#ifdef CHECKBOUNDS
		if (i < leftd || i > rightd) {
			THMessage("error (vectlr::operator[]): Bad index");
			throw BadIndex();
		}
#endif
		return data[i];
	}
	T* begin() const {
		return data+leftd;
	}
	T* end() const {
		return data+rightd+1;
	}
	T* last() const {
		return data+rightd;
	}
	long left() const {
		return leftd;
	}
	long right() const {
		return rightd;
	}
	long size() const {return rightd-leftd+1;}

//	friend int main();			// For testing & debugging
};


//
// Class mtrxlr
//
// Row pointers are always allocated; otherwise shift operations can move the data out from
//   under a matrix
template<class T>
class mtrxlr {
private:
	long rowmind,rowmaxd;
	long leftd,rightd;
	T **data;
	bool alloc;			// Data memory allocated?
	bool ralloc;		// Row pointers allocated?

	void allocate_rowp();	// must have rowmind,rowmaxd,leftd,rightd already set
public:
	class NoMem {};
	class OverWrite {};
	class BadRange {};
	class BadIndex {};
	//class MemBlock {};
	mtrxlr(long rmin,long rmax,long l,long r) {data = 0; alloc = ralloc = false; allocate(rmin,rmax,l,r);}
	mtrxlr() {data = 0; alloc = ralloc = false; leftd = rowmind = 0; rightd = rowmaxd = -1;}
	mtrxlr(const mtrxlr<T> &m,long rmin,long rmax,long l,long r);
	mtrxlr(const mtrxlr<T> &m) {
		rowmind = m.rowmind;
		rowmaxd = m.rowmaxd;
		leftd = m.leftd;
		rightd = m.rightd;
		allocate_rowp();
		for (long j = rowmind; j <= rowmaxd; j++)
			data[j] = m.data[j];
		alloc = false;
	}
	mtrxlr(const mtrxlr<T> &m,const vector<long> &rowlist,long l,long r);
	mtrxlr(const mtrxlr<T> &m,const vectlr<long> &rowlist,long l,long r);
	void allocate(long rmin,long rmax,long l,long r);
	void resize(long rmin,long rmax,long l,long r) {
		clear();
		allocate(rmin,rmax,l,r);
	}
	void clear() {
		if (alloc) delete[] (data[rowmind]+leftd-UNDERRUN);
		if (ralloc) delete[] (data+rowmind-UNDERRUN);
		data = 0;
		alloc = ralloc = false;
		leftd = rowmind = 0; rightd = rowmaxd = -1;
	}
	~mtrxlr() {clear();}
	mtrxlr<T>& operator=(const mtrxlr<T> &m) {
		if (this != &m)	{	// Beware of m = m
			clear();
			leftd = m.leftd;
			rightd = m.rightd;
			rowmind = m.rowmind;
			rowmaxd = m.rowmaxd;
			allocate_rowp();
			for (long i = rowmind; i <= rowmaxd; i++)
				data[i] = m.data[i];
			alloc = false;
		}
		return *this;
	}
	mtrxlr<T> operator()(long rmin,long rmax,long l,long r) {
		return mtrxlr<T>(*this,rmin,rmax,l,r);
	}
	
	// index manipulation & data access
	void shiftfirst(long rmin,long l);
	void shiftleft(long l) {
		shiftfirst(rowmind,l);
	}
#ifdef CHECKBOUNDS
	vectlr<T> operator[](long i) {return row(i);}
	const vectlr<T> operator[](long i) const {return row(i);}
	vectlr<T> row(long i) {
		if (i < rowmind || i > rowmaxd) {
			THMessage("error (mtrxlr::row): Bad row index");
			throw BadIndex();
		}
		return vectlr<T>(leftd,rightd,data[i]);
	}
	const vectlr<T> row(long i) const {
		if (i < rowmind || i > rowmaxd) {
			THMessage("error (mtrxlr::row): Bad row index");
			throw BadIndex();
		}
		return vectlr<T>(leftd,rightd,data[i]);
	}
#else
	T* operator[](long i) {return data[i];}
	const T* operator[](long i) const {return data[i];}
	vectlr<T> row(long i) {return vectlr<T>(leftd,rightd,data[i]);}
	const vectlr<T> row(long i) const {return vectlr<T>(leftd,rightd,data[i]);}
#endif
	T* begin() const;
	T* end() const;
	T* last() const;
	T** nrcast() const {return data;}
	long left() const {return leftd;}
	long right() const {return rightd;}
	long rowmin() const {return rowmind;}
	long rowmax() const {return rowmaxd;}
	long width() const {return rightd-leftd+1;}
	long height() const {return rowmaxd-rowmind+1;}
	long size() const {return width()*height();}

//	friend int main();			// For testing & debugging
};

// mtrxlr member functions
template <class T>
void mtrxlr<T>::allocate_rowp()
{
	const long nrow = rowmaxd-rowmind+1;
	if (nrow > 0) {
		data = new T*[nrow+UNDERRUN];
		if (!data) {
			THMessage("error(mtrxlr::allocate_rowp): No memory");
			throw NoMem();
		}
		ralloc = true;
		data -= rowmind-UNDERRUN;
	}
	else {
		data = 0;
		ralloc = false;
	}
}

template <class T>
void mtrxlr<T>::allocate(long rmin,long rmax,long l,long r)
 {
	if (!(alloc || ralloc)) {
		leftd = l;
		rightd = r;
		rowmind = rmin;
		rowmaxd = rmax;
		allocate_rowp();
		const long nrow = rowmaxd-rowmind+1;
		const long ncol = rightd-leftd+1;
		if (nrow > 0 && ncol > 0) {
			data[rowmind] = new T[nrow*ncol+UNDERRUN];
			if (!data[rowmind]) {
				THMessage("error(mtrxlr::allocate): No memory");
				throw NoMem();
			}
			data[rowmind] -= leftd-UNDERRUN;
			for (long i = rowmind+1; i <= rowmaxd; i++)
				data[i] = data[i-1]+ncol;
			alloc = true;
		}
		else
			alloc = false;
	}
	else {
		THMessage("error (mtrxlr::allocate): Overwriting data");
		throw OverWrite();
	}
}

template <class T>
mtrxlr<T>::mtrxlr(const mtrxlr<T> &m,long rmin,long rmax,long l,long r)
{
#ifdef CHECKBOUNDS
	if (rmin < m.rowmind || rmax > m.rowmaxd || l < m.leftd || r > m.rightd) {
		THMessage("error (mtrxlr::mtrxlr): Bad indices on submatrix");
		throw BadIndex();
	}
#endif
	leftd = l;
	rightd = r;
	rowmind = rmin;
	rowmaxd = rmax;
	allocate_rowp();
	for (long i = rowmind; i <= rowmaxd; i++)
		data[i] = m.data[i];
	alloc = false;
}

template <class T>
mtrxlr<T>::mtrxlr(const mtrxlr<T> &m,const vector<long> &rowlist,long l,long r)
{
	vector<long>::iterator begn = rowlist.begin();
	vector<long>::iterator ennd = rowlist.end();
#ifdef CHECKBOUNDS
	if (*min_element(begn,ennd) < m.rowmind || *max_element(begn,ennd) > m.rowmaxd || l < m.leftd || r > m.rightd) {
		THMessage("error (mtrxlr::mtrxlr): Bad indices on submatrix");
		throw BadIndex();
	}
#endif
	const long sz = rowlist.size();
	leftd = l;
	rightd = r;
	rowmind = 0;
	rowmaxd = sz - 1;
	allocate_rowp();
	long j;
	for (j = rowmind; j <= rowmaxd; j++,begn++)
		data[j] = m.data[*begn];
	alloc = false;
}

template <class T>
mtrxlr<T>::mtrxlr(const mtrxlr<T> &m,const vectlr<long> &rowlist,long l,long r)
{
#ifdef CHECKBOUNDS
	if (min(rowlist) < m.rowmind || max(rowlist) > m.rowmaxd || l < m.leftd || r > m.rightd) {
		THMessage("error (mtrxlr::mtrxlr): Bad indices on submatrix");
		throw BadIndex();
	}
#endif
	const long sz = rowlist.size();
	leftd = l;
	rightd = r;
	rowmind = 0;
	rowmaxd = sz - 1;
	allocate_rowp();
	long j;
	for (j = rowmind; j <= rowmaxd; j++)
		data[j] = m.data[rowlist[rowlist.left()+j]];
	alloc = false;
}

template <class T>
void mtrxlr<T>::shiftfirst(long rmin,long l)
{
	data += rowmind-rmin;
	rowmaxd += rmin-rowmind;
	rowmind = rmin;
	long j;
	for (j = rowmind; j <= rowmaxd; j++)
		data[j] += leftd - l;
	rightd += l-leftd;
	leftd = l;
}

template <class T>
T* mtrxlr<T>::begin() const
{
	if (!alloc)
		THMessage("warning (mtrxlr::begin): Dangerous operation, may not be continuous memory block");
	return row(rowmind).begin();
}

template <class T>
T* mtrxlr<T>::end() const
{
	if (!alloc)
		THMessage("warning (mtrxlr::end): Dangerous operation, may not be continuous memory block");
	return row(rowmaxd).end();
}

template <class T>
T* mtrxlr<T>::last() const
{
	if (!alloc)
		THMessage("warning (mtrxlr::last): Dangerous operation, may not be continuous memory block");
	return row(rowmaxd).last();
}


//
// Class SkipPtr
//
template<class T>
class SkipPtr {
private:
	T *current;
	T *pbegin,*pend;	// beyond-the-end pointer as in STL
	long skip;
public:
	class BadIndex {};		// exception class: subscript out of bounds
							//    (checked only when CHECKBOUNDS is defined)

	SkipPtr(T *b,T *e,long s) {current = pbegin = b; pend = e; skip = s;}
	SkipPtr(T *b,long l,long s) {current = pbegin = b; pend = pbegin + l*s; skip = s;}
	SkipPtr() {current = pbegin = pend = 0; skip = 0;}
	
	SkipPtr& operator=(const SkipPtr &vsp) {
		current = vsp.current;
		pbegin = vsp.pbegin;
		pend = vsp.pend;
		skip = vsp.skip;
		return *this;
	}
	SkipPtr& operator=(T*c) {current = c; return *this;}
	SkipPtr& operator=(long c) {current = pbegin+c*skip; return *this;}

	// Element access: through [], *, ->, and cast by T*
	// This is where bounds are checked, if desired
	// Note that a cast by T* lets you get to the beyond-the-end element,
	// no other method will let you get it. (This is necessary for STL compatibility)
	T& operator[](long i) {
#ifdef CHECKBOUNDS
		if (current+i*skip < pbegin || current+i*skip >= pend) {
			THMessage("error (SkipPtr::operator[]): Bad index");
			throw BadIndex();
		}
#endif
		return current[i*skip];
	}
	const T& operator[](long i) const {
#ifdef CHECKBOUNDS
		if (current+i*skip < pbegin || current+i*skip >= pend) {
			THMessage("error (SkipPtr::operator[]): Bad index");
			throw BadIndex();
		}
#endif
		return current[i*skip];
	}
	T& operator*() {
#ifdef CHECKBOUNDS
		if (current < pbegin || current >= pend) {
			THMessage("error (SkipPtr::operator*): Bad index");
			throw BadIndex();
		}
#endif
		return *current;
	}
	const T& operator*() const {
#ifdef CHECKBOUNDS
		if (current < pbegin || current >= pend) {
			THMessage("error (SkipPtr::operator*): Bad index");
			throw BadIndex();
		}
#endif
		return *current;
	}
	
	T* operator->() {
#ifdef CHECKBOUNDS
		if (current < pbegin || current >= pend) {
			THMessage("error (SkipPtr::operator->): Bad index");
			throw BadIndex();
		}
#endif
		return current;
	}
	const T* operator->() const {
#ifdef CHECKBOUNDS
		if (current < pbegin || current >= pend) {
			THMessage("error (SkipPtr::operator->): Bad index");
			throw BadIndex();
		}
#endif
		return current;
	}
	
	operator T*() {
#ifdef CHECKBOUNDS
		if (current < pbegin || current > pend) {	// Note > pend rather than >= pend; for STL compatibility
			THMessage("error (SkipPtr::operatorT*): Bad index");
			throw BadIndex();
		}
#endif
		return current;
	}
	operator T*() const {
#ifdef CHECKBOUNDS
		if (current < pbegin || current > pend) {	// Note > pend rather than >= pend; for STL compatibility
			THMessage("error (SkipPtr::operatorT*): Bad index");
			throw BadIndex();
		}
#endif
		return current;
	}
	
	// Access to range elements
	T* begin() const {return pbegin;}
	T* unit_offset() const {return pbegin-1;}
	T* end() const {return pend;}
	T* last() const {return pend-skip;}
	long size() const {return (pend-pbegin)/skip;}

	// Pointer-to-index conversion
	long index() const {return (current-pbegin)/skip;}
	
	// Pointer arithmetic
	SkipPtr& operator++() {current += skip; return *this;}
	SkipPtr operator++(int) {current += skip; return *this;}
	SkipPtr& operator--() {current -= skip; return *this;}
	SkipPtr operator--(int) {current -= skip; return *this;}
	SkipPtr& operator+=(long i) {current += i*skip; return *this;}
	SkipPtr& operator-=(long i) {current -= i*skip; return *this;}
	SkipPtr operator+(long i) const;
	SkipPtr operator-(long i) const;

	// Comparison operators
	bool operator!=(T *p) {return current != p;}
	bool operator==(T *p) {return current == p;}
	bool operator<(T *p) {return current < p;}
	bool operator<=(T *p) {return current <= p;}
	bool operator>(T *p) {return current > p;}
	bool operator>=(T *p) {return current >= p;}
};

template<class T>
SkipPtr<T> SkipPtr<T>::operator+(long i) const
{
	SkipPtr<T> thePtr(pbegin,pend,skip);
	thePtr.current = current+i*skip;
	return thePtr;
}

template<class T>
SkipPtr<T> SkipPtr<T>::operator-(long i) const
{
	SkipPtr<T> thePtr(pbegin,pend,skip);
	thePtr.current = current-i*skip;
	return thePtr;
}

//
// Utility functions
//
template <class T>
ostream& operator<<(ostream &s,const vectlr<T> &vlr)
{
	long i;
	for (i = vlr.left(); i <= vlr.right(); i++)
		s << vlr[i] << ' ';
	return s;
}

template <class T>
ostream& operator<<(ostream &s,mtrxlr<T> &m) {
	long j;
	for (j = m.rowmin(); j <= m.rowmax(); j++)
		s << m.row(j) << '\n';
	return s;
}

// Two versions of data copying:
//   copydata works on the region of coordinate overlap between the vects/mtrxs,
//     and copies the data from source to dest
//   movedata starts from the beginning of the source and copies to the beginning of dest,
//     ignoring the coordinates
template <class T>
void copydata(const vectlr<T> &source,vectlr<T> &dest)
{
	const long imin = max(source.left(),dest.left());
	const long imax = min(source.right(),dest.right());
	if (imax-imin+1 > 0)
		memcpy(&dest[imin],&source[imin],(imax-imin+1)*sizeof(T));
}

template <class T>
void copydata(const mtrxlr<T> &source,mtrxlr<T> &dest)
{
	const long jmin = max(source.rowmin(),dest.rowmin());
	const long jmax = min(source.rowmax(),dest.rowmax());
	const long imin = max(source.left(),dest.left());
	const long imax = min(source.right(),dest.right());
	long j;
	if (imax-imin+1 > 0)
		for (j = jmin; j <= jmax; j++)
			memcpy(&dest[j][imin],&source[j][imin],(imax-imin+1)*sizeof(T));
}

template <class T>
void movedata(const vectlr<T> &source,vectlr<T> &dest)
{
	const long w = min(source,width(),dest.width());
	if (w > 0)
		memcpy(dest.begin(),source.begin(),w*sizeof(T));
}

template <class T>
void movedata(const mtrxlr<T> &source,mtrxlr<T> &dest)
{
	const long w = min(source.width(),dest.width());
	const long h = min(source.height(),dest.height());
	long j;
	if (w > 0)
		for (j = 0; j < h; j++)
			memcpy(&dest[j+dest.rowmin()][dest.left()],&source[j+source.rowmin()][source.left()],w*sizeof(T));
}


template <class T>
inline T square(T x)
{
	return x*x;
}

template <class T>
inline T cube(T x)
{
	return x*x*x;
}

template <class T>
inline T quart(T x)
{
	return x*x*x*x;
}

template <class T>
inline T* min_element(const vectlr<T> &v)
{
	T *ret,*iter;
	for (iter = ret = v.begin(); iter != v.end(); iter++)
		if (*iter < *ret)
			ret = iter;
	return ret;
}

template <class T>
inline T min(const vectlr<T> &v)
{
	return *min_element(v);
}

template <class T>
inline T* max_element(const vectlr<T> &v)
{
	T *ret,*iter;
	for (iter = ret = v.begin(); iter != v.end(); iter++)
		if (*iter > *ret)
			ret = iter;
	return ret;
}

template <class T>
inline T max(const vectlr<T> &v)
{
	return *max_element(v);
}

// The following function is very inefficient!
template <class InputIterator>
long size(InputIterator begn,InputIterator ennd)
{
	long ret = 0;
	while (begn != ennd) {
		ret++;
		begn++;
	}
	return ret;
}

#endif //NUMERTYPES

