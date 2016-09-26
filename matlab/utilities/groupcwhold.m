function groupcw(outfile,spikefiles,noisefiles,channels)
% groupcw: shape sorting of snippet waveforms
% Three calling modes:
%	groupcw(outfilename,spikefiles,noisefiles,fchannels,channels)
%		outfilename: name of output .mat file
%		spikefiles: cell array of spike snippet filenames
%		noisefiles: cell array of noise snippet filenames
%		channels (optional): set of channels to analyze. Default all.
%		EXAMPLE: groupcw ('01/01/00.mat',{'1.ssnp','2.ssnp','3.ssnp'},{'1.rsnp'})
%	groupcw(outfilename) 
%		Use this mode when you've sorted previously, and want
%		to continue where you left off. outfilename must already exist.
%	groupcw (outfilename,'proj.mat')
%		For sorting peak-width data. 'proj.mat' is a list of peaks and times

%Determine sorting mode, continuous waveform, or peak-width 
if( (nargin==2) & (length(spikefiles)==1 )& (strmatch(spikefiles{1},'proj.mat'))) %sorting peak width data
	pwflag=1;
else
	if (nargin == 3)
		[channels,nsnips,sniprange] = GetSnipNums(spikefiles); 	% Do all the channels
	end
	pwflag=0;
end

if (~pwflag) %Continuous waveform data
	% Find out if output file already exists.
	% If it does, load it in and start appending	
 	if (isempty(dir(outfile)))		% If file doesn't already exist		
		hmain=setup(outfile,spikefiles,noisefiles,channels,pwflag);		
		g=getappdata(hmain,'g');
		save (outfile,'g');
	else	% Output file already exists, new results will be appended
		fprintf(sprintf('Continuing to sort file %s...\n',outfile));
		load (outfile)
		nfiles=size(g.spikefiles,2);
		nchans=size(g.channels,2);
		g.ctchannels=[];
		if (~exist('removedCT'))
			removedCT=cell(nchans,nfiles);
		end
		%Setup array window
		handles = makearraywindow (g.channels);
		Arrayplot (g.channels,handles.ch,g.xc,g.yc,g.nspikes) ;
		setappdata (handles.main,'g',g);		
	end %end continuous waveform case
else %peak-width
	nfiles=1;
	nchans=size(channels,2);
	load proj.mat
	if (~isempty(fnstruct)) %If file has already been started
		fprintf(sprintf('Continuing where we left off with file %s...\n',outfile));
		load(outfile)
		%Remove spikes already in clusters and the removed crosstalk
		sptimes=removetimes (sptimes,chanclust,removedCT,1:nchans );
	end
end

return

