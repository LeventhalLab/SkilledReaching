function paw_mask = maskPaw( video, frameNum, BGimg, register_ROI, F, rat_metadata, boxMarkers, varargin )
%
% usage:
%
% INPUTS:
%   img - the image in which to find the paw mask
%   BGimg - 
%   register_ROI
%   F - 2 x 3 x 3 matrix; first dimension is left vs right mirror;
%   	next two dimensions are the fundamental matrices themselves
%   register_ROI - 

diff_threshold = 25 / 255;
extentLimit = 0.5;
% epiThresh = 0.2;

decorrStretchMean  = [100.5 127.5 100.5] / 255;
decorrStretchSigma = [025 050 025] / 255;

ctr_paw_hsv_thresh_enh = [0.5 0.5 0.40 1.0 0.30 1.0];
% ctr_paw_hsv_thresh = [0.5 0.5 0.40 1.0 0.40 1.0];

centerPawBlob = vision.BlobAnalysis;
centerPawBlob.AreaOutputPort = true;
centerPawBlob.CentroidOutputPort = true;
centerPawBlob.BoundingBoxOutputPort = true;
centerPawBlob.ExtentOutputPort = true;
centerPawBlob.LabelMatrixOutputPort = true;
centerPawBlob.MinimumBlobArea = 5000;
centerPawBlob.MaximumBlobArea = 30000;

mirrorPawBlob = vision.BlobAnalysis;
mirrorPawBlob.AreaOutputPort = true;
mirrorPawBlob.CentroidOutputPort = true;
mirrorPawBlob.BoundingBoxOutputPort = true;
mirrorPawBlob.ExtentOutputPort = true;
mirrorPawBlob.LabelMatrixOutputPort = true;
mirrorPawBlob.MinimumBlobArea = 3000;
mirrorPawBlob.MaximumBlobArea = 30000;

h = video.Height;
w = video.Width;

% allBeadsMask = boxMarkers.beadMasks(:,:,1) | ...
%                boxMarkers.beadMasks(:,:,2) | ...
%                boxMarkers.beadMasks(:,:,3);
           
% create a mask for the box front in the left and right mirrors
boxFrontMask = poly2mask(boxMarkers.frontPanel_x(1,:), ...
                         boxMarkers.frontPanel_y(1,:), ...
                         h, w);
boxFrontMask = boxFrontMask | poly2mask(boxMarkers.frontPanel_x(2,:), ...
                                        boxMarkers.frontPanel_y(2,:), ...
                                        h, w);
                                    
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
    end
end

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
frameTime = ((frameNum-1) / video.FrameRate);    % need to subtract one because readFrame reads the NEXT frame, not the current frame
video.CurrentTime = frameTime;
% mean_img = zeros(h,w,3);
% for ii = 1 : numFramesToAverage
%     mean_img = mean_img + double(readFrame(video));
% end
% mean_img = mean_img / numFramesToAverage;
% mean_img = mean_img / 255;

img = readFrame(video);
img = double(img) / 255;

% move_diff = imabsdiff(mean_img,img);
BG_diff   = imabsdiff(BGimg,img);

% move_mask = false(h,w);
BG_mask = false(h,w);
for iCh = 1 : 3
%     move_mask = move_mask | (squeeze(move_diff(:,:,iCh)) > diff_threshold);
    BG_mask   = BG_mask | (squeeze(BG_diff(:,:,iCh)) > diff_threshold);
end
% 
% for iCh = 1 : 3    % color channels
%     % find the average background pixel value in each color channel
%     colorCh = squeeze(bg_subtracted_image(:,:,iCh));
%     mean_bg(iCh) = mean(colorCh(bg_mask));
%     
%     colMode = mode(colorCh(:));
%     bg_subtracted_image(:,:,iCh) = bg_subtracted_image(:,:,iCh) - colMode;
% end

paw_diff_img = cell(1,3);paw_img = cell(1,3);
thresh_mask = cell(1,3);
paw_mask = cell(1,3);
% % bg_subtracted_image = imabsdiff(img, BGimg);
% bg_subtracted_image = double(img) - double(BGimg);
% bg_abs_diff = imabsdiff(img,BGimg);
% bg_subtracted_image = (bg_subtracted_image - min(bg_subtracted_image(:)));
% bg_subtracted_image = bg_subtracted_image / max(bg_subtracted_image(:));
% bg_mask = (mean(double(bg_abs_diff),3) < 2);
% 
% % WORKING HERE - HOW TO USE THE "REAL" IMAGE DIFFERENCE FOR BETTER
% % CONTRAST?
% mean_bg = zeros(1,3);



