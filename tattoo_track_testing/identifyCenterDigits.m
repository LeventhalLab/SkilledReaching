function pawRegion = identifyCenterDigits(im, digitMirrorMask, fundmat, register_ROI, rat_metadata, varargin)
%
% usage: 
%
% INPUTS:
%    digitMirrorMask - m x n x 5 matrix, where each m x n layer is a binary
%       mask for the dorsum of the paw, or each digit from index to pinky,
%       respectively
% OUTPUTS:

hsv_digitBounds = [0.25 0.10 0.00 0.70 0.20 0.50
                   0.70 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.35 1.00 0.40 1.00
                   0.25 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.60 1.00 0.40 1.00];

ctr_paw_hsv_thresh = [0.5 0.5 0.20 0.6 0.20 0.7];
paw_bbox_buffer = 30;

pawBlob = vision.BlobAnalysis;
pawBlob.AreaOutputPort = true;
pawBlob.CentroidOutputPort = true;
pawBlob.BoundingBoxOutputPort = true;
pawBlob.ExtentOutputPort = true;
pawBlob.LabelMatrixOutputPort = true;
pawBlob.MinimumBlobArea = 2000;
pawBlob.MaximumBlobArea = 6000;

pawDorsumBlob = vision.BlobAnalysis;
pawDorsumBlob.AreaOutputPort = true;
pawDorsumBlob.CentroidOutputPort = true;
pawDorsumBlob.BoundingBoxOutputPort = true;
pawDorsumBlob.LabelMatrixOutputPort = true;
pawDorsumBlob.MinimumBlobArea = 000;

digitBlob = vision.BlobAnalysis;
digitBlob.AreaOutputPort = true;
digitBlob.CentroidOutputPort = true;
digitBlob.BoundingBoxOutputPort = true;
digitBlob.LabelMatrixOutputPort = true;
digitBlob.MinimumBlobArea = 50;
digitBlob.MaximumBlobArea = 1000;

extentLimit = 0.5;
for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'digitBounds',
            hsv_digitBounds = varargin{iarg + 1};
        case 'minpawarea',
            pawBlob.MinimumBlobArea = varargin{iarg + 1};
        case 'maxpawarea',
            pawBlob.MaximumBlobArea = varargin{iarg + 1};
        case 'extentlimit',
            extentLimit = varargin{iarg + 1};
    end
end

ctrImg = uint8(im(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                  register_ROI(2,1):register_ROI(2,1) + register_ROI(2,3), :));

% threshold the center image to find where the paw grossly should be
% located
ctrMask = HSVthreshold(rgb2hsv(ctrImg), paw_hsv_thresh);
SE = strel('disk',2);
ctrMask = bwdist(ctrMask) < 2;
ctrMask = imopen(ctrMask, SE);
ctrMask = imclose(ctrMask, SE);
ctrMask = imfill(ctrMask, 'holes');

[~, ~, ~, ~, paw_labMat] = step(pawBlob, ctrMask);
ctrMask = paw_labMat > 0;    % eliminates blobs that are too big or too small
[~, ~, ~, paw_extent, paw_labMat] = step(pawBlob, ctrMask);
% eliminate blobs that don't take up enough of their bounding box
extIdx = find(paw_extent > extentLimit);
ctrMask = false(size(ctrMask));
for ii = 1 : length(extIdx)
    ctrMask = ctrMask | (paw_labMat == extIdx(ii));
end
[~, paw_c, ~, ~, paw_labMat] = step(pawBlob, ctrMask);

% find the top and bottom of the paw mask from the mirror
mirrorPawBottom = 0;
mirrorPawTop = size(digitMirrorMask, 1);
for ii = 1 : size(digitMirrorMask, 3)
    [mirrorMaskRows,mirrorMaskCols] = find(squeeze(digitMirrorMask(:,:,ii)));
    if max(mirrorMaskRows) > mirrorPawBottom
        mirrorBotIdx = find(mirrorMaskRows == max(mirrorMaskRows),1);
        mirrorPawBottom = [mirrorMaskCols(mirrorBotIdx), mirrorMaskRows(mirrorBotIdx)];
    end
    if min(mirrorMaskRows) < mirrorPawTop
        mirrorTopIdx = find(mirrorMaskRows == min(mirrorMaskRows),1);
        mirrorPawTop = [mirrorMaskCols(mirrorTopIdx), mirrorMaskRows(mirrorTopIdx)];
    end
end
% calculate the epipolar lines corresponding to these points, find the
% candidate blob with the most overlap with the region between the epipolar
% lines
borderLines = epipolarLine(fundmat, [mirrorPawTop;mirrorPawBottom]);
% create a mask with true values between the epipolar lines
x = 1:size(ctrMask,2);
epipolarRegions = zeros(size(ctrMask,1),size(ctrMask,2),2);
for ii = 1 : 2
    for jj = 1 : size(ctrMask, 1)
        epipolarRegions(jj, :, ii) = x * borderLines(ii,1) + jj * borderLines(ii,2);
    end
    epipolarRegions(:,:,ii) = epipolarRegions(:,:,ii) + borderLines(ii,3);
