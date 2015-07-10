#include "FileHeaders.cp"


//
// SizeTypeVersion
//
void SizeTypeVersion::read(FilePtr &fp)
{
	fp >> dataOffset >> filetype >> version;
}

void SizeTypeVersion::write(FilePtr &fp)
{
	fp << dataOffset << filetype << version;
}

FilePtr& operator>>(FilePtr &fp,SizeTypeVersion &stv)
{
	stv.read(fp);
	return fp;
}

FilePtr& operator<<(FilePtr &fp,SizeTypeVersion &stv)
{
	stv.write(fp);
	return fp;
}

ostream& operator<<(ostream &s,const SizeTypeVersion &stv)
{
	s << stv.dataOffset << ' ' << stv.filetype << ' ' << stv.version << '\n';
	return s;
}


//
//	LenString
//
void LenString::read(FilePtr &p)
{
	uint32 ssize;
	fread(&ssize,sizeof(uint32),1,p);
	resize(ssize);
	fread(begin(),sizeof(char),ssize,p);
	if (ferror(p)) {
		THMessage("error (LenString::read): file reading error");
		throw FileErr();
	}
}

void LenString::write(FilePtr &p) const
{
	uint32 ssize = length();
	fwrite(&ssize,sizeof(uint32),1,p);
	fwrite(begin(),sizeof(char),ssize,p);
	if (ferror(p)) {
		THMessage("error (LenString::write): file writing error");
		throw FileErr();
	}
}

uint32 LenString::size() const
{
	return sizeof(uint32) + length();
}

ostream& operator<<(ostream &s,const LenString &ls)
{
	s << string(ls);
	return s;
}

FilePtr& operator<<(FilePtr &fp,const LenString &ls)
{
	ls.write(fp);
	return fp;
}

FilePtr& operator>>(FilePtr &fp,LenString &ls)
{
	ls.read(fp);
	return fp;
}


//
//	ChInfo
//
void ChInfo::read(FilePtr &p)
{
	ChString.read(p);
	fread(&uilim,sizeof(float32),1,p);
	fread(&lilim,sizeof(float32),1,p);
	fread(&range,sizeof(float32),1,p);
	fread(&polarity,sizeof(uint16),1,p);
	fread(&gain,sizeof(float32),1,p);
	fread(&coupling,sizeof(uint16),1,p);
	fread(&inputmode,sizeof(uint16),1,p);
	fread(&scalemult,sizeof(float32),1,p);
	fread(&scaleoff,sizeof(float32),1,p);
	if (ferror(p)) {
		THMessage("error (ChInfo::read): file reading error");
		throw FileErr();
	}		
	if (isdigit(ChString[0]))
		chNum = atoi(ChString.c_str());
	else
		chNum = int(ChString[0]-'A')*8 + int(ChString[1]-'1');
}

void ChInfo::write(FilePtr &p) const
{
	ChString.write(p);
	fwrite(&uilim,sizeof(float32),1,p);
	fwrite(&lilim,sizeof(float32),1,p);
	fwrite(&range,sizeof(float32),1,p);
	fwrite(&polarity,sizeof(uint16),1,p);
	fwrite(&gain,sizeof(float32),1,p);
	fwrite(&coupling,sizeof(uint16),1,p);
	fwrite(&inputmode,sizeof(uint16),1,p);
	fwrite(&scalemult,sizeof(float32),1,p);
	fwrite(&scaleoff,sizeof(float32),1,p);
	if (ferror(p)) {
		THMessage("error (ChInfo::write): file writing error");
		throw FileErr();
	}
}

ostream& operator<<(ostream &s,const ChInfo &ci)
{
	s << ci.ChString << "\nuilim " <<ci.uilim << ", lilim " << ci.lilim << '\n';
	return s;	
}

uint32 ChInfo::size() const
{
	uint32 ret = 0;
	LenString ChString;
	ret += ChString.size();
	ret += 6*sizeof(float32);
	ret += 3*sizeof(uint16);
	return ret;
}


//
// ScanInfo
//
void ScanInfo::read(FilePtr &fp)
{
	fp >> nscans >> numCh;
	int i;
	int16 temp;
	for (i = 0; i < numCh; i++) {
		fp >> temp;
		channel.push_back(temp);
	}
	fp >> scanrate;
}

