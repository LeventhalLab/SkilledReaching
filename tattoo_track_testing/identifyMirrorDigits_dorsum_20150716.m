function maskedPaw = identifyMirrorDigits_dorsum_20150716(video, frameNum, pawMask, rat_metadata, boxMarkers, varargin)
%
% usage
%
% function to find the initial location of the paw and digits in an image
% with a clear view of the paw in the mirrors
%
% INPUTS:
%   image - rgb image
%   pawMask - mask of the paw in the appropriate mirror (logical matrix)
%   rat_metadata - needed to know whether to look to the left or right of
%       the dorsal aspect of the paw to exclude points that can't be digits
%
% VARARGS:
%
% OUTPUTS:
%   maskedPaw - m x n x 5 matrix, where each m x n matrix contains a mask
%       for a part of the paw. 1st row - dorsum of paw, 2nd through 5th
%       rows are each digit from index finger to pinky

% NEED TO ADJUST THE VALUES TO ENHANCE THE DESIRED PAW BITS
% decorrStretchMean  = [100.0 127.5 100.0     % to isolate dorsum of paw
%                       100.0 127.5 100.0     % to isolate blue digits
%                       100.0 127.5 100.0     % to isolate red digits
%                       127.5 100.0 127.5     % to isolate green digits
%                       100.0 127.5 100.0];   % to isolate red digits
% 
% decorrStretchSigma = [050 050 050       % to isolate dorsum of paw
%                       050 050 050       % to isolate blue digits
%                       050 050 050       % to isolate red digits
%                       050 050 050       % to isolate green digits
%                       050 050 050];     % to isolate red digits

decorrStretchMean  = [150.0 100.0 150.0     % to isolate dorsum of paw
                      100.0 100.0 150.0     % to isolate blue digits
                      150.0 100.0 150.0     % to isolate red digits
                      127.5 100.0 127.5     % to isolate green digits
                      150.0 100.0 150.0];   % to isolate red digits

decorrStretchSigma = [050 025 025       % to isolate dorsum of paw
                      025 025 050       % to isolate blue digits
                      050 025 025       % to isolate red digits
                      050 050 050       % to isolate green digits
                      050 025 025];     % to isolate red digits
decorrStretchMean = decorrStretchMean / 255;
decorrStretchSigma = decorrStretchSigma / 255;
% hsv_digitBounds = [0.33 0.33 0.00 0.90 0.00 0.90
%                    0.67 0.16 0.90 1.00 0.80 1.00
%                    0.00 0.16 0.90 1.00 0.80 1.00
%                    0.33 0.16 0.90 1.00 0.90 1.00
%                    0.00 0.16 0.90 1.00 0.80 1.00];
% rgb_digitBounds = [0.00 0.50 0.50 1.00 0.00 0.80
%                    0.00 0.10 0.00 0.60 0.80 1.00
%                    0.90 1.00 0.00 0.40 0.00 0.40
%                    0.00 0.70 0.90 1.00 0.00 0.50
%                    0.00 0.16 0.90 1.00 0.80 1.00];

% rgb_digitBounds = [0.00 0.50 0.00 0.10 0.00 0.10
%                    0.00 0.10 0.00 0.60 0.80 1.00
%                    0.90 1.00 0.00 0.40 0.00 0.40
%                    0.00 0.70 0.90 1.00 0.00 0.50
%                    0.00 0.16 0.90 1.00 0.80 1.00];

colorList = {'darkgreen','blue','red','green','red'};
minSaturation = [0.00001,0.8,0.8,0.8,0.8];
max_Value = 0.15;
hueLimits = [0.00, 0.16;
             0.33, 0.16;
             0.66, 0.16];
h = video.Height;
w = video.Width;

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'digitbounds',
            rgb_digitBounds = varargin{iarg + 1};
        case 'decorrstretchmean',
            decorrStretchMean = varargin{iarg + 1};
        case 'decorrstretchsigma',
            decorrStretchSigma = varargin{iarg + 1};
    end
end

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
frameTime = ((frameNum-1) / video.FrameRate);    % need to subtract one because readFrame reads the NEXT frame, not the current frame
video.CurrentTime = frameTime;

image = readFrame(video);
image = double(image) / 255;

% create a mask for the box front in the left and right mirrors
boxFrontMask = poly2mask(boxMarkers.frontPanel_x(1,:), ...
                         boxMarkers.frontPanel_y(1,:), ...
                         h, w);
boxFrontMask = boxFrontMask | poly2mask(boxMarkers.frontPanel_x(2,:), ...
                                        boxMarkers.frontPanel_y(2,:), ...
                                        h, w);
                                    
numObjects = size(decorrStretchMean, 1);

pawDorsumBlob = vision.BlobAnalysis;
pawDorsumBlob.AreaOutputPort = true;
pawDorsumBlob.CentroidOutputPort = true;
pawDorsumBlob.BoundingBoxOutputPort = true;
pawDorsumBlob.ExtentOutputPort = true;
pawDorsumBlob.LabelMatrixOutputPort = true;
pawDorsumBlob.MinimumBlobArea = 100;

