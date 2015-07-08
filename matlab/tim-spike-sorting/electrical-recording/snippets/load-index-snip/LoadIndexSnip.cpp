#include <vector>
#include "mex.h"
#include "iotypes.h"
#include "FileHeaders.cp"
#include "Utils.h"

using namespace std;

extern void ReadTimeSnip(FilePtr &fpin,int chindx,const SnippetHeader &sh,long nsnipsout,const double *indxD,double *toutD,double *snipoutD);
extern void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]);

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
	double *snipoutD, *toutD, *indxD;
	char *filename;
	int channel,chindx,m,n,sniplen,nsnipsout;
	
	if (nlhs < 1)
		return;
	else if (nlhs > 2)
		mexErrMsgTxt("Can have at most 2 output arguments");
	if (nrhs != 3)
		mexErrMsgTxt("Requires precisely 3 input arguments");
	
	if (!mxIsChar(prhs[0]))
		mexErrMsgTxt("First input must be the filename");
	filename = mxArrayToString(prhs[0]);
	m = mxGetM(prhs[1]); n = mxGetN(prhs[1]);
	if (!mxIsDouble(prhs[1]) || m*n != 1)
		mexErrMsgTxt("Second input must be the channel number");
	channel = mxGetScalar(prhs[1]);
	m = mxGetM(prhs[2]); n = mxGetN(prhs[2]);
	if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || (m != 1 && n != 1))
		mexErrMsgTxt("Third input must be the vector of snippet indices");
	indxD = mxGetPr(prhs[2]);
	nsnipsout = m*n;
	//mexPrintf("File %s, channel %d, # of snips %d\n",filename,channel,nsnipsout);
	//return;
	
	FilePtr fpin(filename,"rb");
	if (!fpin)
		mexErrMsgTxt("Could not open file");
	SnippetHeader sh;
	fpin >> sh;
	
	//mexPrintf("Got past read SnippetHeader!\n");
	//return;
	// Figure out the channel index
	vector<int> chIndexv;
	vector<short> channelv;
	channelv.push_back(channel);
	try {
		MatchChannels(sh.channel,channelv,chIndexv);
	}
	catch(NoMatch) {
		mexErrMsgTxt("Error: the selected channel was not recorded");
	}
	chindx = chIndexv[0];
	//mexPrintf("chindx = %d\n",chindx);
	
	sniplen = sh.Snip_end_offset-sh.Snip_begin_offset+1;

	plhs[0] = mxCreateDoubleMatrix(sniplen,nsnipsout,mxREAL);
	snipoutD = mxGetPr(plhs[0]);
	if (nlhs > 1) {
		plhs[1] = mxCreateDoubleMatrix(nsnipsout,1,mxREAL);
		toutD = mxGetPr(plhs[1]);
	}
	else
		toutD = 0;		// Signal to skip reading the times
	
	//return;
	ReadTimeSnip(fpin,chindx,sh,nsnipsout,indxD,toutD,snipoutD);
}

void ReadTimeSnip(FilePtr &fpin,int chindx,const SnippetHeader &sh,long nsnipsout,const double *indxD,double *toutD,double *snipoutD)
{
	long i,sniplen,nsnipstot;

	// First, check to make sure that no requested
	// indices go out of range
	nsnipstot = sh.Num_of_snippets[chindx];
	long mini,maxi;
	mini = *min_element(indxD,indxD+nsnipsout);
	maxi = *max_element(indxD,indxD+nsnipsout);
	if (mini < 1)
		mexErrMsgTxt("Indices must be positive");
	if (maxi > nsnipstot)
		mexErrMsgTxt("One of the requested snippets does not exist");
	
	// Read the times, if applicable
	// Read these as a block and then keep only the
	//	ones requested.
	if (toutD) {
		uint32 *t = new uint32[maxi];
		if (!t)
			mexErrMsgTxt("Out of memory on t allocation");
		fpin.goTo(sh.Times_fpos[chindx]);
		fread(t,sizeof(uint32),maxi,fpin);
		indxD[i];
		for (i = 0; i < nsnipsout; i++)
			toutD[i] = t[(long) indxD[i]-1];
		delete[] t;
	}
	sniplen = sh.Snip_end_offset-sh.Snip_begin_offset+1;
	//mexPrintf("chindx %d, nsnipsout %d, sniplen %d\n",chindx,nsnipsout,sniplen);
	
	// Now read the snippets. Here, read only
	//	the requested snippets.
	uint32 pos0 = sh.Snips_fpos[chindx];
	int16 *sniptemp = new int16[sniplen];
	if (!sniptemp)
		mexErrMsgTxt("Out of memory on sniptemp allocation");
	int16 *sti,*psnipend;
	psnipend = sniptemp+sniplen;
	for (i = 0; i < nsnipsout; i++) {
		//mexPrintf("Location %x\n",pos0 + 2*sniplen*((long) indxD[i]-1));
		fpin.goTo(pos0 + 2*sniplen*((long) indxD[i]-1));
		fread(sniptemp,sizeof(int16),sniplen,fpin);
		for (sti = sniptemp; sti != psnipend ; sti++,snipoutD++) {
			*snipoutD = (*sti)*sh.scalemult+sh.scaleoff;	// Copy with cast
			//*snipoutD = (*sti);	// Copy with cast
			//mexPrintf("%d ",*sti);
		}
	}
	//mexPrintf("\n");
	delete[] sniptemp;
}