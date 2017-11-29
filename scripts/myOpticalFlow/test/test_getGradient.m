% test getGradients
addpath('../../../figs');
addpath('..');
im1 = single(imread('../../../figs/mammo/b1_blurred.png'));
im2 = single(imread('../../../figs/mammo/b2_blurred.png'));

% % anisotropic smoothing
% n_iter = 3; %how to decide this number? 
% delta_t = 1/7;
% kappa = 10;
% option = 1;
% 
% im1 = anisodiff2D( im1, n_iter, delta_t, kappa, option);
% im2 = anisodiff2D( im2, n_iter, delta_t, kappa, option);

[Ix, Iy, It] = getGradients(im1, im2);
figure;
imshow([Ix, Iy, It], []);
title('Ix, Iy, It');

