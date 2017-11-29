% % Image-Coordinate based quiver plot
% Input: 
% u = (mxn) matrix whose element is the x-component of the flow at (r,c) location
% v = (mxn) matrix whose element is the y-component of the flow at (r,c) location
% where m = number of rows, i.e. height, n = number of cols, i.e. width
%
% Shows the quiver plot 

function [] = showFlow(u,v)
[m,n] = size(u);
assert (m == size(v,1) && n == size(v,2));
x = repmat([1:n]', 1, m);
y = repmat([m:-1:1], n, 1);
x = reshape(x, m*n, 1);
y = reshape(y, m*n, 1);

u = imToColmvec(u);
v = imToColmvec(v);

% todo: Estimate scale for visualization wrt the range of u,v values
h = [-0.5,0.5];
ux = imfilter(u, h, 'replicate');
vy = imfilter(v, h', 'replicate');
maxVal = max( max(max(abs(ux))), max(max(abs(vy))) );
% want [0,maxVal] to be scaled to [0,1]
scale = 1.0/(4*maxVal);

figure;
quiver(x,y,u,v,scale);
title("U,V Flow");

end

