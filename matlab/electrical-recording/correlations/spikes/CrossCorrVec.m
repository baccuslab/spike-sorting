function [tcc,timet] = CrossCorrVec(t1,t2,tmax)
% This is outdated by CrossCorr (the MEX version of this file)
% [tcc,timet] = CrossCorrVec(t1,t2,tmax)
% Compute cross-correlations
% The output tcc is a vector containing all time differences less (in abs value)
% than tmax.
% timet contains the spike times (in t1) that contribute to the samples in tcc,
	tcc = [];
	timet = [];
	j = 1;	% iterator over cell 1
	k = 1; 	% iterator over cell 2
	if (length(t1) > 0 & length(t2) > 0)
		while (j <= length(t1))
			if (k > length(t2))
				k = length(t2);
			end
			while (k > 1 & t2(k)+tmax > t1(j))	% Back up if necessary
%				fprintf('j %d, k %d, t1(j) %g, t2(k) %g,-\n',j,k,t1(j),t2(k));
				k = k-1;
			end
			while (t2(k)+tmax < t1(j) & k < length(t2))
%				fprintf('j %d, k %d, t1(j) %g, t2(k) %g,+\n',j,k,t1(j),t2(k));
				k = k+1;						% Advance if necessary
			end
			while (k <= length(t2) & t2(k)-tmax < t1(j) & t2(k)-t1(j) > -tmax)
				tcc(end+1) = t2(k)-t1(j);
				timet(end+1) = t1(j);
%				fprintf('j %d, k %d, t1(j) %g, t2(k) %g,Y\n',j,k,t1(j),t2(k));
 				k = k+1;
			end
			j = j+1;
		end
	end
