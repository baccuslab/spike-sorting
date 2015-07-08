function [pout,Cout] = ChangeVar(pnew,pold,pin,Cin)
% ChangeVar: change variables for a parameters and covariance matrix
% Of great use in fitting
% [pout,Cout] = ChangeVar(pnew,pold,pin,Cin)
% pin is a nparm-by-n matrix, and Cin is a nparm-by-nparm-by-n
% 	tensor.
% pold and pnew are symbolic expressions for the new and old
% 	variables, respectively
ncells = size(pin,2);
if (ncells ~= size(Cin,3))
	error('Number of cells in pin and Cin do not agree');
end
J = jacobian(pnew,pold);
for i = 1:ncells
	%size(pold)
	%size(pnew)
	%size(pin(:,i))
	%subs(pnew,pold,pin(:,i)')
	pout(:,i) = subs(pnew,pold,pin(:,i))';
	Ji = eval(subs(J,pold,pin(:,i)));
	Cout(:,:,i) = Ji*Cin(:,:,i)*Ji';
end
