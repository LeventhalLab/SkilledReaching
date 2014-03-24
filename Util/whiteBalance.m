function [wbImage] = whiteBalance(image, saveWbImageAs)
    pageSize = size(image,1) * size(image,2);
    avgRgb = mean(reshape(image, [pageSize,3]));
    avgAll = mean(avgRgb);
    scaleArray = max(avgAll, 128)./avgRgb;
    scaleArray = reshape(scaleArray,1,1,3);
    wbImage = uint8(bsxfun(@times,double(image),scaleArray));
    imwrite(wbImage,saveWbImageAs);
end