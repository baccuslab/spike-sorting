#include <iostream.h>
//#include <iostream>

#ifndef IOTYPES
#define IOTYPES 1

extern void THMessage(char *msg);

// File exception classes
class FileErr { };
class FileCantOpen: FileErr { };

// Comment stripping from ASCII files
class CommentStripper {
private:
	char cmt_char;
public:
	CommentStripper(char c) {cmt_char = c;}
	
	friend istream& operator>>(istream& s,const CommentStripper &cs) {
		char c;
	    s >> ws;
	    while (s.get(c) && c == cs.cmt_char) {
	    	while (s.get(c) && c != '\n') {};	// Strip to end of line
	    	s >> ws;
	    }
	    s.putback(c);
	    return s;
	}
};
using namespace std;
class CommentMaker {
private:
	char cmt_char;
	string linestart;
public:
	CommentMaker(char c) {cmt_char = c; linestart += cmt_char; linestart += ' ';}
	
	string operator()(const string &s) {
		string ret;
		ret += linestart;
		long i;
		for (i = 0; i < s.length(); i++) {
			ret += s[i];
			if (s[i] == '\r' || s[i] == '\n')
				ret += linestart;
		}
		return ret;
	}
};

// File stuff for binary files
class FilePtr {
private:
	FILE *p;
	
	FilePtr(const FilePtr&) {};			// Prevent copying (pass only by reference)
public:	
	FilePtr(const char *name,const char *a) {
		p = fopen(name,a);
		if (p == NULL) {
			THMessage("Can't open file");
			throw FileCantOpen();
		}
	}
	FilePtr(string &name,const char *a) {
		p = fopen(name.c_str(),a);
		if (p == NULL) {
			THMessage("Can't open file");
			throw FileCantOpen();
		}
	}
	FilePtr(FILE *pp) {p = pp;}
	FilePtr() {p = NULL;}
	~FilePtr() {if (p != NULL) fclose(p);}

	void open(const char *name,const char *a) {
		if (p != NULL)
			throw FileErr();
		 p = fopen(name,a);
		 if (p == NULL) {
		 	THMessage("Can't open file");
		 	throw FileCantOpen();
		 }
	}

	void goTo(long i) {fseek(p,i,SEEK_SET);}
	void skip(long i) {fseek(p,i,SEEK_CUR);}
	long tell() const {return ftell(p);}
	operator FILE*() const {return p;}
};

inline FilePtr& operator<<(FilePtr& fp,const char& t)
{
	fwrite(&t,sizeof(char),1,fp);
	return fp;
}
inline FilePtr& operator<<(FilePtr& fp,const unsigned char& t)
{
	fwrite(&t,sizeof(unsigned char),1,fp);
	return fp;
}
inline FilePtr& operator<<(FilePtr& fp,const int& t)
{
	fwrite(&t,sizeof(int),1,fp);
	return fp;
}
inline FilePtr& operator<<(FilePtr& fp,const short& t)
{
	fwrite(&t,sizeof(short),1,fp);
	return fp;
}
inline FilePtr& operator<<(FilePtr& fp,const unsigned short& t)
{
	fwrite(&t,sizeof(unsigned short),1,fp);
	return fp;
}
inline FilePtr& operator<<(FilePtr& fp,const long& t)
{
	fwrite(&t,sizeof(long),1,fp);
	return fp;
}
inline FilePtr& operator<<(FilePtr& fp,const unsigned long& t)
{
	fwrite(&t,sizeof(unsigned long),1,fp);
	return fp;
}
inline FilePtr& operator<<(FilePtr& fp,const float& t)
{
	fwrite(&t,sizeof(float),1,fp);
	return fp;
}
/*inline FilePtr& operator<<(FilePtr& fp,const short double& t)
{
	fwrite(&t,sizeof(double),1,fp);
	return fp;
}*/
inline FilePtr& operator<<(FilePtr& fp,const double& t)
{
	fwrite(&t,sizeof(double),1,fp);
	return fp;
}


#include "SwapEndian.h"


inline FilePtr& operator>>(FilePtr &fp,char &t)
{
	fread(&t,sizeof(char),1,fp);
	return fp;
}
inline FilePtr& operator>>(FilePtr &fp,unsigned char &t)
{
	fread(&t,sizeof(unsigned char),1,fp);
	return fp;
}
inline FilePtr& operator>>(FilePtr &fp,int &t)
{
	fread(&t,sizeof(int),1,fp);	
//	SWAP_LONG(t); // needed for PC, not for Mac
	return fp;
}
inline FilePtr& operator>>(FilePtr &fp,short &t)
{
	fread(&t,sizeof(short),1,fp);
//	SWAP_SHORT(t); // needed for PC, not for Mac
	return fp;
}
inline FilePtr& operator>>(FilePtr &fp,unsigned short &t)
{
	fread(&t,sizeof(unsigned short),1,fp);
//	SWAP_USHORT(t); // needed for PC, not for Mac
	return fp;
}
inline FilePtr& operator>>(FilePtr &fp,long &t)
{
	fread(&t,sizeof(long),1,fp);
//	SWAP_LONG(t); // needed for PC, not for Mac
	return fp;
}
inline FilePtr& operator>>(FilePtr &fp,unsigned long &t)
{
	fread(&t,sizeof(unsigned long),1,fp);
//	SWAP_ULONG(t); // needed for PC, not for Mac
	return fp;
}
inline FilePtr& operator>>(FilePtr &fp,float &t)
{
	fread(&t,sizeof(float),1,fp);
//	SWAP_FLOAT(t); // needed for PC, not for Mac
	return fp;
}
/*inline FilePtr& operator>>(FilePtr &fp,short double &t)
{
	fread(&t,sizeof(short double),1,fp);
	return fp;
}*/
inline FilePtr& operator>>(FilePtr &fp,double &t)
{
	fread(&t,sizeof(double),1,fp);
//	SWAP_DOUBLE(t);   // needed for PC, not for Mac
	return fp;
}


#endif //IOTYPES
