function ldata = loaddata

	[datafiles,datapath] = uigetfile('*','Pick raw data file');
	if (datafiles == 0)	% User hit cancel
		fclose(fid);
		return;
	end
	ldata=[];
	for tstart=0:1800
		tend=tstart+2;
		[onedata,hdr] = loadmc([datapath,datafiles],[tstart,tend]);
		ldata=[ldata onedata];
	end
