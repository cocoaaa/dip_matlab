%simple optical flow test 
%% Create 1D function images
x = 0:0.1:2*pi;
% im1 = sin(x);
% im2 = sin(x+pi/3);
figure;
plot(x, im1, 'r');
% hold on;
% plot(x, im2, 'b');
% imwrite(im1, '../figs/sine1.png');
% imwrite(im2, '../figs/sine2.png');

%%
src = im2double(imread('../figs/sine_src.png'));
target = im2double(imread('../figs/sine_target.png'));
figure;
imshowpair(src, target);
title('originals w/ groundtruth translation of pi/3');
%% LK optical flow
estimated = LKflow(src, target,1,10);
figure;imshowpair(src, estimated); title('src and estimation');


%% Compare with MATLAB built-in function 
