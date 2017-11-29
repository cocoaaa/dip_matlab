clc; clear all; close all;
setupMammo;

b1 = imread('b1.png');
b2 = imread('b2.png');
b3 = imread('b3.png');
B = [b1, b2, b3];

figure;imagesc(B, [0,255]); colormap(gray);title('breast 1,2,3');
figure;imagesc(B, [0,255]); title('breast 1,2,3 in color');

%% Anisotropic diffusion for edge-preserving smoothing

n_iter = 2; %how to decide this number? 
%is there a relationship between niter and sigma in Gaussian blurring?
delta_t = 1/7;
kappa = 70;
option = 1;
[height,width] = size(b1);

im1 = anisodiff2D( b1, n_iter, delta_t, kappa, option);
im2 = anisodiff2D( b2, n_iter, delta_t, kappa, option);
im3 = anisodiff2D( b3, n_iter, delta_t, kappa, option);

% IMPORTANT: ALL images are of data type double in range [0,255]
% change all to single to use vl_sift
im1 = single(im1); im2 = single(im2); im3 = single(im3);

%% Delaunay triangulation
[height,width] = size(im1);
[X,Y] = meshgrid(1:width, 1:height);
tri = delaunay(X(:), Y(:),double(im1(:)));
figure; trisurf(tri, X,Y,im1(:)); title('trimesh of b1');

%% FFT without windowing
F = fft2(im1);
figure;imshow(log(abs(fftshift(F))+1), [])
title('fft on im1 w/o windowing');

%% FFT with windowing
% ref: https://blogs.mathworks.com/steve/2009/12/04/fourier-transform-visualization-using-windowing/
wy  = cos(linspace(-pi/2, pi/2, height));
wx = cos(linspace(-pi/2, pi/2, width));
w = wy' * wx;
f2 = im2uint8(im2single(im1) .* w);
figure; imshow(f2);
F2 = fft2(f2);
figure;
imshow(log(abs(fftshift(F2)) + 1), []);
title('fft with windowing');

%% Filters
% boxFilter = 1/9*ones(3);
gaussFilter = 1/16*[1 2 1; 2 4 2; 1 2 1];
laplaceFilter = 1/16*[-1 -1 -1; -1 8 -1; -1 -1 -1];
% highpass = 1/17*[-1 -1 -1; -1 9 -1; -1 -1 -1];

im1_lp = conv2(double(im1), gaussFilter, 'same');
im1_lp = linScale(im1_lp, min(im1(:)), max(im1(:)));

im1_hp = conv2(double(im1), laplaceFilter, 'same');
im1_hp = linScale(im1_hp, min(im1(:)), max(im1(:)));
figure; imshow( [im1, im1_lp], []); title('original and lp convolved'); 
figure; imshow( [im1, im1_hp], []); title('original and hp convolved'); 

%%
flp = im1_lp.* w;
Flp = fft2(flp);
figure;imshow(log(abs(fftshift(Flp)) + 1), []); title('lp fft');

fhp = im1_hp.* w;
Fhp = fft2(fhp);
figure;imshow(log(abs(fftshift(Fhp)) + 1), []); title('hp fft');





