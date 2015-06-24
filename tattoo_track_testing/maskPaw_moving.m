function paw_mask = maskPaw_moving( img, BGimg, prev_paw_mask, register_ROI, F, rat_metadata, boxMarkers, varargin )
%
% usage:
%
% INPUTS:
%   img - the image in which to find the paw mask
%   BGimg - 
%   prev_paw_mask - 
%   register_ROI
%   F - 2 x 3 x 3 matrix; first dimension is left vs right mirror;
%   	next two dimensions are the fundamental matrices themselves
%   register_ROI - 

diff_threshold = 45;
extentLimit = 0.5;
% epiThresh = 0.2;

decorrStretchMean  = [100.5 127.5 100.5];
decorrStretchSigma = [025 050 025];

ctr_paw_hsv_thresh_enh = [0.5 0.5 0.40 1.0 0.40 1.0];
% ctr_paw_hsv_thresh = [0.5 0.5 0.40 1.0 0.40 1.0];

centerPawBlob = vision.BlobAnalysis;
centerPawBlob.AreaOutputPort = true;
centerPawBlob.CentroidOutputPort = true;
centerPawBlob.BoundingBoxOutputPort = true;
centerPawBlob.ExtentOutputPort = true;
centerPawBlob.LabelMatrixOutputPort = true;
centerPawBlob.MinimumBlobArea = 0;
centerPawBlob.MaximumBlobArea = 30000;

mirrorPawBlob = vision.BlobAnalysis;
mirrorPawBlob.AreaOutputPort = true;
mirrorPawBlob.CentroidOutputPort = true;
mirrorPawBlob.BoundingBoxOutputPort = true;
mirrorPawBlob.ExtentOutputPort = true;
mirrorPawBlob.LabelMatrixOutputPort = true;
mirrorPawBlob.MinimumBlobArea = 3000;
mirrorPawBlob.MaximumBlobArea = 10000;

maxPixelsTraveled = 15;

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'diffthreshold',
            diff_threshold = varargin{iarg + 1};
        case 'extentlimit',
            extentLimit = varargin{iarg + 1};
        case 'mincenterpawarea',
            centerPawBlob.MinimumBlobArea = varargin{iarg + 1};
        case 'maxcenterpawarea',
            centerPawBlob.MaximumBlobArea = varargin{iarg + 1};
        case 'minmirrorpawarea',
            mirrorPawBlob.MinimumBlobArea = varargin{iarg + 1};
        case 'maxmirrorpawarea',
            mirrorPawBlob.MaximumBlobArea = varargin{iarg + 1};
        case 'maxpixelstraveled',
            maxPixelsTraveled = varargin{iarg + 1};
    end
end

SE = strel('disk',4);

paw_diff_img = cell(1,3);paw_img = cell(1,3);
thresh_mask = cell(1,3);
paw_mask = cell(1,3);
bg_subtracted_image = imabsdiff(img, BGimg);
thresh_mask = rgb2gray(bg_subtracted_image) > diff_threshold;
thresh_mask = thresh_mask & imdilate(prev_paw_mask, strel('disk',maxPixelsTraveled));
paw_mask = bwdist(thresh_mask) < 2;
paw_mask = imopen(paw_mask, SE);
paw_mask = imclose(paw_mask,SE);
% try dilating the image slightly to make sure we don't miss the
% boundaries of the paw/digits
paw_mask = imfill(paw_mask,'holes');
paw_mask = imdilate(paw_mask,SE);
% WORKING HERE - NEED TO DO SOMETHING FANCIER THAN JUST BACKGROUND
% SUBTRACTION FOR THE DIRECT VIEW OF THE PAW; SHOULD WORK FOR THE MIRROR
% VIEWS, THOUGH.
    
    
% create a mask for the box front in the left and right mirrors
boxFrontMask = cell(1,2);
x_boxFront = boxMarkers.frontPanel_x(1,:) - register_ROI(1,1) + 1;
y_boxFront = boxMarkers.frontPanel_y(1,:) - register_ROI(1,2) + 1;
boxFrontMask{1} = poly2mask(x_boxFront, ...
                            y_boxFront, ...
                            register_ROI(1,4) + 1, ...
                            register_ROI(1,3) + 1);
