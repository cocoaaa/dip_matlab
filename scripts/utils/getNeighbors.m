% im = imread('../figs/breast1.png');

function [adjs, diags] = getNeighbors(m,n,y,x)
% m: image height, n: image width
% y: row index, x: colm index
% Returns the neighbor indices of a pixel at location row=y, col=x on the image of
% size (m by n).

im_index = vecToIm(1:m*n, m, n);
% figure;
% imshow(im_index,[]); title("index matrix");

frame = Inf(m+2, n+2);
frame(2:end-1, 2:end-1) = im_index;

% figure;
% imshow(frame,[]);
% title("with the nan frame");

fy = y+1; 
fx = x+1;
% assert(  frame(fy,fx) == im(y,x) );
adjs = [frame(fy, fx-1), frame(fy+1, fx), frame(fy, fx+1), frame(fy-1, fx)];
adjs = adjs(~isinf(adjs));

diags = [frame(fy-1, fx-1), frame(fy+1, fx-1), frame(fy-1, fx+1), frame(fy+1, fx+1)];
diags = diags(~isinf(diags));

end
