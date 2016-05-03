function [pixDist,hsvDist,rgbDist] = calcObjDist(rgbImg,hsvImg,prevRGBimg,prevHSVimg,prevMask)

pixDist = bwdist(prevMask);

prev_r = prevRGBimg(:,:,1);
prev_g = prevRGBimg(:,:,2);
prev_b = prevRGBimg(:,:,3);

prev_masked_r = prev_r(prevMask(:));
prev_masked_g = prev_g(prevMask(:));
prev_masked_b = prev_b(prevMask(:));

rgbDist = zeros(size(rgbImg));
rgbDist(:,:,1) = rgbImg(:,:,1) - median(prev_masked_r(:));
rgbDist(:,:,2) = rgbImg(:,:,2) - median(prev_masked_g(:));
rgbDist(:,:,3) = rgbImg(:,:,2) - median(prev_masked_b(:));

prev_h = prevHSVimg(:,:,1);
prev_s = prevHSVimg(:,:,2);
prev_v = prevHSVimg(:,:,3);

prev_masked_h = prev_h(prevMask(:));
prev_masked_s = prev_s(prevMask(:));
prev_masked_v = prev_v(prevMask(:));

hsvDist = zeros(size(hsvImg));
hsvDist(:,:,1) = circDiff(hsvImg(:,:,1), circMedian(prev_masked_h(:),0,1),0,1);   % need to make this a circular median
hsvDist(:,:,2) = hsvImg(:,:,2) - median(prev_masked_s(:));
hsvDist(:,:,3) = hsvImg(:,:,2) - median(prev_masked_v(:));
