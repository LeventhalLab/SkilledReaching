function initPawMask = find_initPawMask_greenPaw( video, BGimg_ud, sr_ratInfo, session_mp, boxCalibration, boxRegions, triggerTime, varargin )

h = video.Height;
w = video.Width;

maxFrontPanelSep = 20;

pawHSVrange = [0.33, 0.05, 0.9, 1.0, 0.9, 1.0   % pick out anything that's green and bright
               0.33, 0.16, 0.1, 1.0, 0.8, 1.0     % pick out only red and bright
               0.33, 0.16, 0.2, 0.8, 0.6, 1.0]; % pick out anything green (only to be used just behind the front panel in the mirror view

targetMean = [0.5,0.2,0.5
              0.3,0.5,0.5];
    
targetSigma = [0.2,0.2,0.2
               0.2,0.2,0.2];
           
initPawMask = cell(1,2);
foregroundThresh = 25/255;
whiteThresh = 0.3;

ROIheight = 220;    % in pixels - how high above the shelf to look for the paw
ROIwidth = 120;

stretchTol = [0 1];
directWidth = 250;    % in pixels

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'hsvlimits',
            pawHSVrange = varargin{iarg + 1};
        case 'targetmean',
            targetMean = varargin{iarg + 1};
        case 'targetsigma',
            targetSigma = varargin{iarg + 1};
        case 'maxfrontpanelsep',
            maxFrontPanelSep = varargin{iarg + 1};
    end
end

frontPanelMask = cell(1,2);
frontPanelEdge = cell(1,2);
temp = boxRegions.frontPanelMask;
for iSide = 1 : 2
    frontPanelMask{iSide} = false(h,w);
    if iSide == 1
        frontPanelMask{iSide}(1:h,1:round(w/2)) = temp(1:h,1:round(w/2));
    else
        frontPanelMask{iSide}(1:h,round(w/2):end) = temp(1:h,round(w/2):end);
    end
    frontPanelEdge{iSide} = imdilate(frontPanelMask{iSide}, strel('disk',maxFrontPanelSep)) & ~frontPanelMask{iSide};
end
intMask = boxRegions.intMask;
shelfMask = boxRegions.shelfMask;
belowShelfMask = boxRegions.belowShelfMask;
floorMask = boxRegions.floorMask;

pawBlob = cell(1,2);
% blob parameters for direct view
pawBlob{1} = vision.BlobAnalysis;
pawBlob{1}.AreaOutputPort = true;
pawBlob{1}.CentroidOutputPort = true;
pawBlob{1}.BoundingBoxOutputPort = true;
pawBlob{1}.LabelMatrixOutputPort = true;
pawBlob{1}.MinimumBlobArea = 100;
pawBlob{1}.MaximumBlobArea = 10000;

% blob parameters for mirror view
pawBlob{2} = vision.BlobAnalysis;
pawBlob{2}.AreaOutputPort = true;
pawBlob{2}.CentroidOutputPort = true;
pawBlob{2}.BoundingBoxOutputPort = true;
pawBlob{2}.LabelMatrixOutputPort = true;
pawBlob{2}.MinimumBlobArea = 100;
pawBlob{2}.MaximumBlobArea = 3000;

% blob parameters for tight thresholding
restrictiveBlob = vision.BlobAnalysis;
restrictiveBlob.AreaOutputPort = true;
restrictiveBlob.CentroidOutputPort = true;
restrictiveBlob.BoundingBoxOutputPort = true;
restrictiveBlob.LabelMatrixOutputPort = true;
restrictiveBlob.MinimumBlobArea = 1;
restrictiveBlob.MaximumBlobArea = 3000;

if strcmpi(class(BGimg_ud),'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end
orig_BGimg_ud = BGimg_ud;
BGimg_ud = color_adapthisteq(BGimg_ud);

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = triggerTime;

cameraParams = boxCalibration.cameraParams;
% K = cameraParams.IntrinsicMatrix;
srCal = boxCalibration.srCal;

image = readFrame(video);
orig_image_ud = undistortImage(image, cameraParams);
if strcmpi(class(orig_image_ud),'uint8')
    orig_image_ud = double(orig_image_ud) / 255;
end
image_ud = color_adapthisteq(orig_image_ud);

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

decorr_green = decorrstretch(image_ud,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
abs_BGdiff = imabsdiff(BGimg_ud,image_ud);
BGdiff = imsubtract(image_ud,BGimg_ud);
BGdiff_stretch = color_adapthisteq(abs_BGdiff);
decorr_green_BG = decorrstretch(BGdiff_stretch,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
decorr_green_BG_hsv = rgb2hsv(decorr_green_BG);
BGdiff2 = imabsdiff(BGimg_ud,image_ud);
% decorr_green_hsv = rgb2hsv(decorr_green);
% greenHSVthresh = HSVthreshold(decorr_green_hsv, pawHSVrange(1,:));
greenHSVthresh = HSVthreshold(decorr_green_BG_hsv, pawHSVrange(1,:));
whiteHSVthresh = HSVthreshold(decorr_green_BG_hsv, pawHSVrange(3,:));

whiteMask = true(h,w);
im_masked = false(h,w);
for iCh = 1 : 3
    whiteMask = whiteMask & (BGdiff(:,:,iCh) > whiteThresh);
    im_masked = im_masked | (abs_BGdiff(:,:,iCh) > foregroundThresh);
end
im_masked = processMask(im_masked,2);
whiteMask = processMask(whiteMask,2);
whiteMask_b = whiteMask & whiteHSVthresh;
whiteMask_c = whiteMask_b & ~imdilate(greenHSVthresh,strel('disk',5));
greenMasked = im_masked & greenHSVthresh;

leftMirrorMask = false(h,w);
shelf_bot = session_mp.leftMirror.left_back_shelf_corner(2)+20;
shelf_top = shelf_bot - ROIheight;
shelf_right = session_mp.leftMirror.left_back_shelf_corner(1)+20;
shelf_left = max(1,shelf_right - ROIwidth);
leftMirrorMask(shelf_top:shelf_bot,shelf_left:shelf_right) = true;

rightMirrorMask = false(h,w);
shelf_bot = session_mp.rightMirror.right_back_shelf_corner(2)+20;
shelf_top = shelf_bot - ROIheight;
shelf_left = session_mp.rightMirror.right_back_shelf_corner(1)-20;
shelf_right = min(w,shelf_left + ROIwidth);
rightMirrorMask(shelf_top:shelf_bot,shelf_left:shelf_right) = true;

directMask = false(h,w);
shelf_left = session_mp.direct.left_back_shelf_corner(1);
shelf_right = session_mp.direct.right_back_shelf_corner(1);
shelf_bot = session_mp.direct.left_bottom_shelf_corner(2);
shelf_top = shelf_bot - 200;
direct_left = round((shelf_left+shelf_right)/2 - directWidth/2);
direct_right = direct_left + directWidth;
directMask(shelf_top:shelf_bot,direct_left:direct_right) = true;

leftMirrorGreen = leftMirrorMask & greenMasked;
rightMirrorGreen = rightMirrorMask & greenMasked;
directGreen = directMask & greenMasked;

mirrorGreen = cell(1,2);
mirrorGreen{1} = processMask(leftMirrorGreen,2);
mirrorGreen{2} = processMask(rightMirrorGreen,2);
directGreen = processMask(directGreen,2);

% if mirror green masks are adjacent to the front panel, look for green
% behind the front panel
for iSide = 1 : 2
    overlapMask = imdilate(mirrorGreen{iSide},strel('disk',5)) & frontPanelMask{iSide};
    if any(overlapMask(:))
        mirrorGreen{iSide} = mirrorGreen{iSide} | (frontPanelEdge{iSide} & intMask & greenHSVthresh);
    end
    mirrorGreen{iSide} = processMask(mirrorGreen{iSide}, 2);
end
switch pawPref
    case 'left',
        mirror_mask = mirrorGreen{2};    % right mirror
        fundMat = srCal.F(:,:,2);
    case 'right',
        mirror_mask = mirrorGreen{1};     % left mirror
        fundMat = srCal.F(:,:,1);
end
direct_mask = directGreen;

% mirrorMask = imdilate(mirror_mask,strel('disk',40));
% s = regionprops(mirrorMask, 'BoundingBox');
% mirror_bbox = round(s.BoundingBox);
% directMask = imdilate(direct_mask,strel('disk',40));
% s = regionprops(directMask, 'BoundingBox');
% direct_bbox = round(s.BoundingBox);

% BGimg_mirror = BGimg_ud(mirror_bbox(2) : mirror_bbox(2) + mirror_bbox(4), ...
%                 mirror_bbox(1) : mirror_bbox(1) + mirror_bbox(3), :);
% image_ud_mirror = orig_image_ud(mirror_bbox(2) : mirror_bbox(2) + mirror_bbox(4), ...
%                 mirror_bbox(1) : mirror_bbox(1) + mirror_bbox(3), :);
% 
% BGimg_direct = BGimg_ud(direct_bbox(2) : direct_bbox(2) + direct_bbox(4), ...
%                 direct_bbox(1) : direct_bbox(1) + direct_bbox(3), :);
% image_ud_direct = orig_image_ud(direct_bbox(2) : direct_bbox(2) + direct_bbox(4), ...
%                 direct_bbox(1) : direct_bbox(1) + direct_bbox(3), :);
%             
% BGdiff_mirror = imabsdiff(image_ud_mirror, BGimg_mirror);
% BGdiff_direct = imabsdiff(image_ud_direct, BGimg_direct);
% 
% image_ud_mirror = image_ud(mirror_bbox(2) : mirror_bbox(2) + mirror_bbox(4), ...
%                 mirror_bbox(1) : mirror_bbox(1) + mirror_bbox(3), :);
% image_ud_direct = image_ud(direct_bbox(2) : direct_bbox(2) + direct_bbox(4), ...
%                 direct_bbox(1) : direct_bbox(1) + direct_bbox(3), :);
            
% BGdiff_gray_mirror = mean(BGdiff_mirror, 3);
% BGdiff_gray_direct = mean(BGdiff_direct, 3);
% image_masked_mirror = false(size(BGimg_mirror,1),size(BGimg_mirror,2));
% image_masked_direct = false(size(BGimg_direct,1),size(BGimg_direct,2));
% for iChannel = 1 : 3
%     image_masked_mirror = image_masked_mirror | (BGdiff_mirror(:,:,iChannel) > foregroundThresh);
%     image_masked_direct = image_masked_direct | (BGdiff_direct(:,:,iChannel) > foregroundThresh);
% end

% decorr_fg_mirror = decorrstretch(image_ud_mirror,'tol',stretchTol);
% decorr_fg_mirror = decorr_fg_mirror .* repmat(double(image_masked_mirror),1,1,3);
% 
% decorr_fg_direct = decorrstretch(image_ud_direct,'tol',stretchTol);
% decorr_fg_direct = decorr_fg_direct .* repmat(double(image_masked_direct),1,1,3);
% 
% decorr_hsv_mirror = rgb2hsv(decorr_fg_mirror);
% decorr_hsv_mirror = decorr_hsv_mirror .* repmat(double(image_masked_mirror),1,1,3);
% decorr_hsv_direct = rgb2hsv(decorr_fg_direct);
% decorr_hsv_direct = decorr_hsv_direct .* repmat(double(image_masked_direct),1,1,3);
% 
% liberal_mask_mirror = HSVthreshold(decorr_hsv_mirror, pawHSVrange(3,:));
% restrictive_mask_mirror = HSVthreshold(decorr_hsv_mirror, pawHSVrange(1,:));
% 
% temp = imdilate(frontPanelMask,strel('disk',maxFrontPanelSep));
% temp = temp & intMask;
% behindPanelMask = temp(mirror_bbox(2) : mirror_bbox(2) + mirror_bbox(4), ...
%                        mirror_bbox(1) : mirror_bbox(1) + mirror_bbox(3));
% restrictive_mask_mirror = restrictive_mask_mirror | (liberal_mask_mirror & behindPanelMask);

% [~,~,~,resLabMat] = step(restrictiveBlob,restrictive_mask_mirror);
% restrictive_mask_mirror = (resLabMat > 0);
% [~,~,~,mirrorLabMat] = step(pawBlob{2},liberal_mask_mirror);
% liberal_mask_mirror = (mirrorLabMat > 0);
% 
% liberal_mask_direct = HSVthreshold(decorr_hsv_direct, pawHSVrange(3,:));
% restrictive_mask_direct = HSVthreshold(decorr_hsv_direct, pawHSVrange(1,:));
% [~,~,~,resLabMat] = step(restrictiveBlob,restrictive_mask_direct);
% restrictive_mask_direct = (resLabMat > 0);
% [~,~,~,directLabMat] = step(pawBlob{1},liberal_mask_direct);
% liberal_mask_direct = (directLabMat > 0);
% 
% mask = processMask(liberal_mask_mirror, 2);
% overlap_mask = mask & restrictive_mask_mirror;
% mirror_mask = imreconstruct(overlap_mask, mask);
% full_mirrorMask = false(h,w);
% full_mirrorMask(mirror_bbox(2):mirror_bbox(2) + mirror_bbox(4),...
%                 mirror_bbox(1):mirror_bbox(1) + mirror_bbox(3)) = mirror_mask;
% 
% mask = processMask(liberal_mask_direct, 2);
% overlap_mask = mask & restrictive_mask_direct;
% direct_mask = imreconstruct(overlap_mask, mask);
% full_directMask = false(h,w);
% full_directMask(direct_bbox(2):direct_bbox(2) + direct_bbox(4),...
%                 direct_bbox(1):direct_bbox(1) + direct_bbox(3)) = direct_mask;
% temp = imdilate(full_directMask & boxRegions.slotMask,strel('disk',10));
% temp = temp & full_directMask;
% full_directMask = imreconstruct(temp, full_directMask);   % only keep blobs that overlap with the slot
%             
mirror_projMask = projMaskFromTangentLines(mirror_mask, fundMat, [1,1,h-1,w-1], [h,w]);
direct_projMask = projMaskFromTangentLines(direct_mask, fundMat, [1,1,h-1,w-1], [h,w]);

mirror_proj_overlap = (mirror_mask & direct_projMask);
direct_proj_overlap = (direct_mask & mirror_projMask);

initPawMask{1} = imreconstruct(direct_proj_overlap, direct_mask);
initPawMask{2} = imreconstruct(mirror_proj_overlap, mirror_mask);

for iView = 1 : 2
    s = regionprops(initPawMask{iView},'area');
    if length(s) > 1
        % dilate blobs until they're all connected
        [temp,n] = mergeBlobs(initPawMask{iView});
%         temp = imdilate(temp,strel('disk',1));
        temp_skel = bwmorph(temp,'skel',inf);
        temp2 = bwconvhull(initPawMask{iView},'union');
        initPawMask{iView} = (initPawMask{iView} | temp_skel) & temp2;
    end
end
% [mirror_tpts, mirror_tlines] = findTangentToEpipolarLine(initPawMask{2}, fundMat, [1 1 w-1 h-1]);
% m_bpts = lineToBorderPoints(mirror_tlines, [h,w]);
% [direct_tpts, direct_tlines] = findTangentToEpipolarLine(initPawMask{1}, fundMat, [1 1 w-1 h-1]);
% d_bpts = lineToBorderPoints(direct_tlines, [h,w]);
% mask = HSVthreshold(decorr_hsv_direct, pawHSVrange);
% mask = processMask(mask, 2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