cb_mask = cb_fp_mask(boxMarkers, [h,w]);   % mask out anything above the bottom of the 
                                           % checkerboards and in front of
                                           % the front panel in the mirrors
for ii = 1 : 3
    paw_diff_img{ii} = BG_diff(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                               register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3),:);
    paw_img{ii} = img(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                      register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3),:);
                                                               
% 	thresh_mask{ii} = rgb2gray(paw_diff_img{ii}) > diff_threshold;
    thresh_mask{ii} = BG_mask(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                      register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3),:);
end

% work on the left and right images first...
SE = strel('disk',4);
for ii = 1 : 2 : 3
    paw_mask{ii} = bwdist(thresh_mask{ii}) < 2;
    paw_mask{ii} = imopen(paw_mask{ii}, SE);
    paw_mask{ii} = imclose(paw_mask{ii},SE);
    % try dilating the image slightly to make sure we don't miss the
    % boundaries of the paw/digits
    paw_mask{ii} = imfill(paw_mask{ii},'holes');
%     paw_mask{ii} = imdilate(paw_mask{ii},SE);
    
    % only take regions that are on the correct side of the front box wall
    wallMask = false(size(paw_mask{ii}));
    if ii == 1
        % only take points to the left of the red mirror beads
        rightBorder = max(boxMarkers.beadLocations.left_mirror_red_beads(:,1)) + 25;
        rightBorder = rightBorder + register_ROI(1,1);
        wallMask(:, 1:rightBorder) = true;
    else
        % only take points to the right of the green mirror beads
        leftBorder = min(boxMarkers.beadLocations.right_mirror_green_beads(:,1)) - 25;
        leftBorder = leftBorder - register_ROI(3,1);
        wallMask(:, leftBorder:end) = true;
    end
    paw_mask{ii} = paw_mask{ii} & wallMask;
    
    paw_mask{ii} = paw_mask{ii} & ...
                   ~boxFrontMask(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                                 register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3)) & ...
                   ~cb_mask(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                                 register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3));
%                    ~allBeadsMask(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
%                                  register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3)) & ...

    paw_mask{ii} = fliplr(paw_mask{ii});
    
    % take only the largest region from each mask
    [A,~,~,~,labelMask] = step(mirrorPawBlob, paw_mask{ii});
    validIdx = find(A == max(A));
    paw_mask{ii} = (labelMask == validIdx);
    
    % create the convex hull around the paw mask to make sure we get all of
    % it
%     s = regionprops(paw_mask{ii},'BoundingBox','ConvexImage');
%     tempMask = false(size(paw_mask{ii}));
%     bbox = round(s.BoundingBox);
%     tempMask(bbox(2):bbox(2)+bbox(4)-1,bbox(1):bbox(1)+bbox(3)-1) = s.ConvexImage;

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
digitImg  = fliplr(paw_img{digitWindow}) .* double(digitMask);
% digitImg_enh = decorrstretch(digitImg,'samplesubs',{pawRows,pawCols});
% digitImg = fliplr(digitImg);
% digitImg_enh  = fliplr(digitImg_enh);

palmMask  = repmat(paw_mask{palmWindow},1,1,3);
palmImg   = fliplr(paw_img{palmWindow}) .* double(palmMask);
% palmImg   = fliplr(palmImg);
% given the fundamental transformation matrix from the background, we
% should be able to constrain where the paw is in the front view

% threshold the center image to find where the paw grossly should be
% located
% paw_img_enh = decorrstretch(paw_img{2},'targetmean',decorrStretchMean,'targetsigma',decorrStretchSigma);
paw_img_enh = enhanceColorImage(paw_img{2},decorrStretchMean,decorrStretchSigma);
paw_mask{2} = HSVthreshold(rgb2hsv(paw_img_enh), ctr_paw_hsv_thresh_enh);
SE = strel('disk',3);
lftProjectionMask = pawProjectionMask(imdilate(paw_mask{1},SE), squeeze(F(1,:,:)), size(paw_mask{2}));
rgtProjectionMask = pawProjectionMask(imdilate(paw_mask{3},SE), squeeze(F(2,:,:)), size(paw_mask{2}));
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

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
