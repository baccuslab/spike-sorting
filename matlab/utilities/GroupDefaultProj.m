function [tout,indexout] = GroupDefaultProj(g,sortchannels,chindices,blocksize,useclnums,snipindx,multiindx,multitimes,hsort)
% tout{clustnum,filenum} = Times of spikes of cell # clustnum, in the file spikefiles{filenum}
% indexout: same as tout except it's the index # of the snippet rather than the time
% nfiles=size(g.spikefiles,2);
nfiles = size(g.snipfiles, 2);
for i = 1:length(snipindx)
	nsnips(i) = length(snipindx{i});
end
cumsnip = [0 cumsum(nsnips)];
% Process these snippets in blocks
outrange = 0;
start = 0;
clustnums = [];
polygons = {};
tout = cell(0,nfiles);
indexout = cell(0,nfiles);
mode = 'scatter';
slidervalue = 0;
while (outrange == 0)
	[range,outrange] = BuildRangeMF(nsnips,[start+1,start+blocksize]);	% Figure out how to load the next block
	blkindx = BuildIndexMF(range,snipindx);
	% Load in the default projections
	maxblkindx(size(sortchannels,2),nfiles)=0;
	for chidx=1:size(sortchannels,2)
		for fnum=1:nfiles
			if (isempty (blkindx{fnum}))
				maxblkindx(chidx,fnum)=0;
			else
				maxblkindx(chidx,fnum)=max(multiindx{fnum}(chidx,blkindx{fnum}));
			end
		end
	end
	proj=loadproj('proj.bin',chindices(1),size(g.channels,2),nfiles,maxblkindx(1,:));
	%Select projections for first channel
	for fnum=1:nfiles
		if (~isempty(multitimes{fnum}))
			t{fnum}=multitimes{fnum}(blkindx{fnum});
			proj{1,fnum}=proj{1,fnum}(:,multiindx{fnum}(1,blkindx{fnum}));
		else
			t{fnum}=[];
			proj{1,fnum}=[];
		end
	end
	%Select projections for other channels
	for chidx=2:size(sortchannels,2)		
		for fnum=1:nfiles
			t{fnum}=multitimes{fnum}(blkindx{fnum});
			midx=find(multiindx{fnum}(chidx,blkindx{fnum})>0);
			pidx=multiindx{fnum}(chidx,blkindx{fnum}(midx));
			tproj=proj{chidx,fnum}(:,pidx);
			proj{chidx,fnum}=zeros(3,size(blkindx{fnum},2));
			proj{chidx,fnum}(:,midx)=tproj;
		end
	end
	%Sum projections
	sumproj=proj(1,:);
	for chidx=2:size(sortchannels,2);
		for fnum=1:nfiles
			sumproj{fnum}=sumproj{fnum}+proj{chidx,fnum};
		end
	end
	% Convert the times to seconds
	for fnum = 1:nfiles
		if (~isempty(t{fnum}))
			tsecs{fnum} = t{fnum}/g.scanrate;
		else
			tsecs{fnum}=[];
		end
	end
	%f
	fc=cell(1,fnum);
	for fnum = 1:nfiles
		if (length(blkindx{fnum}>0))
			fc{fnum}(1,:) = fnum*ones(1,length(blkindx{fnum}));
			fc{fnum}(2,:) = 1:length(blkindx{fnum});
		else
			fc{fnum} = [];
		end
	end
	sumproj=cat(2,sumproj{:});
	f = cat(2,fc{:});
	% Cluster their projections:
	% First, set up the GUI
	hfig = ClusterDefaultProj(sortchannels,snipindx,multiindx,sumproj,g,f,tsecs,clustnums,polygons,hsort);
	% Modify a couple of the properties of the figure window
	if (outrange == 0)
		set(findobj(gcf,'Tag','DoneButton'),'String','Next');
	end
	setappdata(hfig,'mode',mode);		% Use the same mode that finished with last time
	hslider = findobj(hfig,'Tag','Slider');
	slidermin = get(hslider,'Min');
	slidermax = get(hslider,'Max');
	if (slidervalue < slidermin)
		slidervalue = slidermin;
	elseif (slidervalue > slidermax)
		slidervalue = slidermax;
	end
	set(hslider,'Value',slidervalue);
	setappdata(hfig,'ClusterLabels',useclnums);	% Set the sequence of cluster #s to print on screen
	ClusterFunctions('Replot',hfig);	% Plot in correct mode
	% Now wait for user input to finish
	waitfor(hfig,'UserData','done');
	if (~ishandle(hfig))
		warning('Operation cancelled by user');
		tout = {};
		indexout = {};
		return
	end
	% Retrieve the information about the clusters
	clustnums = getappdata(hfig,'clustnums');
	polygons = getappdata(hfig,'polygons');
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	mode = getappdata(hfig,'mode');
	slidervalue = get(hslider,'Value');
	close(hfig)
	% Determine which points fall in each polygon
	membership = ComputeMembership(x,y,polygons);
	% Sort this information across clusters & files
	clusts = unique(clustnums);
	%fnums = unique(f(1,:));
	fnums = 1:nfiles;
	for i = 1:length(clusts)
		if (clusts(i) ~= 0)
			indx = find(membership == clusts(i));	% Indices are relative to "start"
			if (length(indx) > 0)
				for j = 1:length(fnums)
					findx = find(f(1,indx) == fnums(j));
					cfindx = indx(findx);
					if (clusts(i) <= size(tout,1) & fnums(j) <= size(tout,2))
						tout{clusts(i),fnums(j)} = [tout{clusts(i),fnums(j)},t{fnums(j)}(f(2,cfindx))];
						indexout{clusts(i),fnums(j)} = [indexout{clusts(i),fnums(j)},cfindx+start - cumsnip(fnums(j))];
					else
						tout{clusts(i),fnums(j)} = t{fnums(j)}(f(2,cfindx));
						indexout{clusts(i),fnums(j)} = cfindx+start - cumsnip(fnums(j));
					end
				end
			end
		end
	end
	start = start+blocksize;
