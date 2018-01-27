addpath('/Local/Users/hjsong/Playground/dip_matlab/scripts/OpticalFlow')
dirPath = '/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/itkDeformRegistration12';
load '/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/itkDeformRegistration12/flow2D.mat'
flow_view=flowToColor(cat(3,u,v));
imwrite(flow_view,[dirPath '/flow.png'],'png');
