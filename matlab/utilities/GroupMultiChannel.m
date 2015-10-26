function [tout,indexout] = GroupMultiChannel(g,channels,filters,subrange,blocksize,useclnums,snipindx,spindx,sptimes,hsort)
% tout{clustnum,filenum} = Times of spikes of cell # clustnum, in the file spikefiles{filenum}
% indexout: same as tout except it's the index # of the snippet rather than the time
% spikefiles=g.spikefiles;
snipfiles = g.snipfiles;
ctfiles=g.ctfiles;
for i = 1:length(snipindx)
	nsnips(i) = length(snipindx{i});
end
cumsnip = [0 cumsum(nsnips)];
% Process these snippets in blocks
outrange = 0;
start = 0;
clustnums = [];
polygons = {};
tout = cell(0,length(snipfiles));
indexout = cell(0,length(snipfiles));
mode = 'scatter';
slidervalue = 0;
loadblock=blocksize;
while (outrange == 0)
	snips=0;
	f=0;
	t=cell(1,length(snipfiles));
	tsecs=cell(1,length(snipfiles));
	lstart=start;
	while (and(outrange== 0,(lstart-start)<blocksize))
		[range,outrange] = BuildRangeMF(nsnips,[lstart+1,lstart+loadblock]);	% Figure out how to load the next block
		if (max(range(2,:))>0)
			blkindx = BuildIndexMF(range,snipindx);
			% Load in the snippets
			[snips,f1,~]= MultiLoadIndexSnippetsMF(snipfiles,'spike', ...
                ctfiles,channels,blkindx,spindx,hsort);
			for fnum=1:length(snipfiles)
				t1{fnum}=sptimes{fnum}(blkindx{fnum});
			end
			% Convert the times to seconds
			for i = 1:length(snipfiles)
				if (~isempty(t1{i}))
					t{i} = [t{i} t1{i}];
% 					tsecs{i} = [tsecs{i} t{i}/header{i}.scanrate];
                    tsecs{i} = [tsecs{i} t{i} / ...
                        double(h5readatt(snipfiles{i}, '/', 'sample-rate'))];
				end
			end
			proj1 = filters'*snips(subrange(1):subrange(2),:);
			if (lstart==start)
				proj=proj1;
				f=f1;
			else
				proj=cat(2,proj,proj1);
				f=cat(2,f,f1);
			end
			lstart=lstart+loadblock;
		end
	end
	clear snips
	%t = cat(1,t{:});
	% Cluster their projections:
	% First, set up the GUI
	hfig = ClusterSpikeWfms(snipfiles,ctfiles,channels,snipindx,spindx,f,tsecs,proj,clustnums,polygons,hsort);
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
	fnums = 1:length(snipfiles);
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
