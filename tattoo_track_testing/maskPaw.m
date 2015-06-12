function paw_mask = maskPaw( img, BGimg, register_ROI, fundmat,rat_metadata,varargin )
%
% usage:
%
% INPUTS:
%   img - the image in which to find the paw mask
%   BGimg - 
%   register_ROI
%   fundmat - 2 x 3 x 3 matrix; first dimension is left vs right mirror;
%   	next two dimensions are the fundamental matrices themselves
%   register_ROI - 

diff_threshold = 45;
extentLimit = 0.5;
% epiThresh = 0.2;

ctr_paw_hsv_thresh = [0.5 0.5 0.20 0.6 0.20 1.0];

centerPawBlob = vision.BlobAnalysis;
centerPawBlob.AreaOutputPort = true;
centerPawBlob.CentroidOutputPort = true;
centerPawBlob.BoundingBoxOutputPort = true;
centerPawBlob.ExtentOutputPort = true;
centerPawBlob.LabelMatrixOutputPort = true;
centerPawBlob.MinimumBlobArea = 2000;
centerPawBlob.MaximumBlobArea = 8000;

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'diffthreshold',
            diff_threshold = varargin{iarg + 1};
        case 'extentlimit',
            extentLimit = varargin{iarg + 1};
        case 'mincenterpawarea',
            centerPawBlob.MinimumBlobArea = varargin{iarg + 1};
        case 'maxcenterpawarea',
            centerPawBlob.MaximumBlobArea = varargin{iarg + 1};
    end
end

paw_diff_img = cell(1,3);paw_img = cell(1,3);
thresh_mask = cell(1,3);
paw_mask = cell(1,3);
bg_subtracted_image = imabsdiff(img, BGimg);

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
    paw_mask{ii} = bwdist(thresh_mask{ii}) < 2;
    paw_mask{ii} = imopen(paw_mask{ii}, SE);
    paw_mask{ii} = imclose(paw_mask{ii},SE);
    paw_mask{ii} = imfill(paw_mask{ii},'holes');
    % try dilating the image slightly to make sure we don't miss the
    % boundaries of the paw/digits
    paw_mask{ii} = imdilate(paw_mask{ii},SE);
    paw_mask{ii} = fliplr(paw_mask{ii});
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
paw_mask{2} = HSVthreshold(rgb2hsv(paw_diff_img{2}), ctr_paw_hsv_thresh);
paw_mask{2} = bwdist(paw_mask{2}) < 2;
paw_mask{2} = imopen(paw_mask{2}, SE);
paw_mask{2} = imclose(paw_mask{2}, SE);
paw_mask{2} = imfill(paw_mask{2}, 'holes');
paw_mask{2} = imdilate(paw_mask{2},SE);

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
%         fundmat = Fleft;
%     else
%         fundmat = Fright;
%     end
%     epiLines{epiIdx} = epipolarLine(fundmat, [x,y]);
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
borderLines = zeros(2,2,3);    % first dimension is left vs right mirror;
                               % second dimension is top vs bottom;
                               % third is A,B,C (see epipolarLine documentation)
projectionMasks = false(size(paw_mask{2},1),size(paw_mask{2},2),2);
for ii = 1 : 2
    mirrorViewIdx = ii*2 - 1;    % 1 for left mirror, 3 for right mirror
    [mirrorMaskRows,mirrorMaskCols] = find(paw_mask{mirrorViewIdx});
    mirrorBotIdx = find(mirrorMaskRows == max(mirrorMaskRows),1);
    mirrorTopIdx = find(mirrorMaskRows == min(mirrorMaskRows),1);
    mirrorPawBottom = [mirrorMaskCols(mirrorBotIdx), mirrorMaskRows(mirrorBotIdx)];
    mirrorPawTop    = [mirrorMaskCols(mirrorTopIdx), mirrorMaskRows(mirrorTopIdx)];
    
    borderLines(ii,:,:) = epipolarLine(squeeze(fundmat(ii,:,:)), [mirrorPawTop;mirrorPawBottom]);

    % create a mask with true values between the epipolar lines
    x = 1:size(paw_mask{2},2);
    epipolarRegions = zeros(size(paw_mask{2},1),size(paw_mask{2},2),2);
    for jj = 1 : 2
        for kk = 1 : size(paw_mask{2}, 1)
            epipolarRegions(kk, :, jj) = x * borderLines(ii,jj,1) + kk * borderLines(ii,jj,2);
        end
        epipolarRegions(:,:,jj) = epipolarRegions(:,:,jj) + borderLines(ii,jj,3);
    end
    if ii == 1   % haven't thought through why the signs change for the
                 % region of interest depending on whether mapping the left
                 % or right mirror to the direct view, but this seems to
                 % work
        projectionMasks(:,:,ii) = (epipolarRegions(:,:,1) < 0) & (epipolarRegions(:,:,2) > 0);
    else
        projectionMasks(:,:,ii) = (epipolarRegions(:,:,1) > 0) & (epipolarRegions(:,:,2) < 0);
    end
end
projectionMask = squeeze(projectionMasks(:,:,1)) & squeeze(projectionMasks(:,:,2));
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
SE = strel('disk',5);
paw_mask{2} = imdilate(paw_mask{2},SE);

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
