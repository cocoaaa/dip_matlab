% Experiment:vanilla HS vs HS+warping vs. HS+warping+pyramid
close all;
clear all;
%%
addpath('../');
addpath('/Local/Users/hjsong/Playground/dip_matlab/scripts/utils');
imgDir='/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/other-data-gray/';
gtDir = '/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/other-gt-flow/';

im1 = im2double(imread(strcat(imgDir, 'RubberWhale/frame10.png')));
im2 = im2double(imread(strcat(imgDir, 'RubberWhale/frame11.png')));
flowGT = readFlowFile(strcat(gtDir, 'RubberWhale/flow10.flo'));
% figure; imshowpair(im1, im2); title("original im1 and im2");
figure; imshowpair(flowGT(:,:,1), flowGT(:,:,2), 'montage'); title("ground truth flow");
figure; imshow(computeColor( flowGT(:,:,1), flowGT(:,:,2) )); title("ground truth flow");

[m,n] = size(im1);

%% Perform optical flows
lambda = 15; % needs to be set per image
maxMotion = 16;
reduceFactor = .5;
tic;
[uScale, vScale] = opticalFlowHSWarp(im1, im2, zeros(m,n), zeros(m,n), lambda);
toc; 

flowScale = cat(3, uScale, vScale);
