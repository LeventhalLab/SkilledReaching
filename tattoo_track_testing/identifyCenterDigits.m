function centerMask = identifyCenterDigits(centerImg, digitMirrorMask, fundmat, rat_metadata, varargin)
%
% usage
%
% INPUTS:
%   centerImg - rgb masked image of paw in the direct camera view. Seems to
%       work better if decorrstretched first to enhance color contrast
%   digitMirrorMask - 
%   fundmat - 
%   rat_metadata - needed to know whether to look to the left or right of
%       the dorsal aspect of the paw to exclude points that can't be digits
%
% VARARGS:
%
% OUTPUTS:
%   centerMask - m x n x 5 matrix, where each m x n matrix contains a mask
%       for a part of the paw. 1st row - dorsum of paw, 2nd through 5th
%       rows are each digit from index finger to pinky

hsv_digitBounds = [0.25 0.20 0.00 0.30 0.20 0.50
                   0.70 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.35 0.70 0.40 1.00
                   0.25 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.60 1.00 0.40 1.00];
               
for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case digitBounds,
            hsv_digitBounds = varargin{iarg + 1};
    end
end

pawDorsumBlob = vision.BlobAnalysis;
pawDorsumBlob.AreaOutputPort = true;
pawDorsumBlob.CentroidOutputPort = true;
pawDorsumBlob.BoundingBoxOutputPort = true;
pawDorsumBlob.LabelMatrixOutputPort = true;
pawDorsumBlob.MinimumBlobArea = 0000;

digitBlob = vision.BlobAnalysis;
digitBlob.AreaOutputPort = true;
digitBlob.CentroidOutputPort = true;
digitBlob.BoundingBoxOutputPort = true;
digitBlob.LabelMatrixOutputPort = true;
digitBlob.MinimumBlobArea = 50;
digitBlob.MaximumBlobArea = 500;

hsv_centerImg = rgb2hsv(centerImg);

