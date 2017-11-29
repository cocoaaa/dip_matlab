% rowwise image index i -> (r,c) index on a image of (mxn) domain
function [r,c] = twoDimIndex(i, m, n)
    r = floor( (i-1)/n )+1;
    c = i - (r-1)*n;
end
