% Experiment:vanilla HS vs HS+warping vs. HS+warping+pyramid
close all;
clear all;
addpath('../');
addpath('/Local/Users/hjsong/Playground/dip_matlab/scripts/utils');

%% Part1: small motions]
imgDir='/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/other-data-gray/';
gtDir = '/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/other-gt-flow/';

im1 = im2double(imread(strcat(imgDir, 'RubberWhale/frame10.png')));
im2 = im2double(imread(strcat(imgDir, 'RubberWhale/frame11.png')));

flowGT = readFlowFile(strcat(gtDir, 'RubberWhale/flow10.flo'));
% figure; imshowpair(im1, im2); title("original im1 and im2");
figure; imshowpair(flowGT(:,:,1), flowGT(:,:,2), 'montage'); title("ground truth flow");
figure; imshow(computeColor( flowGT(:,:,1), flowGT(:,:,2) )); title("ground truth flow");

%% Part2: larger motions
im1 = rgb2gray(im2double(imread('/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/Juggle/0.png')));
im2 = rgb2gray(im2double(imread('/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/Juggle/1.png')));


%% Perform optical flows
[m,n] = size(im1);
lambda = 0.01; % needs to be set per image
maxMotion = 16;
reduceFactor = .5;
verbose = true;
tic;
[u_hs, v_hs] = hs_opticalFlow(im1, im2, zeros(m,n), zeros(m,n), lambda, verbose);
toc; tic;
% [u_warp, v_warp] = opticalFlowHSWarp(im1, im2, zeros(m,n), zeros(m,n), lambda);
% toc; tic;
[u_pyr, v_pyr] = pyrhs_opticalFlow(im1, im2, lambda, maxMotion, reduceFactor, verbose);
toc;

flowHS = cat(3, u_hs, v_hs);
% flowWarp = cat(3, u_warp, v_warp);
flowPyr = cat(3, u_pyr, v_pyr);

%% Evaluation 
% Error metrics
% aeps = [ computeAEP(flowHS, flowGT), computeAEP(flowWarp, flowGT), computeAEP(flowPyr, flowGT) ];
% aaes = [ computeAAE(flowHS, flowGT), computeAAE(flowWarp, flowGT), computeAAE(flowPyr, flowGT) ];

% figure; scatter(1:3, aeps); title('avg. endpoint errors');
% figure; scatter(1:3, aaes); title('avg. angle errors');

% Estimated images and color coding
% Warp im1 using u,v in a backwards fashion
est_hs = warpFW(im1, u_hs, v_hs);
% est_warp = warpFW(im1, u_warp, v_warp);
est_pyr = warpFW(im1, u_pyr, v_pyr);

color_hs = computeColor(u_hs, v_hs);
% color_warp = computeColor(u_warp, v_warp);
color_pyr = computeColor(u_pyr, v_pyr);

figure;imshowpair(est_hs, im2); title('est-hs vs. im2');
% figure;imshowpair(est_warp, im2); title('est-warp vs. im2');
figure;imshowpair(est_pyr, im2); title('est-pyr vs. im2');

% figure; imshowpair(im2, estimated); title(sprintf("im2 and estimated, lambda: %.4f", lambda)); 
figure; imshow(color_hs); title(sprintf("hs, lambda: %.4f", lambda));
% figure; imshow(color_warp); title(sprintf("hs+warp lambda: %.4f", lambda));
figure; imshow(color_pyr); title(sprintf("hs+warp+pyr lambda: %.4f", lambda));

% figure; imshowpair(im2, im1); title(sprintf("im2 and im1, lambda: %.4f", lambda)); 