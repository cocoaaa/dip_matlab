% test kmeans2D
run('setPathForTests.m');
% im = imread('../../figs/opticalFlow/toy-car-images-bw/toy_formatted2.png');
im1 = im2double(imread('../../figs/mammo/b1.png'));
im2 = im2double(imread('../../figs/mammo/b2.png'));
im3 = im2double(imread('../../figs/mammo/b3.png'));

figure;imshow(im2); title('original');

%% Set the parameters
K = 2;
maxIter = 100;
tol = 1e-3;

%% Run clustering
% lambda = weight on spatial information 
im = im1;
lambdas = [0, 0.0003, 0.0006, 0.001, 0.003];%, 0.01, 0.1] ;
for i = 1:length(lambdas)
  lambda = lambdas(i);
  [labelsIm,clusterIm] = kmeans_spatial(im, K, lambda, maxIter, tol, "manual");
  figure;imshow([im, clusterIm],[]); title(sprintf('clustered, labmda %.4f', lambda));
end

% good lambdas (with manual centers selected)
% im1: 0.003
% im2: 0.00   - hard to tell whether spatial information is helping
% im3: 0.001 




%% 
for k = 4:2:10
  [~,clusterIm] = kmeans_spatial(im, k, lambda, maxIter, tol, "random");
  figure;imshow([im, clusterIm],[]); title(sprintf('clustered,K=%d, lambda %.4f',k, lambda));
end