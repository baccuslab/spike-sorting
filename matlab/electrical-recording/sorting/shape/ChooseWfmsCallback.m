function ChooseWfmsCallback(action)
hfig = gcbf;
unselwidth = 0.5;
selwidth = 2;
switch(action)
case 'SelectRegion'
	% Unless shift-clicking, unselect any currently selected waveforms
	selection_type = get(hfig,'SelectionType');
	if (~strcmp(selection_type,'extend'))
		hsellines = findobj(hfig,'Tag','wfm','Selected','on');
		set(hsellines,'Selected','off','LineWidth',unselwidth);
	end
	% Give the user the rubber band box and return coords
	theRect = GetSelRect;
	% Now find the lines that cross into the box
	xlim = get(gca,'XLim');
	leftrange = max(ceil(theRect(1)-xlim(1)+1),1);
	rightrange = min(floor(theRect(1)+theRect(3)-xlim(1)+1),xlim(2)-xlim(1)+1);
	hlines = findobj(hfig,'Tag','wfm','Visible','on');	% Get all visible lines (ones above thresh)
	yd = GetYData(hlines);
	[bi,bj] = find(yd(leftrange:rightrange,:) > theRect(2) &yd(leftrange:rightrange,:) < theRect(2)+theRect(4));
	% Select these lines
	set(hlines(bj),'Selected','on','LineWidth',selwidth);
case 'SelectLine'
	% Unless shift-clicking, unselect any currently selected waveforms
	selection_type = get(hfig,'SelectionType');
	if (~strcmp(selection_type,'extend'))
		hsellines = findobj(hfig,'Tag','wfm','Selected','on');
		set(hsellines,'Selected','off','LineWidth',unselwidth);
	end
	% Select the current line
	set(gcbo,'Selected','on','LineWidth',selwidth);
case 'Delete'
	c = get(hfig,'CurrentCharacter');
	if (double(c) == 8)
		hsellines = findobj(hfig,'Tag','wfm','Selected','on','Visible','on');
		delete(hsellines);
		UpdateNumLeft
	end
case 'ThreshStart'
	set(gcbf,'WindowButtonMotionFcn','ChooseWfmsCallback ThreshMove');
	set(gcbf,'WindowButtonUpFcn','ChooseWfmsCallback ThreshStop');
case 'ThreshMove'
	currPt = get(gca,'CurrentPoint');
	currPtx = currPt(1,1);
	% Make sure it stays in bounds
	xlim = get(gca,'XLim');
	if (xlim(1) > currPtx)
		currPtx = xlim(1);
	elseif (xlim(2) < currPtx)
		currPtx = xlim(2);
	end
	set(gco,'XData',[currPtx currPtx]);
case 'ThreshStop'
	set(gcbf,'WindowButtonMotionFcn','');
	set(gcbf,'WindowButtonUpFcn','');
	currPt = get(gca,'CurrentPoint');
	thresh = currPt(1,1);	% Determine new thresh
    
    % Get the axes object in which the threshold was saved in
    % ChooseWaveforms.m. The data was historically stored in the axes
    % storing the waveforms themselves, but retrieved from the parent
    % figure. It appears that the new setappdata/getappdata API is more
    % exacting, in that data is not visible to a parent, but only the
    % actual object in which it was stored.
    children = get(hfig, 'Children');
    %axs = children(4);
    axs = findobj(children, 'Tag', 'WaveformsAxes');
	oldthresh = getappdata(axs,'oldthresh');		% Look up old threshold
    
% 	rmappdata(hfig,'oldthresh');				% It's not clear why this is nec., but it seems to be
	setappdata(axs,'oldthresh',thresh);			% Record for next time
	x0 = getappdata(axs,'PeakPos');
	% If the threshold increases, lines below thresh need to be turned off
	if (thresh > oldthresh)
		hlines = findobj(hfig,'Tag','wfm','Visible','on');
		yd = GetYData(hlines);
		offindx = find(yd(x0,:) < thresh);
		set(hlines(offindx),'Visible','off');
	else		% if decreases, lines above new thresh need to be turned on
		hlines = findobj(hfig,'Tag','wfm','Visible','off');
		yd = GetYData(hlines);
		onindx = find(yd(x0,:) >= thresh);
		set(hlines(onindx),'Visible','on');
	end
	UpdateNumLeft
case 'WidthStart'
	set(gcbf,'WindowButtonMotionFcn','ChooseWfmsCallback WidthMove');
	set(gcbf,'WindowButtonUpFcn','ChooseWfmsCallback WidthStop');
case 'WidthMove'
	currPt = get(gca,'CurrentPoint');
	currPtx = currPt(1,1);
	% Make sure it stays in bounds
	xlim = get(gca,'XLim');
	if (xlim(1) > currPtx)
		currPtx = xlim(1);
	elseif (xlim(2) < currPtx)
		currPtx = xlim(2);
	end
	set(gco,'XData',[currPtx currPtx]);
case 'WidthStop'
	set(gcbf,'WindowButtonMotionFcn','');
	set(gcbf,'WindowButtonUpFcn','');
case 'Cancel'
	close(hfig)
case 'Done'
	% Extract the indices of the remaining visible lines
	hlines = findobj(hfig,'Tag','wfm','Visible','on');
	indx = get(hlines,'UserData');
	indx = cat(1,indx{:});
	setappdata(hfig,'GoodSpikes',indx);
	% Find out the width coordinates
	hwidth = findobj(hfig,'Tag','WidthLine');
	xd = get(hwidth,'XData');
	xloc = [xd{1}(1),xd{2}(1)];
	xloc = round(sort(xloc));
	setappdata(hfig,'NewRange',xloc);
	set(hfig,'UserData','done');	% Let other programs know we're done (through waitfor)
otherwise
	error(['Do not know about action ',action]);
end
return

function yd = GetYData(hlines)
if (nargin == 0)
	hlines = findobj(gcf,'Tag','wfm');	% Note: will also get data for invisible lines
end
yd = get(hlines,'YData'); yd = cat(1,yd{:})';
return

function UpdateNumLeft
hshow = findobj(gcf,'Tag','wfm','Visible','on');
htext = findobj(gcf,'Tag','NumWaveforms');
set(htext,'String',sprintf('%d waveforms',length(hshow)));
return
