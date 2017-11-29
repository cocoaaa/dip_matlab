%% Demon's algorithm [Thirion 1998]
% M: moving image
% S: fixed image/ target
% U: displacement field on S
% Gs: gradient field on S

%% image preprocessing: read, crop, save to new files
addpath('/Local/Users/hjsong/Playground/dip_matlab/');
addpath('/Local/Users/hjsong/Playground/scripts/');
% addpath('./anisodiff_Perona-Malik/');

M1 = imread('../figs/breast1.png');
M1 = M1(:, 1:250);

F = imread('../figs/breast2.png');
F = F(:, 1:250);

M2 = imread('../figs/breast3.png');
M2 = M2(1:463, 1:250);
% remove logo from M2
logo = M2(1:50,125:end);
M2(1:50, 125:end) = 0;

imstack = cat(3, M1, F, M2);
imconcat = cat(2, M1, F, M2);
figure; imshow(imconcat); title("unregistered");
%% Preprocessing
close all;
n_iter = 3; %how to decide this number? 
%is there a relationship between niter and sigma in Gaussian blurring?
delta_t = 1/7;
kappa = 30;
option = 1;
[h,w] = size(M1);

blurred_stack = zeros(h,w,3);
for i=1:3
    blurred_stack(:,:,i) = anisodiff2D( imstack(:,:,i), n_iter, delta_t, kappa, option);
end 

figure;
imshow( cat(2, cat(2, blurred_stack(:,:,1), blurred_stack(:,:,2)), blurred_stack(:,:,3) ), [] );
title("blurred m1, f, m2");

% match histogram of M1 and M2 to F's histogram
% M1 = imhistmatch(M1, F); %imhistmatch assumes if double, in range [0,1]. not suitable after anisotropic smoothing
% M2 = imhistmatch(M2, F);

% IMPORTANT: ALL images are of data type DOUBLE in range [0,255]
%% Apply demon's algorithm 
maxIter = 0;
precision = 0.001; %rms?
deformed = demons(M1, F, maxIter, precision);
