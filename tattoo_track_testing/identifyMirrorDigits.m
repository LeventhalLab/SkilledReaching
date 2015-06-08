function digitMask = identifyMirrorDigits(digitImg, rat_metadata, varargin)
%
% usage
%
% INPUTS:
%   digitImg - rgb masked image of paw in the relevant mirror. Seems to
%       work better if decorrstretched first to enhance color contrast
%   pawMask - black/white paw mask. easier to include this as an input than
%       extract from digitImg; if decorrstretch has been performed,
%       backgound isn't necessarily zero
%   rat_metadata - needed to know whether to look to the left or right of
%       the dorsal aspect of the paw to exclude points that can't be digits
%
% VARARGS:
%
% OUTPUTS:
%   digitMask - m x n x 5 matrix, where each m x n matrix contains a mask
%       for a part of the paw. 1st row - dorsum of paw, 2nd through 5th
%       rows are each digit from index finger to pinky

hsv_digitBounds = [0.55 0.25 0.00 0.40 0.20 0.50
                   0.70 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.35 0.60 0.40 1.00
                   0.25 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.60 1.00 0.40 1.00];
               
for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case digitBounds,
            hsv_digitBounds = varargin{iarg + 1};
    end
end

% find the centroid of the paw mask
pawDorsumBlob = vision.BlobAnalysis;
pawDorsumBlob.AreaOutputPort = true;
pawDorsumBlob.CentroidOutputPort = true;
pawDorsumBlob.BoundingBoxOutputPort = true;
pawDorsumBlob.LabelMatrixOutputPort = true;
pawDorsumBlob.MinimumBlobArea = 1000;

digitBlob = vision.BlobAnalysis;
digitBlob.AreaOutputPort = true;
digitBlob.CentroidOutputPort = true;
digitBlob.BoundingBoxOutputPort = true;
digitBlob.LabelMatrixOutputPort = true;
digitBlob.MinimumBlobArea = 50;
digitBlob.MaximumBlobArea = 500;

hsv_digitImg = rgb2hsv(digitImg);
% 1st row masks the dorsum of the paw
% next 4 rows mask the digits


digitMask = zeros(size(digitImg,1), size(digitImg,2), size(hsv_digitBounds,1));
SE = strel('disk',2);
digitCtr = zeros(size(hsv_digitBounds,1), 2);
for ii = 1 : size(hsv_digitBounds, 1)
    tempMask = double(HSVthreshold(hsv_digitImg, hsv_digitBounds(ii,:)));
    tempMask = bwdist(tempMask) < 2;
    tempMask = imopen(tempMask, SE);
    tempMask = imclose(tempMask, SE);
    tempMask = imfill(tempMask, 'holes');
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
        tempMask = logical(tempMask .* ~squeeze(digitMask(:,:,1)));
        [~, digit_c, ~, digitLabMat] = step(digitBlob, tempMask);
        % first, eliminate blobs that are on the wrong side of the paw
        % centroid (to the left in looking in the left mirror, to the right
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
            % first, get rid of any blobs whose centroid is above the previous
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
        end    % if ii > 2
        digitCtr(ii,:) = digit_c;
    end
        
    digitMask(:,:,ii) = tempMask;
end


% find the centroids of the digits

end