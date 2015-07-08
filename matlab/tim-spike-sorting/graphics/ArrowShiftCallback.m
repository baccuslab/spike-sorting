function ArrowShiftCallback
% Callback for mzoom to handle key presses
c = get(gcf,'CurrentCharacter');
xl = get(gca,'xlim');
width = xl(2)-xl(1);
if (double(c) == 29)	% right arrow
	% Shift everything right
	xl = xl + [width width];
elseif (double(c) == 28) % left arrow
	% Shift everything left
	xl = xl - [width width];
elseif (c == '>')
	% Nudge everything right
	xl = xl + [width width]/20;
elseif (c == '<')
	% Nudge everything left
	xl = xl - [width width]/20;
end
list = mzoom(gcf,'getconnect'); % Circular list of connected axes.
set(gca,'xlim',xl)
h = list(1);
while h ~= gca,
  set(h,'xlim',xl)
  % Get next axes in the list
  next = get(get(h,'ZLabel'),'UserData');
  if all(size(next)==[2 4]), h = next(2,1); else h = gca; end
end
return
