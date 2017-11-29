% ref: http://mghassem.mit.edu/pcasvd/
% excellent lecture note: https://people.cs.pitt.edu/~milos/courses/cs3750-Fall2007/lectures/PCA.pdf

close all;
clc;
clear all;

% addpath('/Local/Users/hjsong/Downloads/images/standard_test_images/');
% m_imdata_path = '/Applications/MATLAB_R2017a.app/toolbox/images/imdata/';
dirpath = '/Local/Users/hjsong/Downloads/faces/train/face/';
fpath = strcat(dirpath,'face000');

n = 90;
d = 19*19;
X_display = zeros(19*n,19);
X = zeros(n,d);

for i = 10:10+n-1
    fname = strcat( strcat(fpath, num2str(i)), '.pgm');
    X_display(19*(i-10)+1:19*(i-10)+19,:) = imread(fname);
    X(i-9,:) = reshape(imread(fname), 1, d);
%     imshow(X)
end
% imshow(X_display,[]);
% imshow(X, []);

% zero-mean
means = mean(X, 1);
meanFace = reshape(means, 19,19);
figure; imshow(meanFace,[]); title("meanFace");
X = X - repmat(means, n, 1);

% Cov matrix of X
C = X'*X/n;
[U,D] = eig(C);
evalues = diag(D); %increasing order
p = 10; % number of principle components to select; dim of subspace to project the original data onto
U_p = U(:, end-p+1:end);

% Reconstruct the original dataset
Y = X*U;
diff = X-Y;
error = sqrt(trace(diff*diff')); %reconstruction error, must be very close to zero

% dataset projected to p-dim subspace
Y_p = X*U_p; 

% plot the eigenfaces
figure;
for i = 1:p
    subplot(5,p/5,i); 
    imshow(reshape(U_p(:,i),19,19), []);
    title(num2str(i)); 
end

% compare the first image and first image constructed from p basis vectors
figure;
idx = 10;
subplot(1,3,1);imshow(reshape(X(idx,:), 19,19), []); title("original image");
subplot(1,3,2);imshow(reshape(Y(idx,:)*U', 19,19), []); title("full reconstruction");
subplot(1,3,3);imshow(reshape(U_p*Y_p(idx,:)', 19,19), []); title("p-basis reconstruction");



