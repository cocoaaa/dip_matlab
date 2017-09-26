%% 1D denoising with varying lambdas
% n = 1000000;
% f = [1:n] + 0.2.*rand(1,n)-0.1;
% figure; hold on;
% plot(f, 'Color', [0 0 0]);
% lambdas = [0 0.5 1];
% for lambda = lambdas
%     u = denoise(f, lambda);
%     plot(u, 'Color', [0, 0+lambda, 0]);
% end
% names = ["input", string(lambdas)]; 
% 
% legend(names);
% title("1D denoising, lambdas varied");

%% n-dim denoising 
% Example: 2-dim images
% create sample image
% im_test = [zeros(5,5)];% ones(5,5); ones(5,5) zeros(5,5)];


% preprocessing
%crop
close all;
fname = '../../dip/data/breast1.png';

temp = imread(fname); temp = temp(1:end-15,:,1); %heuristic: remove the bottom 15 rows
if size(temp,1) > size(temp,2)
    temp = temp(end-size(temp,2)+1:end,:);
elseif size(temp,1) < size(temp,2)
    temp = temp(:, 1:size(temp,1)-1);
end
    
imshow(temp);
%% low-pass (for noise)
%parameters
lowpass_sigma = 0.01;
noise_sigma = 0.2;

im = imgaussfilt(im2double(temp), lowpass_sigma); %low-passed image's first channel. All channels have the same info
im_noised = imnoise(im,'gaussian',noise_sigma); %added noise to the (blurred) image
figure;
subplot(1,3,1); imshow(temp); title("original before low-pass");
subplot(1,3,2); imshow(im); title('original with small gauss');
subplot(1,3,3); imshow(im_noised); title('adds gaussian noise');

%% Denoise with various lambdas
stack = [];
lambdas = 0:0.2:1;
for lambda=lambdas
    out = denoise(im_noised, lambda);
    stack = [stack out];
%     figure;
%     subplot(1,2,1); imshow(out); title(string(lambda));
%     subplot(1,2,2); imshow(im); title("input");
end 

%% Plotting
figure;
for iter=1:size(stack,2)/size(out,2)
    subplot(3,3,iter); imshow(stack(:,1+(iter-1)*size(out,2):iter*size(out,2)) ); title(string(lambdas(iter)));
end
subplot(3,3,8); imshow(im_noised); title("input");