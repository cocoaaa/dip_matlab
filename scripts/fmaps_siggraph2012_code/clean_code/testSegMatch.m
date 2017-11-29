function resid = testSegMatch(mesh1, basis1, basis1i, mesh2, basis2, basis2i, segMatches,alpha)
if nargin < 8
    alpha = 1;
end

options.descriptors = {};
options.descriptorsParams = {};

% NOT USING WKS ATM
% options.descriptors{end+1}          = 'wks';
% wksParams.timeSteps = 100;
% options.descriptorsParams{end+1}    = wksParams;       

options.descriptors{end+1}          = 'segment_wkm';
segHkmParams.segs = segMatches;
segHkmParams.timeSteps = 100;
options.descriptorsParams{end+1}    = segHkmParams;       

[f g] = collectDescriptors(mesh1, mesh2, options);
F = descriptorsToCoeffsFast(f, basis1i);
G = descriptorsToCoeffsFast(g, basis2i);

options.operators = {};
options.operators{end+1} = 'confLB';
[s r] = collectOperators(mesh1, mesh2, options);
S = operatorsToMtxFast(s, basis1, basis1i);
R = operatorsToMtxFast(r, basis2, basis2i);

[~,resid] = leastSquaresMapFast(F,G,S,R,alpha);
