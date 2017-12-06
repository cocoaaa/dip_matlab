function [us, vs] = opticalFlowPyrHSWarp(I1, I2, lambda, maxMotion, reduceFactor)
  % Assumes inputs are normalized to [0,255) and blurred (anisotropic diffusion)
  % reduceFactor: pyramid downsampling factor. It must be in range of [0,1].
  % Default is 0.8
  % maxMotion: size of maxMotion to detect (in pixel) 
  % us, vs: (s here stands for scale) estimated flow
  if ~exist('reduceFactor', 'var') || isempty(reduceFactor)
    reduceFactor = 0.5;
  end
%   [m,n] = size(I1);
  nLevels = computePyrHeight(maxMotion, reduceFactor);
  pyrSigma = 0.6*sqrt(-1 + reduceFactor^(-2)); % suggested by IPOL report

  pyr1 = buildGPyr(I1, pyrSigma, reduceFactor, nLevels);
  pyr2 = buildGPyr(I2, pyrSigma, reduceFactor, nLevels);
  
  [m0, n0] = size(pyr1{nLevels});
  us_0 = zeros(m0,n0); %u0 at the coarsest scale 
  vs_0 = zeros(m0,n0); %v0 at the coarsest scale
  
  for s = nLevels:-1:1
    [ms, ns] = size(pyr1{s});
    fprintf("---level: %d \nimg size: %d, %d\n", s, ms, ns ); 
    fprintf("\t init u,v size: %d, %d\n", size(us_0,1), size(us_0,2) );
    
    % assert us_0, vs_0 have the same size as the image at current scale
    us_0 = us_0(1:ms, 1:ns);
    vs_0 = vs_0(1:ms, 1:ns);
    [us,vs] = opticalFlowHSWarp(pyr1{s}, pyr2{s}, us_0, vs_0, lambda); % estimated flow at current scale
    
    if (s==1); break; end
    % If not at the finest scale, upsameple current scale's estimated flow 
    % to get the initial flow for next scale
%     us_0 = upsampleFlow(us, 1/reduceFactor); 
    us_0 = imresize(us, 1/reduceFactor, 'bicubic');
    vs_0 = imresize(vs, 1/reduceFactor, 'bicubic');
  end
  
  
  
end
