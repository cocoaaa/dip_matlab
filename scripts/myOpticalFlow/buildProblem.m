function [S,rhs] = buildProblem(...
  ucurr, vcurr, dPhi_data, dPhi_smooth, alpha, ...
  cu1, cv1, cb1, cu2, cv2, cb2)
% Build a sparse matrix that describes the two (u,v) constraints
% - First nPixel number of rows correspond to the first constrain with the
% Euler Lagrange equation wrt u-field
% - Second nPixel number of rows correpsond to the second straint with the
% euler lagrange equation wrt v-field
% This function is to be called within the inner loop

[m,n] = size(ucurr);
nPixels = m*n;
twoNPixels = 2*nPixels;

alpha_dPhi_smooth = alpha*dPhi_smooth;
% uii and vii values for the first equation
DiagU1 = dPhi_data.*cu1- alpha_dPhi_smooth;
DiagV1 = dPhi_data.*cv1;

% uii and vii values for the second equation
DiagU2 = dPhi_data.*cu2;
DiagV2 = dPhi_data.*cv2 - alpha_dPhi_smooth;

% values for direct,diagonal neighbor pixels
directValue = (1/6)*alpha_dPhi_smooth;
diagValue = (1/12)*alpha_dPhi_smooth;

% construct the vector on RHS
rhs1 = reshape( dPhi_data.*( -cb1 + cu1.*ucurr + cv1.*vcurr ), nPixels, 1);
rhs2 = reshape( dPhi_data.*( -cb2 + cu2.*ucurr + cv2.*vcurr ), nPixels, 1);
rhs = [rhs1;rhs2];

% collect entries for sparse matrix
% triplets(:,1) = row indices, triplets(:,2) = colm indices, triplets(:,3) = values
nTriplets = 10*twoNPixels;
triplets = nan(nTriplets,3); 
ti = 1; %count for triplets element
for j = 1:nPixels
  
  x = floor( (j-1)/m ) + 1;
  y = j - (x-1)*m;
  
  % uii and vii 
  %first equation
  triplets(ti,:) = [j,j,DiagU1(y,x)];
  ti = ti+1;
  triplets(ti,:) = [j, j+nPixels, DiagV1(y,x)];
  ti = ti+1;
  
  %second equation
  triplets(ti,:) = [j+nPixels, j, DiagU2(y,x) ];
  ti = ti+1;
  triplets(ti,:) = [j+nPixels, j+nPixels, DiagV2(y,x) ];
  ti = ti+1;
  
  % Get the neighbors' indices
  [directs, diagonals] = getNeighborsNaive(m,n,y,x);
  
  nx = nan; ny = nan; i = nan;
  for i = 1:size(directs,1)
    nx = directs(i, 1); ny = directs(i,2);
    ii = ny + (nx-1)*m;
    % first equation
    triplets(ti,:) = [j, ii, directValue(y,x)]; %note directValue at jth pixel
    ti = ti+1;
    
    % second equation
    triplets(ti,:) = [j+nPixels, ii+nPixels, directValue(y,x)];
    ti = ti+1;
  end
  
  nx = nan; ny = nan; i = nan;
  for i = 1:size(diagonals,1)
    nx = diagonals(i,1); ny = diagonals(i,2);
    ii = ny + (nx-1)*m;
    % first equation
    triplets(ti,:) = [j, ii, diagValue(y,x)];
    ti = ti+1;  
    
    % second equation
    triplets(ti,:) = [j+nPixels, ii+nPixels, diagValue(y,x)];
    ti = ti+1;
  end
 
end

% Check if we have filled up all the predesignated number of non-zeros in
% the sparse matrix
fprintf("ti: %d\n", ti);
fprintf("nTriplets: %d\n", nTriplets);

if (ti<nTriplets)
  triplets = triplets(1:ti-1, :);
end


S = sparse( triplets(:,1), triplets(:,2), triplets(:,3) , twoNPixels, twoNPixels);
figure;spy(S); title("problem matrix");

end