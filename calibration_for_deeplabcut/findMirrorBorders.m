function mirrorBorders = findMirrorBorders(img, directBorderMask, mirror_hsvThresh, ROIs)

SEsize = 3;
SE = strel('disk',SEsize);
minCheckerboardArea = 5000;
maxCheckerboardArea = 20000;

diffThresh = 0.1;
threshStepSize = 0.01;

h = size(img,1);
w = size(img,2);

img_stretch = decorrstretch(img);
initSeedMasks = false(h,w,3);
denoisedMasks = false(h,w,3);

% figure(1); imshow(img_stretch);

img_hsv = rgb2hsv(img_stretch);

for iMirror = 1 : 3
    mirrorMask = false(h,w);
    mirrorMask(ROIs(iMirror+1,2):ROIs(iMirror+1,2)+ROIs(iMirror+1,4)-1, ROIs(iMirror+1,1):ROIs(iMirror+1,1)+ROIs(iMirror+1,3)-1) = true;
    mirrorView_hsv = img_hsv .* repmat(double(mirrorMask),1,1,3);
    
    initSeedMasks(:,:,iMirror) = HSVthreshold(mirrorView_hsv, mirror_hsvThresh(iMirror,:)) & mirrorMask;
    
    denoisedMasks(:,:,iMirror) = imopen(squeeze(initSeedMasks(:,:,iMirror)), SE);
    denoisedMasks(:,:,iMirror) = imclose(squeeze(denoisedMasks(:,:,iMirror)), SE);
end