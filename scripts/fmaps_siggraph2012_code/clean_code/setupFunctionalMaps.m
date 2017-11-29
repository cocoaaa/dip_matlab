% Add cache directory
path(path,'cache/');

% Add directory with model data
path(path,'../shapes/');
path(path,'../shapes/tosca-blended');
path(path,'../shapes/segmentation_benchmark');
path(path,'../shapes/SCAPE');
path(path,'../shapes/coff');

% Add directory with segmentation data
path(path,'../shapes/tosca-blended/segmentations');
path(path,'../shapes/segmentation_benchmark/segmentations');
path(path,'../shapes/SCAPE/segmentations');

% Add directory with utility methods
path(path,'util/');

% Add directory with mapping methods
path(path,'optimization/');

% Add path for descriptor computation
path(path,'descriptors/');

% Add path for operators computation
path(path,'operators/');

% Add path for evaluation code
path(path,'eval/'); 

% Add path for benchmark code
path(path,'benchmark/'); 
path(path,'benchmark/plots/'); 

% External libraries
% Add path for Laplace-Beltrami code
path(path,'../external/lb_code/');
path(path,'../external/lb_code/MeshLP');

% Add path for Matlab BGL (only dijkstra_sp is there)
path(path,'../external/matlab_bgl');

% Add path for ann_mwrapper
path(path,'../external/ann_mwrapper');
path(path,'../external/voronoi-laplace');
path(path,'../external/voronoi-laplace/functions');
path(path,'../external/voronoi-laplace/GLtree3DMex');
path(path,'../external');
