function [err, destinations, distances] = mapErr(map, basis1, basis2, mesh2, step) 
if nargin < 5
    step = 1;
end
toTest = 1:step:mesh2.nv;
destinations = mapClosestDelta(map, toTest, basis1, basis2);                                    

edgeLengths2 = mesh2.edgeLens;
meanEdgeLength2 = mean(nonzeros(edgeLengths2));
X2 = mesh2.vertices;
distances = normv(X2(toTest,:) - X2(destinations,:));
err = mean(distances) / meanEdgeLength2;        
