function [cb_pts, varargout] = detect_SR_checkerboard(I, varargin)
%
% usage: 

blackThresh = 60;
whiteThresh = 170;
areaLimits  = [1500 3500];
minExtent   = 0.8;
eccLimits   = [0 1];
maxCentroidSeparation = 90;
maxVertexSeparation = 10;    % for finding points that really represent the same vertex
pointsPerRow = 4;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'blackthresh',
            blackThresh = varargin{iarg + 1};
        case 'whitethresh',
            whiteThresh = varargin{iarg + 1};
        case 'arealimits',
            areaLimits = varargin{iarg + 1};
        case 'pointsperrow',
            pointsPerRow = varargin{iarg + 1};
    end
end

squareBlob = vision.BlobAnalysis;
squareBlob.AreaOutputPort = true;
squareBlob.CentroidOutputPort = true;
squareBlob.BoundingBoxOutputPort = true;
squareBlob.EccentricityOutputPort = true;
squareBlob.ExtentOutputPort = true;
squareBlob.LabelMatrixOutputPort = true;
squareBlob.MinimumBlobArea = areaLimits(1);   % eliminate everything that is too small
squareBlob.MaximumBlobArea = areaLimits(2);   % or too big

gray_I = rgb2gray(I);
% first, find the outline of the checkerboard
% threshold to find the black squares
blackSquareMask = gray_I < blackThresh;

SE = strel('disk',2);
blackSquareMask = imopen(blackSquareMask,SE);
blackSquareMask = imclose(blackSquareMask,SE);
blackSquareMask = imfill(blackSquareMask,'holes');
        
[blackSquareArea,blackSquareCent, blackSquarebbox, blackSquareEccentricity,blackSquareExtent,blackSquareLabelMatrix] = step(squareBlob,blackSquareMask);

% check that the extent (area/area of bounding box)of each region is
% large enough
validExtentIdx = find(blackSquareExtent > minExtent);
blackSquareMask = false(size(gray_I));
for ii = 1 : length(validExtentIdx)
    blackSquareMask = blackSquareMask | (blackSquareLabelMatrix == validExtentIdx(ii));
end
[blackSquareArea,blackSquareCent, blackSquarebbox, blackSquareEccentricity,blackSquareExtent,blackSquareLabelMatrix] = step(squareBlob,blackSquareMask);
% check that the eccentricity is in the appropriate range. Excludes, for
% example, vertical or horizontal lines that might not be captured by the
% Extent constraint above
validEccentricityIdx = find(blackSquareEccentricity > eccLimits(1) & blackSquareEccentricity < eccLimits(2));
blackSquareMask = false(size(gray_I));
for ii = 1 : length(validEccentricityIdx)
    blackSquareMask = blackSquareMask | (blackSquareLabelMatrix == validEccentricityIdx(ii));
end
[blackSquareArea,blackSquareCent, blackSquarebbox, blackSquareEccentricity,blackSquareExtent,blackSquareLabelMatrix] = step(squareBlob,blackSquareMask);

% now, throw out blobs that are too far away from the other blobs
[nn, meansep,~] = nearestNeighbor(blackSquareCent);
validDistanceIdx = find(nn < maxCentroidSeparation);
blackSquareMask = false(size(gray_I));
for ii = 1 : length(validDistanceIdx)
    blackSquareMask = blackSquareMask | (blackSquareLabelMatrix == validDistanceIdx(ii));
end
[blackSquareArea,blackSquareCent, blackSquarebbox, blackSquareEccentricity,blackSquareExtent,blackSquareLabelMatrix] = step(squareBlob,blackSquareMask);
% at this point, should have the black squares isolated pretty well
% now find the white squares that satisfy "squareness" criteria. Note, this
% may miss some edge white squares because of the ruler shelf they sit on
whiteSquareMask = gray_I > whiteThresh;

SE = strel('disk',2);
whiteSquareMask = imopen(whiteSquareMask,SE);
whiteSquareMask = imclose(whiteSquareMask,SE);
whiteSquareMask = imfill(whiteSquareMask,'holes');
[whiteSquareArea,whiteSquareCent, whiteSquarebbox, whiteSquareEccentricity,whiteSquareExtent,whiteSquareLabelMatrix] = step(squareBlob,whiteSquareMask);

% check that the extent (area/area of bounding box)of each region is
% large enough
validExtentIdx = find(whiteSquareExtent > minExtent);
whiteSquareMask = false(size(gray_I));
for ii = 1 : length(validExtentIdx)
    whiteSquareMask = whiteSquareMask | (whiteSquareLabelMatrix == validExtentIdx(ii));
end
[whiteSquareArea,whiteSquareCent, whiteSquarebbox, whiteSquareEccentricity,whiteSquareExtent,whiteSquareLabelMatrix] = step(squareBlob,whiteSquareMask);
% check that the eccentricity is in the appropriate range. Excludes, for
% example, vertical or horizontal lines that might not be captured by the
% Extent constraint above
validEccentricityIdx = find(whiteSquareEccentricity > eccLimits(1) & whiteSquareEccentricity < eccLimits(2));
whiteSquareMask = false(size(gray_I));
for ii = 1 : length(validEccentricityIdx)
    whiteSquareMask = whiteSquareMask | (whiteSquareLabelMatrix == validEccentricityIdx(ii));