void ScanInfo::write(FilePtr &fp)
{
	fp << nscans << numCh;
	int i;
	for (i = 0; i < numCh; i++)
		fp << channel[i];
	fp << scanrate;
}

FilePtr& operator<<(FilePtr &fp,ScanInfo &si)
{
	si.write(fp);
	return fp;
}

FilePtr& operator>>(FilePtr &fp,ScanInfo &si)
{
	si.read(fp);
	return fp;
}

ostream& operator<<(ostream &s,const ScanInfo &si)
{
	s << "Nscans: " << si.nscans << ", Channels: ";
	int i;
	for (i = 0; i < si.numCh; i++)
		s << ' ' << si.channel[i];
	s << " (" << si.numCh << " channels)\nScanrate: " << si.scanrate << '\n';
	return s;
}


//
//	AIHeader
//
void AIHeader::read(FilePtr &p)
{
	SizeTypeVersion::read(p);
	if (version == 1) {
		int i;
		ChannelsString.read(p);
		uint32 chconfiglen;
		fread(&chconfiglen,sizeof(uint32),1,p);
		fread(&numCh,sizeof(int32),1,p);
		ChInfo chtemp;
		for (i = 0; i < numCh; i++) {
			chtemp.read(p);
			chanInfo.push_back(chtemp);
		}
		fread(&scanrate,sizeof(float32),1,p);
		fread(&chclock,sizeof(float32),1,p);
		date.read(p);
		time.read(p);
		usrheader.read(p);
		fread(&acqtime,sizeof(float32),1,p);
		p >> nscans;
		// Now set up ScanInfo data
		channel.erase(channel.begin(),channel.end());
		for (i = 0; i < numCh; i++)
			channel.push_back(chanInfo[i].chNum);
		// Set up rest of info
		scalemult = chanInfo[0].scalemult;
		scaleoff = chanInfo[0].scaleoff;
	}
	else {
		ScanInfo::read(p);
		p >> scalemult >> scaleoff;
		p >> date >> time >> usrheader;
	}
	if (ferror(p)) {
		THMessage("error (AIHeader::read): file reading error");
		throw FileErr();
	}
}

void AIHeader::write(FilePtr &p)
{
	SizeTypeVersion::write(p);
	if (version == 1) {
		ChannelsString.write(p);
		uint32 chconfiglen = 0;
		vector<ChInfo>::const_iterator i;
		for (i = chanInfo.begin(); i != chanInfo.end(); i++)
			chconfiglen += i->size();
		fwrite(&chconfiglen,sizeof(uint32),1,p);
		fwrite(&numCh,sizeof(int32),1,p);
		for (i = chanInfo.begin(); i != chanInfo.end(); i++)
			i->write(p);
		fwrite(&scanrate,sizeof(float32),1,p);
		fwrite(&chclock,sizeof(float32),1,p);
		date.write(p);
		time.write(p);
		usrheader.write(p);
		fwrite(&acqtime,sizeof(float32),1,p);
		p << nscans;
	}
	else {
		ScanInfo::write(p);
		p << scalemult << scaleoff;
		p << date << time << usrheader;
	}
	dataOffset = p.tell();
	dataOffset.update(p);
	if (ferror(p)) {
		THMessage("error (AIHeader::write): file writing error");
		throw FileErr();
	}
}
void AIHeader::writeasAIB(FilePtr &p, int32 windowsize)
{
	p << dataOffset << int16(2) << int16(1);//Type=2 Version = 1
	//SizeTypeVersion::write(p);
	ScanInfo::write(p);
	p << int32 (windowsize);
	p << scalemult << scaleoff;
	p << date << time << usrheader;
	dataOffset = p.tell();
	dataOffset.update(p);
	if (ferror(p)) {
		THMessage("error (AIHeader::writeasAIB): file writing error");
		throw FileErr();
	}
}

FilePtr& operator<<(FilePtr &fp,AIHeader &aih)
{
	aih.write(fp);
	return fp;
}

FilePtr& operator>>(FilePtr &fp,AIHeader &aih)
{
	aih.read(fp);
	return fp;
}

