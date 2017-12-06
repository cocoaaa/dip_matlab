function [u_est,v_est] = opticalFlowHSWarp(I1, I2, u0, v0, lambda)%, alpha, tol, maxIter, nWarps)
% lambda = 15; %suggested from IPOL report
% w: relaxation parameter for SOR method in range of (0,2). Default 1.9
debug = true;
w = 1.9;
tol = 1e-4;
maxIter = 100;
nWarps = 1;
laplacian = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12];
lambdaSq = lambda*lambda;
[m,n] = size(I1);

[I2x, I2y] = gradient(I2); %central difference for non-boundary pixels and forward diff for bd pixels

u_curr = u0; v_curr = v0;
for wi = 1:nWarps % warping idx
  warpedI2 = warpFW(I2, u_curr, v_curr); % Q: should this be a separate varialbe (that is do I use the original I2 or update I2 for warping in the next warping iteration. That is, is u_curr the total displacement(*) or incremental displacement.
  warpedI2x = warpFW(I2x, u_curr, v_curr);
  warpedI2y = warpFW(I2y, u_curr, v_curr);
%   u_avg = imfilter(u_curr, laplacian, 'replicate', 'same', 'conv');
%   v_avg = imfilter(v_curr, laplacian, 'replicate', 'same', 'conv');
  
  %% Fixed warpedI2, warpedI2x, warpedI2y
  % update until SOR converges to a reasonable solution u,v for this warping
  % step
  urBottom = warpedI2x.^2 + lambdaSq;
  vrBottom = warpedI2y.^2 + lambdaSq;

  ur_curr = u_curr; vr_curr = v_curr;
  diff_r = Inf;
  for innerIter = 1: maxIter 
    if (diff_r < tol); break; end
    ur_avg = imfilter(ur_curr, laplacian, 'replicate', 'same', 'conv');
    vr_avg = imfilter(vr_curr, laplacian, 'replicate', 'same', 'conv');
    
    urTop1 = I1 - warpedI2 + warpedI2x.*u_curr - warpedI2y.*(vr_curr - v_curr);
    urTop = urTop1.*warpedI2x + (lambdaSq*ur_avg);
    ur_next = (1-w)*ur_curr + w*(urTop./urBottom); % check division by zeros (never as long as lambda is not super small or zero)
  
    vrTop1 = I1 - warpedI2 - warpedI2x.*(ur_next - u_curr) + warpedI2y.*v_curr;
    vrTop = vrTop1.*warpedI2y + (lambdaSq*vr_avg); % this becomes NaN
    vr_next = (1-w)*vr_curr + w*(vrTop./vrBottom); % check division by zeros (never as long as lambda is not super small or zero)
    
    % filter out out-of-bound movements
    notValid = ~(abs(ur_next) <= n & abs(vr_next) <= m); 
    if (debug && any(notValid(:)))
      fprintf("---SOR iter %d: out of bound count %d\n", ...
        innerIter, sum(notValid(:)) );
      fprintf("\t avg notValid displacement:%f, %f\n", ... 
        meanabs(ur_next(notValid)), meanabs(vr_next(notValid)) );
      dbstop in opticalFlowHSWarp at 56
    end
    ur_next(notValid) = 0; vr_next(notValid) = 0; %okay?%todo

    % compute difference
    diff_r = sqrt(norm(ur_next - ur_curr, 'fro')^2 + norm(vr_next - vr_curr, 'fro')^2);     
    
    % update for the next iteration
    ur_curr = ur_next;
    vr_curr = vr_next;
  end
  % END OF SOR
  fprintf("---warp(%d) sor ended after %d, diff %.3f\n", wi, innerIter, diff_r);
  
  %% update for the next warping iteration
  u_curr = ur_curr;
  v_curr = vr_curr;
 
end
u_est = u_curr;
v_est = v_curr;

end


