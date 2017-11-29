%% Lukas-Kanade Optical Flow
% close all;
% im1 = imread('../figs/b1.png');
% im2 = imread('../figs/b2.png');
% function [] = optical_flow_LK(src, target, kernel_size)
% close all;
% src = im2double(imread('../figs/half_walking_frame07.png'));
% target = im2double( imread('../figs/half_walking_frame09.png') );
function estimated = LKflow(src, target, wsize, maxIter)
% LK neighborhood of (2*wsize+1) by (2*wsize+1)

% src = im2double(imread('../figs/b2.png'));
% target = im2double( imread('../figs/b3.png') );
% kernel_size = 50;

[m,n] = size(src);
nPixels = m*n;
figure; imshowpair(src, target);
title("original images");

%% Preprocessing
n_iter = 3; %how to decide this number? 
%is there a relationship between niter and sigma in Gaussian blurring?
delta_t = 1/7;
kappa = 10;
option = 1;
[h,w] = size(src);

src = anisodiff2D( src, n_iter, delta_t, kappa, option);
target = anisodiff2D( target, n_iter, delta_t, kappa, option);

% figure;
% imshowpair(src, target, 'montage');
% title("after anisotropic diffusion blurring");

% IMPORTANT: ALL images are of data type DOUBLE in range [0,255]
d_kernel = [0.5 -0.5];
% d_kernel = (1/12)*[-1 8 0 -8 1]; *brb kernel\
% gKernel = gauss_kernel(2*wsize+1); %[1/16 1/8 1/16; 1/8 1/4 1/8; 1/16 1/8 1/16];
gKernel = [1/16 1/8 1/16; 1/8 1/4 1/8; 1/16 1/8 1/16];
U = zeros(m,n);
V = zeros(m,n);
for iter=1:maxIter
    %% Get gradients
    % [Ix, Iy] = imgradientxy(im1); % can't use it because tot. energy must
    % stay const which is not the way imgradientxy applied the sobel filter.

    Ix = conv2(src, d_kernel, 'same');
    Iy = conv2(src, d_kernel', 'same');
    It = target - src;

%     figure;
%     imshowpair(Ix, Iy, 'montage');
%     title('Gradients of im1');
% 
%     figure;
%     imshow(It,[]); title('time gradient');

    %% Use Gaussian as the weight within the window
    % Solve A'WAx = A'Wb where W_ii = wi to be assigned to the equation of 
    % pixel q_i in the window of point p, w(p).
    % W will be taken care of by convolving the Ix.^2, Ix.*Iy, Iy.^2, Ix.*It,
    % Iy.*It matrices with nxn gaussian kernel.
    WIx2 = conv2(Ix.*Ix, gKernel, 'same');
    WIy2 = conv2(Iy.*Iy, gKernel, 'same');
    WIxIy = conv2(Ix.*Iy, gKernel, 'same');
    WIxIt = conv2(Ix.*It, gKernel, 'same');
    WIyIt = conv2(Iy.*It, gKernel, 'same');

    dU = zeros(h,w);
    dV = zeros(h,w);

    for c = 1:w
        for r = 1:h
            x = pinv([WIx2(r,c) WIy2(r,c); WIxIy(r,c) WIy2(r,c)]) * [-WIxIt(r,c);-WIyIt(r,c)];
            dU(r,c) = x(1);
            dV(r,c) = x(2);
        end
    end

    % Q: why is this better?
    dU = conv2(dU, gKernel, 'same');
    dV = conv2(dV, gKernel, 'same');
    dU = cutAtNStd(dU,2); dV = cutAtNStd(dV,2);
    figure;imshowpair(dU, dV, 'montage');title('U,V with 2*std cutoff');
    %warp src using dU and dV
    warped = warp(src, dU, dV);

    figure;
    imshowpair(src, warped); 
    title(sprintf('after %d iter', iter));

    figure;
    imshow(dU,[]);
    title(sprintf('U; wsize,iter = %d,%d', wsize, iter));

    figure;
    imshow(dV,[]);
    title(sprintf('V; wsize,iter = %d,%d', wsize,iter));

    U = U + dU;
    V = V + dV;
    src = warped;

end

estimated = src;
end