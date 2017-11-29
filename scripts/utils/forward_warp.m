%% Forward warping
 
function warped = warp(im, vx, vy)
% warp im according to flow filed vx and vy components
[m,n] = size(im);
[x,y] = meshgird(1:n, 1:m);
warped = interp2(x,y,im,x+vx, y+vy,'cubic', 0);

end