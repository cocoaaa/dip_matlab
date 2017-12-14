function [crop1, crop2] = cropToyImages
im1 = imread('/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/toy-car-images-bw/toy_formatted2.png');
im2 = imread('/Local/Users/hjsong/Playground/dip_matlab/figs/opticalFlow/toy-car-images-bw/toy_formatted3.png');

im1 = im1(13:end, 300:end-100);
im2 = im2(13:end, 300:end-100);

im1 = im1(120:end,:);
im2 = im2(120:end,:);

figure;imshowpair(im1, im2);

crop1 = im2double(im1);
crop2 = im2double(im2);
end
