function pyr = buildGPyr(I, sigma, reduceFactor, maxMotion)%, nLevels) % since redundant to have both reduceFactor and nLevels
% construct a gaussian pyramid of I.
% Lowest level (level 1) contains the original image.
% Image at the next level is recursively constructed from the image at t
if ~exist('maxMotion', 'var') || isempty(maxMotion)
  disp("---GPyr: maxMotion is deafulted to min(height, width)");
  maxMotion = min( size(I) );
end
nLevels = computePyrHeight(maxMotion, reduceFactor);
pyr{1} = I;
for l = 2:nLevels
  Ibelow = imgaussfilt(pyr{l-1}, sigma, 'Padding', 'replicate'); 
  pyr{l} = imresize(Ibelow, reduceFactor, 'bicubic');
  figure; imshow(pyr{l}); title(strcat('level: ', num2str(l)));
end
end