digitBlob = vision.BlobAnalysis;
digitBlob.AreaOutputPort = true;
digitBlob.CentroidOutputPort = true;
digitBlob.BoundingBoxOutputPort = true;
digitBlob.ExtentOutputPort = true;
digitBlob.LabelMatrixOutputPort = true;
digitBlob.MinimumBlobArea = 0000;
digitBlob.MaximumBlobArea = 1500;

% pawMask = (rgb2gray(image) > 0);
s = regionprops(pawMask,'area','centroid');
wholePawCentroid = s.Centroid;
% wholePawArea     = s.Area;      % this might be useful to set minimum and maximum digit/paw dorsum sizes as a function of the total paw size

% 1st row masks the dorsum of the paw
% next 4 rows mask the digits

masked_hsv_enh = zeros(numObjects,h,w,size(image,3));
rgbMask = double(repmat(pawMask,1,1,3));
for ii = 1 : numObjects
    
    % CREATE THE ENHANCED IMAGE DEPENDING ON ii BEFORE DOING ANYTHING ELSE
    rgb_enh = enhanceColorImage(image, ...
                                decorrStretchMean(ii,:), ...
                                decorrStretchSigma(ii,:), ...
                                'mask',pawMask);
	masked_hsv_enh(ii,:,:,:) = rgb2hsv(rgbMask .* squeeze(rgb_enh(:,:,:)));
end

dMask = zeros(h,w,numObjects);
SE = strel('disk',2);
s = regionprops(pawMask,'centroid');                      
wholePawCentroid = s.Centroid;
fullDigitMask = false(h,w);

for ii = 2 : numObjects    % CONSIDER PUTTING A CHECK HERE THAT IF ALL DIGITS AREN'T FOUND, TRY ANOTHER IMAGE
    switch lower(colorList{ii}),
        case 'red',
            colorIdx = 1;
        case 'green',
            colorIdx = 2;
        case 'blue',
            colorIdx = 3;
    end
    sameColIdx = find(strcmp(colorList{ii},colorList));
    if any(sameColIdx < ii)   % if mask already computed for a color, use the previous mask
        lastColIdx = max(sameColIdx(sameColIdx < ii));
        tempMask = dMask(:,:,lastColIdx);
    else
        tempMask = HSVthreshold(squeeze(masked_hsv_enh(ii,:,:,:)), ...
                                [hueLimits(colorIdx,:), minSaturation(ii), 1.0, 0.000001, 1.0]);
        tempMask = bwdist(tempMask) < 2;
        tempMask = imopen(tempMask, SE);
        tempMask = imclose(tempMask, SE);
        tempMask = imfill(tempMask, 'holes');

        s = regionprops(tempMask, 'centroid');
        centroids = [s.Centroid];
        centroids = reshape(centroids,2,[])';   % now an m x 2 array where each row is another centroid
        tempLabel = bwlabel(tempMask);

        if strcmpi(rat_metadata.pawPref,'right')   % looking in left mirror
            % take only blobs with centroids to the left of the paw centroid
            validIdx = find(centroids(:,1) < wholePawCentroid(1));
        else
            % take only blobs with centroids to the right of the paw centroid
            validIdx = find(centroids(:,1) > wholePawCentroid(1));
        end
        newMask = false(h,w);
        for jj = 1 : length(validIdx)
            newMask = newMask | (tempLabel == validIdx(jj));
        end

        % now take the n largest of the remaining blobs, where n is the number
        % of digits with that color
        n = length(find(strcmpi(colorList{ii},colorList)));
        s = regionprops(newMask, 'area');
        A = [s.Area];
        [~,idx] = sort(A, 'descend');
        tempLabel = bwlabel(newMask);
        tempMask = false(h,w);
        for jj = 1 : n
            tempMask = tempMask | (tempLabel == idx(jj));
        end
    end
    
    overlapMask = dMask(:,:,ii-1) & tempMask;
    dMask(:,:,ii-1) = dMask(:,:,ii-1) & ~overlapMask;
    tempMask = tempMask & ~overlapMask;
    
    dMask(:,:,ii) = tempMask;
        
end

for ii = 2 : numObjects
    fullDigitMask = fullDigitMask | imerode(dMask(:,:,ii),strel('disk',1));
end
% now need to assign blobs that are the same color to the appropriate digit
s = regionprops(fullDigitMask,'centroid');
centroids = [s.Centroid];
centroids = reshape(centroids,2,[])';   % now an m x 2 array where each row is another centroid
% sort centroids from top to bottom
[~, idx] = sort(centroids(:,2));
centroids = round(centroids(idx,:));

for ii = 1 : numObjects - 1
    regionMarker = false(h,w);
    regionMarker(centroids(ii,2),centroids(ii,1)) = true;
    dMask(:,:,ii+1) = imreconstruct(regionMarker, fullDigitMask);
end

% now identify the dorsum of the paw as everything on the opposite side of
% a line connecting the base of the index finger and pinky compared to the
% digit centroids
% start by creating the convex hull mask for all the digits together
[digitHullMask,digitHullPoints] = multiRegionConvexHullMask(fullDigitMask);
pdMask = HSVthreshold(squeeze(masked_hsv_enh(1,:,:,:)), ...
                      [0.5,0.5,0,1,0.0001,max_Value]);     % with the current (201507) tattoo regimen, best mask for paw dorsum is the grayscale
