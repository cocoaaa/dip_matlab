% test kmeans2D
run('setPathForTests.m');
% im = imread('../../figs/opticalFlow/toy-car-images-bw/toy_formatted2.png');
im1 = im2double(imread('../../figs/mammo/b1.png'));
im2 = im2double(imread('../../figs/mammo/b2.png'));
im3 = im2double(imread('../../figs/mammo/b3.png'));

figure;imshow(im); title('original');

%% Set the parameters
K = 2;
lambda = 0.01; % weight on spatial information
maxIter = 100;
tol = 1e-3;

%% Run clustering
% lambda = weight on spatial information 
lambdas = [0, 0.0001, 0.0003, 0.0006, 0.001, 0.003, 0.01, 0.1, 1];
for i = 1:length(lambdas)
  lambda = lambdas(i);
  binary = kmeans_spatial(im, K, lambda, maxIter, tol);
  figure;imshow([im,binary],[]); title(sprintf('clustered, labmda %.4f', lambda));
end