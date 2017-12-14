function [labelsIm, clusterIm] = kmeans_spatial(im, K, lambda, maxIter, tol, option)
% lambda is the weight on the spatial coordinates
% That is, (1-lambda) is the weight for intensity
% maxIter: max number of iterations 
% tol: consecutive update difference as stopping criterion
% option: 'random' - initialize with random centers
%       : 'manual' - user selects random centers on the image;
im = im2double(im);
[m,n,nc] = size(im);
X = zeros(m*n, nc+2); %row = [im(x,y,:), x, y]

% construct the data matrix
for x=1:n
  for y=1:m
    i = (x-1)*m + y;
    if (nc > 1)
      X(i,:) = [reshape(im(y,x,:), 1, nc, 1), x, y];
    else
      X(i,:) = [im(y,x), x, y];
    end
  end
end
% Standarize X's columns to have a zero mean and unit std
X = cwise_normalize(X);

% Initial centroids
if (nargin > 5 &&  strcmp(option,"manual"))
  figure; imshow(im,[]);
  [centerXs, centerYs] = ginput(K);
else
  centerXs = randi([1,n], [1,K]);
  centerYs = randi([1,m], [1,K]);
end

centers = zeros(K, nc+2);
normedXcoords = cwise_normalize([1:n]');
normedYcoords = cwise_normalize([1:m]');


for k = 1:K
  xloc = centerXs(k);
  yloc = centerYs(k);
  cx = normedXcoords(xloc); cy = normedYcoords(yloc);
  if (nc > 1)
    centers(k,:) = [reshape(im(yloc,xloc,:), 1, nc, 1), cx, cy];
  else
    centers(k,:) = [im(yloc,xloc), cx, cy];
  end
end



% labels = zeros(m*n);
% newCenters = nan(K, nc+2);
% Iterative update
diff = Inf;
for i = 1:maxIter
  if (diff < tol); break; end
  % assign to new cluster, and accumulate 
  [labels, newCenters] = update(X, centers, lambda);
  diff = norm(centers - newCenters); 
  centers = newCenters;
%   fprintf("iter: %d, diff: %.5f\n", i, diff);
end
fprintf("---(lambda=%.4f)clustering ended after iter=%d, diff=%.5f\n",...
  lambda, i, diff);
labelsIm = reshape(labels, m,n);

% Assign center's avg intensity value to the pixels
clusterIm = zeros(m,n,nc);
for x=1:n
  for y=1:m
    myCluster = labelsIm(y,x);
    clusterIm(y,x,:) = centers(myCluster, 1:nc);
  end
end

end

function [labels, newCenters] = update(X, centers, lambda)
  K = size(centers,1);
  nPoints = size(X,1);
  nc = size(X,2) - 2;
  nMembers = zeros(K);
  labels = nan(nPoints,1);
  newCenters = zeros(size(centers));
  for i = 1:nPoints
    
    minDist = Inf;
    myCluster = nan;
    for k=1:K
      dIntensity = norm( X(i,1:nc) - centers(k, 1:nc) );
      dSpace = norm( X(i, nc:end) - centers(k, nc:end) );
      dist = (1-lambda)*dIntensity + lambda*dSpace;
      
      if (dist > minDist); continue; end
      minDist = dist;
      myCluster = k;
    end
    % store the best cluster and minDist to calculate the center
    labels(i) = myCluster;
    nMembers(myCluster) = nMembers(myCluster) + 1;
    newCenters(myCluster,:) = newCenters(myCluster, :) + X(i,:);  
    
  end
  
  for k = 1:K
    newCenters(k,:) = newCenters(k,:)/nMembers(k);
  end
 
end