ostream& operator<<(ostream &s,const AIHeader &aih)
{
	s << aih.date << "  " << aih.time << '\n' << aih.usrheader << '\n'
		<< "Scan info:\n" << ScanInfo(aih);
	return s;
}

//
//	AIBHeader
//
void AIBHeader::read(FilePtr &p)
{
	SizeTypeVersion::read(p);
	if (filetype==2) {
		ScanInfo::read(p);
		p >> windowsize;
		p >> scalemult >> scaleoff;
		p >> date >> time >> usrheader;
	}
	if (ferror(p)) {
		THMessage("error (AIHeader::read): file reading error");
		throw FileErr();
	}
}

void AIBHeader::write(FilePtr &p)
{
	SizeTypeVersion::write(p);
	if (version == 1) {
		ChannelsString.write(p);
		uint32 chconfiglen = 0;
		vector<ChInfo>::const_iterator i;
		for (i = chanInfo.begin(); i != chanInfo.end(); i++)
			chconfiglen += i->size();
		fwrite(&chconfiglen,sizeof(uint32),1,p);
		fwrite(&numCh,sizeof(int32),1,p);
		for (i = chanInfo.begin(); i != chanInfo.end(); i++)
			i->write(p);
		fwrite(&scanrate,sizeof(float32),1,p);
		fwrite(&chclock,sizeof(float32),1,p);
		date.write(p);
		time.write(p);
		usrheader.write(p);
		fwrite(&acqtime,sizeof(float32),1,p);
		p << nscans;
	}
	else {
		ScanInfo::write(p);
		p << windowsize;
		p << scalemult << scaleoff;
		p << date << time << usrheader;
	}
	dataOffset = p.tell();
	dataOffset.update(p);
	if (ferror(p)) {
		THMessage("error (AIBHeader::write): file writing error");
		throw FileErr();
	}
}

FilePtr& operator<<(FilePtr &fp,AIBHeader &aibh)
{
	aibh.write(fp);
	return fp;
}

FilePtr& operator>>(FilePtr &fp,AIBHeader &aibh)
{
	aibh.read(fp);
	return fp;
}

ostream& operator<<(ostream &s,const AIBHeader &aibh)
{
	s << aibh.date << "  " << aibh.time << '\n' << aibh.usrheader << '\n'
		<< "Scan info:\n" << ScanInfo(aibh);
	return s;
}


//
// EigHeader
//
FilePtr& operator<<(FilePtr &fp,EigHeader &eh)
{
	eh.SizeTypeVersion::write(fp);;
	fp << eh.threshp << eh.threshn << eh.polarity;
	fp << eh.neig;
	fp << eh.left << eh.right;
	fp << eh.dt << eh.scalemult;
	fp << eh.totvar;
	return fp;
}


//
// FeatureHeader
//
FilePtr& operator<<(FilePtr &fp,FeatureHeader &fh)
{
	fh.SizeTypeVersion::write(fp);
	if (fh.version == 1) {
		fp << fh.thresh << fh.lthresh << fh.polarity;
		fp << fh.left << fh.right;
		fp << fh.nscans << fh.scanrate << fh.numCh;
	}
	else {
		fp << ScanInfo(fh);
		fp << fh.thresh << fh.lthresh << fh.polarity;
		fp << fh.left << fh.right;
	}
	fh.dataOffset = fp.tell();
	fh.dataOffset.update(fp);
	return fp;
}

FilePtr& operator>>(FilePtr &fp,FeatureHeader &fh)
{
	fh.SizeTypeVersion::read(fp);
	if (fh.version == 1) {
		fp >> fh.thresh >> fh.lthresh >> fh.polarity;
		fp >> fh.left >> fh.right;
		fp >> fh.nscans >> fh.scanrate >> fh.numCh;
	}
	else {
		fp >> ScanInfo(fh);
		fp >> fh.thresh >> fh.lthresh >> fh.polarity;
		fp >> fh.left >> fh.right;
	}		
	return fp;
}

ostream& operator<<(ostream &s,const FeatureHeader &fh)
{
	s << "version " << fh.version << '\n';
	s << "thresh " << fh.thresh << "  lthresh " << fh.lthresh << "  polarity " << fh.polarity << '\n';
	s << "left " << fh.left << "  right " << fh.right << '\n';
	s << "nscans " << fh.nscans << "  scanrate " << fh.scanrate << "  numCh " << fh.numCh << endl;
	return s;
}


