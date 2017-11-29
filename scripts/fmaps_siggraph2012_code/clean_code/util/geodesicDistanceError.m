function distances = geodesicDistanceError(mesh2, destinations)

distances = zeros(mesh2.nv,1);
for i=1:mesh2.nv
    if mod(i,100)==0
        fprintf('%d ', i);
    end
    EL = mesh2.edgeLens;
    d = dijkstra_sp(EL, i);
    distances(i) = d(destinations(i));
end
fprintf('\n');
