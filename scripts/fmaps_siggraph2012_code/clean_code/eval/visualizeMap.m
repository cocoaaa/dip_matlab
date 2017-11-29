function [vertices, testf, ind2, h1, h2] = visualizeMap(mesh1, basis1, mesh2, basis2, Fmap, vertices, testf)
% Visualizes the map from the given vertex.

if nargin < 6
    r = randperm(mesh1.nv);
    vertices = r(1:3);
end
if nargin < 7
    testf = testFunctions(mesh1, vertices);
end
ntv = length(vertices);
ind2 = {};
for m = 1:length(Fmap.maps)    
    h = figure; 
    if isfield(Fmap,'ppMaps')
        fmap = Fmap.ppMaps{m};
    else
        fmap = Fmap.maps{m};
    end
    for i=1:ntv
        indicator1 = testf{i};
        indicator2 = transferFunction(indicator1, basis1, basis2, fmap);
        ind2{m,i} = indicator2;
        
        h1(i,m) = subplot(2,ntv,i);
        patch('Faces',mesh1.triangles,'Vertices',mesh1.vertices,'FaceColor','interp', ...
              'CData', indicator1, 'EdgeColor', 'none'); axis equal; axis tight; axis off; cameratoolbar; 

        h2(i,m) = subplot(2,ntv,i+ntv);
        if mesh2.nf > 0
            patch('Faces',mesh2.triangles,'Vertices',mesh2.vertices,'FaceColor','interp', ...
                  'CData', indicator2, 'EdgeColor', 'none'); axis equal; axis tight; axis off; cameratoolbar;
        else % a point cloud!
            %scatter3(mesh2.vertices(:,1),mesh2.vertices(:,2),mesh2.vertices(:,3),3,...
            %    indicator2,'filled');axis equal;axis tight;axis off;cameratoolbar;
            plot3k(mesh2.vertices,'ColorData',indicator2);axis equal;
            colorbar('off');
        end
    end
    set(h,'WindowStyle','docked','name',getTitle(Fmap,m));    
end

function titleStr = getTitle(Fmap,m)
titleStr = Fmap.method;
if isfield(Fmap,'params') && ~isempty(Fmap.params)
    titleStr = sprintf('%s (%g)', titleStr, Fmap.params{m});
end

error = -1;
if isfield(Fmap,'ppMaps')
    titleStr = sprintf('%s + %s', titleStr, Fmap.ppMethod);
    if isfield(Fmap,'ppParams') 
        titleStr = sprintf('%s (%g)', titleStr, Fmap.ppParams{1});
    end        
    if isfield(Fmap,'ppErrors')
        error = Fmap.ppErrors(m);
    end
else
    error = Fmap.errors(m);
end
titleStr = sprintf('%s, Error: %g',titleStr, error);

