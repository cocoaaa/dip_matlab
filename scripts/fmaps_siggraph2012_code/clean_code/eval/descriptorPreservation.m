% Compute ground truth map
myOptions = options;
myOptions.mappingMethods = {'groundTruth'};
myOptions.mappingParams = { {0} };
myFmap = computeMap(basis1, F, basis2, G, myOptions);
groundTruthMatrix = myFmap{1}.maps{1};

% Compute residual for all the descriptors so that we can plot them with
% the same axes
fullResid = G - groundTruthMatrix * F;
fullNorms = sqrt(sum(fullResid.*fullResid,1));
fullGNorms = sqrt(sum(G.*G,1));
fullError = fullNorms./fullGNorms;
maxError = max(fullError);

for i=1:length(options.descriptors)
    fprintf(1,'%s\n',options.descriptors{i});
    
    % Generate the i-th descriptor
    optionsCopy = options;
    optionsCopy.descriptors = { options.descriptors{i} };
    optionsCopy.descriptorsParams = { options.descriptorsParams{i} };
    [Fdesc Gdesc] = collectDescriptors(mesh1,mesh2,optionsCopy);
    Fdesc = descriptorsToCoeffs(Fdesc, basis1);
    Gdesc = descriptorsToCoeffs(Gdesc, basis2);
    
    % Plot its residual
    Gdescs{i} = Gdesc;
    Fdescs{i} = Fdesc;
    resid = Gdesc - groundTruthMatrix * Fdesc;
    resids{i} = resid;
    norms = sqrt(sum(resid.*resid,1));
    gNorms = sqrt(sum(Gdesc.*Gdesc,1));
    p = subplot(1,length(options.descriptors),i);
    plot(norms./gNorms); % divide by norm of G for some normalization
    axis([1 size(norms,2) 0 maxError]);
    title(optionsCopy.descriptors{1});
end