function warpedI2 = warpBW(I2, u, v)
% I2(x+u, y+v) = warpedI2(x,y)
% uses bicubic interpolation
  [m,n] = size(I2);
  [X,Y] = meshgrid(1:n, 1:m);
  
  u1 = u;
  u1(isnan(u)) = 0;
  v1 = v;
  v1(isnan(v)) = 0;
  
  xnew = X + u1;
  ynew = Y + v1;
  xnew(xnew < 1) = 1;
  xnew(xnew > n) = n;
  ynew(ynew < 1) = 1;
  ynew(ynew > n) = n;
  
  warpedI2 = interp2(X,Y,I2, xnew, ynew, 'bilinear');
  warpedI2(isnan(u) | isnan(v)) = nan;
end
