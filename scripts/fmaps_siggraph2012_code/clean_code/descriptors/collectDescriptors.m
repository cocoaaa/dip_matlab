function [F G] = collectDescriptors(mesh1, mesh2, options)
% Collects functional constraints F and G from mesh1 and mesh2.  Takes as
% an optional argument an options struct specifying which constraints to
% construct.

F = [];
G = [];

numDescriptors = length(options.descriptors);
for i=1:numDescriptors
    desc = options.descriptors{i};
    descParams = options.descriptorsParams{i};
    
    Fnew = getDescriptor(mesh1, desc, descParams, 1);
    Gnew = getDescriptor(mesh2, desc, descParams, 2);
    
%     Fnew = Fnew/norm(Fnew,inf);
%     Gnew = Gnew/norm(Fnew,inf);
    
    F = [F Fnew]; clear Fnew
    G = [G Gnew];
end

function F = getDescriptor(mesh, name, params, m)        
if strcmp(name, 'wks')
    F = waveKernelSignature(mesh, params.timeSteps);

elseif strcmp(name, 'hks')
    F = heatKernelSignature(mesh, params.timeSteps);

elseif strcmp(name, 'wkm')
    F = [];
    if ~isempty(params.landmarks)
        landmarks = params.landmarks(:,m);
        for i=1:length(landmarks)
            F = [F waveKernelMap(mesh, params.timeSteps, landmarks(i))];
        end
    end

elseif strcmp(name, 'hkm')
    F = [];
    if ~isempty(params.landmarks)
        landmarks = params.landmarks(:,m);
        for i=1:length(landmarks)
            F = [F heatKernelMap(mesh, params.timeSteps, landmarks(i))];
        end
    end

elseif strcmp(name, 'segment_indicator')
    F = segmentIndicators(mesh, params.segs(:,m));
    
elseif strcmp(name, 'segment_hkm')
    indicators = segmentIndicators(mesh, params.segs(:,m));
    F = [];
    for i=1:size(indicators,2)
        F = [F segmentHeatKernelMap(mesh, params.timeSteps, indicators(:,i))];
    end

elseif strcmp(name, 'segment_wkm')
    indicators = segmentIndicators(mesh, params.segs(:,m));
    % add "the rest"
    indicators(:,end+1) = 1 - sum(indicators,2);
    F = [];
    for i=1:size(indicators,2)
        F = [F segmentWaveKernelMap(mesh, params.timeSteps, indicators(:,i))];
    end

elseif strcmp(name,  'additional_features')
    F = faceToVertex(mesh.additionalFeatures,mesh);
    
elseif strcmp(name, 'coff')
    [~,~,F] = readCoff([mesh.name '.off'],4);
    
elseif strcmp(name, 'diffused_coff')
    [~,~,coff] = readCoff([mesh.name '.off'],4);
    F = [];
    for i=1:size(coff,2)
        F = [F segmentHeatKernelMap(mesh, params.timeSteps, coff(:,i))];
    end
    
else fprintf(1,'Unrecognized descriptor: %s', descriptor);
end
