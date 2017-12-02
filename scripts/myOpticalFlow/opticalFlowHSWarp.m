function [u_curr,v_curr] = opticalFlowHSWarp(I1, I2, u0, v0)%, alpha, tol, maxIter, nWarps)
alpha = 15;
tol = 1e-4;
maxIter = 1000;
nWarps = 5;
laplacian = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12];

[I2x, I2y] = gradient(I2);

u_curr = u0; v_curr = v0;
for wi = 1:nWarps % warping idx
  
  warpedI2 = warpFW(I2, u_curr, v_curr); % Q: should this be a separate varialbe (that is do I use the original I2 or update I2 for warping in the next warping iteration. That is, is u_curr the total displacement(*) or incremental displacement.
  warpedI2x = warpFW(I2x, u_curr, v_curr);
  warpedI2y = warpFW(I2y, u_curr, v_curr);
  u_avg = imfilter(u_curr, laplacian, 'replicate', 'same', 'conv');
  v_avg = imfilter(v_curr, laplacian, 'replicate', 'same', 'conv');
  
  %% Fixed warpedI2, warpedI2x, warpedI2y
  % update until SOR converge to a reasonable solution u,v for this warping
  % stage
  innerIter = 1;
  ur_curr = u_curr; vr_curr = v_curr;
  while( innerIter < maxIter )
    if (diff_r < tol); break; end
    
    ur_avg = imfilter(ur_curr, laplacian, 'replicate', 'same', 'conv');
    vr_avg = imfilter(vr_curr, laplacian, 'replicate', 'same', 'conv');
    
    urBottom = warpedI2x.^2 + alpha^2;
    urTop = I1 - I2 + warpedI2x.*u_curr - warpedI2y.*(vr_curr - v_curr);
    urTop = urTop.*warpedI2x + (alpha*alpha.*ur_avg);
    ur_next = (1-w)*ur_curr + w*(urTop./urBottom); %check division by zeros 
  
    vrBottom = warpedI2y.^2 + alpha^2;
    vrTop = I1 - I2 - warpedI2x.*(ur_next - u_curr) + warpedI2y.*v_curr;
    vrTop = vrTop.*warpedI2y + (alpha*alpha.*vr_avg);
    vr_next = (1-w)*vr_curr + w*(vrTop./vrBottom); %check division by zeros

    dUr = norm(ur_next-ur_curr, 'fro');
    dVr = norm(vr_next-vr_curr, 'fro');
    diff_r = (dUr^2 + dVr^2)/(m*n);

    % update for the next iteration
    ur_curr = ur_next;
    vr_curr = vr_next;
    innerIter = innerIter + 1;
  end
  % END OF SOR
  
  %% update for the next warping iteration
  u_curr = ur_curr;
  v_curr = vr_curr;
 
end

end


