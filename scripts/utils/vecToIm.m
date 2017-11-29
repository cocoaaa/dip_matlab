%% vec = [1,2,3,4,5,6]
% we want to make it a 2x3 matrix by using the vec's element rowwise
% Res: A = reshape(vec, 3,2)'

function im = vecToIm(vec, m, n)
 im = reshape(vec, n, m)';
end


