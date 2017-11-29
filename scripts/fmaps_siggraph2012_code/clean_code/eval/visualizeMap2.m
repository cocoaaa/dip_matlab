function [h1s, h2s] = visualizeMap2(mesh1, basis1, mesh2, basis2, Fmap)
% Visualizes the map from the given vertex.

for m = 1:length(Fmap.maps)    
    if isfield(Fmap,'ppMaps')
        fmap = Fmap.ppMaps{m};
        dest = Fmap.ppDestinations{m};
    else
        fmap = Fmap.maps{m};
        dest = Fmap.destinations{m};
    end
    [h, h1,h2] = showMap(mesh1, basis1, mesh2, basis2, fmap, dest);
    h1s(m) = h1; h2s(m) = h2;
    set(h,'WindowStyle','docked','name',getTitle(Fmap,m));    
end

function titleStr = getTitle(Fmap,m)
titleStr = Fmap.method;
if isfield(Fmap,'params') && ~isempty(Fmap.params)
    titleStr = sprintf('%s (%g)', titleStr, Fmap.params{m});
end
if isfield(Fmap,'ppMaps')
    titleStr = sprintf('%s + %s', titleStr, Fmap.ppMethod);
    if isfield(Fmap,'ppParams') 
        titleStr = sprintf('%s (%g)', titleStr, Fmap.ppParams{1});
    end        
    error = Fmap.ppErrors(m);
else
    error = Fmap.errors(m);
end
titleStr = sprintf('%s, Error: %g',titleStr, error);