end
[whiteSquareArea,whiteSquareCent, whiteSquarebbox, whiteSquareEccentricity,whiteSquareExtent,whiteSquareLabelMatrix] = step(squareBlob,whiteSquareMask);

% now, throw out blobs that are too far away from the other blobs
[nn, meansep] = nearestNeighbor(whiteSquareCent);
validDistanceIdx = find(nn < maxCentroidSeparation);
whiteSquareMask = false(size(gray_I));
for ii = 1 : length(validDistanceIdx)
    whiteSquareMask = whiteSquareMask | (whiteSquareLabelMatrix == validDistanceIdx(ii));
end
[whiteSquareArea,whiteSquareCent, whiteSquarebbox, whiteSquareEccentricity,whiteSquareExtent,whiteSquareLabelMatrix] = step(squareBlob,whiteSquareMask);

% at this point, may have fewer white squares than really exist, but should
% be enough to help define the minimun quadrilateral bounding the
% checkerboard
squareMask = blackSquareMask | whiteSquareMask;

% find the minimum quadrilateral that will bound the black squares
% first, find the convex hull for each square
props = regionprops(squareMask,'convexhull');
hullPoints = props(1).ConvexHull;
for ii = 1 : length(props)
    hullPoints = [hullPoints;props(ii).ConvexHull];
end
[qx,qy,~] = minboundquad(hullPoints(:,1),hullPoints(:,2));
quadMask = poly2mask(qx,qy,size(I,1),size(I,2));    % create a mask within which all checkerboard points must reside

% now, identify white squares again, but only those squares within quadMask
whiteSquareMask = gray_I > whiteThresh & quadMask;
SE = strel('disk',2);
whiteSquareMask = imopen(whiteSquareMask,SE);
whiteSquareMask = imclose(whiteSquareMask,SE);
whiteSquareMask = imfill(whiteSquareMask,'holes');

% squareMask = blackSquareMask | whiteSquareMask;

% find minimum bounding qudrilaterals around each square, and that should
% give us our checkerboard corners for point matching
blackSquareProps = regionprops(blackSquareMask,'convexhull');
whiteSquareProps = regionprops(whiteSquareMask,'convexhull');
props = [blackSquareProps; whiteSquareProps];
qx = zeros(length(props) * 5,1);qy = zeros(length(props) * 5,1);
for ii = 1 : length(props)
    startIdx = (ii-1)*5 + 1;endIdx = ii*5;
    [qx(startIdx:endIdx),qy(startIdx:endIdx),~] = ...
        minboundquad(props(ii).ConvexHull(:,1),props(ii).ConvexHull(:,2));
end
% get rid of points that are repeats
vtx = unique([qx,qy],'rows');

% now find points that really represent the same vertex and average them
diffMatrix = zeros(size(vtx,1)-1,size(vtx,2));

for ii = 1 : size(vtx,1)
    ctrPoint = vtx(ii,:);
    switch ii
        case 1,
            otherPoints = vtx(ii+1:end,:);
        case size(vtx,1),
            otherPoints = vtx(1:end-1,:);
        otherwise,
            otherPoints = [vtx(1:ii-1,:);vtx(ii+1:end,:)];   
    end
    for jj = 1 : size(vtx,2)
        diffMatrix(:,jj) = ctrPoint(jj) - otherPoints(:,jj);
    end
    distances = sqrt(sum(diffMatrix.^2, 2));
    distIdx = find(distances < maxVertexSeparation);
    distIdx(distIdx >= ii) = distIdx(distIdx >= ii) + 1;
    distIdx = [distIdx; ii];
    if ii == 1
        cb_pts = mean(vtx(distIdx,:),1);
    else
        cb_pts = [cb_pts;mean(vtx(distIdx,:),1)];
    end
end
cb_pts = round(cb_pts * 1e4)/1e4;    % get rid of rounding errors past 10^-4
cb_pts = unique(cb_pts,'rows');

% sort checkerboard points so they go from top left to bottom right, moving
% from left to right then top to bottom
% first, sort along the y-axis
[~, idx] = sort(cb_pts(:,2));
cb_pts = cb_pts(idx,:);
% sort the points in each block of pointsPerRow points
numRows = size(cb_pts,1) / pointsPerRow;
if numRows ~= round(numRows)
    disp('different numbers of points in each row, unable to sort');
    return;
end

for iRow = 1 : numRows
    startIdx = (iRow-1)*pointsPerRow + 1;
    endIdx   = iRow*pointsPerRow;
    tempPts  = cb_pts(startIdx:endIdx,:);
    [~, idx] = sort(tempPts(:,1),1);
    tempPts = tempPts(idx,:);
    cb_pts(startIdx:endIdx,:) = tempPts;
end

% figure(1);imshow(blackSquareMask);
% figure(2);imshow(quadMask);
% figure(3);imshow(whiteSquareMask);
% figure(4);imshow(I);
% figure(5);imshow(blackSquareMask | whiteSquareMask);


end