% 1st row masks the dorsum of the paw
% next 4 rows mask the digits
centerMask = false(size(centerImg,1), size(centerImg,2), size(hsv_digitBounds,1));
SE = strel('disk',2);
digitCtr = zeros(size(hsv_digitBounds,1), 2);
for ii = 1 : size(hsv_digitBounds, 1)
    % calculate the boundaries of the projection from the mirror into the
    % direct camera view
    [mirrorMaskRows,mirrorMaskCols] = find(squeeze(digitMirrorMask(:,:,ii)));
    mirrorBotIdx = find(mirrorMaskRows == max(mirrorMaskRows),1);
    mirrorTopIdx = find(mirrorMaskRows == min(mirrorMaskRows),1);
    mirrorPawBottom = [mirrorMaskCols(mirrorBotIdx), mirrorMaskRows(mirrorBotIdx)];
    mirrorPawTop    = [mirrorMaskCols(mirrorTopIdx), mirrorMaskRows(mirrorTopIdx)];
    
    borderLines = epipolarLine(fundmat, [mirrorPawTop;mirrorPawBottom]);
    
    % create a mask with true values between the epipolar lines
    x = 1:size(centerImg,2);
    epipolarRegions = zeros(size(centerImg,1),size(centerImg,2),2);
    for jj = 1 : 2
        for kk = 1 : size(centerImg, 1)
            epipolarRegions(kk, :, jj) = x * borderLines(jj,1) + kk * borderLines(jj,2);
        end
        epipolarRegions(:,:,jj) = epipolarRegions(:,:,jj) + borderLines(jj,3);
    end
    if strcmpi(rat_metadata.pawPref,'right')       % haven't thought through why the signs change for the
                                                   % region of interest depending on whether mapping the left
                                                   % or right mirror to the direct view, but this seems to
                                                   % work
        projectionMask = (epipolarRegions(:,:,1) < 0) & (epipolarRegions(:,:,2) > 0);
    else
        projectionMask = (epipolarRegions(:,:,1) > 0) & (epipolarRegions(:,:,2) < 0);
    end
    
    tempMask = double(HSVthreshold(hsv_centerImg, hsv_digitBounds(ii,:)));
    tempMask = bwdist(tempMask) < 2;
    tempMask = imopen(tempMask, SE);
    tempMask = imclose(tempMask, SE);
    tempMask = imfill(tempMask, 'holes');
    
    % only accept regions within the projection of the mirror paw dorsum /
    % digit into the direct camera view. make sure to keep elements of
    % blobs that lie both within and outside the projection area
    [~,~,~,paw_labMat] = step(pawDorsumBlob, tempMask);
    tempMask2 = paw_labMat .* uint8(projectionMask);
    validRegionList = unique(tempMask2);
    validRegions = validRegionList(validRegionList > 0);
    tempMask = false(size(centerImg,1),size(centerImg,2));
    for jj = 1 : length(validRegions)
        tempMask = tempMask | (paw_labMat == validRegions(jj));
    end
    
    % THINK ABOUT WHETHER IT'S WORTH FINDING DIGIT
    % CANDIDATES BEFORE EXTRACTING THE PAW PROPER. THIS MAY ALSO BE USEFUL
    % IN THE MIRROR ALGORITHM
    if ii == 1    % masking out the dorsum of the paw
        % keep only the largest region
        [paw_a, ~, ~, pawLabMat] = step(pawDorsumBlob,tempMask);
        maxRegionIdx = find(paw_a == max(paw_a));
        tempMask = (pawLabMat == maxRegionIdx);
        [~, digitCtr(ii,:), ~, ~] = step(pawDorsumBlob,tempMask);
    else
        % use the coordinates of the dorsum of the paw to help identify
        % which digit is which. needed because orange and red look so much
        % alike
        % first, exclude any points labeled as the dorsal aspect of the paw
        % from the digits
        tempMask = logical(tempMask .* ~squeeze(centerMask(:,:,1)));
        [~, digit_c, ~, digitLabMat] = step(digitBlob, tempMask);
        % first, eliminate blobs that are on the wrong side of the paw
        % centroid (to the left if looking in the left mirror, to the right
        % if looking in the right mirror).
        if strcmpi(rat_metadata.pawPref,'right')    % back of paw in the left mirror
            % looking in the left mirror for the digits
            digitIdx = find(digit_c(:,1) < digitCtr(1));
        else
            % looking in the right mirror for the digits
            digitIdx = find(digit_c(:,1) > digitCtr(1));
        end
        if ~isempty(digitIdx)
            for jj = 1 : length(digitIdx)
                digitLabMat(digitLabMat == digitIdx(jj)) = 0;
            end
            tempMask = (digitLabMat > 0);
        end
        [~, digit_c, ~, digitLabMat] = step(digitBlob, tempMask);
        % now, take the blob that is closest to the previous digit & below
        % it. Can't do this for the first digit
        if ii > 2
            % get rid of any blobs whose centroid is above the previous
            % digit centroid
            digitIdx = find(digit_c(:,2) < digitCtr(ii-1,2));
            if ~isempty(digitIdx)
                for jj = 1 : length(digitIdx)
                    digitLabMat(digitLabMat == digitIdx(jj)) = 0;
                end
                tempMask = (digitLabMat > 0);
            end
            [~, digit_c, ~, digitLabMat] = step(digitBlob, tempMask);
            % now, take the blob closest to the previous digit
            digitDist = zeros(size(digit_c,1),2);
            digitDist(:,1) = digitCtr(ii-1,1) - digit_c(:,1);
            digitDist(:,2) = digitCtr(ii-1,2) - digit_c(:,2);
            digitDistances = sum(digitDist.^2,2);
            minDistIdx = find(digitDistances == min(digitDistances));
            tempMask = (digitLabMat == minDistIdx);
            [~, digit_c, ~, ~] = step(digitBlob, tempMask);
        elseif size(digit_c,1) > 1
            % take the centroid closest to the dorsum of the paw if this is
            % the first digit identified
            x_dist = digit_c(:,1) - digitCtr(1,1);
            y_dist = digit_c(:,2) - digitCtr(1,2);
            dist_from_paw = x_dist.^2 + y_dist.^2;
            minDistIdx = find(dist_from_paw == min(dist_from_paw));
            tempMask = (digitLabMat == minDistIdx);
            [~, digit_c, ~, ~] = step(digitBlob, tempMask);
            % NOTE, NOT SURE IF THIS WILL BE ROBUST - COULD GET BLOBS
            % CLOSER TO THE PAW CENTROID THAN THE DIGITS - DL 20150609
        end    % if ii > 2
        digitCtr(ii,:) = digit_c;
    end
        
    centerMask(:,:,ii) = tempMask;
end


% find the centroids of the digits

end