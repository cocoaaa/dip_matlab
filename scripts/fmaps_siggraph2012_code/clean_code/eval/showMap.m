function [h, h1,h2] = showMap(mesh1, basis1, mesh2, basis2, fmap, dest)
h = figure; 
X1 = mesh1.vertices; T1 = mesh1.triangles;
X2 = mesh2.vertices; T2 = mesh2.triangles;
col1 = X1 - repmat(mean(X1),mesh1.nv,1);    
col1 = col1./repmat(max(col1),mesh1.nv,1);

h1 = subplot(2,1,1);
patch('Faces',T1,'Vertices',X1,'FaceColor','interp', ...
      'FaceVertexCData', col1, 'EdgeColor', 'none'); 
axis equal; axis tight; axis off; cameratoolbar; 

h2 = subplot(2,1,2);
%col2 = transferFunction(col1, basis1, basis2, fmap);
col2 = col1(dest,:);
patch('Faces',T2,'Vertices',X2,'FaceColor','interp', ...
      'FaceVertexCData', col2, 'EdgeColor', 'none'); axis equal; axis tight; axis off; cameratoolbar;         
set(h,'WindowStyle','docked');    