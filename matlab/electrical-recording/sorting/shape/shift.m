function Ys = shift(Y,dx)
% Ys = shift(Y,dx)
% Shift the column vectors in Y by an amount dx
% Uses cubic interpolation, and sets the undefined endpoint
% to zero
[sz,nvec] = size(Y);
if (length(dx) ~= nvec)
	error('Number of input vectors does not match number of offsets');
end
Ys = zeros(size(Y));
for i = 1:nvec
	Ys(:,i) = interp1(Y(:,i),(1:sz)-dx(i),'*cubic')';
	if (dx(i) < 0)
		Ys(sz,i) = 0;
	elseif (dx(i) > 0)
		Ys(1,i) = 0;
	end
end
