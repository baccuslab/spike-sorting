function [tout,indexout] = GroupChannel(spikefiles,channel,filters,subrange,blocksize,useclnums,snipindx)
% tout{clustnum,filenum} = Times of spikes of cell # clustnum, in the file spikefiles{filenum}
% indexout: same as tout except it's the index # of the snippet rather than the time
subset = 0;
if (nargin == 7), subset = 1; end
if (nargin == 5), useclnums = []; end
% First figure out how many snippets we have in each file
if (subset)
	for i = 1:length(snipindx)
		nsnips(i) = length(snipindx{i});
	end
else
	[chans,mnsnips] = GetSnipNums(spikefiles);
	chindx = find(chans == channel);
	nsnips = mnsnips(chindx,:);
end
cumsnip = [0 cumsum(nsnips)];
% Process these snippets in blocks
outrange = 0;
start = 0;
clustnums = [];
polygons = {};
tout = cell(0,length(spikefiles));
indexout = cell(0,length(spikefiles));
mode = 'scatter';
slidervalue = 0;
while (outrange == 0)
	[range,outrange] = BuildRangeMF(nsnips,[start+1,start+blocksize]);	% Figure out how to load the next block
	if (subset)
		blkindx = BuildIndexMF(range,snipindx);
	else
		blkindx = BuildIndexMF(range);
	end
	% Load in the snippets
	[snips,f,t,header] = LoadIndexSnippetsMF(spikefiles,channel,blkindx);
	% Convert the times to seconds
	for i = 1:length(header)
		if (~isempty(t{i}))
			tsecs{i} = t{i}/header{i}.scanrate;
		end
	end
	%t = cat(1,t{:});
	% Cluster their projections:
	% First, set up the GUI
	hfig = ClusterSpikeWfms(snips(subrange(1):subrange(2),:),f,tsecs,filters,clustnums,polygons);
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
	fnums = 1:length(spikefiles);
	for i = 1:length(clusts)
		if (clusts(i) ~= 0)
			indx = find(membership == clusts(i));	% Indices are relative to "start"
			if (length(indx) > 0)
				for j = 1:length(fnums)
					findx = find(f(1,indx) == fnums(j));
					cfindx = indx(findx);
					if (clusts(i) <= size(tout,1) & fnums(j) <= size(tout,2))
						%size(tout{i,j})
						%size(t(indx(findx)))
						tout{clusts(i),fnums(j)} = [tout{clusts(i),fnums(j)},t{fnums(j)}(f(2,cfindx))'];
						indexout{clusts(i),fnums(j)} = [indexout{clusts(i),fnums(j)},cfindx+start - cumsnip(fnums(j))];
					else
						tout{clusts(i),fnums(j)} = t{fnums(j)}(f(2,cfindx))';
						indexout{clusts(i),fnums(j)} = cfindx+start - cumsnip(fnums(j));
					end
				end
			end
		end
	end
	start = start+blocksize;
end
