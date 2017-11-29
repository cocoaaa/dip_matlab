clear all
close all
setupFunctionalMaps

numEig = 100;

mesh1 = loadMeshLB('cat0', numEig);
mesh2 = loadMeshLB('cat10', numEig);
% 'joint' for segmentation benchmark models (1.off-400.off)
% 'hks_basic' or 'wks_finer' for tosca models (cat0,...)
% 'wks_wks_5' for scape models (mesh000,...)
segMethod.name = 'wks_5_pers_8';
segMethod.faceSeg = 0;
% segMethod.name = 'joint';
% segMethod.faceSeg = 1;
mesh1 = loadSegmentation(mesh1, segMethod);
mesh2 = loadSegmentation(mesh2, segMethod);

%%%%%% Basis
% use conf LB basis - unweighted cot matrix
basis1 = mesh1.confLaplaceBasis;
%eig1 = mesh1.confLaplaceEvals;
basis2 = mesh2.confLaplaceBasis;
%eig2 = mesh2.confLaplaceEvals;

%basis1 = basis1*spdiags(exp(-0.1*abs(eig1)),0,numEig,numEig);
%basis2 = basis2*spdiags(exp(-0.1*abs(eig2)),0,numEig,numEig);


%%%%%% Descriptors
% descriptor options
options.descriptors = {};
options.descriptorsParams = {};

% Point descriptors
% WKS
options.descriptors{end+1}          = 'wks';
wksParams.timeSteps = 100;
options.descriptorsParams{end+1}    = wksParams;       

% HKS
% options.descriptors{end+1}          = 'hks';
% hksParams.timeSteps = 30;
% options.descriptorsParams{end+1}    = hksParams;       

% Texture
% TODO

% Point landmarks
% TODO, where do we get these?
% catLandmarks = [5626,18995,26057];
% scapeLandmarks = [1, 1000, 10000];
% landmarks = scapeLandmarks(1:3);
% % WKM
% options.descriptors{end+1}          = 'wkm';
% wkmParams.timeSteps = 130;
% wkmParams.landmarks(:,1) = landmarks;
% wkmParams.landmarks(:,2) = landmarks;
% options.descriptorsParams{end+1}    = wkmParams;       

% % HKM
% options.descriptors{end+1}          = 'hkm';
% options.descriptorsParams{end+1}    = wkmParams;       

% Segment descriptors
% Find segment matches
numSegMatches = 3; 
[segMatches1,resid1] = findSegmentMatches(mesh1, basis1, mesh2, basis2, numSegMatches);
skip = segMatches1(1,:);
[segMatches2,resid2] = findSegmentMatches(mesh1, basis1, mesh2, basis2, numSegMatches, skip);
if resid1 < resid2
    segMatches = segMatches1;
else
    segMatches = segMatches2;
end
%segMatches = [[5;6;7],[5;6;7]];          % cats
%segMatches = [7    10; 6     9; 5     8]; % Dog0 Dog1
%segMatches = [[3;4;5],[3;4;5]];          % cats
%segMatches = [[3;5;7],[3;7;5]];
%segMatches = [[1;2;4],[1;2;4]];
% Segment HKM
options.descriptors{end+1}          = 'segment_wkm';
segHkmParams.segs = segMatches;
segHkmParams.timeSteps = 100;
options.descriptorsParams{end+1}    = segHkmParams;       

% Segment landmarks
% options.descriptors{end+1}          = 'segment_indicator';
% segParams.segs(:,1) = [3 5];
% segParams.segs(:,2) = [3 5];
% options.descriptorsParams{end+1}    = segParams;       

% Compute descriptors
fprintf(1, 'Computing descriptors...\n');
[f g] = collectDescriptors(mesh1, mesh2, options);

% Write descriptors in provided basis
fprintf(1, 'Writing descriptors in provided basis...\n');
F = descriptorsToCoeffs(f, basis1);
G = descriptorsToCoeffs(g, basis2);

%%%%%%%%% Operator commutativity
options.operators = {};

% LB operator
options.operators{end+1} = 'confLB';

% collect operators
fprintf(1, 'Computing operators...\n');
[s r] = collectOperators(mesh1, mesh2, options);

% Write operators in provided basis
fprintf(1, 'Writing operators in provided basis...\n');
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

% options.mappingMethods{end+1} = 'groundTruth';
% options.mappingParams{end+1}  = {};
% 
% options.mappingMethods{end+1} = 'l1';
% options.mappingParams{end+1}  = {0.075,0.1};
% 
% options.mappingMethods{end+1} = 'svd';
% options.mappingParams{end+1} = {1e-4};
% % 
options.mappingMethods{end+1} = 'leastSquares';
options.mappingParams{end+1} = {};

%%%%%%%%% Post-processing
% Snap to closest rotation, ignore eigenvals below alpha
% options.postprocessing = 'closestRotation';
% options.postprocessingParams = {1e-4,0};         % alpha

% Perform ICP in eigenvec space for 
options.postprocessing = 'ICP';
options.postprocessingParams = {10};               % step

% Compute the maps
fprintf('Computing the maps\n');
Fmaps = computeMap(basis1, F, S, basis2, G, R, options);

% compute errors
fprintf('Computing the errors\n');
Fmaps = mapErrorClosestDelta(mesh1, basis1, mesh2, basis2, Fmaps, 1:mesh1.nv);
% 
% % Visualize
visualizeMaps2(mesh1, basis1, mesh2, basis2, Fmaps);
printMapsErrors(options, mesh1, mesh2, Fmaps);

% Compute geodesic errors
% mapp = Fmaps{1}.ppDestinations{1};
% distances = geodesicDistanceError(mesh2, mapp);