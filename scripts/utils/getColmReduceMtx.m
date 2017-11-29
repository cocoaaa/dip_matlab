function colmReduceMtx = getColmReduceMtx(originalWidth)
    colmReduceMtx = zeros(originalWidth, ceil(originalWidth/2));
    for c=1:size(colmReduceMtx,2)
        colmReduceMtx(1+2*(c-1), c) =1;
    end

end


