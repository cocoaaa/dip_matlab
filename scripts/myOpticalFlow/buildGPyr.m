function pyr = buildGPyr(I, sigma, reduceFactor, nLevels) 
% construct a gaussian pyramid of I.
% Lowest level (level 1) contains the original image.
% Image at the next level is recursively constructed from the image at t

pyr{1} = I;
for l = 2:nLevels
  Ibelow = imgaussfilt(pyr{l-1}, sigma, 'Padding', 'replicate'); 
  pyr{l} = imresize(Ibelow, reduceFactor, 'bicubic');
%   figure; imshow(pyr{l}); title(strcat('level: ', num2str(l)));
end
end
