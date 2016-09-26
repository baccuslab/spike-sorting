%STEVE TEMP PROC
case 'Sep'
	t = getappdata(h,'t');
	scanrate = getappdata(h,'scanrate');
	clflindx = getappdata(h,'clflindx');
	[selindx,wvindx] = GetSelClust(h);
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
	spikefiles = getappdata(h,'spikefiles');
	channel = getappdata(h,'channel');
	dispnsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	actime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	%   Get the spike times, in units of seconds
		tsecs = cell(1,nfiles);
		for j = 1:nfiles
			if (~isempty(t{j}(clflindx{2,j})))
				tsecs{j} = t{j}(clflindx{2,j})/scanrate(j);
			end
		end
		newindx=cell(nclust+1,nfiles);
	for i=1:nclust-1
			for j=1:nfiles
				newindx{i,j}=clflindx{i,j};
			end
		end
	for i = 1:nfiles
		nclosesp=1;
		%First spike in each file is a special case
		if  (tsecs{i}(2)-tsecs{i}(1)<=0.0035) 
			newindx{nclust+1,i}(1)=wvindx{i}(1);
			nclosesp=2;
		else
			newindx{nclust,i}(1)=wvindx{i}(1);
			nfarsp=2;
		end
		for j = 2:(size(tsecs{i},1)-1)
			if  (tsecs{i}(j)-tsecs{i}(j-1)<=0.0035) 
				newindx{nclust+1,i}(nclosesp)=wvindx{i}(j);
				nclosesp=nclosesp+1;
			else
				if  (tsecs{i}(j+1)-tsecs{i}(j)<=0.0035) 
					newindx{nclust+1,i}(nclosesp)=wvindx{i}(j);
					nclosesp=nclosesp+1;
				else
					newindx{nclust,i}(nfarsp)=wvindx{i}(j);
					nfarsp=nfarsp+1;
				end		
			end
		end
		%Last spike in each file is a special case
		if  (tsecs{i}(j+1)-tsecs{i}(j)<=0.0035) 
			newindx{nclust+1,i}(nclosesp)=wvindx{i}(j+1);
			nclosesp=nclosesp+1;
		else
			newindx{nclust,i}(nfarsp)=wvindx{i}(j+1);
			nfarsp=nfarsp+1;
		end		
		
	end
		% Determine the cluster #s of the newly-created clusters
		% Make replclust at least as long as # of new clusters
		% (it's OK if it's longer)
		replclust=[2 3];
		% Replace the old assignments with the new, and append
		% any new clusters
		newclflindx = newindx;	% Not strictly necessary, but useful for debugging
	
		if (length(replclust)-1 > size(newindx,1))
			% Trash any clusters that got eliminated
			elim = replclust(size(newindx,1)+1:end-1); % eliminate if selected more than returned
			newclflindx(elim,:) = [];
		end
		nsnips = getappdata(h,'nsnips');
		newclflindx(1,:) = RebuildUnassigned(newclflindx,nsnips,h);
		% Store the new assignments
		setappdata(h,'clflindx',newclflindx);
		DoChanFunctions('Unselect',h);
		DoChanFunctions('UpdateDisplay',h);
	
