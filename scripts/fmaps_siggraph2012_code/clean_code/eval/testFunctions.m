function test = testFunctions(mesh, vertices, widths)
% Generates test functions on the mesh centered at the list of vertices
% with the given widths.  The matrix test{i} contains the test functions
% for vertex i as its columns.

edgeLengths = mesh.edgeLens;

if nargin < 3
    widths = 10*mean(nonzeros(edgeLengths));
end

nv = length(vertices);

test = cell(nv,1);
for i=1:nv
    vertex = vertices(i);
    
    distances = dijkstra_sp(edgeLengths,vertex);
    
    test{i} = zeros(size(mesh.vertices,1),length(widths));
    for j=1:length(widths)
        test{i}(:,j) = normpdf(distances,0,widths(j));
    end
end