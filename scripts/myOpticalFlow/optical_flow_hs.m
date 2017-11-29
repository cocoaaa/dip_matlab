function estimated = opticalFlowHS(im1, im2, toSimulate)
% Horn-Schunck Optical Flow
% im1 is the one being moved to become as close to im2 as possible
if (nargin == 2); toSimulate=false; end
    
im1 = im2double(im1);
im2 = im2double(im2);

[m,n] = size(im1);
nPixels = m*n;
figure; imshowpair(im1, im2);
title("original images");

%% Preprocessing
n_iter = 3; %how to decide this number? 
%is there a relationship between niter and sigma in Gaussian blurring?
delta_t = 1/7;
kappa = 10;
option = 1;

im1 = anisodiff2D( im1, n_iter, delta_t, kappa, option);
im2 = anisodiff2D( im2, n_iter, delta_t, kappa, option);

figure;
imshowpair(im1, im2, 'montage');
title("after anisotropic diffusion blurring");

% IMPORTANT: ALL images are of data type DOUBLE in range [0,255]

%% Get gradients
% [Ix, Iy] = imgradientxy(im1); % can't use it because tot. energy must
% stay const which is not the way imgradientxy applied the sobel filter.

[Ix, Iy, It] = getGradients(im1, im2); 

figure;imshow([Ix, Iy, It],[]);title('Ix, Iy, It');

%% Iterative: using update method in HS paper
lambda = 0.5;
maxIter = 1000;
tol = 1e-2;
laplacian_filter = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12 ];
u_curr = zeros(m,n); % u0
v_curr = zeros(m,n); % v0
u_curr_avg = zeros(m,n);
v_curr_avg = zeros(m,n);

diff = Inf;
iter = 1;
fRatio = figure;
fShowU = figure;
fShowV = figure;
fHistU = figure;
fHistV = figure;

while( iter < maxIter )
    if (diff < tol); break; end
    
    top = Ix.*u_curr_avg + Iy.*v_curr_avg + It;
    bottom = lambda + Ix.^2 + Iy.^2;
    ratio = top./bottom;

    u_next = u_curr_avg - (Ix.*ratio);
    v_next = v_curr_avg - (Iy.*ratio);
    
    diff_u = norm(u_next - u_curr, 'fro')/norm(u_next, 'fro'); 
    diff_v = norm(v_next - v_curr, 'fro')/norm(v_next, 'fro');
    diff = diff_u + diff_v;
    
    % update for the next iteration
    u_curr = u_next;
    v_curr = v_next;
    u_curr_avg = imfilter(u_curr, laplacian_filter, 'replicate', 'same') ;
    v_curr_avg = imfilter(v_curr, laplacian_filter, 'replicate', 'same');
    iter = iter + 1;
    
    % debug
    if (iter ==2 || toSimulate)
        fprintf("diff: %d\n", diff);
        fprintf("max val of ratio: %d\n", max(ratio(:)));
        fprintf("min val of ratio: %d\n", min(ratio(:)));
        fprintf("avg val of ratio: %d\n", mean(ratio(:)));    
        fprintf("range of u,v: %d, %d\n", range(u_curr(:)), range(v_curr(:)));

        set(0, 'CurrentFigure', fRatio);
        imshow(ratio,[]); title("ratio");

        set(0, 'CurrentFigure', fShowU);
        imshow(u_curr,[]);  title("u");
        set(0, 'CurrentFigure', fHistU);
        hist(u_curr); title("hist U");

        set(0, 'CurrentFigure', fShowV);
        imshow(v_curr,[]); title("v");
        set(0, 'CurrentFigure', fHistV);
        hist(v_curr); title("hist V");
    end
    
end

fprintf("---Iterative method ended after %d,w with diff %3f", iter, diff);
figure;
imshowpair(u_curr, v_curr, 'montage'); title('u and v iterative soln');
%% Warp im1 using u,v in a backwards fashion

estimated = warpFW(im1, u_curr, v_curr);
figure;
imshow([im1, estimated, im2]); 
title("im1, estimated, im2"); 

end


