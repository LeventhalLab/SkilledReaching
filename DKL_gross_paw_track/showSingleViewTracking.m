function showSingleViewTracking(image_ud,fullMask)

figure(1)
mask_outline = bwmorph(fullMask,'remove');

A = imoverlay(image_ud,mask_outline,[1 0 0]);
imshow(A);