function [digitImg,palmImg,paw_img,paw_mask] = maskPaw( img, BGimg, ROI_to_mask_paw, Fleft,Fright,register_ROI,rat_metadata,varargin )
%
% usage:
%
% INPUTS:
%   img - the image in which to find the paw mask
%   ROI_to_mask_paw - 

diff_threshold = 45;
extentLimit = 0.5;
epiThresh = 0.2;

ctr_paw_hsv_thresh = [0.5 0.5 0.20 0.6 0.20 0.7];

centerPawBlob = vision.BlobAnalysis;
centerPawBlob.AreaOutputPort = true;
centerPawBlob.CentroidOutputPort = true;
centerPawBlob.BoundingBoxOutputPort = true;
centerPawBlob.ExtentOutputPort = true;
centerPawBlob.LabelMatrixOutputPort = true;
centerPawBlob.MinimumBlobArea = 2000;
centerPawBlob.MaximumBlobArea = 6000;

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
    end
end

paw_diff_img = cell(1,3);paw_img = cell(1,3);
thresh_mask = cell(1,3);
paw_mask = cell(1,3);
bg_subtracted_image = imabsdiff(img, BGimg);

for ii = 1 : 3
    paw_diff_img{ii} = bg_subtracted_image(ROI_to_mask_paw(ii,2):ROI_to_mask_paw(ii,2) + ROI_to_mask_paw(ii,4),...
                                           ROI_to_mask_paw(ii,1):ROI_to_mask_paw(ii,1) + ROI_to_mask_paw(ii,3),:);
    paw_img{ii} = img(ROI_to_mask_paw(ii,2):ROI_to_mask_paw(ii,2) + ROI_to_mask_paw(ii,4),...
                      ROI_to_mask_paw(ii,1):ROI_to_mask_paw(ii,1) + ROI_to_mask_paw(ii,3),:);
                                                               
	thresh_mask{ii} = rgb2gray(paw_diff_img{ii}) > diff_threshold;
end

% work on the left and right images first...
SE = strel('disk',3);
for ii = 1 : 2 : 3
    paw_mask{ii} = bwdist(thresh_mask{ii}) < 2;
    paw_mask{ii} = imopen(paw_mask{ii}, SE);
    paw_mask{ii} = imclose(paw_mask{ii},SE);
    paw_mask{ii} = imfill(paw_mask{ii},'holes');
    paw_mask{ii} = fliplr(paw_mask{ii});
end

% mask out the individual digits
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
ctrMask = HSVthreshold(rgb2hsv(paw_img{2}), ctr_paw_hsv_thresh);
SE = strel('disk',2);
ctrMask = bwdist(ctrMask) < 2;
ctrMask = imopen(ctrMask, SE);
ctrMask = imclose(ctrMask, SE);
ctrMask = imfill(ctrMask, 'holes');

[~, ~, ~, ~, paw_labMat] = step(centerPawBlob, ctrMask);
ctrMask = paw_labMat > 0;    % eliminates blobs that are too big or too smal
[~, ~, ~, paw_extent, paw_labMat] = step(centerPawBlob, ctrMask);
% eliminate blobs that don't take up enough of their bounding box
extIdx = find(paw_extent > extentLimit);
ctrMask = false(size(ctrMask));
for ii = 1 : length(extIdx)
    ctrMask = ctrMask | (paw_labMat == extIdx(ii));
end
[~, ~, ~, ~, paw_labMat] = step(centerPawBlob, ctrMask);

% calculate epipolar lines for the paw masked in each mirror
epiLines = cell(1,2);
epipolarMask = false(size(ctrMask,1),size(ctrMask,2),2);
map_x = 1:size(ctrMask,2);
for ii = 1 : 2 : 3
    [y, x] = find(paw_mask{ii});
    epiIdx = ceil(ii/2);
    epiLines{epiIdx} = epipolarLine(Fleft, [x,y]);
    % set any point that lies on these epipolar lines to true
    for jj = 1 : size(epiLines{epiIdx}, 1)
        epipolarMap = zeros(size(ctrMask,1),size(ctrMask,2));
        for kk = 1 : size(ctrMask, 1)
            epipolarMap(kk, :) = map_x * epiLines{epiIdx}(jj,1) + kk * epiLines{epiIdx}(jj,2);
        end
        epipolarMap = epipolarMap + epiLines{epiIdx}(1,3);
        epipolarMask(:,:,epiIdx) = epipolarMask(:,:,epiIdx) | (abs(epipolarMap) < epiThresh);
    end
end
epipolarOverlapMask = squeeze(epipolarMask(:,:,1)) & squeeze(epipolarMask(:,:,2));
figure(1);imshow(squeeze(epipolarMask(:,:,1)));
figure(2);imshow(squeeze(epipolarMask(:,:,2)));
figure(3);imshow(squeeze(epipolarOverlapMask));
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