end
% create a masking matrix with true values between the epipolar lines from
% the top and bottom of the paw in the mirror projection
projectionMask = (epipolarRegions(:,:,1) < 0) & (epipolarRegions(:,:,2) > 0);
% take only the largest region that overlaps with projectionMask
ctrPawMask = projectionMask & ctrMask;
[paw_proj_a, ~, ~, ~, paw_proj_labMat] = step(pawBlob, ctrPawMask);
max_a_idx = find(paw_proj_a == max(paw_proj_a));
ctrPawMask = (paw_proj_labMat == max_a_idx);
% find points from ctrMask (paw masking based only on colors and
% morphological features) within projectionMask
ctrPawMask = uint8(ctrPawMask) .* paw_labMat;
% figure out which blob element(s) are contained within the projection
% region
validRegionList = unique(ctrPawMask);
validRegion = validRegionList(validRegionList > 0);
ctrPawMask = (paw_labMat == validRegion);
[~, ~, paw_bbox, ~, ~] = step(pawBlob, ctrPawMask);

paw_bbox = [paw_bbox(1) - paw_bbox_buffer, ...
            paw_bbox(2) - paw_bbox_buffer, ...
            paw_bbox(3) + 2 * paw_bbox_buffer, ...
            paw_bbox(4) + 2 * paw_bbox_buffer];

pawRegion = ctrImg(paw_bbox(2):paw_bbox(2)+paw_bbox(4), ...
                   paw_bbox(1):paw_bbox(1)+paw_bbox(3), :);
% at this point, have a window around the paw (hopefully). Now stretch the
% colors, see if we can identify the individual digits
pawRegion_enh = decorrstretch(pawRegion);

% now have an enhanced image where we should be able to pull out the digits
% pretty well
hsv_digitImg = rgb2hsv(pawRegion_enh);

% 1st row masks the dorsum of the paw
% next 4 rows mask the digits
digitMask = zeros(size(pawRegion,1), size(pawRegion,2), size(hsv_digitBounds,1));
SE = strel('disk',2);
digitCtr = zeros(size(hsv_digitBounds,1), 2);

for ii = 1 : size(hsv_digitBounds, 1)
    % find epipolar lines inside the pawRegion window
    [paw_y, paw_x] = find(squeeze(digitMirrorMask(:,:,ii)));
    epiLines = epipolarLine(fundmat, [paw_x, paw_y]);
end
for ii = 1 : size(hsv_digitBounds, 1)
    
    
    tempMask = double(HSVthreshold(hsv_digitImg, hsv_digitBounds(ii,:)));
    tempMask = bwdist(tempMask) < 2;
    tempMask = imopen(tempMask, SE);
    tempMask = imclose(tempMask, SE);
    tempMask = imfill(tempMask, 'holes');
    
    
    
% COMMENTED STUFF BELOW IS IMPORTED FROM THE IDENTIFY MIRROR DIGITS
% FUNCTION. HERE FOR REFERENCE, TO BE DELETED ONCE FRONT VIEW ALGORITHM IS
% SET
%     if ii == 1    % masking out the dorsum of the paw
%         % keep only the largest region
%         [paw_a, ~, ~, pawLabMat] = step(pawDorsumBlob,tempMask);
%         maxRegionIdx = find(paw_a == max(paw_a));
%         tempMask = (pawLabMat == maxRegionIdx);
%         [~, digitCtr(ii,:), ~, ~] = step(pawDorsumBlob,tempMask);
%     else
% 
%         
        
%         % use the coordinates of the dorsum of the paw to help identify
%         % which digit is which. needed because orange and red look so much
%         % alike
%         % first, exclude any points labeled as the dorsal aspect of the paw
%         % from the digits
%         tempMask = logical(tempMask .* ~squeeze(digitMask(:,:,1)));
%         [~, digit_c, ~, digitLabMat] = step(digitBlob, tempMask);
%         % first, eliminate blobs that are on the wrong side of the paw
%         % centroid (to the left if rat is righthanded, to the right if the
%         % rat is lefthanded).
%         if strcmpi(rat_metadata.pawPref,'right')    % digits to right of paw dorsum
%             % looking in the left mirror for the digits
%             digitIdx = find(digit_c(:,1) < digitCtr(1));
%         else
%             % looking in the right mirror for the digits
%             digitIdx = find(digit_c(:,1) > digitCtr(1));
%         end
%         if ~isempty(digitIdx)
%             for jj = 1 : length(digitIdx)
%                 digitLabMat(digitLabMat == digitIdx(jj)) = 0;
%             end
%             tempMask = (digitLabMat > 0);
%         end
%         [~, digit_c, ~, digitLabMat] = step(digitBlob, tempMask);
        
%         if ii > 2
%             % first, get rid of any blobs whose centroid is above the previous
%             % digit centroid
%             digitIdx = find(digit_c(:,2) < digitCtr(ii-1,2));
%             if ~isempty(digitIdx)
%                 for jj = 1 : length(digitIdx)
%                     digitLabMat(digitLabMat == digitIdx(jj)) = 0;
%                 end
%                 tempMask = (digitLabMat > 0);
%             end
%             [~, digit_c, ~, digitLabMat] = step(digitBlob, tempMask);
%             % now, take the blob closest to the previous digit
%             digitDist = zeros(size(digit_c,1),2);
%             digitDist(:,1) = digitCtr(ii-1,1) - digit_c(:,1);
%             digitDist(:,2) = digitCtr(ii-1,2) - digit_c(:,2);
%             digitDistances = sum(digitDist.^2,2);
%             minDistIdx = find(digitDistances == min(digitDistances));
%             tempMask = (digitLabMat == minDistIdx);
%             [~, digit_c, ~, ~] = step(digitBlob, tempMask);
%         elseif size(digit_c,1) > 1
%             % the location of this digit is constrained by the location of
%             % the 
%         end 
        digitCtr(ii,:) = digit_c;
    end
end