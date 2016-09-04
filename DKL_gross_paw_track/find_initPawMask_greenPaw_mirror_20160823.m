function initPawMask = find_initPawMask_greenPaw_mirror_20160823( video, BGimg_ud, sr_ratInfo, session_mp, boxCalibration, boxRegions, triggerTime, greenBGmask, varargin )

h = video.Height;
w = video.Width;

maxFrontPanelSep = 20;

pawHSVrange = [0.33, 0.05, 0.95, 1.0, 0.95, 1.0   % pick out anything that's green and bright
               0.33, 0.05, 0.98, 1.0, 0.98, 1.0     % pick out anything that's green and bright immediately behind the front panel
               0.50, 0.50, 0.95, 1.0, 0.95, 1.0
               0.00, 0.16, 0.90, 1.0, 0.90, 1.0       % find red objects
               0.33, 0.10, 0.85, 1.0, 0.85, 1.0          % liberal green mask
               0.33, 0.02, 0.99, 1.0, 0.99, 1.0];  % very narror for the external region where lighting is good

targetMean = [0.5,0.2,0.5
              0.3,0.5,0.5];
    
targetSigma = [0.2,0.2,0.2
               0.2,0.2,0.2];

initPawMask = cell(1,2);
foregroundThresh = 25/255;

ROIheight = 220;    % in pixels - how high above the shelf to look for the paw
ROIwidth = 120;

directWidth = 250;    % in pixels


for iarg = 1 : 2 : nargin - 8
    switch lower(varargin{iarg})
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
        case 'whitethresh',
            whiteThresh = varargin{iarg + 1};
    end
end

frontPanelMask = boxRegions.frontPanelMask;
% shelfMask = boxRegions.shelfMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
intMask = boxRegions.intMask;

shelfMask = boxRegions.shelfMask;
intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
slotMask = boxRegions.slotMask;
floorMask = boxRegions.floorMask;
[y,~] = find(floorMask);
ROI_bot = min(y);

[~,x] = find(shelfMask);
centerPoly_x = [min(x),max(x),max(x),min(x),min(x)];
centerPoly_y = [1,1,h,h,1];
centerMask = poly2mask(centerPoly_x,centerPoly_y,h,w);
centerMask = imdilate(centerMask,strel('line',100,0));
belowShelfMask = boxRegions.belowShelfMask;

shelfLims = regionprops(boxRegions.shelfMask,'boundingbox');

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

switch lower(pawPref),
    case 'right',
        fundMat = boxCalibration.srCal.F(:,:,1);
        ROI = [1,1,floor(shelfLims.BoundingBox(1)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)),1,ceil(shelfLims.BoundingBox(3)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot];
    case 'left',
        fundMat = boxCalibration.srCal.F(:,:,2);
        ROI = [ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)),1,ceil(shelfLims.BoundingBox(3)),ROI_bot;...
               1,1,floor(shelfLims.BoundingBox(1)),ROI_bot];
end

cameraParams = boxCalibration.cameraParams;

video.CurrentTime = triggerTime;
image = readFrame(video);
if strcmpi(class(image),'uint8')
    image = double(image) / 255;
end
image_ud = undistortImage(image, cameraParams);

mirror_image_ud = image_ud(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:);
direct_image_ud = image_ud(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:);
other_mirror_image_ud = image_ud(ROI(3,2):ROI(3,2)+ROI(3,4),ROI(3,1):ROI(3,1)+ROI(3,3),:);
lh  = stretchlim(other_mirror_image_ud,0.05);
direct_str_img = imadjust(direct_image_ud,lh,[]);
mirror_str_img = imadjust(mirror_image_ud,lh,[]);

direct_green = decorrstretch(direct_str_img,'tol',0.02);
mirror_green = decorrstretch(mirror_str_img,'tol',0.02);
decorr_green = image_ud;
decorr_green(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:) = mirror_green;
decorr_green(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:) = direct_green;