x_boxFront = boxMarkers.frontPanel_x(2,:) - register_ROI(3,1) + 1;
y_boxFront = boxMarkers.frontPanel_y(1,:) - register_ROI(3,2) + 1;
boxFrontMask{2} = poly2mask(x_boxFront, ...
                            y_boxFront, ...
                            register_ROI(3,4) + 1, ...
                            register_ROI(3,3) + 1);
for ii = 1 : 3
    paw_diff_img{ii} = bg_subtracted_image(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                                           register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3),:);
    paw_img{ii} = img(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                      register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3),:);
                                                               
	thresh_mask{ii} = rgb2gray(paw_diff_img{ii}) > diff_threshold;
end

% work on the left and right images first...
SE = strel('disk',4);
for ii = 1 : 2 : 3
%     prev_mask = imdilate(prev_paw_mask{ii}, strel('disk',maxPixelsTraveled));
%     prev_mask = fliplr(prev_mask);
    
    figure(1)
    imshow(prev_mask)
    figure(2)
    imshow(thresh_mask{ii})
    paw_mask{ii} = thresh_mask{ii} & prev_mask;
    paw_mask{ii} = bwdist(paw_mask{ii}) < 2;
    paw_mask{ii} = imopen(paw_mask{ii}, SE);
    paw_mask{ii} = imclose(paw_mask{ii},SE);
    % try dilating the image slightly to make sure we don't miss the
    % boundaries of the paw/digits
    paw_mask{ii} = imfill(paw_mask{ii},'holes');
    paw_mask{ii} = imdilate(paw_mask{ii},SE);
    paw_mask{ii} = fliplr(paw_mask{ii});
    
    % NEED TO FIGURE OUT HOW TO ACCOUNT FOR PAW PASSING
    % BEHIND THE FRONT PANEL OF THE BOX

    
    
    
    % take only the largest region from each mask
%     [A,~,~,~,labelMask] = step(mirrorPawBlob, paw_mask{ii});
%     validIdx = find(A == max(A));
%     paw_mask{ii} = (labelMask == validIdx);
%     figure(1)
%     imshow(paw_mask{ii})

end

if strcmpi(rat_metadata.pawPref,'right')    % back of paw in the left mirror
    digitWindow = 1;    % look in the left mirror for the digits
    palmWindow  = 3;    % look in the right mirror for the palm
else
    digitWindow = 3;    % look in the right mirror for the digits
    palmWindow  = 1;    % look in the left mirror for the palm
end

digitMask = repmat(paw_mask{digitWindow},1,1,3);
% [pawRows,pawCols] = find(paw_mask{digitWindow});
digitImg  = fliplr(paw_img{digitWindow}) .* uint8(digitMask);
% digitImg_enh = decorrstretch(digitImg,'samplesubs',{pawRows,pawCols});
% digitImg = fliplr(digitImg);
% digitImg_enh  = fliplr(digitImg_enh);

palmMask  = repmat(paw_mask{palmWindow},1,1,3);
palmImg   = fliplr(paw_img{palmWindow}) .* uint8(palmMask);
% palmImg   = fliplr(palmImg);
% given the fundamental transformation matrix from the background, we
% should be able to constrain where the paw is in the front view

% threshold the center image to find where the paw grossly should be
% located
paw_img_enh = decorrstretch(paw_img{2},'targetmean',decorrStretchMean,'targetsigma',decorrStretchSigma);
paw_mask{2} = HSVthreshold(rgb2hsv(paw_img_enh), ctr_paw_hsv_thresh_enh);
lftProjectionMask = pawProjectionMask(paw_mask{1}, squeeze(F(1,:,:)), size(paw_mask{2}));
rgtProjectionMask = pawProjectionMask(paw_mask{3}, squeeze(F(2,:,:)), size(paw_mask{2}));
projectionMask = lftProjectionMask & rgtProjectionMask;

paw_mask{2} = projectionMask & paw_mask{2};
% paw must be in the middle third of the image
ctrMask = false(size(paw_mask{2}));
h = size(paw_mask{2},1); w = size(paw_mask{2},2);
ctrMask(:,round(w/3):round(2*w/3)) = true;
paw_mask{2} = paw_mask{2} & ctrMask;

