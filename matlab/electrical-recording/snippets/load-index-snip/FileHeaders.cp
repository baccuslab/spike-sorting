#include "FileHeaders.h"

template<class T>
void Updateable<T>::read(FilePtr &fp)
{
	FilePos = fp.tell();
	fp >> value;
}

template<class T>
void Updateable<T>::write(FilePtr &fp)
{
	FilePos = fp.tell();
	fp << value;
}
	
template<class T>
void Updateable<T>::write(ostream &s) const
{
	s << value;
}


template<class T>
FilePtr& operator>>(FilePtr &fp,Updateable<T> &u)
{
	u.read(fp);
	return fp;
}

template<class T>
FilePtr& operator<<(FilePtr &fp,Updateable<T> &u)
{
	u.write(fp);
	return fp;
}

template<class T>
void Updateable<T>::update(FilePtr &fp) const
{
	long thePosition = fp.tell();	// Remember current position
	fp.goTo(FilePos);
	fp << value;
	fp.goTo(thePosition);			// Restore file position
}

template<class T>
ostream& operator<<(ostream &s,const Updateable<T> &u)
{
	u.write(s);
	return s;
}
