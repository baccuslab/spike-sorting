function proj = DoPrincompProj(spikes,nproj)
% proj = DoPrincompProj(spikes,nproj)
% Calculate principal components and the projections
% onto the spike data for a set of spike snippets
[pc,score,ev] = princomp(spikes');
if (nproj > size(pc,1))
	nproj = size(pc,1);
end
proj = score(:,1:nproj)';
