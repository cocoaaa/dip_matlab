function A = cutAtNStd(A, N, val)
% Change elemnts of A that is N std away from the mean to val
    if ~exist('N', 'var') ||  isempty(N)
       N = 3;
    end

    if ~exist('val', 'var') ||  isempty(val)
       val = 0;
    end

    mu = mean2(A);
    stdDiv = std2(A);
    A(A > mu + N*stdDiv | A < mu - N*stdDiv) = val;
end
