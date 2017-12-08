function scaled = cwise_normalize(X)
% Each column of X is a feature. Normalize each feature space to have a
% unit std and zero mean.

means = mean(X,1);
stds = std(X);
scaled = (X - repmat(means, size(X,1) ,1))./repmat(stds, size(X,1),1);
end