% paw_mask{2} = HSVthreshold(rgb2hsv(paw_diff_img{2}), ctr_paw_hsv_thresh);
paw_mask{2} = bwdist(paw_mask{2}) < 2;
paw_mask{2} = imopen(paw_mask{2}, SE);
paw_mask{2} = imclose(paw_mask{2}, SE);
paw_mask{2} = imfill(paw_mask{2}, 'holes');
% paw_mask{2} = imdilate(paw_mask{2},SE);

[~, ~, ~, ~, paw_labMat] = step(centerPawBlob, paw_mask{2});
paw_mask{2} = paw_labMat > 0;    % eliminates blobs that are too big or too small
[~, ~, ~, paw_extent, paw_labMat] = step(centerPawBlob, paw_mask{2});
% eliminate blobs that don't take up enough of their bounding box
extIdx = find(paw_extent > extentLimit);
paw_mask{2} = false(size(paw_mask{2}));
for ii = 1 : length(extIdx)
    paw_mask{2} = paw_mask{2} | (paw_labMat == extIdx(ii));
end
[~, ~, ~, ~, paw_labMat] = step(centerPawBlob, paw_mask{2});
% COULD ALSO GET RID OF THE BEADS SINCE WE ALREADY LOCATED THEM FOR
% GENERATING THE FUNDAMENTAL MATRICES, OR FILTER THEM OUT BASED ON BEING
% TOO BLUE

% calculate epipolar lines for the paw masked in each mirror. THIS TAKES
% TOO LONG, LEFT IT IN IN CASE I COME BACK TO IT BUT WILL TRY JUST TAKING
% THE TOP AND BOTTOM POINTS FROM EACH MIRROR VIEW
% epiLines = cell(1,2);
% epipolarMask = false(size(ctrMask,1),size(ctrMask,2),2);
% map_x = 1:size(ctrMask,2);
% for ii = 1 : 2 : 3
%     [y, x] = find(paw_mask{ii});
%     epiIdx = ceil(ii/2);
%     if epiIdx == 1
%         F = Fleft;
%     else
%         F = Fright;
%     end
%     epiLines{epiIdx} = epipolarLine(F, [x,y]);
%     % set any point that lies on these epipolar lines to true
%     for jj = 1 : size(epiLines{epiIdx}, 1)
%         epipolarMap = zeros(size(ctrMask,1),size(ctrMask,2));
%         for kk = 1 : size(ctrMask, 1)
%             epipolarMap(kk, :) = map_x * epiLines{epiIdx}(jj,1) + kk * epiLines{epiIdx}(jj,2);
%         end
%         epipolarMap = epipolarMap + epiLines{epiIdx}(1,3);
%         epipolarMask(:,:,epiIdx) = epipolarMask(:,:,epiIdx) | (abs(epipolarMap) < epiThresh);
%     end
% end
% epipolarOverlapMask = squeeze(epipolarMask(:,:,1)) & squeeze(epipolarMask(:,:,2));
% borderLines = zeros(2,2,3);    % first dimension is left vs right mirror;
%                                % second dimension is top vs bottom;
%                                % third is A,B,C (see epipolarLine documentation)
% projectionMasks = false(size(paw_mask{2},1),size(paw_mask{2},2),2);

