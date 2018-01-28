addpath('/Local/Users/hjsong/Playground/dip_matlab/scripts/OpticalFlow')
% dirPath = '/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/itkDeformRegistration17';
% load '/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/itkDeformRegistration17/flow2D.mat'

dirPath = '/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/itkMSOpticalFlow';
load '/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/itkMSOpticalFlow/flow2D.mat'

flow_view=flowToColor(cat(3,u,v));
imwrite(flow_view,[dirPath '/flow.png'],'png');
