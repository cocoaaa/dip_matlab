function [] = showPyramid(pyramid)
% pyramid: a cell containing all pyramids 
nLevel = length(pyramid);
m = 0;
n = 0;
for i=1:nLevel
    if size(pyramid{i},1) > m
       m = size(pyramid{i},1);
    end
    
    n = n + size(pyramid{i},2); 
end

hStack = nan(m,n);
c = 1;
for i = 1:nLevel
    hStack(1:size(pyramid{i},1), c:c+size(pyramid{i},2)-1) = pyramid{i};
    c = c + size(pyramid{i},2);
end

figure;
imshow(hStack, []); title("pyramid");

end