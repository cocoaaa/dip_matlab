
function [u,v] = ldof(I1, I2, reduceFactor, nOuterIter, nInnerIter, ...
                      rho, alpha, epsilon)
[I1x, I1y] = gradient(I1);
[m,n] = size(I1);
nPixels = m*n;

% Build pyramids



u = zeros(m,n);
v = zeros(m,n);
for k = 1: nOuterIter
  fprintf("outerIter: %d\n", k);
  warpI = warpBW(I2, u, v);
  [Ix, Iy] = gradient(warpI);
  [Ixx, Iyx] = gradient(Ix); % potentially want to check Iyx and Ixy
  [Ixy, Iyy] = gradient(Iy);
  Iz = warpI - I1;
  Ixz = Ix - I1x;
  Iyz = Iy - I1y;
  % compute terms that are constant over inner iteration  
  cu1 = Ix.^2 + rho*(Ixx.^2 + Ixy.^2);
  cv1 = Ix.^Iy + rho*(Ixy.*(Ixx + Iyy));
  cb1 = Ix.^Iz + rho*(Ixx.*Ixz + Ixy.*Iyz);
  
  cu2 = Ix.^Iy + rho*(Iyy.*(Ixx + Iyy));
  cv2 = Iy.^2 + rho*(Iyy.^2 + Ixy.^2);
  cb2 = Iy.^Iz + rho*(Iyy.*Iyz + Ixy.*Ixz);
   
  % verbose
  figure; imshow(warpI); title('warped im2');
  figure; imshowpair(I1, warpI); title('im1 and warped im2');
  
  figure;
  subplot(3,3,1); imshow(Iz); title('Iz'); subplot(3,3,2); imshow(Ixx); title('Ixx'); subplot(3,3,3); imshow(Iyx); title('Iyx');
  subplot(3,3,4); imshow(Ixy); title('Ixy'); subplot(3,3,5); imshow(Iy); title('Iy'); subplot(3,3,6); imshow(Iz); title('Iz');
  subplot(3,3,7); imshow(Ixz); title('Ixz'); subplot(3,3,8); imshow(Iyz); title('Iyz');

  figure;
  subplot(2,3,1); imshow(cu1); title('cu1');subplot(2,3,2); imshow(cv1); title('cv1');subplot(2,3,3); imshow(cb1); title('cb1');
  subplot(2,3,4); imshow(cu2); title('cu2');subplot(2,3,5); imshow(cv2); title('cv2');subplot(2,3,6); imshow(cb2); title('cb2');

  % inner iteration
  uCurr = u; vCurr = v; %u_kl, v_kl (with l=1) is set to u_k, v_k
  prev_du = zeros(m,n); prev_dv = zeros(m,n);
  for l = 1: nInnerIter
    dPhi_data = computeDPhiData(prev_du, prev_dv, ...
      Ix, Iy, Iz, Ixx, Ixy, Ixz, Iyy, Iyz, rho, epsilon);
    dPhi_smooth = computeDPhiSmooth(uCurr, vCurr, epsilon);
    tic;
    [S,b] = buildProblem(...
      uCurr, vCurr, dPhi_data, dPhi_smooth, alpha, ...
      cu1, cv1, cb1, cu2, cv2, cb2);
    toc; 
    figure;spy(S); title('problem matrix');
    wNext = S\b;
    uNext = reshape(wNext(1:nPixels), m,n); %u_k,(l+1)
    vNext = reshape(wNext(nPixels+1:end), m,n); %v_k,(l+1)
    
    % update u,v,du,dv for next innerIter
    prev_du = uNext - uCurr; %du_kl
    prev_dv = vNext - vCurr; %dv_kl
    uCurr = uNext;
    vCurr = vNext;
  end
  
  u = (1/reduceFactor) * imresize(uCurr, 1/reduceFactor, 'bicubic');
  v = (1/reduceFactor) * imresize(vCurr, 1/reduceFactor, 'bicubic');
end


end