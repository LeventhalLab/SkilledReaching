function [pts, numIterations] = detectDirectCalibrationPoints(img, boardMask, anticipatedSize)

detectedSize = [0 0];
mincornermetric = 0.05;
numIterations = 0;
maxIterations = 10;
maxCentroidSep = 10;
minAreaRatio = 0.2;

boardProps = regionprops(boardMask,'centroid','Area');
exitFlag = false;
while ~exitFlag
    
    [pts, detectedSize] = detectCheckerboardPoints(img,'mincornermetric',mincornermetric);
    if size(pts,1) < 3
        mincornermetric = mincornermetric + 0.05;
        numIterations = numIterations + 1;
        continue;
    end
    cvHull = convhull(pts);
    cvMask = poly2mask(pts(cvHull,1),pts(cvHull,2),size(img,1),size(img,2));
    
    cvProps = regionprops(cvMask,'centroid','Area');
    % the centroids of cvMask and boardMask should be very close to each
    % other
    centroidSep = vecnorm(cvProps.Centroid - boardProps.Centroid);
    areaRatio = cvProps.Area / boardProps.Area;
    
   
    
    if (all(detectedSize == anticipatedSize) || ...
        all(detectedSize == fliplr(anticipatedSize))) && ...
        centroidSep < maxCentroidSep && ...
        areaRatio > minAreaRatio
    
        exitFlag = true;
    end

	if numIterations >= maxIterations
        exitFlag = true;
    end
    
    mincornermetric = mincornermetric + 0.05;
    numIterations = numIterations + 1;
    
end
    
if numIterations < maxIterations
    return;
end


% something went wrong and it didn't find the corners properly