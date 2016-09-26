function startsort
	if strcmp(getappdata(gcf,'SortEnable'),'on')
		g=getappdata (gcf,'g');
		handles=getappdata (gcf,'handles');
		pwflag=getappdata(gcf,'pwflag');
		status=get(gcf,'Userdata');
		%ch = find(g.channels==str2num(get(findobj(handles.main,'Tag','sortchan'),'String')));
		set(findobj(handles.main,'Tag','Quit'),'Enable','Off');
		ch=get(gcbo,'UserData');
		ctchannels=setdiff(g.ctchannels,g.channels(ch));
		if (~isempty(ch))
			set(gcf,'Userdata','sorting')
			setappdata(gcf,'SortEnable','off');
			DoMultiChannel(handles.main,g,[g.channels(ch) ctchannels]);
		end
	end
