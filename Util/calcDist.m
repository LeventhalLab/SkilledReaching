function [pixDist,hsvDist,rgbDist] = calcObjDist(rgbImg,hsvImg,prevRGBimg,prevHSVimg,prevMask)

pixDist = bwdist(prevMask);

prev_r = prevRGBimg(:,:,1);
prev_g = prevRGBimg(:,:,2);
prev_b = prevRGBimg(:,:,3);

prev_masked_r = prev_r(prevMask(:));
prev_masked_g = prev_g(prevMask(:));
prev_masked_b = prev_b(prevMask(:));

prev_meanRGB = [mean(prev_masked_r(:)),mean(prev_masked_g(:)),mean(prev_masked_b(:))];

hsvDist = [];
rgbDist = [];