if strcmpi(class(BGimg_ud),'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end
% orig_BGimg_ud = BGimg_ud;
BGimg_ud = color_adapthisteq(BGimg_ud);

% vidName = fullfile(video.Path, video.Name);
% video = VideoReader(vidName);



% K = cameraParams.IntrinsicMatrix;
srCal = boxCalibration.srCal;

% image = readFrame(video);
% orig_image_ud = undistortImage(image, cameraParams);
% if strcmpi(class(orig_image_ud),'uint8')
%     orig_image_ud = double(orig_image_ud) / 255;
% end
% image_ud = color_adapthisteq(orig_image_ud);
% str_img = image_ud;
% for ii = 1 : numStretches
%     str_img = color_adapthisteq(str_img);
% end
% whiteMask = rgb2gray(str_img) > whiteThresh;
ctrstImg = imadjust(image_ud,[0.2,0.2,0.2;0.8,0.8,0.8],[]);
ctrstImg_hsv = rgb2hsv(ctrstImg);

whiteMask = HSVthreshold(ctrstImg_hsv,[0.5,0.5,0,0.001,0.999,1]);



% decorr_green = decorrstretch(image_ud,...
%                              'targetmean',targetMean(1,:),...
%                              'targetsigma',targetSigma(1,:));
% lo_hi = stretchlim(decorr_green);
% decorr_green = imadjust(decorr_green,lo_hi,[]);

% decorr_green_BG = decorrstretch(BGimg_ud,...
%                              'targetmean',targetMean(1,:),...
%                              'targetsigma',targetSigma(1,:));
% lo_hi = stretchlim(decorr_green_BG);
% decorr_green_BG = imadjust(decorr_green_BG,lo_hi,[]);
% 
% decorr_green_BG_hsv = rgb2hsv(decorr_green_BG);
% greenBGthresh = HSVthreshold(decorr_green_BG_hsv,pawHSVrange(1,:));

% orig_decorr_green = decorrstretch(image_ud,...
%                              'targetmean',targetMean(1,:),...
%                              'targetsigma',targetSigma(1,:));
abs_BGdiff = imabsdiff(BGimg_ud,image_ud);
% BGdiff = imsubtract(image_ud,BGimg_ud);

decorr_green_hsv = rgb2hsv(decorr_green);
% orig_decorr_green_hsv = rgb2hsv(orig_decorr_green);
greenHSVthresh = HSVthreshold(decorr_green_hsv, pawHSVrange(1,:));
greenHSVthresh = greenHSVthresh & ~greenBGmask & ~imdilate(whiteMask,strel('disk',5));


greenHSVthresh = processMask(greenHSVthresh,'sesize',2);
% diff_greenHSVthresh = HSVthreshold(decorr_green_BG_hsv, pawHSVrange(1,:));
libHSVthresh = HSVthreshold(decorr_green_hsv, pawHSVrange(2,:));

im_masked = false(h,w);
for iCh = 1 : 3
    im_masked = im_masked | (abs_BGdiff(:,:,iCh) > foregroundThresh);
end
im_masked = processMask(im_masked,'sesize',2);

temp = greenHSVthresh & ~whiteMask;
libHSVthresh = libHSVthresh & ~whiteMask;
greenMasked = imreconstruct(temp,libHSVthresh);
greenMasked = im_masked & greenMasked;

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

% orig_greenHSVthresh = HSVthreshold(orig_decorr_green_hsv,pawHSVrange(7,:));
% orig_greenHSVthresh = orig_greenHSVthresh & ~whiteMask & directMask;
% orig_greenHSVthresh = processMask(orig_greenHSVthresh,'sesize',1);
% orig_libHSVthresh = HSVthreshold(orig_decorr_green_hsv,pawHSVrange(5,:));
% orig_green_masked = imreconstruct(orig_greenHSVthresh,orig_libHSVthresh);
% directGreen = directMask & orig_green_masked;
directGreen = directMask & greenMasked;

leftFrontPanelMask = false(h,w);
rightFrontPanelMask = false(h,w);
leftFrontEdge = false(h,w);
rightFrontEdge = false(h,w);

leftFrontPanelMask(1:h,1:round(w/2)) = frontPanelMask(1:h,1:round(w/2));
rightFrontPanelMask(1:h,round(w/2):end) = frontPanelMask(1:h,round(w/2):end);
leftFrontEdge(1:h,1:round(w/2)) = frontPanelEdge(1:h,1:round(w/2));
rightFrontEdge(1:h,round(w/2):end) = frontPanelEdge(1:h,round(w/2):end);

switch pawPref
    case 'left',
        frontPanelMask = rightFrontPanelMask;    % right mirror
        frontPanelEdge = rightFrontEdge;
        fundMat = srCal.F(:,:,2);
        mirror_mask = rightMirrorGreen;
        
        SE_fromExt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [ones(1,5),zeros(1,5)];
    case 'right',
        frontPanelMask = leftFrontPanelMask;     % left mirror
        frontPanelEdge = leftFrontEdge;
        fundMat = srCal.F(:,:,1);
        mirror_mask = leftMirrorGreen;
        
        SE_fromExt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [zeros(1,5),ones(1,5)];
end

side_overlap_mask = imdilate(mirror_mask,overlapCheck_SE_fromExt) & frontPanelMask;

if any(side_overlap_mask(:))    % previous paw mask is very close to the front panel image in the mirror
                                % therefore, check the other side of the
                                % front panel to see if the paw is showing
                                % up there
%     SE = strel('rectangle',[5 boxFrontThick + 50]);
    mask_panel_dilate = imdilate(mirror_mask, SE_fromExt);
    mask_panel_dilate = imdilate(mask_panel_dilate,strel('line',10,90));
    int_greenHSVthresh = HSVthreshold(decorr_green_hsv, pawHSVrange(2,:));
    int_greenHSVthresh = int_greenHSVthresh & intMask;
    int_greenHSVthresh = processMask(int_greenHSVthresh,2);
    
    libHSVthresh_int = HSVthreshold(decorr_green_hsv, pawHSVrange(2,:));
    libHSVthresh_int = libHSVthresh_int & intMask;
    
    int_greenHSVthresh = imreconstruct(int_greenHSVthresh, libHSVthresh_int);
else
    mask_panel_dilate = false(size(mirror_mask));
    int_greenHSVthresh = false(size(mirror_mask));
end

behindPanelMask = frontPanelEdge & intMask;
behindOverlap = behindPanelMask & mask_panel_dilate;
if any(behindOverlap(:))
    BGdiff_stretch = color_adapthisteq(abs_BGdiff);
    decorr_green_BG = decorrstretch(BGdiff_stretch,...
                                 'targetmean',targetMean(1,:),...
                                 'targetsigma',targetSigma(1,:));
    decorr_green_BG_hsv = rgb2hsv(decorr_green_BG);

    temp = HSVthreshold(decorr_green_BG_hsv,pawHSVrange(2,:));
    temp = temp & behindOverlap & mask_panel_dilate;
    mirror_mask = mirror_mask | temp | (mask_panel_dilate & int_greenHSVthresh);
end
overlapMask = imdilate(mirror_mask,strel('disk',5)) & greenMasked;
if any(overlapMask(:))
    temp = imreconstruct(overlapMask,greenMasked);
    mirror_mask = mirror_mask | temp;
end
mirror_mask = bwconvhull(mirror_mask,'union');
% direct_mask = processMask(directGreen,'sesize',2);
      
mirror_projMask = projMaskFromTangentLines(mirror_mask, fundMat, [1,1,h-1,w-1], [h,w]);
% direct_projMask = projMaskFromTangentLines(direct_mask, fundMat, [1,1,h-1,w-1], [h,w]);

% mirror_proj_overlap = (mirror_mask & direct_projMask);
direct_proj_overlap = (directGreen & mirror_projMask);
direct_proj_overlap = imreconstruct(direct_proj_overlap, directGreen);

initPawMask{1} = bwconvhull(direct_proj_overlap,'union');
initPawMask{2} = mirror_mask;

bbox = [1,1,w-1,h-1];
bbox(2,:) = bbox;
initPawMask = estimateHiddenSilhouette(initPawMask, bbox,fundMat,[h,w]);

% for iView = 1 : 2
%     s = regionprops(initPawMask{iView},'area');
%     if length(s) > 1
%         % dilate blobs until they're all connected
%         [temp,n] = mergeBlobs(initPawMask{iView});
% %         temp = imdilate(temp,strel('disk',1));
%         temp_skel = bwmorph(temp,'skel',inf);
%         temp2 = bwconvhull(initPawMask{iView},'union');
%         initPawMask{iView} = (initPawMask{iView} | temp_skel) & temp2;
%     end
% end
% [mirror_tpts, mirror_tlines] = findTangentToEpipolarLine(initPawMask{2}, fundMat, [1 1 w-1 h-1]);
% m_bpts = lineToBorderPoints(mirror_tlines, [h,w]);
% [direct_tpts, direct_tlines] = findTangentToEpipolarLine(initPawMask{1}, fundMat, [1 1 w-1 h-1]);
% d_bpts = lineToBorderPoints(direct_tlines, [h,w]);
% mask = HSVthreshold(decorr_hsv_direct, pawHSVrange);
% mask = processMask(mask, 2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
