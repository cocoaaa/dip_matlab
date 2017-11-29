function [testf,outf] = visualizeMaps(mesh1, basis1, mesh2, basis2, Fmaps)

r = randperm(mesh1.nv);
vertices = r(1:3);


testf = testFunctions(mesh1, vertices);
ntv = length(testf);

h1s = [];
h2s = [];
outf = {};
for i=1:length(Fmaps)
    [~,~,ind2,h1,h2] = visualizeMap(mesh1, basis1, mesh2, basis2, Fmaps{i}, vertices, testf);
    h1s = [h1s, h1]; h2s = [h2s, h2];
    outf{i} = ind2;
end

for i=1:ntv
    hlink = linkprop(h1s(i,:),{'CameraPosition','CameraUpVector'});
    key = 'graphics_linkprop';
    setappdata(h1s(i,1),key,hlink); 
    
    hlink = linkprop(h2s(i,:),{'CameraPosition','CameraUpVector'});
    key = 'graphics_linkprop';
    setappdata(h2s(i,1),key,hlink);     
end