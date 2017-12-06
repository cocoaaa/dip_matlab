function [ur_next,vr_next] = sor_solve_dFlow(I1, warpedI2, warpedI2x, warpedI2y, U, V, w, maxIter )
  [m,n] = size(I1);
  lambda2 = lambda*lambda;
  laplacian = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12];
  w = 1.9;
  tol = 1e-4;
  diff = Inf;
  ur_curr = U;
  vr_curr = V;
  for r = 1:maxIter    
    if (diff < tol); break; end
    ur_avg = imfilter(ur_curr, laplacian, 'replicate', 'same', 'conv');
    vr_avg = imfilter(vr_curr, laplacian, 'replicate', 'same', 'conv');
    
    utop = I1 - warpedI2 + warpedI2x.*U - warpedI2y.*(vr_curr - V);
    ubottom = warpedI2x.^2 + lambda2;
    ur_next = (1-w).*ur_curr + w*(utop.*warpedI2x + labmda2*ur_avg)./ubottom;
    
    vtop = I1 - warpedI2 - warpedI2x.*(ur_curr - U) + warpedI2y.*V;
    vbottom = warpedI2y.^2 + lambda2;
    vr_next = (1-w)*vr_curr + w*(vtop.*warpedI2y + lambda2*vr_avg)./vbottom;
    
    % filter out disappearing pixels
    isValid = (abs(ur_next(:)) <= n & abs(vr_next(:)) <= m);
    notValid = 1 - isValid;
    ur_next(notValid) = 0; vr_next(notValid) = 0; %okay?
    if (any(notValid(:)))
      fprintf("---SOR iter %d: out of bound count %d", r, sum(notValid(:)) );
    end 
    
    % update
    diff = sqrt(norm(ur_next - ur_curr, 'fro')^2 + norm(vr_next - vr_curr, 'fro')^2); 
    ur_curr = ur_next;
    vr_curr = vr_next;
  end

end