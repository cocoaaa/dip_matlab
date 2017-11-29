function [Fmaps, toTest, functions] = mapError(mesh1, basis1, mesh2, basis2, Fmaps, toTest)
% Computes the error of a map by sampling points and measuring how far they
% are from their actual mapped points (assume mesh1 and mesh2 are in
% point-to-point correspondence).  An optional argument says which vertices
% to test.

if nargin < 6
    toTest = mesh1.nv:-1000:1; 
end
if size(toTest,2) > 1
    toTest = toTest';
end


% Compute a list of kernel sizes
numTimes = 10; % we could make this a parameter if it matters
edgeLengths1 = mesh1.edgeLens;
meanEdgeLength1 = mean(nonzeros(edgeLengths1));
kernelSizes = linspace(4,10,numTimes) * meanEdgeLength1 * sqrt(2);

edgeLengths2 = mesh2.edgeLens;
meanEdgeLength2 = mean(nonzeros(edgeLengths2));

% Compute actual kernels
functions = testFunctions(mesh1, toTest, kernelSizes);

% Project kernels onto mesh 1's basis, taking advantage of parallelism
pseudoInv = pinv(basis1);
coeffs1 = cellfun(@(x) pseudoInv*x, functions, 'UniformOutput', false);

for i=1:length(Fmaps)
    for j=1:length(Fmaps{i}.maps)
        map = Fmaps{i}.maps{j};

        [distances, destinations] = mapErrDeltaFunc(map, toTest, coeffs1, mesh2, basis2);
        
        Fmaps{i}.errors(j) = mean(distances) / meanEdgeLength2;        
        Fmaps{i}.destinations{j} = destinations;
    end
    
    if isfield(Fmaps{i},'ppMaps')
        [m,n] = size(Fmaps{i}.ppMaps);
        Fmaps{i}.ppErrors = zeros(m,n);
        for j=1:m
            for k=1:n
                map = Fmaps{i}.ppMaps{j,k};
                
                [distances, destinations] = mapErrDeltaFunc(map, toTest, coeffs1, mesh2, basis2);

                Fmaps{i}.ppErrors(j,k) = mean(distances) / meanEdgeLength2;        
                Fmaps{i}.ppDestinations{j,k} = destinations;
            end
        end
    end
end

function [dist, dest] = mapErrDeltaFunc(map, toTest, coeffs1, mesh2, basis2)
% Send to mesh 2, put back in primal basis, and sum
sums = cellfun(@(x) sum(basis2*(map*x),2), coeffs1, 'UniformOutput', false);

% Figure out destination of each point
dest = cellfun(@(x) maxPos(x), sums);

% Figure out distance 
dist = cellfun(@(x,y) normv(mesh2.vertices(x,:)-mesh2.vertices(y,:)), ...
    num2cell(dest), num2cell(toTest));


function p = maxPos(v)
[~,p] = max(v);

function nn = normv(v)
nn = sqrt(sum(v.^2,2));