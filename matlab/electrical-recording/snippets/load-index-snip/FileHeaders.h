// Headers & components for binary files
// See "TextFiles" for utilities & formats
// for textfiles.
#include <vector>
#include "iotypes.h"
#include "numertypes.h"

#ifndef FILEHEADERS
#define FILEHEADERS 1

using namespace std;

class FileTypes {
public:
	enum names {Raw = 1,				//.bin
				Eig,					//.eig (project Covar)
				Features,				//.ftr
				Envelopes,				//.env
				PFA,					//.flt
				Proj,					//.prj
				Snippet};					
};		

//
//  Following are several component parts; none is a file
//  header in itself
//

//  A string that prepends its length
//  when writing/reading with FilePtr
class LenString : public string {
public:
	void read(FilePtr&);
	void write(FilePtr&) const;
	friend ostream& operator<<(ostream&,const LenString&);
	friend FilePtr& operator<<(FilePtr&,const LenString&);	//write
	friend FilePtr& operator>>(FilePtr&,LenString&);		//read

	uint32 size() const;			// Includes the length header (use length() to get string length)
};


//  A class for maintaining variables that will
//  have to be adjusted after their initial writing
//  to disk
template<class T>
class Updateable {
private:
	long FilePos;
	T value;
public:
	T operator=(const T &t) {value = t; return t;}
	operator T() const {return value;}
	
	void read(FilePtr&);
	void write(FilePtr&);
	void write(ostream&) const;
	void update(FilePtr&) const;
};


// Standard info at the beginning of a header
class SizeTypeVersion {
public:
	Updateable<long> dataOffset;
	int16 filetype,version;

	void read(FilePtr&);
	void write(FilePtr&);
	friend FilePtr& operator>>(FilePtr&,SizeTypeVersion&);
	friend FilePtr& operator<<(FilePtr&,SizeTypeVersion&);
	friend ostream& operator<<(ostream&,const SizeTypeVersion&);
};


class ChInfo {
public:
	// These probably shouldn't be used very heavily
	// (here for LabView compatibility)
	LenString ChString;
	float32 uilim,lilim,range;
	uint16 polarity;
	float32 gain;
	uint16 coupling,inputmode;
	// These are the useful parameters
	int chNum;
	float32 scalemult,scaleoff;

	void read(FilePtr&);
	void write(FilePtr&) const;
	friend ostream& operator<<(ostream&,const ChInfo&);
	uint32 size() const;
};


class ScanInfo {
public:
	Updateable<uint32> nscans;
	int32 numCh;
	vector<int16> channel;
	float32 scanrate;

	void read(FilePtr&);
	void write(FilePtr&);
	friend FilePtr& operator<<(FilePtr&,ScanInfo&);
	friend FilePtr& operator>>(FilePtr&,ScanInfo&);	
	friend ostream& operator<<(ostream&,const ScanInfo&);
};


//
//  Following are complete file headers
//
//
//  Analog input header
//  Assumes all channels have the same gain.
//  You would only use different gains if your
//  sampling rate is quite low.
//
class AIHeader : protected SizeTypeVersion, public ScanInfo {
protected:
	LenString ChannelsString;
	vector<ChInfo> chanInfo;
	float32 chclock,acqtime;
public:
	float32 scalemult,scaleoff;
	LenString date,time,usrheader;
	
	AIHeader() {filetype = FileTypes::Raw; latestVersion();}
	void latestVersion() {version = 2;}

	void read(FilePtr&);
	void write(FilePtr&);
	void writeasAIB(FilePtr&, int32 windowsize);
	friend ostream& operator<<(ostream&,const AIHeader&);
};
extern FilePtr& operator<<(FilePtr&,AIHeader&);
extern FilePtr& operator>>(FilePtr&,AIHeader&);	

class AIBHeader : protected SizeTypeVersion, public ScanInfo {
protected:
	LenString ChannelsString;
	vector<ChInfo> chanInfo;
	float32 chclock,acqtime;
public:
	int32 windowsize;
	float32 scalemult,scaleoff;
	LenString date,time,usrheader;
	
	AIBHeader() {filetype = FileTypes::Raw; latestVersion();}
	void latestVersion() {version = 3;}

	void read(FilePtr&);
	void write(FilePtr&);
	friend ostream& operator<<(ostream&,const AIBHeader&);
};
extern FilePtr& operator<<(FilePtr&,AIBHeader&);
extern FilePtr& operator>>(FilePtr&,AIBHeader&);	


class EigHeader : protected SizeTypeVersion {
protected:
public:
	float32 threshp,threshn;
	int16 polarity;
	int16 neig;
	int16 left,right;
	float32 dt,scalemult;
	float32 totvar;
	
	EigHeader() {filetype = FileTypes::Eig; version = 1;}
	friend FilePtr& operator<<(FilePtr&,EigHeader&);
};


class FeatureHeader : protected SizeTypeVersion, public ScanInfo {
public:
	float32 thresh,lthresh;
	int16 polarity;
	int32 left,right;
	
	FeatureHeader() {filetype = FileTypes::Features; version = 2;}
	friend FilePtr& operator<<(FilePtr&,FeatureHeader&);
	friend FilePtr& operator>>(FilePtr&,FeatureHeader&);
	friend ostream& operator<<(ostream&,const FeatureHeader&);
}; 


class EnvDataHeader : public AIHeader {
private:
	int16 versionEnv;
public:
	int32 decfactor;
	
	EnvDataHeader() : AIHeader() {filetype = FileTypes::Envelopes; latestVersion();}
	EnvDataHeader(AIHeader &aih) : AIHeader(aih) {filetype = FileTypes::Envelopes; latestVersion();}
	void latestVersion() {versionEnv = 1;}
	
	friend FilePtr& operator<<(FilePtr &fp,EnvDataHeader &edh) {
		fp << AIHeader(edh) << edh.versionEnv << edh.decfactor;
		edh.dataOffset = fp.tell();
		edh.dataOffset.update(fp);
		return fp;
	}
};

class PFAHeader : protected SizeTypeVersion {
public:
	int16 left,right,nfilters;
	float thresh;

	PFAHeader() {filetype = FileTypes::PFA; latestVersion();}
	void latestVersion() {version = 1;}
	
	friend FilePtr& operator<<(FilePtr &fp,PFAHeader &pfah);
	friend FilePtr& operator>>(FilePtr &fp,PFAHeader &pfah);
};

class ProjHeader : protected SizeTypeVersion, public ScanInfo {
public:
	int16 nproj,nnbrs;
	vector<int32> NSpikes;		// The number of spikes/recorded channel

	ProjHeader() {filetype = FileTypes::Proj; latestVersion();}
	void latestVersion() {version = 1;}
	
	friend FilePtr& operator<<(FilePtr &fp,ProjHeader &prjh);
	friend FilePtr& operator>>(FilePtr &fp,ProjHeader &prjh);
};

class SnippetHeader : public AIHeader {
public:
	int16 Num_random_snips; //0 for spikes
	int16 Snip_begin_offset; // Typical value is -10 
	int16 Snip_end_offset;   // Typical value is 30
	vector <float32> Thresholds;
	vector <int32> Num_of_snippets;
	vector <Updateable<uint32> > Times_fpos;
	vector <Updateable<uint32> > Snips_fpos;

	friend FilePtr& operator<<(FilePtr &fp,SnippetHeader &sniph);

};

#endif //FILEHEADERS