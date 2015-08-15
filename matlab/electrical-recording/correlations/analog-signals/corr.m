function c = corr(v1,v2)
% CORR(v1,v2) returns the correlation coefficient of vectors v1 and v2
if (size(v1,1)==1 & size(v2,1)==1)
	c = ((v1-mean(v1))*(v2-mean(v2))')/size(v1,2);
elseif (size(v1,2)==1 & size(v2,2)==1)
	c = ((v1-mean(v1))'*(v2-mean(v2)))/size(v1,1);
else
	error('Works only with vectors, both column or both row')
end
