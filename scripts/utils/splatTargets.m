function targets = splatTargets(x,y,r, w, h)
% Returns n by 2 matrix of (x,y) locations of targets to splat from (x,y) 
% where n is the number of target indices. Returned index is guaranteed to
% be in the image domain (i.e. range of 1:w and 1:h)

    % check if x,y are integers
    targets = [];
    if ( floor(x) == x && floor(y) == y)
        targets = [ [x,y] ] ;
    end
    
    topLeft = [floor(x), floor(y)];
    bottomLeft = topLeft + [0,1];
    topRight = topLeft + [1, 0];
    bottomRight = topLeft + [1 1];
    
    candidates = [topLeft; bottomLeft; topRight; bottomRight];
    % no need to check if inside image boundary 
    % because if x,y is inside, targets will contain only indices that are
    % valid (i.e. within the image boundary) as long as r<0.5
    candidates = candidates(candidates(:,1) >= 1 & candidates(:,1)<=  w & candidates(:,2) >= 1 & candidates(:,2) <= w, :);
    
    X = repmat([x,y], size(candidates,1), 1);
    squaredD = sum((X-candidates).*(X-candidates),2); %check if rowwise summation
%   which is equivalent to 
%     D = X-candidates;
%     tr(D*D')
    targets = candidates(squaredD<r*r, :);
    
    if (size(targets,1) > 1)
        fprintf("number of splat targets: %d", size(targets,1));
    end
    
end
