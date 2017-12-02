function nScale = computePyrHeight(maxMotion, reduceFactor)
% maxMotion: mag of largest estimated motion in pixel
% reduceFactor: downsampling factor in between two consecutive pyramids
nScale = -log2(maxMotion)/log2(reduceFactor) + 1;
end