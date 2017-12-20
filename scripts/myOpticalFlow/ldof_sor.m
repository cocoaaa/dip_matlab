
function [u,v] = ldof_sor(im1, im2, pyrSigma, reduceFactor, nLevels, nInnerIter, w, ...
                      rho, alpha, epsilon, verbose)
fig1 = 1; fig2 = 2; fig3 = 3; fig4 = 4; fig5 = 5; fig6 = 6;
% Build pyramids
% gPyr1 = getPyramid(im1, pyrSigma, reduceFactor);
% gPyr2 = getPyramid(im2, pyrSigma, reduceFactor);
% nLevels = 

inds_outofimage = [];
for k = nLevels:-1:1 %outerIter
  fprintf("---pyrLevel: %d\n", k);
%   I1 = gPyr1{k};
%   I2 = gPyr2{k};
  I1 = im1; I2 = im2;

  [m,n] = size(I1);
  nPixels = m*n;
  [ys, xs] = meshgrid(1:m, 1:n); % to check inds_outofimage locations
  
  % initial u,v at the coarest level
  if k == nLevels
    u = zeros(m,n);
    v = zeros(m,n);
  end
  inds_outofimage = find(xs+u < 1 | xs+u > n | ys+v < 1 | ys+v > m);
  
  % compute derivatives that stay constant at this scale
  [I1x, I1y] = gradient(I1);
  warpI = warpBW(I2, u, v);
  [Ix, Iy] = gradient(warpI);
  [Ixx, Iyx] = gradient(Ix); % potentially want to check Iyx and Ixy
  [Ixy, Iyy] = gradient(Iy);
  Iz = warpI - I1;
  Ixz = Ix - I1x;
  Iyz = Iy - I1y;
  
  % fix warped values at outofimage pixel locations
  Ixx = handle_outofimage(Ixx, inds_outofimage);
  Ixy = handle_outofimage(Ixy, inds_outofimage);
  Iyy = handle_outofimage(Iyy, inds_outofimage);
  Ixz = handle_outofimage(Ixz, inds_outofimage);
  Iyz = handle_outofimage(Iyz, inds_outofimage);

  % compute terms that are constant over inner iteration  
  cu1 = Ix.^2 + rho*(Ixx.^2 + Ixy.^2);
  cv1 = Ix.*Iy + rho*(Ixy.*(Ixx + Iyy));
  cb1 = Ix.*Iz + rho*(Ixx.*Ixz + Ixy.*Iyz);
  
  cu2 = Ix.*Iy + rho*(Iyy.*(Ixx + Iyy));
  cv2 = Iy.^2 + rho*(Iyy.^2 + Ixy.^2);
  cb2 = Iy.*Iz + rho*(Iyy.*Iyz + Ixy.*Ixz);
  
%   % compute Laplacian values of u_k, v_k for inner iteration
%   laplacian = [1/12 1/6 1/12; 1/6 0 1/6; 1/12 1/6 1/12];
%   Lu = imfilter(u, laplacian, 'same', 'conv');
%   Lv = imfilter(v, laplacian, 'same', 'conv');

  % verbose
  if verbose
    figure(fig1); imshow(warpI); title('warped im2'); 
    figure(fig2); imshowpair(I1, warpI); title('im1 and warped im2'); 

    figure(fig3);
    subplot(3,3,1); imshow(Iz); title('Iz'); subplot(3,3,2); imshow(Ixx); title('Ixx'); subplot(3,3,3); imshow(Iyx); title('Iyx');
    subplot(3,3,4); imshow(Ixy); title('Ixy'); subplot(3,3,5); imshow(Iy); title('Iy'); subplot(3,3,6); imshow(Iz); title('Iz');
    subplot(3,3,7); imshow(Ixz); title('Ixz'); subplot(3,3,8); imshow(Iyz); title('Iyz');

    figure(fig4);
    subplot(2,3,1); imshow(cu1); title('cu1');subplot(2,3,2); imshow(cv1); title('cv1');subplot(2,3,3); imshow(cb1); title('cb1');
    subplot(2,3,4); imshow(cu2); title('cu2');subplot(2,3,5); imshow(cv2); title('cv2');subplot(2,3,6); imshow(cb2); title('cb2');
  end
  
  % inner iteration
  %u_k,1, v_k,1 is set to u_k, v_k 
  %equivalent to set du_k,1 and dv_k,1  to zero
  du = zeros(m,n); dv = zeros(m,n);
  for l = 1:nInnerIter
    if verbose; fprintf('------inner %d\n', l); end;
    dPhi_data = computeDPhiData(du, dv, ...
      Ix, Iy, Iz, Ixx, Ixy, Ixz, Iyy, Iyz, rho, epsilon);
    dPhi_smooth = computeDPhiSmooth(u, v, du, dv, epsilon);
    
    if ( any(isnan(dPhi_data(:))) || any(isnan(dPhi_smooth(:))) )
     disp("dPhi_data or dPhi_smooth has nan");
     dbstop at 91 in ldof_sor
    end
    
    
    % solve the constraints and update du and dv
    tic;
    [du,dv] = sor_iteration(...
      du, dv, u, v, dPhi_data, dPhi_smooth, w, alpha, ...
      cu1, cv1, cb1, cu2, cv2, cb2); %update du, dv to du_k,l+1, dv_k,l+1
    toc;
    
    if verbose
      figure;%figure(fig6);
      subplot(2,2,1); imshow(du,[]); title(sprintf('du %d,%d', k, l+1));
      subplot(2,2,2); imshow(dv,[]); title(sprintf('dv  %d,%d', k, l+1));
      subplot(2,2,3); imshow(dPhi_data,[]); title(sprintf('dphidata %d,%d', k, l+1));
      subplot(2,2,4); imshow(dPhi_smooth,[]); title(sprintf('dphismooth  %d,%d', k, l+1));
    end
    
  end
  
  
  if verbose 
    figure%(fig5); 
    subplot(1,2,1); imshow(du); title(sprintf('pyrlevel %d: updated du',k));
    subplot(1,2,2); imshow(dv); title(sprintf('pyrlevel %d: updated dv',k));
  end
  
  % update u_k and v_k 
  u = u + du;
  v = v + dv;
%   inds_outofimage = find(xs+u < 1 | xs+u > n | ys+v < 1 | ys+v > m);
  
  if l == 1; break; end
  % upsample and rescale for next pyramid level
  % todo: check the dimension (rounding)
  u = (1/reduceFactor) * imresize(u, 1/reduceFactor, 'bilinear');
  v = (1/reduceFactor) * imresize(v, 1/reduceFactor, 'bilinear');
 
end


end

function A = handle_outofimage(A, inds)
if isempty(inds)
    return;
end
[p,q,r]=size(A);
for i=1:r
    A(inds+(i-1)*p*q)=0;
end
end
