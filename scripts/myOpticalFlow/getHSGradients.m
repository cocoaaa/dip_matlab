
function [Ix, Iy, It] = getHSGradients(im1, im2)
% computes Ix, Iy, It from im1 and im2 as described in HS paper
addpath('/Local/Users/hjsong/Playground/dip_matlab/scripts/utils/');

[m,n] = size(im1);
[m2, n2] = size(im2);
if (m ~= m2 || n ~= n2)
    disp('InputError: two input images must be of same size');
    return;
end
Ix = nan(m,n);
Iy = nan(m,n);
It = nan(m,n);

for i=1:n
    for j=1:m
        Ix(j,i) = 0.25*(smartAccessor(im1, j, i+1) - smartAccessor(im1, j, i) ...
                         + smartAccessor(im1, j+1, i+1) - smartAccessor(im1, j+1, i) ...
                         + smartAccessor(im2, j, i+1) - smartAccessor(im2, j, i) ...
                         + smartAccessor(im2, j+1, i+1) - smartAccessor(im2, j+1, i));
                
        Iy(j,i) = 0.25*(smartAccessor(im1, j+1, i) - smartAccessor(im1, j, i) ...
                         + smartAccessor(im1, j+1, i+1) - smartAccessor(im1, j, i+1) ...
                         + smartAccessor(im2, j+1, i) - smartAccessor(im2, j, i) ...
                         + smartAccessor(im2, j+1, i+1) - smartAccessor(im2, j, i+1));
                     
        It(j,i) = 0.25*(smartAccessor(im2, j, i) - smartAccessor(im1, j, i) ...
                         + smartAccessor(im2, j, i+1) - smartAccessor(im1, j, i+1) ...
                         + smartAccessor(im2, j+1, i) - smartAccessor(im1, j+1, i) ...
                         + smartAccessor(im2, j+1, i+1) - smartAccessor(im1, j+1, i+1));
    end
end
    
end