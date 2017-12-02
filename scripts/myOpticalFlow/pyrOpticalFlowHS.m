function [u_est, v_est] = pyrOpticalFlowHS(I1, I2, maxMotion, reduceFactor)
  % Assumes inputs are normalized to [0,255) and blurred (anisotropic diffusion)
  % reduceFactor: pyramid downsampling factor. It must be in range of [0,1].
  % Default is 0.8
  % maxMotion: size of maxMotion to detect (in pixel) 
  if ~exist('reduceFactor', 'var') || isempty(reduceFactor)
    reduceFactor = 0.5;
  end

  [m,n] = sizes(I1);
  nLevels = computePyrHeight(reduceFactor);

  pyr1 = buildGPyr(I1, pyrSigma, reduceFactor, maxMotion);
  pyr2 = buildGPyr(I2, pyrSigma, reduceFactor, maxMotion);
  
  us = zeros(m,n); %u0 at the coarsest scale 
  vs = zeros(m,n); %v0 at the coarsest scale
  for s = nLevels:-1:1
    [u,v] = runHSWarp(pyr1{s}, pyr2{s}, us, vs);
    
    if (s==1); break; end
    us_below = upsampleFlow(u, 1/reduceFactor); 
    vs_below = upsampleFlow(v, 1/reduceFactor);
  end
end
