% main
function [im1, im2] = preprocessOF(im1, im2)
% Applies anisodiffusion on im1 and im2.
% Returns in double-precision in range of [0, 255]
addpath('/Local/Users/hjsong/Playground/dip_matlab/scripts/anisodiff_Perona-Malik');
im1 = im2double(im1);
im2 = im2double(im2);

figure; imshowpair(im1, im2);
title("original images");

%% Preprocessing
n_iter = 3; %how to decide this number? 
%is there a relationship between niter and sigma in Gaussian blurring?
delta_t = 1/7;
kappa = 10;
option = 1;

im1 = anisodiff2D( im1, n_iter, delta_t, kappa, option);
im2 = anisodiff2D( im2, n_iter, delta_t, kappa, option);

figure;
imshowpair(im1, im2);
title("after anisotropic diffusion blurring");

% IMPORTANT: ALL images are of data type DOUBLE in range [0,255]
end

