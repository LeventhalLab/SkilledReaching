function [meanRGB, stdRGB] = RGBstats(img, mask)

[idx] = find(mask(:));

meanRGB = zeros(size(img,3),1);
stdRGB = zeros(size(img,3),1);

for ii = 1 : size(img,3)
    
    col_plane = squeeze(img(:,:,ii));
    col_plane = col_plane(:);
    
    meanRGB(ii) = mean(col_plane(idx));
    stdRGB(ii) = std(col_plane(idx),0,1);
    
end
    