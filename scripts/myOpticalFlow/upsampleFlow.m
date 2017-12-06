function upU = upsampleFlow(u, upFactor)
  upU = imresize(u, upFactor, 'bicubic');
end