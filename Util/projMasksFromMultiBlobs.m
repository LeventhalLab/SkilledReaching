function projMasks = projMasksFromMultiBlobs(mask, fundMat, imSize)

labelMat = bwlabel(mask);
h = size(mask,1);
w = size(mask,2);

numBlobs = max(labelMat(:));
if numBlobs == 0
    projMasks = false(size(mask));
    return
end

projMasks = cell(1,numBlobs);

for ii = 1 : numBlobs
    projMasks{ii} = projMaskFromTangentLines((labelMat==ii), fundMat, [1 1 w-1 h-1],imSize);
end