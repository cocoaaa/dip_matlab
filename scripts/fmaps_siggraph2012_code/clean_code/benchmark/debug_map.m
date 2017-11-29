clear all
close all

m1 = 'victoria25';
m2 = 'victoria17';

load(sprintf('benchmark/Fmaps/%s_to_%s.mat', m1, m2));

mesh1 = loadMeshLB(m1);
mesh2 = loadMeshLB(m2);

segMethod.name = 'wks_5_pers_8';
segMethod.faceSeg = 0;
mesh1 = loadSegmentation(mesh1, segMethod);
mesh2 = loadSegmentation(mesh2, segMethod);

showSegmentations
showMap(mesh1, [], mesh2, [], fmap, destinations);

segMatches