function printMapsErrors(options, mesh1, mesh2, Fmaps)
fprintf('%s to %s\n', mesh1.name, mesh2.name);

fprintf('Descriptors: ');
for i=1:length(options.descriptors)
    fprintf('%s, ', options.descriptors{i});
end
fprintf('\n');

fprintf('Operators: ');
for i=1:length(options.operators)
    fprintf('%s, ', options.operators{i});
end
fprintf('\n');

for i=1:length(Fmaps)
    printMapErr(Fmaps{i});
end

function printMapErr(Fmap)
for m = 1:length(Fmap.maps)    
    % Map error
    titleStr = Fmap.method;
    if isfield(Fmap,'params') && ~isempty(Fmap.params)
        titleStr = sprintf('%s (%g)', titleStr, Fmap.params{m});
    end
    if isfield(Fmap,'errors')
        error = Fmap.errors(m);
        titleStr = sprintf('%s,\tError: %g\n',titleStr, error);
    end
    
    % Postprocessing
    if isfield(Fmap,'ppMaps')
        titleStr = sprintf('\n%s + %s', titleStr, Fmap.ppMethod);
        if isfield(Fmap,'ppParams') 
            titleStr = sprintf('%s (%g)', titleStr, Fmap.ppParams{1});
        end        
        error = Fmap.ppErrors(m);
        titleStr = sprintf('%s,\tError: %g\n',titleStr, error);
    end
    
    fprintf('%s', titleStr);
end
    
