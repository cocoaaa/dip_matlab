% experiment1: simple translation by +1 pixel in x direction
im1 = zeros(10,100);
im1(:, 1:20) = 1;

im2 = zeros(10,100);
im2(:, 2:21) = 1;

estimated = opticalFlowHS(im1, im2);
%check estimates(:,21)
estimated(:,21);
% [im1, im2] = preprocessOF(im1, im2);
