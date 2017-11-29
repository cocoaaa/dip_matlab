segMethod.name = 'wks_wks_5';
segMethod.faceSeg = 0;
mesh1 = loadSegmentation(mesh1, segMethod);
mesh2 = loadSegmentation(mesh2, segMethod);

%%%%%% Basis
% use conf LB basis - unweighted cot matrix
basis1 = mesh1.confLaplaceBasis;
basis2 = mesh2.confLaplaceBasis;


%%%%%% Descriptors
% descriptor options
options.descriptors = {};
options.descriptorsParams = {};

% Point descriptors
% WKS
options.descriptors{end+1}          = 'wks';
wksParams.timeSteps = 100;
options.descriptorsParams{end+1}    = wksParams;       

% Segment descriptors
% Find segment matches
numSegMatches = 3;
[segMatches1,resid1] = findSegmentMatches(mesh1, basis1, mesh2, basis2, numSegMatches);
skip = segMatches1(1,:);
[segMatches2,resid2] = findSegmentMatches(mesh1, basis1, mesh2, basis2, numSegMatches, skip);
% Pick better from the two greedy runs
if resid1 < resid2
    segMatches = segMatches1;
else
    segMatches = segMatches2;
end
% Segment HKM
options.descriptors{end+1}          = 'segment_wkm';
segHkmParams.segs = segMatches;
segHkmParams.timeSteps = 100;
options.descriptorsParams{end+1}    = segHkmParams;       

% Compute descriptors
[f g] = collectDescriptors(mesh1, mesh2, options);

% Write descriptors in provided basis
F = descriptorsToCoeffs(f, basis1);
G = descriptorsToCoeffs(g, basis2);

%%%%%%%%% Operator commutativity
options.operators = {};

% LB operator
options.operators{end+1} = 'confLB';

% collect operators
[s r] = collectOperators(mesh1, mesh2, options);

% Write operators in provided basis
S = operatorsToMtx(s, basis1);
R = operatorsToMtx(r, basis2);

for m=1:length(R)
    if (nnz(S{m}) > 10*mesh1.nv || nnz(R{m}) > 10*mesh2.nv)
        error('?');
    end
end

%%%%%%%%% Optimization
% Which maps. options are: band, groundTruth, l1, leastSquares, qr, svd
options.mappingMethods = {};
options.mappingParams = {};

options.mappingMethods{end+1} = 'leastSquares';
options.mappingParams{end+1} = {};

%%%%%%%%% Post-processing
% Snap to closest rotation, ignore eigenvals below alpha
% Perform ICP in eigenvec space for 
options.postprocessing = 'ICP';
options.postprocessingParams = {10};               % step

% Compute the maps
Fmaps = computeMap(basis1, F, S, basis2, G, R, options);

% compute errors
Fmaps = mapErrorClosestDelta(mesh1, basis1, mesh2, basis2, Fmaps, 1:mesh1.nv);
% 
printMapsErrors(options, mesh1, mesh2, Fmaps);

% Save map
destinations = Fmaps{1}.ppDestinations{1};
fmap = Fmaps{1}.ppMaps{1};
p2p_fname = sprintf('benchmark/Maps/%s_to_%s.map',mesh1.name, mesh2.name);
dlmwrite(p2p_fname, (destinations-1)');
fmap_fname = sprintf('benchmark/FMaps/%s_to_%s.mat',mesh1.name, mesh2.name);
save(fmap_fname, 'fmap','destinations','segMatches','options','numEig');