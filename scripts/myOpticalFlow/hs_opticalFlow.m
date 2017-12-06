function [u_est, v_est] = hs_opticalFlow(im1, im2, u0, v0, lambda, verbose)
%% Get gradients
% [Ix, Iy] = imgradientxy(im1); % can't use it because tot. energy must
% stay const which is not the way imgradientxy applied the sobel filter.
[m,n] = size(im1);
[Ix, Iy, It] = getHSGradients(im1, im2); % computing gradient takes way too long
if verbose
  figure;imshow([Ix, Iy, It],[]);title('Ix, Iy, It');
end
% Iterative: using update method in HS paper
% fixed parameters
maxIter = 5000;
tol = 1e-3;
laplacian_filter = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12 ];
% constant terms 
bottom = lambda^2 + Ix.^2 + Iy.^2; %division by zero can occur if labmda = 0, and no gradient

u_curr = u0;
v_curr = v0;
diff = Inf;
iter = 1;
% solve the linear system 
while( iter < maxIter )
    if (diff < tol); break; end
    
    u_curr_avg = imfilter(u_curr, laplacian_filter, 'replicate', 'same', 'conv') ;
    v_curr_avg = imfilter(v_curr, laplacian_filter, 'replicate', 'same', 'conv');

    top = Ix.*u_curr_avg + Iy.*v_curr_avg + It;
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
    iter = iter + 1;
end
u_est = u_curr; 
v_est = v_curr;
fprintf("---Iterative method ended after %d, diff %.4f\n", iter, diff);
fprintf("\t lambda: %.4f\n", lambda);

if verbose
  % Warp im1 using u,v towawrds im2 using interpolation
  estimated = warpFW(im1, u_est, v_est);
  estimated_color = computeColor(u_est, v_est);
  figure; imshow(estimated_color); title(sprintf("flow estimation lambda: %.4f", lambda));
  figure; imshowpair(estimated, im2); title(sprintf("estimaed and im2, lambda: %.4f", lambda));
end

end

