function subsampled = subsampleByHalf(im)
    [h,w] = size(im);
    rowReduceMtx = getRowReduceMtx(h);
    colmReduceMtx = getColmReduceMtx(w);
    subsampled = rowReduceMtx*im*colmReduceMtx;
end