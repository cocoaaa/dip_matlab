function [us, vs] = pyrhs_opticalFlow(I1, I2, lambda, maxMotion, reduceFactor, verbose)
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
  
  fprintf("---Building gPyrs");
  tic; 
  pyr1 = buildGPyr(I1, pyrSigma, reduceFactor, nLevels);
  pyr2 = buildGPyr(I2, pyrSigma, reduceFactor, nLevels);
  toc; 
  
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
%     [us,vs] = opticalFlowHSWarp(pyr1{s}, pyr2{s}, us_0, vs_0, lambda); % estimated flow at current scale
   [us,vs] = hs_opticalFlow(pyr1{s}, pyr2{s}, us_0, vs_0, lambda, false); % estimated flow at current scale

    if (s==1); break; end
    
    % If not at the finest scale, upsameple current scale's estimated flow 
    % to get the initial flow for next scale
    us_0 = (1/reduceFactor) * imresize(us, 1/reduceFactor, 'bicubic');
    vs_0 = (1/reduceFactor) * imresize(vs, 1/reduceFactor, 'bicubic');
    
    % Handle the flow components that go out of bound?
    
  end
  
  if verbose
    est = warpFW(I1, us, vs);
    figure; imshowpair(est, I2); title('est-pyrhs vs. im2');
  
    % if gt is available
%     flow = cat(3, us, vs);
%     flowColor = computeColor(us,vs);
%     fprintf("--- aae: %.3f, aep: %.3f, ", computeAEP(flow, flowGT), computeAAE(flow, flowGT));
  end

end
