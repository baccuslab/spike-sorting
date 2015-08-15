function ExportFigure(fig)
% ExportFigure(fig)
% Puts figures in a consistent form for
% export & publication, then saves as a color EPS
% Adjust line widths, marker sizes, font sizes, and axis boxes

if (nargin == 0)
	fig = gcf;
end
% Ask the user for appropriate values
prompt = {'Line width','MarkerSize','Title font size','Label font size','Tag font size','Tick font size'};
defans = {'2','6','14','12','12','12'};
answer = inputdlg(prompt,'Set figure properties',1,defans);
if (length(answer) == 0)
	return;
end
% Set the values for the selected figure
% But don't modify most legend properties
hlegend = findobj(fig,'Tag','legend');
hax = findobj(fig,'Type','axes');
haxnotl = setdiff(hax,hlegend);
hlines = findobj(fig,'Type','line');
htag = findobj(fig,'Type','text');
htag = setdiff(htag,findobj(hlegend,'Type','text'));	% Don't modify legend text
htitle = get(hax,'Title');
if (length(htitle)>1)
	htitle = cat(2,htitle{:});	% Turn cell array into vector
end
hlabels = get(hax,{'Xlabel','Ylabel','Zlabel'});
if (length(hlabels)>1)
	hlabels = cat(2,hlabels{:});
end
set(hlines,'LineWidth',str2num(answer{1}));
set(hlines,'MarkerSize',str2num(answer{2}));
set(htitle,'FontSize',str2num(answer{3}));
set(hlabels,'FontSize',str2num(answer{4}));
set(htag,'FontSize',str2num(answer{5}));
set(hax,'FontSize',str2num(answer{6}));
% Give user the chance to set box states
boxstate = {'no change','on','off'};
[selection,ok] = listdlg('ListString',boxstate,'SelectionMode','single',...
	'PromptString','Boxes on axes?','ListSize',[100 45]);
if ok
	if (selection == 2)
		set(haxnotl,'Box','on');
	elseif (selection == 3)
		set(haxnotl,'Box','off');
	end
else
	return
end
% Save the figure as color EPS
[filename,path] = uiputfile('filename.eps','Save figure as:');
if (filename ~= 0)
	command = sprintf('print -depsc -adobecset ''%s'' -f%g',[path,filename],fig);
	eval(command);
	disp(command)
end
