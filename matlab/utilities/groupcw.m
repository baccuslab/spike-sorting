function groupcw(outfile, datafiles, snipfiles, channels, noise_channels)
% groupcw: Shape sorting of snippet waveforms
%
% The function groupcw is the entry point for the shape-based spike waveform
% clustering application, used to sort spikes. 
%
% INPUT:
%	outfile		- Output file, in which the Matlab struct containing information
%					about the sorting process, as well as sorted spikes, will
%					be saved.
%
%	datafiles	- A single string or cell array of strings, giving the paths
%					to the HDF5 files containing raw multi-electrode array data.
%
% 	snipfiles	- A single string or cell array of strings, giving the paths
%					to the HDF5 files containing the extracted candidate spike
%					and noise snippets. These are the outputs of the `extract` program.
%	
%	channels	- An array of the channel numbers from which data should be sorted.
%                   If not given, or given as [], data will be sorted from
%                   all channels in the files.
%   
%   noise_channels - An array of channel numbers from which noise should be
%                   drawn. Defaults to same as `channels`
%
% CALLING:
%
% The program may be called in two ways. If just the `outfile` is specified, the
% application will continue sorting a previous session. The output file given must
% exist.
%
% Alternatively, the first three arguments can be given, in order to start a new
% sorting session with the given data and snippet files. The final argument, 
% `channels`, is optional in this case. If not given, all data channels from which
% snippets were extracted will be included in the sorting.
%
% HISTORY:
%
% The original version of the application was written by Tim Holy and Stephen 
% Baccus, between 1999 and 2004. The application was updated in 2015, to operate
% with a new HDF5 file format adopted in the Baccus lab. Contributors for the 
% update include: Pablo Jadzinsky, Lane McIntosh, Benjamin Naecker, Aran Nayebi,
% and Bongsoo Suh.
%
% (C) 1999-2016 The Baccus Lab

if nargin > 1
    if nargin == 3
        channels = [];
        noise_channels = [];
    elseif nargin == 4
        noise_channels = [];
    end
    
    if isempty(channels)
        channels = double(h5read(snipfiles{1}, '/extracted-channels'));
        channels = channels(:)';
    end
    if isempty(noise_channels)
        noise_channels = channels;
    end
end

pwflag = false; % Never sort this way anymore, will be removed in future

if (~pwflag) %Continuous waveform data
	% Find out if output file already exists.
	% If it does, load it in and start appending	
 	if (isempty(dir(outfile)))		% If file doesn't already exist		
		hmain=setup(outfile,datafiles,snipfiles,channels,noise_channels,pwflag);		
		g=getappdata(hmain,'g');
		save (outfile,'g');
	else	% Output file already exists, new results will be appended
		fprintf(sprintf('Continuing to sort file %s...\n',outfile));
		load (outfile)
% 		nfiles=size(g.spikefiles,2);
        nfiles = size(g.snipfiles, 2);
		nchans=size(g.channels,2);
		g.ctchannels=[];
		if (~exist('removedCT'))
			removedCT=cell(nchans,nfiles);
		end
		%Setup array window
		handles = makearraywindow (g.channels, g.array);
		Arrayplot (g.channels,handles.ch,g.xc,g.yc,g.nspikes) ;
		setappdata (handles.main,'g',g);		
	end %end continuous waveform case
else %peak-width - currently not implemented
	nfiles=1;
	nchans=size(channels,2);
	sptimes=[];
	global proj,sptimes;
	load proj.mat
	if (isempty(dir(outfile))) %If file has already been started
		hmain=setup(outfile,{},spikefiles,{},channels,pwflag);		
		g=getappdata(hmain,'g');
		save (outfile,'g');	
	else
		fprintf(sprintf('Continuing to sort file %s...\n',outfile));
		load(outfile)
		%Remove spikes already in clusters and the removed crosstalk
		sptimes=removetimes (sptimes,chanclust,removedCT,1:nchans );
		%Setup array window
		handles = makearraywindow (g.channels);
		Arrayplot (g.channels,handles.ch,g.xc,g.yc,g.nspikes) ;
		setappdata (handles.main,'g',g);	
	end
end

return

