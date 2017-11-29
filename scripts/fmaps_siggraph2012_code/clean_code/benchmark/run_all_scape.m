close all
clear all
plist_fname = 'benchmark/PairList/VerboseSCAPEPairsSorted_end';
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
    mesh1 = loadMeshLB(m1{i}, numEig);
    mesh2 = loadMeshLB(m2{i}, numEig);  
    
    fprintf('%s to %s\n', mesh1.name, mesh2.name);    

    runme_scape
end

fclose(fid);