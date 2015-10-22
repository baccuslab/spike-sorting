function startsort
	if strcmp(getuprop(gcf,'SortEnable'),'on')
		g=getuprop (gcf,'g');
		handles=getuprop (gcf,'handles');
		pwflag=getuprop(gcf,'pwflag');
		status=get(gcf,'Userdata');
		%ch = find(g.channels==str2num(get(findobj(handles.main,'Tag','sortchan'),'String')));
		set(findobj(handles.main,'Tag','Quit'),'Enable','Off');
		ch=get(gcbo,'UserData');
		ctchannels=setdiff(g.ctchannels,g.channels(ch));
		if (~isempty(ch))
			set(gcf,'Userdata','sorting')
			setuprop(gcf,'SortEnable','off');
			DoMultiChannel(handles.main,g,[g.channels(ch) ctchannels]);
		end
	end
