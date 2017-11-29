%% Gaussian pyramid
% At each iteration, convolve the previous level's image with the kernel 
% and downsample by 1/2 in both x and y direction 
% The first level contains the original image, and the last level contains
% the smallest(coarst) image.
% \begin{displaymath}

function gPyramid = gaussPyramid(im, a)
% a: parameter that controls the five-tap kernel [.25-.5*a .25 a .25 .25-.5*a] 
% nLevel: number of pyramid levels
    im = im2double(im);
    if ~exist('a', 'var') ||  isempty(a)
        a = 0.4;
    end

    gkernel = [.25-.5*a .25 a .25 .25-.5*a];
    [m,n] = size(im);
    minDim = min(m,n);
    nLevel = floor(log2(minDim));
    gPyramid{1} = im;
    for i = 2:nLevel
        im_filtered = conv2(gPyramid{i-1}, gkernel, 'same');
        im_filtered = conv2(im_filtered, gkernel', 'same');
        gPyramid{i} = subsampleByHalf(im_filtered);
    end
end