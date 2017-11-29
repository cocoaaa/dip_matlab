close all
clear all

setupFunctionalMaps

plist_fname = 'benchmark/PairList/VerboseNRWPairs';
fid = fopen(plist_fname);
if fid == -1
    error('?');
end
plist = textscan(fid,'%s %s');
if size(plist,1) ~= 1 || size(plist,2) ~= 2 
    error('?');
end

m1 = plist{1}; m2 = plist{2};
if length(m1) ~= length(m2)
    error('?');
end

numEig = 100;
for i=1:length(m1)    
    p2p_fname = sprintf('benchmark/Maps/%s_to_%s.map',m1{i}, m2{i});
    if exist(p2p_fname,'file')
        fprintf('skipping: %s\n', p2p_fname);
        continue
    end

    mesh1 = loadMeshLB(m1{i}, numEig);
    mesh2 = loadMeshLB(m2{i}, numEig);  

    fprintf('%s to %s\n', mesh1.name, mesh2.name);    

    clear f g
    
    runme_tosca_blended

    % Save map
    destinations = Fmaps{1}.ppDestinations{1};
    fmap = Fmaps{1}.ppMaps{1};
    dlmwrite(p2p_fname, (destinations-1)');
    fmap_fname = sprintf('benchmark/FMaps/%s_to_%s.mat',mesh1.name, mesh2.name);
    save(fmap_fname, 'fmap','destinations','segMatches','options','numEig','segMethod');        
end

fclose(fid);
