function m = CellToMatrix(array)
% CellToMatrix: convert a cell array of vectors to a matrix
% m = CellToMatrix(array)
ncols = length(array);
maxlen = 0;
for i = 1:ncols
	maxlen = max(maxlen,length(array{i}));
end
m = zeros(maxlen,ncols);
for i = 1:ncols
	m(1:length(array{i}),i) = array{i}';
	if (length(array{i}) < maxlen)
		m(length(array{i})+1:maxlen,i) = array{i}(end);
	end
end
