function Fmaps = mapErrorClosestDelta(mesh1, basis1, mesh2, basis2, Fmaps, toTest)
% Computes the error of a map by sampling points and measuring how far they
% are from their actual mapped points (assume mesh1 and mesh2 are in
% point-to-point correspondence).  An optional argument says which vertices
% to test.
% Uses the closest delta function to compute the map

if nargin < 6
    toTest = 1:10:mesh1.nv; 
end
if size(toTest,2) > 1
    toTest = toTest';
end

edgeLengths2 = mesh2.edgeLens;
meanEdgeLength2 = mean(nonzeros(edgeLengths2));
X2 = mesh2.vertices;

for i=1:length(Fmaps)
    if isfield(Fmaps{i},'ppMaps')
        [m,n] = size(Fmaps{i}.ppMaps);
        Fmaps{i}.ppErrors = zeros(m,n);
        for j=1:m
            for k=1:n
                map = Fmaps{i}.ppMaps{j,k};
                
                fprintf('postprocessed map: %d,%d,%d ... ', i,j,k);
                t = tic;
                destinations = mapClosestDelta(map, toTest, basis1, basis2);                                    
                if max(toTest) <= length(X2) 
                    distances = normv(X2(toTest,:) - X2(destinations,:));
                else
                    distances = zeros(size(destinations));
                end

                Fmaps{i}.ppErrors(j,k) = mean(distances) / meanEdgeLength2;        
                Fmaps{i}.ppDestinations{j,k} = destinations;
                fprintf('%g\n', toc(t));
            end
        end
    else
        for j=1:length(Fmaps{i}.maps)
            map = Fmaps{i}.maps{j};

            fprintf('map: %d,%d ... ', i,j);
            t = tic;
            destinations = mapClosestDelta(map, toTest, basis1, basis2);                                    
            distances = normv(X2(toTest,:) - X2(destinations,:));

            Fmaps{i}.errors(j) = mean(distances) / meanEdgeLength2;        
            Fmaps{i}.destinations{j} = destinations;
            fprintf('%g\n', toc(t));
        end
    end
end

function nn = normv(v)
nn = sqrt(sum(v.^2,2));