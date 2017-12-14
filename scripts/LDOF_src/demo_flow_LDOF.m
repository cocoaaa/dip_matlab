
% imfile1='im1.jpg';
% imfile2='im2.jpg';

imfile1='/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/b1.png';
imfile2='/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/b2.png';
imfile3='/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/b3.png';


% imfile1='/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/clusterIm1_0.003.png';
% imfile2='/Local/Users/hjsong/Playground/dip_matlab/figs/mammo/clusterIm2_0.001.png';

im1=imread(imfile1);
im2=imread(imfile2); % or im2=imread(imfile3);


verbose=0;
[p,q,~]=size(im1);
para=get_para_flow(p,q);


[F,c1,c2]=LDOF(imfile1,imfile2,para,verbose);

% check_flow_correspondence(im1,im2,F);
flow_warp(im1,im2,F,1)
flow_view=flowToColor(F);
imwrite(flow_view,[pwd '/view.png'],'png');
