function rowvec = imToColmvec(im)
 [m,n] = size(im);
 rowvec = reshape(im', m*n, 1);
end