% playground
% experiment1: small translation by +1 pixel in x direction
im1 = zeros(30,50);
im1(10:20, 10:30) = 1;

% +1 in x direction
im2 = zeros(30,50);
im2(10:20, 11:31) = 1;

% exp2: small translation +1, +1 in both x and y direction
% im2 = zeros(30,50);
% im2(11:21, 11:31) = 1;

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

lambdas = [0.01, 0.3, 1.2, 30]%, 0.3 0.6 0.9 1.2 10];
diffs = zeros(1, length(lambdas));
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