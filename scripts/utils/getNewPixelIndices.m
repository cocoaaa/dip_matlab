function newPixelIndices = getNewPixelIndices(u,v, option)
% u: mxn matrix of flow's x-component
% v: mxn matrix of flow's y-component
% option: 0 if maintaing the image size of the estimated imaged,
%         1 if to extend the estimated/flowed image

 if ~exist('option','var'), option=0; end

[m,n] = size(u);
assert(m == size(v,1) && n == size(v,2));

[colIndices, rowIndices] = meshgrid(1:n, 1:m);
newColIndices = u + colIndices;
newRowIndices = v + rowIndices;
% newPixelIndices;
if (option==0) % use image1's value if the moved pixel location is out-of-bound
    cut = u;
    cut( newColIndices<1 | newColIndices>n ) = 0;
    newColIndices = cut + colIndices;
    
    cut = v;
    cut( newRowIndices <1 | newRowIndices>m ) = 0;
    newRowIndices = cut + rowIndices;
    
    newPixelIndices = newColIndices + n.*(newRowIndices-1);
    
    
% else  % extend the estimated image to fit the largest movement
%     maxCol = max(max(newColIndices)); minCol = min(min(newColIndices));
%     cRight = max(maxCol, n) - n;
%     cLeft = 1 - min(minCol,1);
%     
%     maxRow = max(max(newRolIndices)); minRow = min(min(newRowIndices));
%     cUp = 1 - min(minRow, 1);
%     cDown = max(maxRow,m) - m;
    
end
% disp("newColIndices: "); disp(newColIndices);
% disp("\n newRowIndices: "); disp(newRowIndices);


end