//
// PFAHeader
//
FilePtr& operator<<(FilePtr &fp,PFAHeader &pfah)
{
	pfah.SizeTypeVersion::write(fp);
	fp << pfah.left << pfah.right << pfah.nfilters;
	fp << pfah.thresh;
	pfah.dataOffset = fp.tell();
	pfah.dataOffset.update(fp);
	if (ferror(fp)) {
		THMessage("error (PFAHeader::operator<<): file writing error");
		throw FileErr();
	}
	return fp;
}

FilePtr& operator>>(FilePtr &fp,PFAHeader &pfah)
{
	pfah.SizeTypeVersion::read(fp);
	fp >> pfah.left >> pfah.right >> pfah.nfilters;
	fp >> pfah.thresh;
	if (ferror(fp)) {
		THMessage("error (PFAHeader::operator>>): file reading error");
		throw FileErr();
	}
	return fp;
}


//
// ProjHeader
//
FilePtr& operator<<(FilePtr &fp,ProjHeader &prjh)
{
	prjh.SizeTypeVersion::write(fp);
	prjh.ScanInfo::write(fp);
	fp << prjh.nproj << prjh.nnbrs;
	if (prjh.numCh != prjh.NSpikes.size()) {
		THMessage("error (ProjHeader::operator<<): number of channels don't match");
		throw FileErr();
	}
	int i;
	for (i = 0; i < prjh.numCh; i++) {
		//cout << "On " << i << " there are " << prjh.NSpikes[i] << endl;
		fp << prjh.NSpikes[i];
	}
	if (ferror(fp)) {
		THMessage("error (ProjHeader::operator<<): file writing error");
		throw FileErr();
	}
	return fp;		
}

FilePtr& operator>>(FilePtr &fp,ProjHeader &prjh)
{
	prjh.SizeTypeVersion::read(fp);
	prjh.ScanInfo::read(fp);
	fp >> prjh.nproj >> prjh.nnbrs;
	int i;
	int32 temp;
	for (i = 0; i < prjh.numCh; i++) {
		fp >> temp;
		prjh.NSpikes.push_back(temp);
	}
	if (ferror(fp)) {
		THMessage("error (ProjHeader::operator>>): file reading error");
		throw FileErr();
	}
	return fp;		
}


//
// SnippetHeader
//
FilePtr& operator<<(FilePtr &fp,SnippetHeader &sniph)
{
	sniph.AIHeader::write(fp);
	fp << sniph.Num_random_snips << sniph.Snip_begin_offset << sniph.Snip_end_offset;
	if (sniph.numCh != sniph.Thresholds.size()) {
		THMessage("error (SnippetHeader::operator<<): number of channels don't match");
		throw FileErr();
	}
	int i;
 	for (i = 0; i < sniph.numCh; i++) 
		fp << sniph.Thresholds[i];
	for (i = 0; i < sniph.numCh; i++) 
		fp << sniph.Num_of_snippets[i];

	Updateable <uint32> zero;
 	zero = 0;
	for (i = 0; i < sniph.numCh; i++) {	  //Clear file offset variables.
		sniph.Times_fpos.push_back(zero); //then write them.  Because they	
		sniph.Times_fpos[i].write(fp);	  //are of class "Updateable", the
	}									  //position in the write file is
	for (i = 0; i < sniph.numCh; i++) {   //saved for later updating 
		sniph.Snips_fpos.push_back(zero); //(see Updateable defs. in
		sniph.Snips_fpos[i].write(fp);    //Fileheaders.h & .cp).
	}
	

	if (ferror(fp)) {
		THMessage("error (SnippetHeader::operator<<): file writing error");
		throw FileErr();
	}
	return fp;		
}

// Useful code fragment:
/*
	char tc[40];
	fread(tc,sizeof(char),40,p);
	//cerr << tc << endl;
	cout << hex;
	for (i = 0; i < 40; i++)
		cout << uchar(tc[i]) << ' ';
	cout << dec << endl;
	for (i = 0; i < 40; i++)
		cout << tc[i] << ' ';
	cout << endl;
*/
