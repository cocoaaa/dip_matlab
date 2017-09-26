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
close all;
im = [zeros(5,5) ones(5,5); ones(5,5) zeros(5,5)];
% figure;
% imshow(im, []);
for lambda=0:0.2:1
    out = denoise(im, lambda);

    figure;
    subplot(1,2,1); imshow(out); title(string(lambda));
    subplot(1,2,2); imshow(im); title("input");
end 