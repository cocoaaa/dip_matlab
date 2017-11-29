path(path, '../utils');
path(path, '../../figs');
path(path, '../anisodiff_Perona-Malik');

% Add vlfeat library for SIFT 
path(path, '../vlfeat/');
run('../vlfeat/toolbox/vl_setup')

% Add numerical tour's toolboxes
addpath('/Local/Users/hjsong/Playground/numerical-tours/matlab/toolbox_signal');
addpath('/Local/Users/hjsong/Playground/numerical-tours/matlab/toolbox_general');
