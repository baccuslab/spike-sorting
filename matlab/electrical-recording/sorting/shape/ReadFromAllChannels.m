function [snipm,sniprange] = ReadFromAllChannels(filename,num,channels)
h = ReadSnipHeader(filename);
totsnips = sum(h.numofsnips);
fracsnips = min(1,num/totsnips);
if (nargin == 3)
	chans = intersect(channels,h.channels);
else
	chans = h.channels;
end
for i = 1:length(chans)
	snips{i} = LoadSnip(filename,chans(i),ceil(fracsnips*h.numofsnips(i)));
end
%for i = 1:length(chans)
%	if (~isempty(snips{i}))
%		figure
%		plot(snips{i});
%		title(sprintf('Channel %d',chans(i)));
%	end
%end
snipm = cat(2,snips{:});
sniprange = h.sniprange;
return
