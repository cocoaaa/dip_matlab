clear all
close all
setupFunctionalMaps

numEig = 100;

mesh1 = loadMeshLB('cat1', numEig);
mesh2 = loadCloudLB('cat0_rescaled_cloud', numEig);

%%%%%% Basis
% use LB basis
basis1 = mesh1.laplaceBasis;
basis2 = mesh2.laplaceBasis;

% Comment this block out if you don't want to rescale the eigenvalues
% to be on closer scales.  It's hard to know which map is better -- both
% yield OK, not great results.
% aveig1 = mean(mesh1.eigenvalues);
% aveig2 = mean(mesh2.eigenvalues);
% multiplier = aveig1/aveig2;
% mesh2.cotLaplace = mesh2.cotLaplace * multiplier;
% mesh2.eigenvalues = mesh2.eigenvalues * multiplier;
% fprintf(1,'Eigenvalue multiplier = %g\n',multiplier);

%%%%%% Descriptors
% descriptor options
options.descriptors = {};
options.descriptorsParams = {};

% Point descriptors
% WKS
options.descriptors{end+1}          = 'wks';
wksParams.timeSteps = 30;
options.descriptorsParams{end+1}    = wksParams;       

% HKS
options.descriptors{end+1}          = 'hks';
options.descriptorsParams{end+1}    = wksParams;       

% Point landmarks

% HKM
options.descriptors{end+1}          = 'hkm';
hkmParams.timeSteps = 130;
hkmParams.landmarks(:,1) = [5621,18991,26051,27894];
hkmParams.landmarks(:,2) = [5621,18991,26051,27894];
options.descriptorsParams{end+1}    = hkmParams;       

% WKM
options.descriptors{end+1}          = 'wkm';
wkmParams.timeSteps = 130;
wkmParams.landmarks(:,1) = [5621,18991,26051,27894];
wkmParams.landmarks(:,2) = [5621,18991,26051,27894];
options.descriptorsParams{end+1}    = wkmParams;   

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
options.operators{end+1} = 'LB';

% collect operators
fprintf(1, 'Computing operators...\n');
[s r] = collectOperators(mesh1, mesh2, options);

% Write operators in provided basis
fprintf(1, 'Writing operators in provided basis...\n');
S = operatorsToMtx(s, basis1);
R = operatorsToMtx(r, basis2);

%%%%%%%%% Optimization
% Which maps. options are: band, groundTruth, l1, leastSquares, qr, svd
options.mappingMethods = {};
options.mappingParams = {};

%options.mappingMethods{end+1} = 'l1';
%options.mappingParams{end+1}  = {0.075,0.1};

%options.mappingMethods{end+1} = 'svd';
%options.mappingParams{end+1} = {1e-4};
 
options.mappingMethods{end+1} = 'leastSquares';
options.mappingParams{end+1} = {};

%%%%%%%%% Post-processing
% Snap to closest rotation, ignore eigenvals below alpha
% options.postprocessing = 'closestRotation';
% options.postprocessingParams = {1e-4,0};         % alpha

% Perform ICP in eigenvec space for 
options.postprocessing = 'ICP';
options.postprocessingParams = {30};               % step

% Compute the maps
fprintf('Computing the maps\n');
Fmaps = computeMap(basis1, F, S, basis2, G, R, options);

% Visualize
visualizeMaps(mesh1, basis1, mesh2, basis2, Fmaps);