% for ii = 1 : 2
%     mirrorViewIdx = ii*2 - 1;    % 1 for left mirror, 3 for right mirror
%     [mirrorMaskRows,mirrorMaskCols] = find(paw_mask{mirrorViewIdx});
%     mirrorBotIdx = find(mirrorMaskRows == max(mirrorMaskRows),1);
%     mirrorTopIdx = find(mirrorMaskRows == min(mirrorMaskRows),1);
%     mirrorPawBottom = [mirrorMaskCols(mirrorBotIdx), mirrorMaskRows(mirrorBotIdx)];
%     mirrorPawTop    = [mirrorMaskCols(mirrorTopIdx), mirrorMaskRows(mirrorTopIdx)];
%     
%     borderLines(ii,:,:) = epipolarLine(squeeze(F(ii,:,:)), [mirrorPawTop;mirrorPawBottom]);
% 
%     % create a mask with true values between the epipolar lines
%     x = 1:size(paw_mask{2},2);
%     epipolarRegions = zeros(size(paw_mask{2},1),size(paw_mask{2},2),2);
%     for jj = 1 : 2
%         for kk = 1 : size(paw_mask{2}, 1)
%             epipolarRegions(kk, :, jj) = x * borderLines(ii,jj,1) + kk * borderLines(ii,jj,2);
%         end
%         epipolarRegions(:,:,jj) = epipolarRegions(:,:,jj) + borderLines(ii,jj,3);
%     end
%     if ii == 1   % haven't thought through why the signs change for the
%                  % region of interest depending on whether mapping the left
%                  % or right mirror to the direct view, but this seems to
%                  % work
%         projectionMasks(:,:,ii) = (epipolarRegions(:,:,1) < 0) & (epipolarRegions(:,:,2) > 0);
%     else
%         projectionMasks(:,:,ii) = (epipolarRegions(:,:,1) > 0) & (epipolarRegions(:,:,2) < 0);
%     end
% end
% projectionMask = squeeze(projectionMasks(:,:,1)) & squeeze(projectionMasks(:,:,2));
projectionMask = lftProjectionMask & rgtProjectionMask;

ctrPawMask = projectionMask & paw_mask{2};
[paw_proj_a, ~, ~, ~, paw_proj_labMat] = step(centerPawBlob, ctrPawMask);
max_a_idx = find(paw_proj_a == max(paw_proj_a));
ctrPawMask = (paw_proj_labMat == max_a_idx);
% find points from paw_mask{2} (paw masking based only on colors and
% morphological features) within projectionMask
ctrPawMask = uint8(ctrPawMask) .* paw_labMat;   % paw_labMat contains the
                                                % label matrix for center
                                                % paw possibilities
                                                % unconstrained by the
                                                % mirror projections
validRegionList = unique(ctrPawMask);
validRegion = validRegionList(validRegionList > 0);
paw_mask{2} = (paw_labMat == validRegion);
    
% dilate the paw mask a little more to make sure we get everything we need
% for finding the individual digits
% SE = strel('disk',5);
% paw_mask{2} = imdilate(paw_mask{2},SE);

% figure(1);imshow(paw_mask{1});
% figure(2);imshow(paw_mask{2});
% figure(3);imshow(paw_mask{3});

% test this code tomorrow!!!!!!!!!!!!!!! should show where projections from
% left and right mirrors overlap.
            
    

% % find the top and bottom of the paw mask from the mirror
% mirrorPawBottom = 0;
% mirrorPawTop = size(digitMirrorMask, 1);
% for ii = 1 : size(digitMirrorMask, 3)
%     [mirrorMaskRows,mirrorMaskCols] = find(squeeze(digitMirrorMask(:,:,ii)));
%     if max(mirrorMaskRows) > mirrorPawBottom
%         mirrorBotIdx = find(mirrorMaskRows == max(mirrorMaskRows),1);
%         mirrorPawBottom = [mirrorMaskCols(mirrorBotIdx), mirrorMaskRows(mirrorBotIdx)];
%     end
%     if min(mirrorMaskRows) < mirrorPawTop
%         mirrorTopIdx = find(mirrorMaskRows == min(mirrorMaskRows),1);
%         mirrorPawTop = [mirrorMaskCols(mirrorTopIdx), mirrorMaskRows(mirrorTopIdx)];
%     end
% end


% START BY THRESHOLDING BASED ON IMAGE SUBTRACTION, THEN GO BACK TO
% IDENTIFY COLORS IN THE PREVIOUSLY MASKED IMAGE
% LOOK INTO WHETHER ANY OF THE MATLAB IMAGE TRACKING ALGORITHMS WILL FOLLOW
% THE PAW AND/OR DIGITS ONCE IDENTIFIED IN THE FIRST FRAME
% ALSO NEED TO FIGURE OUT WHAT TO DO ABOUT THE CENTER WHERE THE BG
% SUBTRACTION ISN'T AS CLEAN

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
