
function output = denoise(input, lambda)
% input and output are (1,n) row vectors


% Image denoising via variational method
% Example: 1D
n = length(input);
% Create the second difference matrix with regularization
D = sparse(1:n, 1:n, [1+lambda ,1+2*lambda*ones(1,n-2), 1+lambda], n,n);
A = sparse(1:n-1, 2:n, -lambda*ones(1, n-1), n, n);
S = D+A+A';

% Solve S*u = f
output = S\input';
end






