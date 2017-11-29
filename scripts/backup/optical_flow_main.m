% close all;
for n_iter = 1:5:100

im1 = im2double(imread('../figs/b2.png'));
im2 = im2double(imread('../figs/b3.png'));

% im1 = im2double(imread('../figs/half_walking_frame07.png'));
% im2 = im2double(imread('../figs/half_walking_frame09.png'));

% estimated = optical_flow_hs(im1, im2);
%% Preprocessing

% n_iter = 2; %how to decide this number? 
%is there a relationship between niter and sigma in Gaussian blurring?
delta_t = 1/7;
kappa = 70;
option = 1;
[h,w] = size(im1);

im1 = anisodiff2D( im1, n_iter, delta_t, kappa, option);
im2 = anisodiff2D( im2, n_iter, delta_t, kappa, option);

% figure;
% imshowpair(im1, im2, 'montage');
% title(sprintf("after anisotropic diffusion, nIter=%d, k=%d",n_iter, kappa));

% IMPORTANT: ALL images are of data type DOUBLE in range [0,255]
%% Extract boundary

[m,n] = size(im1);

[gx1, gy1] = imgradientxy(im1);
[gx2, gy2] = imgradientxy(im2);

gx1 = abs(gx1);
gx2 = abs(gx2);

mask = false(m,n);
mask(:,end-10:end) = true;
% mask(100:end,1:50) = true;

% Get boundaries from the gradientx images
bd1 = activecontour(gx1, mask, 100, 'Chan-Vese');
bd2 = activecontour(gx2, mask, 100, 'Chan-Vese');

if (n_iter == 1 || n_iter == 6 || n_iter == 12 || n_iter == 96)
    %show mask
    figure;imshow(im1); hold on;
    % visboundaries(mask,'Color','b'); %initial contour
    visboundaries(bd1,'Color','r'); title(sprintf("im1 and bd1, nIter=%d, k=%d", n_iter, kappa));

    figure;imshow(im2); hold on;
    visboundaries(bd2,'Color','g'); title(sprintf("im2 and bd2, nIter=%d, k=%d", n_iter, kappa));
end 

end
%% Run optical flow on the boundary images
