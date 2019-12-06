// #define char16_t UINT16_T
#include "mex.h"
#include <math.h>
#include <vector>
//#include <sstream>

using namespace std;
vector<int> pointsinpolygon (double *x, double *y,long sizex,double *polx,double *poly,long sizepol);

vector<int> pointsinpolygon (double *x, double *y,long sizex,double *polx,double *poly,long sizepol)
{
	long p;
	int i;
	int ni;
	vector<int> idx(sizex);
	float u,v,a,b,yi;
	
	for (p=0;p<sizex;p++)
	{	
		u=x[p];v=y[p];
		ni = 0;
		for (i=0;i<(sizepol-1);i+=1) 
		{
			if (polx[i+1] != polx[i]) 
			{
				if (((polx[i+1]-u) * (u-polx[i])) >= 0) 
				{
					if  (((polx[i+1] ) != u) || (polx[i] >= u))
					{
						if ((polx[i] != u) || (polx[i+1] >= u ))
						{
							b = (poly[i+1]-poly[i]) / (polx[i+1]-polx[i]);
							a = poly[i]-b * polx[i];
							yi = a+b*u;
							if (yi > v)
							{
								ni = 1-ni;
							}
						}
					}
				}
			}
		}
		idx[p]=ni;
	}
	return idx;
}

// The gateway routine
void mexFunction(int nlhs, mxArray *plhs[],
				 int nrhs, const mxArray *prhs[])
{
	// Argument parsing
	if (nrhs != 4)
		mexErrMsgTxt("Pointsinpolygon requires 4 inputs");
	int bad1 =  (!mxIsNumeric(prhs[0]) || !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])
			|| (mxGetN(prhs[0]) != 1 && mxGetM(prhs[0]) != 1));
	if (bad1 && !mxIsEmpty(prhs[0]))
		mexErrMsgTxt("The first input to pointsinpolygon must be a real double vector");
	double *x = mxGetPr(prhs[0]);
	long npointsx = mxGetN(prhs[0])*mxGetM(prhs[0]);
	bad1 =  (!mxIsNumeric(prhs[1]) || !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])
			|| (mxGetN(prhs[1]) != 1 && mxGetM(prhs[1]) != 1));
	if (bad1 && !mxIsEmpty(prhs[1]))
		mexErrMsgTxt("The second input to pointsinpolygon must be a real double vector");
	double *y = mxGetPr(prhs[1]);
	long npointsy = mxGetN(prhs[1])*mxGetM(prhs[1]);
	if (npointsx != npointsy)
		mexErrMsgTxt("The first two vectors must be the same length");
	bad1 =  (!mxIsNumeric(prhs[2]) || !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2])
			|| (mxGetN(prhs[2]) != 1 && mxGetM(prhs[2]) != 1));
	if (bad1 && !mxIsEmpty(prhs[2]))
		mexErrMsgTxt("The third input to pointsinpolygon must be a real double vector");
	double *polyx = mxGetPr(prhs[2]);
	long npolyx = mxGetN(prhs[2])*mxGetM(prhs[2]);
	bad1 =  (!mxIsNumeric(prhs[3]) || !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3])
			|| (mxGetN(prhs[3]) != 1 && mxGetM(prhs[3]) != 1));
	if (bad1 && !mxIsEmpty(prhs[3]))
		mexErrMsgTxt("The fourth input to pointsinpolygon must be a real double vector");
	double *polyy = mxGetPr(prhs[3]);
	long npolyy = mxGetN(prhs[3])*mxGetM(prhs[3]);
	if (npolyx != npolyy)
		mexErrMsgTxt("The third and fourth vectors must be the same length");

	if (nlhs != 1)
		mexErrMsgTxt("One output is required");
	
	vector<int> idx = pointsinpolygon(x,y,npointsx,polyx,polyy,npolyx);
	plhs[0] = mxCreateDoubleMatrix(1,npointsx,mxREAL);
	double *outp = mxGetPr(plhs[0]);
	for (long i = 0; i < npointsx; i++)
		outp[i] = idx[i];
	return;
}
