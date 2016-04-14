function HSVdist = calcHSVdist(im_hsv, targetVal)

HSVdist = zeros(size(im_hsv));

HSVdist(:,:,1) = circDiff(im_hsv(:,:,1),targetVal(1),0,1);

for iDim = 2 : 3
    HSVdist(:,:,iDim) = abs(im_hsv(:,:,iDim) - targetVal(iDim));
end