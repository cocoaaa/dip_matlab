% experiement on middlebury dataset
% playground
% experiment1: small translation by +1 pixel in x direction
close all;
clear all;
addpath('../');
addpath('/Local/Users/hjsong/Playground/dip_matlab/scripts/utils');
imgDir='/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/other-data-gray/';
gtDir = '/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/other-gt-flow/';

im1 = im2double(imread(strcat(imgDir, 'RubberWhale/frame10.png')));
im2 = im2double(imread(strcat(imgDir, 'RubberWhale/frame11.png')));
flowGT = readFlowFile(strcat(gtDir, 'RubberWhale/flow10.flo'));
% figure; imshowpair(im1, im2); title("original im1 and im2");
figure; imshowpair(flowGT(:,:,1), flowGT(:,:,2), 'montage'); title("ground truth flow");
figure; imshow(computeColor( flowGT(:,:,1), flowGT(:,:,2) )); title("ground truth flow");
%% Get gradients
% [Ix, Iy] = imgradientxy(im1); % can't use it because tot. energy must
% stay const which is not the way imgradientxy applied the sobel filter.
[m,n] = size(im1);

[Ix, Iy, It] = getGradients(im1, im2);

figure;imshow([Ix, Iy, It],[]);title('Ix, Iy, It');

% Iterative: using update method in HS paper
% fixed parameters
maxIter = 5000;
tol = 1e-3;
toSimulate = false;
laplacian_filter = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12 ];

lambdas = [1e-4, 1.5e-4, 0.001, 0.005, 0.01, 0.05, 0.1];
% smallest aae and aep are achieved with lambda 0.001

aaes = zeros(1, length(lambdas));
aeps = zeros(1, length(lambdas));

for li=1:length(lambdas)
    lambda = lambdas(li);

    u_curr = zeros(m,n); % u0
    v_curr = zeros(m,n); % v0
    u_curr_avg = zeros(m,n);
    v_curr_avg = zeros(m,n);

    diff = Inf;
    iter = 1;
    
    if (toSimulate)
    fRatio = figure; fShowU = figure; fShowV = figure; 
    fHistU = figure; fHistV = figure;
    end
    
    while( iter < maxIter )
        if (diff < tol); break; end

        top = Ix.*u_curr_avg + Iy.*v_curr_avg + It;
        bottom = lambda + Ix.^2 + Iy.^2; %division by zero can occur if labmda = 0, and no gradient
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
        u_curr_avg = imfilter(u_curr, laplacian_filter, 'replicate', 'same', 'conv') ;
        v_curr_avg = imfilter(v_curr, laplacian_filter, 'replicate', 'same', 'conv');
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
            imshow(u_curr,[]);  title(sprintf("u, iter %d, lambda: %.4f", iter, lambda));
            set(0, 'CurrentFigure', fHistU);
            hist(u_curr); title("hist U");

            set(0, 'CurrentFigure', fShowV);
            imshow(v_curr,[]); title(sprintf("v, iter %d, lambda: %.4f", iter, lambda));
            set(0, 'CurrentFigure', fHistV);
            hist(v_curr); title("hist V");
        end
    end
    
%     figure; imshowpair(u_curr, v_curr, 'montage'); title(sprintf('u and v soln, lambda: %.4f', lambda));
    fprintf("---Iterative method ended after %d, diff %.4f\n", iter, diff);
    fprintf("\t lambda: %.4f\n", lambda);
    
    % compute errors
    flow = cat(3, u_curr, v_curr);
    aaes(li) = computeAAE(flow, flowGT);
    aeps(li) = computeAEP(flow, flowGT);

    % Warp im1 using u,v in a backwards fashion
    estimated = warpFW(im1, u_curr, v_curr);
    estimated_color = computeColor(u_curr, v_curr);

%     figure; imshowpair(im2, estimated); title(sprintf("im2 and estimated, lambda: %.4f", lambda)); 
    figure; imshow(estimated_color); title(sprintf("flow estimation lambda: %.4f", lambda));
%     figure; imshowpair(im2, im1); title(sprintf("im2 and im1, lambda: %.4f", lambda)); 
end
figure;scatter(lambdas, aaes); title('avg angular error vs. lambda');
figure;scatter(lambdas, aeps); title('avg endpoint error vs. lambda');