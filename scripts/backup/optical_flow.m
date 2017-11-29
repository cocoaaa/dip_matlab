%% Horn Optical Flow
% close all;
im1 = imread('../figs/b1.png');
im2 = imread('../figs/b2.png');

% % im1 = imread('../figs/half_walking_frame07.png');
% im2 = imread('../figs/half_walking_frame09.png');
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
[h,w] = size(im1);

im1 = anisodiff2D( im1, n_iter, delta_t, kappa, option);
im2 = anisodiff2D( im2, n_iter, delta_t, kappa, option);

figure;
imshowpair(im1, im2, 'montage');
title("after anisotropic diffusion blurring");

% IMPORTANT: ALL images are of data type DOUBLE in range [0,255]

%% Get gradients
% close all;
deriv_filter = [0.5 -0.5];
brb_kernel = (1/12)*[-1 8 0 -8 1];

% [Ix, Iy] = imgradientxy(im1); % can't use it because tot. energy must
% stay const which is not the way imgradientxy applied the sobel filter.

Ix = conv2(im1, brb_kernel, 'same');
Iy = conv2(im1, brb_kernel', 'same');

figure;
imshowpair(Ix, Iy, 'montage');
title('Gradients of im1');


figure;
imshow(It,[]); title('time gradient');

% vectorize Ix, Iy, It
vecIx = imToColmvec(Ix);
vecIy = imToColmvec(Iy);
vecIt = imToColmvec(It);

% %% Initial guess
% U = zeros(h,w);
% V = zeros(h,w);
% imshowpair(U,V, 'montage');

%% Build tripletList
lambda = 0.5;
tripletList = NaN(nPixels*32, 3);
t = 1;

tic;
for pi=1:nPixels

    % diagnoal 
    % A pair of triplets from the first and second eqns
    tripletList(t,:) = [pi,pi,lambda + vecIx(pi)^2 + vecIy(pi)^2];
    t = t+1;
    tripletList(t,:) = [pi+nPixels, pi+nPixels,lambda + vecIx(pi)^2 + vecIy(pi)^2];
    t = t+1;
    
    % neighborhood
    [r,c] = twoDimIndex(pi,m,n);
    [adjs, diags] = getNeighbors(h,w,r,c);
    for ii=1:length(adjs)
        % first eqn
        tripletList(t,:) = [pi, adjs(ii), -(1./6)*(lambda + vecIy(pi)^2)];
        t = t+1;
        tripletList(t,:) = [pi, adjs(ii)+nPixels, (1./6)*vecIx(pi)*vecIy(pi)]; %for vi's neighbors
        t = t+1;
        
        % second eqn
        tripletList(t,:) = [pi+nPixels, adjs(ii), (1./6)*vecIx(pi)*vecIy(pi)];
        t = t+1;
        tripletList(t,:) = [pi+nPixels, adjs(ii)+nPixels, -(1./6)*(lambda + vecIx(pi)^2)]; %for vi's neighbors
        t = t+1;
        
    end
    
    for ii=1:length(diags)
        % first eqn
        tripletList(t,:) = [pi, adjs(ii), -(1./12)*(lambda + vecIy(pi)^2)];
        t = t+1;
        tripletList(t,:) = [pi, adjs(ii)+nPixels, (1./12)*Ix(pi)*vecIy(pi)];
        t = t+1;
        
        %second eqn
        tripletList(t,:) = [pi+nPixels, adjs(ii), (1./12)*Ix(pi)*vecIy(pi)];
        t = t+1;
        tripletList(t,:) = [pi+nPixels, adjs(ii)+nPixels, -(1./12)*(lambda + vecIx(pi)^2)]; %for vi's neighbors
        t = t+1;
        
    end 
end
disp("time building the problem matrix");
toc

%% Construct sparse matrix and b_rhs vector
spMat = sparse(tripletList(:,1), tripletList(:,2), tripletList(:,3));
assert(size(spMat,1) == size(spMat,2) && size(spMat,1) == 2*nPixels);
disp("Problem matrix is constructed");

figure;
spy(spMat); title("problem matrix");

% Construct b_rhs
b_rhs = [-vecIx.*vecIt; -vecIy.*vecIt];

%% Solve the problem using MATLAB's backslash for sparse matrix
tic
flow = spMat \ b_rhs;
disp("time spent solving the sparse matrix");
toc

u = vecToIm(flow(1:nPixels), m,n);
v = vecToIm(flow(nPixels+1:end),m,n);

figure;
imshowpair(u,v); title('u,v from MATLAB backslash for sparse');
% showFlow(u,v);

%% Alternative1: Iterative solution using Gauss-Seidel
tic
maxIter = 100;
tol = 1e-4;
x0 = zeros(2*nPixels, 1);
x = gauss_seidel(spMat, b_rhs, x0, maxIter);
u_gs = vecToIm(x(1:nPixels),m,n);
v_gs = vecToIm(x(nPixels:end),m,n);

figure;
imshowpair(u_gs, v_gs); title("gauss-seidel solution");
toc

%% Alternative2: Iterative: using update method in HS paper
maxIter = 1000;
tolerance = 1e-5;
laplacian_filter = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12 ];
u_curr = zeros(m,n); % u0
v_curr = zeros(m,n); % v0
u_curr_avg = zeros(m,n);
v_curr_avg = zeros(m,n);

diff_u = Inf(m,n);
diff_v = Inf(m,n);
iter = 1;
while ( any(diff_u(:) > tolerance) || any(diff_v(:) > tolerance))
    if (iter > maxIter)
        break;
    end
    
    ratio = (1./(lambda + Ix.^2.*Iy.^2)).*(Ix.*u_curr_avg + Iy.*v_curr_avg + It);
    u_next = u_curr_avg - (Ix.*ratio);
    v_next = v_curr_avg - (Iy.*ratio);
    
    diff_u = abs(u_next - u_curr); 
    diff_v = abs(v_next - v_curr);
    
    % update for the next iteration
    u_curr = u_next;
    v_curr = v_next;
    u_curr_avg = conv2(u_curr, laplacian_filter, 'same') ;
    v_curr_avg = conv2(v_curr, laplacian_filter, 'same');
    iter = iter + 1;
    
%     figure;
%     imshowpair(u_curr, v_curr, 'montage'); title('u and v iterative soln');
    
end

fprintf("---Iterative method ended after %d\n", iter);
figure;
imshowpair(u_curr, v_curr, 'montage'); title('u and v iterative soln');

%% Warp im1 using u,v in a backwards fashion

estimated = warp(im1, u, v);
figure;
imshowpair(im1, estimated); 
title("im1 and estimated image");

figure;
imshowpair(im2, estimated);
title("true im2 and estimated im2");






%% Evaluation 
% assuming 'cut' option 
newIndices = imToColmvec(round(getNewPixelIndices(u,v)));
estimated = zeros(nPixels,1);
vec1 = imToColmvec(im1);
% esimated(newIndices) = imToColmvec(im1);
for i=1:nPixels
    estimated(newIndices(i)) = vec1(i);
end

estimated = vecToIm(estimated, m,n);

figure;
imshowpair(im1, estimated, 'montage'); title('Horm-Schrunk estimation');

%% Compare with MATLAB built-in function 
opticFlow = opticalFlowHS;



