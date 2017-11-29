function rowReduceMtx = getRowReduceMtx(originalHeight)
    % width: original width 
    % subsample matrix to subsample every other rows

 
 rowReduceMtx = zeros(ceil(originalHeight/2), originalHeight);
 for r=1:size(rowReduceMtx, 1)
     rowReduceMtx(r, 1+2*(r-1)) = 1;
 end

end

