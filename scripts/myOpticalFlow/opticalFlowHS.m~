function estimated = opticalFlowHS(im1, im2, lambda, maxIter, tol, toSimulate)
% Horn-Schunck Optical Flow
% im1: moving image to become as close to im2 as possible
% lambda: regularizer weight
% maxIter: max number of iterations to solve a sparse matrix Au = b
%           Defaulted to 1000
% tol: normalized difference of the difference between two consecutive u
%       and v fields in terms of forbineus norm. Default to 1e-2
% toSimulate: creates window simulation for u, v, histU and histV to keep
%           track of their evolution over iterations
% 
if ~exist('lambda', 'var') || isempty(lambda)
    lambda = 0.5;
end

if ~exist('maxIter', 'var') || isempty(maxIter)
    maxIter = 1000;
end

if ~exist('tol', 'var') || isempty(tol)
    tol = 1e-2;
end


if ~exist('toSimulate', 'var') || isempty(toSimulate)
    toSimulate = false;
end

str = 'false';
if (toSimulate); str='true'; end
fprintf("---\nlambda: %.3f, maxIter: %d, tol: %.3f, toSimulate: %s\n", lambda, maxIter, tol, str);
%% Load images as double 
    
% im1 = im2double(im1);
% im2 = im2double(im2);
% 
% [m,n] = size(im1);
% figure; imshowpair(im1, im2);
% title("original images");
% 
% %% Preprocessing
% n_iter = 3; %how to decide this number? 
% %is there a relationship between niter and sigma in Gaussian blurring?
% delta_t = 1/7;
% kappa = 10;
% option = 1;
% 
% im1 = anisodiff2D( im1, n_iter, delta_t, kappa, option);
% im2 = anisodiff2D( im2, n_iter, delta_t, kappa, option);
% 
% figure;
% imshowpair(im1, im2, 'montage');
% title("after anisotropic diffusion blurring");
% 
% % IMPORTANT: ALL images are of data type DOUBLE in range [0,255]

%% Get gradients
% [Ix, Iy] = imgradientxy(im1); % can't use it because tot. energy must
% stay const which is not the way imgradientxy applied the sobel filter.
[m,n] = size(im1);

[Ix, Iy, It] = getGradients(im1, im2); 

figure;imshow([Ix, Iy, It],[]);title('Ix, Iy, It');

% Iterative: using update method in HS paper
% fixed parameters
maxIter = 1000;
tol = 1e-2;
toSimulate = false;
laplacian_filter = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12 ];

lambdas = [0];% 0.3 0.6 0.9 1.2 10];
diffs = zeros(1, length(lambdas));
for li=1:length(lambdas)
    lambda = lambdas(li);

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

        normU = norm(u_next, 'fro');
        normV = norm(v_next, 'fro');
        if(abs(normU) < 1e-6); normU=1; end
        if(abs(normV) < 1e-6); normV=1; end
        diff_u = norm(u_next - u_curr, 'fro')/normU; 
        diff_v = norm(v_next - v_curr, 'fro')/normV;
        diff = diff_u + diff_v;

        % update for the next iteration
        u_curr = u_next;
        v_curr = v_next;
        u_curr_avg = imfilter(u_curr, laplacian_filter, 'replicate', 'same') ;
        v_curr_avg = imfilter(v_curr, laplacian_filter, 'replicate', 'same');
        iter = iter + 1;

        % debug
%         if (iter == 2 || toSimulate)
        if (toSimulate)
            fprintf("---\niter: %d\n", iter);
            fprintf("diff: %d\n", diff);
            fprintf("max val of ratio: %d\n", max(ratio(:)));
            fprintf("min val of ratio: %d\n", min(ratio(:)));
            fprintf("avg val of ratio: %d\n", mean(ratio(:)));    
            fprintf("range of u,v: %d, %d\n", range(u_curr(:)), range(v_curr(:)));

            set(0, 'CurrentFigure', fRatio);
            imshow(ratio,[]); title("ratio");

            set(0, 'CurrentFigure', fShowU);
            imshow(u_curr,[]);  title(sprintf("u, iter %d, lambda: %.3f", iter, lambda));
            set(0, 'CurrentFigure', fHistU);
            hist(u_curr); title("hist U");

            set(0, 'CurrentFigure', fShowV);
            imshow(v_curr,[]); title(sprintf("v, iter %d, lambda: %.3f", iter, lambda));
            set(0, 'CurrentFigure', fHistV);
            hist(v_curr); title("hist V");
        end
    end
    diffs(li) = diff;
    figure; imshowpair(u_curr, v_curr, 'montage'); title(sprintf('u and v soln, lambda: %.3f', lambda));
    fprintf("---Iterative method ended after %d, diff %.3f\n", iter, diff);
    fprintf("\t lambda: %.3f\n", lambda);

    % Warp im1 using u,v in a backwards fashion
    estimated = warpFW(im1, u_curr, v_curr);
    figure; imshowpair(im2, estimated); title(sprintf("im2 and estimated, lambda: %.3f", lambda)); 
%     figure; imshowpair(im2, im1); title(sprintf("im2 and im1, lambda: %.3f", lambda)); 
end

end