end
function fig = ClusterDefaultProj(sortchannels,snipindx,multiindx,proj,g,f,t,clustnums,polygons,hsort)
% Compute their projections on the filters
hfig = Cluster(proj(2,:),proj(1,:));
h1 = uicontrol('Parent',hfig, ...
'Units','points', ...
'Position',[412 337 76 30], ...
'String','AutoCorr',...
'Callback','ClustSWCallback AutoCorr',...
'Tag','AutoCorrButton');
h1 = uicontrol('Parent',hfig, ...
'Units','points', ...
'Position',[412 298 76 30], ...
'String','Waveforms',...
'Callback','ClustSWCallback Waveforms',...
'Tag','WaveformsButton');
hclustmodebox = uicontrol('Parent',hfig, ...
'Units','points', ...
'Position',[425 20 111 25], ...
'String','Draw polygon', ...
'Style','checkbox', ...
'Callback','ClustSWCallback Clustmodebox',...
'Tag','clustmode', ...
'Value',getappdata(hsort,'clustmode'));
setappdata (hfig,'hsort',hsort);
setappdata(hfig,'t',t);
setappdata(hfig,'f',f);
% setappdata(hfig,'spikefiles',g.spikefiles);
setappdata(hfig, 'snipfiles', g.snipfiles);
setappdata(hfig,'ctfiles',g.ctfiles);
setappdata(hfig,'channels',sortchannels);
setappdata(hfig,'snipindx',snipindx);
setappdata(hfig,'multiindx',multiindx);
if (nargin > 4)
	% Co-opt the "Clear" function and turn it into a "Revert" function
	h = findobj(hfig,'Tag','ClearButton');
	set(h,'String','Revert','Callback','ClustSPCallback Revert');
	setappdata(hfig,'clustnums0',clustnums);
	setappdata(hfig,'polygons0',polygons);
	ClustSPCallback('Revert',hfig);
end
if nargout > 0, fig = hfig; end

