function [u_curr, v_curr] = computeFlow(I1, I2, u0, v0, nWarps, sorMaxIter)

[I2x, I2y] = gradient(I2);
u_curr = u0;
v_curr = v0;
for k = 1:nWarps
  warpedI2 = warpBW(I2, u_curr, v_curr);
  warpedI2x = warpBW(I2x, u_curr, v_curr);
  warpedI2y = warpBW(I2y, u_curr, v_curr);
  
  % update for next warping
  [u_curr, v_curr] = sor_solve_dFlow(I1, warpedI2, warpedI2x, warpedI2y, ...
                                      u_curr, v_curr, w, sorMaxIter);
end

end