SE = strel('disk',2);

pdMask = pdMask & ~digitHullMask;    % make 
pdMask = bwdist(pdMask) < 2;
pdMask = imopen(pdMask, SE);
pdMask = imclose(pdMask, SE);
pdMask = imfill(pdMask, 'holes');

s = regionprops(pdMask, 'area');
pdLabel = bwlabel(pdMask);
A = [s.Area];
maxAreaIdx = find(A == max(A));
pdMask = (pdLabel == maxAreaIdx);
s = regionprops(pdMask,'Centroid');
pdCentroid = s(1).Centroid;
% find the two closest points in the digit region hull to the paw dorsum
% centroid as currently calculated. We are trying to get rid of any parts
% of the paw dorsum mask that really are part of the digit region; at this
% point, there may still be digit points around the edges included in the
% dorsum of the paw.

% find the hull point for the index finger closest to the paw dorsum
% centroid
s_idx = regionprops(squeeze(dMask(:,:,2)), 'ConvexHull');
[~,idx_nnidx] = findNearestNeighbor(pdCentroid, s_idx(1).ConvexHull, 1);
idx_base = s_idx(1).ConvexHull(idx_nnidx,:);
% find the hull point for the pinky closest to the paw dorsum centroid
[~,pinkyHullPoints] = multiRegionConvexHullMask(squeeze(dMask(:,:,5)));
[~,pinky_nnidx] = findNearestNeighbor(pdCentroid, pinkyHullPoints, 1);
pinky_base = pinkyHullPoints(pinky_nnidx,:);
% now find the hull points for the entire "digits" region closest to the
% hull points for the individual digits that are closest to the paw dorsum
% centroid. This ensures that when we draw a line separating the "digits"
% and "paw dorsum" regions, we take one point from the index finger and one
% point from the pinky finger.
nnHull = zeros(2,2);
[~,nnidx] = findNearestNeighbor(idx_base, digitHullPoints);
nnHull(1,:) = digitHullPoints(nnidx,:);
[~,nnidx] = findNearestNeighbor(pinky_base, digitHullPoints);
nnHull(2,:) = digitHullPoints(nnidx,:);

% now draw a line between the base of the pinky and index finger;
% everything on the same side of that line as the paw dorsum centroid is
% part of the paw dorsum; everything on the same side as the digit
% centroids is part of the digit region
% to separate these regions, create a mask that separates the image into
% two regions, and has true values on the same side as the index finger
% centroid
s = regionprops(dMask(:,:,2),'centroid');
digitRegionMask = segregateImage(nnHull, s.Centroid, [h, w]);
digitRegionMask = digitRegionMask | ...
                  dMask(:,:,2) | ...
                  dMask(:,:,3) | ...
                  dMask(:,:,4) | ...
                  dMask(:,:,5);
pdMask = pdMask & ~digitRegionMask;

dMask(:,:,1) = pdMask;

% now have all the fingers and the dorsum of the paw
% make sure none of the blobs overlap; the digit blobs already have been
% separated from each other
for ii = 2 : numObjects
    overlapMask = dMask(:,:,ii) & pdMask;
    dMask(:,:,ii) = dMask(:,:,ii) & ~overlapMask;
    pdMask = pdMask & ~overlapMask;
end
pdMask = imerode(pdMask, strel('disk',1));
dMask(:,:,1) = pdMask;

[~,P] = imseggeodesic(image, dMask(:,:,2), dMask(:,:,3), dMask(:,:,4));
[~, P2] = imseggeodesic(image, dMask(:,:,1), dMask(:,:,5), dMask(:,:,4));

maskedPaw = false(h, w, numObjects);
maskedPaw(:,:,1) = (P2(:,:,1) > 0.9) & pawMask & ~digitRegionMask;
maskedPaw(:,:,2) = (P(:,:,1) > 0.9) & pawMask;
maskedPaw(:,:,3) = (P(:,:,2) > 0.9) & pawMask;
maskedPaw(:,:,4) = (P(:,:,3) > 0.9) & pawMask;
maskedPaw(:,:,5) = (P2(:,:,2) > 0.9) & pawMask;

[pd_a,~,~,~,pdLabMask] = step(pawDorsumBlob, squeeze(maskedPaw(:,:,1)));
maxAreaIdx = find(pd_a == max(pd_a));
maskedPaw(:,:,1) = (pdLabMask == maxAreaIdx);

for ii = 1 : size(maskedPaw,3)
    if ii > 1
        [A,~,~,~,labMask] = step(digitBlob, squeeze(maskedPaw(:,:,ii)));
        maxAreaIdx = find(A == max(A));
        maskedPaw(:,:,ii) = (labMask == maxAreaIdx);    % WORKING HERE...
    end
    maskedPaw(:,:,ii) = imfill(squeeze(maskedPaw(:,:,ii)),'holes');
    maskedPaw(:,:,ii) = maskedPaw(:,:,ii) & ~boxFrontMask;
end


end