function visualizeMaps2(mesh1, basis1, mesh2, basis2, Fmaps)

h1s = [];
h2s = [];
for i=1:length(Fmaps)
    [h1,h2] = visualizeMap2(mesh1, basis1, mesh2, basis2, Fmaps{i});
    h1s = [h1s, h1]; h2s = [h2s, h2];
end

for i=1:length(Fmaps)
    hlink = linkprop(h1s(i),{'CameraPosition','CameraUpVector'});
    key = 'graphics_linkprop';
    setappdata(h1s(1),key,hlink); 
    
    hlink = linkprop(h2s(i),{'CameraPosition','CameraUpVector'});
    key = 'graphics_linkprop';
    setappdata(h2s(1),key,hlink);     
end