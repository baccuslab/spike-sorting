// Compute the crosscorrelation function for a set of spikes, represented
// by vectors of their arrival times
#include <vector>
#include "mex.h"
#include <math.h>
//#include "FileHeaders.cp"
//#include "Utils.h"
//#include "iotypes.h"
//#include <sstream>

using namespace std;
void CrossCorrEnum(double *t1,double *t2,long n1,long n2,double tmax,vector<double> &tcc,vector<long> *tccindx);
vector<long> CrossCorrBin(double *t1,double *t2,long n1,long n2,double tmax,int nbins);

void CrossCorrEnum(double *t1,double *t2,long n1,long n2,double tmax,vector<double> &tcc,vector<long> *tccindx)
{
	long i,j;
	j = 0;
	double dt;
	for (i = 0; i < n1; i++) {
		if (j >= n2) j = n2-1;
		// Back up if necessary
		while (j > 0 && t2[j]+tmax > t1[i]) j--;
		// Advance if necessary
		while (j < n2 && t2[j]+tmax < t1[i]) j++;
		// Grab the appropriate range
		while (j < n2 && fabs(dt = t2[j]-t1[i]) < tmax) {
			tcc.push_back(dt);
			tccindx[0].push_back(i+1);
			tccindx[1].push_back(j+1);
			j++;
		}
	}
}

vector<long> CrossCorrBin(double *t1,double *t2,long n1,long n2,double tmax,int nbins)
{
	double binnumfac = (double) nbins/(2*tmax);
	vector<long> nInBins(nbins+1,0);		// One extra for dt = tmax (roundoff errors)
	
	long i,j;
	j = 0;
	double dt;
	for (i = 0; i < n1; i++) {
		if (j >= n2) j = n2-1;
		// Back up if necessary
		while (j > 0 && t2[j]+tmax > t1[i]) j--;
		// Advance if necessary
		while (j < n2 && t2[j]+tmax < t1[i]) j++;
		// Grab the appropriate range
		while (j < n2 && fabs(dt = t2[j]-t1[i]) < tmax) {
			nInBins[binnumfac*(dt+tmax)]++;
			j++;
		}
	}
	nInBins.erase(--nInBins.end());		// Get rid of the extra one
	return nInBins;
}

// The gateway routine
void mexFunction(int nlhs, mxArray *plhs[],
				 int nrhs, const mxArray *prhs[])
{
	//mexPrintf("Version 1\n");
	// Argument parsing
	if (nrhs < 3 || nrhs > 4)
		mexErrMsgTxt("CrossCorr requires 3 or 4 inputs");
	int bad1 =  (!mxIsNumeric(prhs[0]) || !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])
			|| (mxGetN(prhs[0]) != 1 && mxGetM(prhs[0]) != 1));
	//if (bad1)
	//	mexWarnMsgTxt("bad1 = 1");
	if (bad1 && !mxIsEmpty(prhs[0]))
	//if (bad1)
		mexErrMsgTxt("The first input to CrossCorr must be a real double vector");
	double *t1 = mxGetPr(prhs[0]);
	long n1 = mxGetN(prhs[0])*mxGetM(prhs[0]);
	bad1 =  (!mxIsNumeric(prhs[1]) || !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])
			|| (mxGetN(prhs[1]) != 1 && mxGetM(prhs[1]) != 1));
	//if (bad1)
	//	mexWarnMsgTxt("bad1 = 1");
	if (bad1 && !mxIsEmpty(prhs[1]))
	//if (bad1)
		mexErrMsgTxt("The second input to CrossCorr must be a real double vector");
	double *t2 = mxGetPr(prhs[1]);
	long n2 = mxGetN(prhs[1])*mxGetM(prhs[1]);
	if (!mxIsNumeric(prhs[2]) || !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2])
			|| mxGetN(prhs[2]) * mxGetM(prhs[2]) != 1)
		mexErrMsgTxt("The third input to CrossCorr must be a real double scalar");
	double tmax = mxGetScalar(prhs[2]);
	int binning = 0;
	int nbins;
	if (nrhs == 4) {
		if (!mxIsNumeric(prhs[3]) || !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3])
				|| mxGetN(prhs[3]) * mxGetM(prhs[3]) != 1)
			mexErrMsgTxt("The fourth input (if present) to CrossCorr must be a real double scalar");
		else {
			binning = 1;
			nbins = mxGetScalar(prhs[3]);
		}
	}
/*
	// Echo the inputs
	stringstream outtext;
	outtext << "First vector: ";
	for (int i = 0; i < n1; i++)
		outtext << ' ' << t1[i];
	outtext << "\nSecond vector: ";
	for (int i = 0; i < n2; i++)
		outtext << ' ' << t2[i];
	outtext << "\ntmax = " << tmax << ", binning = " << binning << '\n';
	mexPrintf(outtext.str().c_str());
*/
	if (binning && nlhs != 1)
		mexErrMsgTxt("When binning, one output is required");
	else if(nlhs < 1 || nlhs > 2)
		mexErrMsgTxt("When not binning, one or two outputs are required");
	if (binning) {
		vector<long> nInBin = CrossCorrBin(t1,t2,n1,n2,tmax,nbins);
		plhs[0] = mxCreateDoubleMatrix(1,nbins,mxREAL);
		double *outp = mxGetPr(plhs[0]);
		for (long i = 0; i < nbins; i++)
			outp[i] = nInBin[i];
		return;
	}
	else {
		vector<double> tcc;
		vector<long> tccindx[2];
		CrossCorrEnum(t1,t2,n1,n2,tmax,tcc,tccindx);
		plhs[0] = mxCreateDoubleMatrix(1,tcc.size(),mxREAL);
		double *outp = mxGetPr(plhs[0]);
		for (long i = 0; i < tcc.size(); i++)
			outp[i] = tcc[i];
		if (nlhs == 2) {
			plhs[1] = mxCreateDoubleMatrix(2,tcc.size(),mxREAL);
			outp = mxGetPr(plhs[1]);
			for (long i = 0; i < tcc.size(); i++) {
				outp[2*i] = tccindx[0][i];
				outp[2*i+1] = tccindx[1][i];
			}	
		}
	}
}
