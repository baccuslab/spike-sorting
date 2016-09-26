function p = untangle(punique,locs,dims)
% untangle: utility for fitting; enables some parameters to be common, others unique
% p = untangle(punique,locs,dims)
% Given a set of Nexp different experiments, and a model described by a set of Np
% parameters, one may wish to fit the model to all Nexp experiments.
% Some of the parameters may be different in each of the experiments,
% while others should be fit simultaneously to some/all of the experiments.
% This utility makes this process easy.
% Outputs:
%	p: a Np-by-Nexp matrix, each column of which is the set of parameters
%		for a particular experiment.
% Inputs:
%	punique: a vector containing a set of parameter values
%	locs: a cell array containing the indices in p for each of these
%		parameter values, i.e. puinque(i) gets put in p(locs{i}). Parameters
%		that apply to n of the experiments will have n entries here.
%	dims: the dimensions of the resulting p
p = zeros(dims);
np = length(punique);
if (~iscell(locs))
	error('locs must be a cell array');
end
if (length(locs) ~= np)
	error('Number of parameters & number of location vectors doesn''t match');
end
for i = 1:np
	p(locs{i}) = punique(i);
end
