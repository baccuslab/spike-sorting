function indxout = BuildIndexMF(range,indxin)
%  BuildIndexMF: Given a range, make the corresponding index
% See BuildRangeMF for more detail
% indxout = BuildIndexMF(range,indxin)
% If indxin is absent, the range is interpreted literally, otherwise the 
%   subrange of indxin is returned
for i = 1:size(range,2)
	indxout{i} = range(1,i):range(2,i);
	if (nargin == 2)
		indxout{i} = indxin{i}(indxout{i});
	end
end
