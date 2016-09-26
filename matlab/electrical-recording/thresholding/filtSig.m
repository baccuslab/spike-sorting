function dfilt = filtSig(d,f,offset)
% dfilt = filtSig(d,f,offset)
% Filters the waveform d with the filter f, and
% returns the waveform dfilt of the same length as
% d and shifted by offset
% Filter should be supplied in time-reversed order!
% (i.e. this is a correlation, not a convolution)
fr = f(length(f):-1:1);		% Reverse the time axis
dfilt = filter(fr,1,d);
if (offset == 0) return; end;
pad = zeros(1,abs(offset));
if (offset > 0)
	dfilt = [pad dfilt(1:size(dfilt,2)-offset)];
else
	dfilt = [dfilt(-offset+1:size(dfilt,2)) pad];
end
if (size(dfilt,2) ~= size(d,2))
	error('sizes do not match!');
end
