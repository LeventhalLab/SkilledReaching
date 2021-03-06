function initPawMask = find_initPawMask_greenPaw_mirror( video, BGimg_ud, sr_ratInfo, session_mp, boxCalibration, boxRegions, triggerTime, varargin )

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

numStretches = 15;

initPawMask = cell(1,2);
foregroundThresh = 25/255;
whiteThresh = 0.8;

ROIheight = 220;    % in pixels - how high above the shelf to look for the paw
ROIwidth = 120;

directWidth = 250;    % in pixels

boxFrontThick = 20;

for iarg = 1 : 2 : nargin - 7
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
% shelfMask = boxRegions.shelfMask;
% belowShelfMask = boxRegions.belowShelfMask;
% floorMask = boxRegions.floorMask;

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

if strcmpi(class(BGimg_ud),'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end
<<<<<<< HEAD
% orig_BGimg_ud = BGimg_ud;
BGimg_ud = color_adapthisteq(BGimg_ud);

% vidName = fullfile(video.Path, video.Name);
% video = VideoReader(vidName);
=======
orig_BGimg_ud = BGimg_ud;
BGimg_ud = color_adapthisteq(BGimg_ud);

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
>>>>>>> origin/master
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
str_img = image_ud;
for ii = 1 : numStretches
    str_img = color_adapthisteq(str_img);
end
whiteMask = rgb2gray(str_img) > whiteThresh;

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

decorr_green = decorrstretch(str_img,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
<<<<<<< HEAD
orig_decorr_green = decorrstretch(image_ud,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
=======
>>>>>>> origin/master
abs_BGdiff = imabsdiff(BGimg_ud,image_ud);
% BGdiff = imsubtract(image_ud,BGimg_ud);

decorr_green_hsv = rgb2hsv(decorr_green);
<<<<<<< HEAD
orig_decorr_green_hsv = rgb2hsv(orig_decorr_green);
=======
>>>>>>> origin/master
greenHSVthresh = HSVthreshold(decorr_green_hsv, pawHSVrange(6,:));
% diff_greenHSVthresh = HSVthreshold(decorr_green_BG_hsv, pawHSVrange(1,:));
libHSVthresh = HSVthreshold(decorr_green_hsv, pawHSVrange(5,:));

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
<<<<<<< HEAD

orig_greenHSVthresh = HSVthreshold(orig_decorr_green_hsv,pawHSVrange(7,:));
orig_greenHSVthresh = orig_greenHSVthresh & ~whiteMask & directMask;
orig_greenHSVthresh = processMask(orig_greenHSVthresh,'sesize',1);
orig_libHSVthresh = HSVthreshold(orig_decorr_green_hsv,pawHSVrange(5,:));
orig_green_masked = imreconstruct(orig_greenHSVthresh,orig_libHSVthresh);
directGreen = directMask & orig_green_masked;
=======
directGreen = directMask & greenMasked;
>>>>>>> origin/master

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
<<<<<<< HEAD
        
        SE_fromExt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [ones(1,5),zeros(1,5)];
=======
>>>>>>> origin/master
    case 'right',
        frontPanelMask = leftFrontPanelMask;     % left mirror
        frontPanelEdge = leftFrontEdge;
        fundMat = srCal.F(:,:,1);
        mirror_mask = leftMirrorGreen;
<<<<<<< HEAD
        
        SE_fromExt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [zeros(1,5),ones(1,5)];
end

side_overlap_mask = imdilate(mirror_mask,overlapCheck_SE_fromExt) & frontPanelMask;
=======
end

side_overlap_mask = imdilate(mirror_mask,strel('line',3,0)) & frontPanelMask;
>>>>>>> origin/master

if any(side_overlap_mask(:))    % previous paw mask is very close to the front panel image in the mirror
                                % therefore, check the other side of the
                                % front panel to see if the paw is showing
                                % up there
<<<<<<< HEAD
%     SE = strel('rectangle',[5 boxFrontThick + 50]);
    mask_panel_dilate = imdilate(mirror_mask, SE_fromExt);
    mask_panel_dilate = imdilate(mask_panel_dilate,strel('line',10,90));
    int_greenHSVthresh = HSVthreshold(decorr_green_hsv, pawHSVrange(2,:));
    int_greenHSVthresh = int_greenHSVthresh & intMask;
    
    libHSVthresh_int = HSVthreshold(decorr_green_hsv, pawHSVrange(5,:));
    libHSVthresh_int = libHSVthresh_int & intMask;
    
    int_greenHSVthresh = imreconstruct(int_greenHSVthresh, libHSVthresh_int);
else
    mask_panel_dilate = false(size(mirror_mask));
    int_greenHSVthresh = false(size(mirror_mask));
=======
    SE = strel('rectangle',[5 boxFrontThick + 50]);
    mask_panel_dilate = imdilate(mirror_mask, SE);
else
    mask_panel_dilate = false(size(mirror_mask));
>>>>>>> origin/master
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
<<<<<<< HEAD
    temp = temp & behindOverlap & mask_panel_dilate;
    mirror_mask = mirror_mask | temp | (mask_panel_dilate & int_greenHSVthresh);
=======
    temp = temp & behindOverlap;
    mirror_mask = mirror_mask | temp;
>>>>>>> origin/master
end
overlapMask = imdilate(mirror_mask,strel('disk',5)) & greenMasked;
if any(overlapMask(:))
    temp = imreconstruct(overlapMask,greenMasked);
    mirror_mask = mirror_mask | temp;
end
mirror_mask = bwconvhull(mirror_mask,'union');
<<<<<<< HEAD
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

=======
direct_mask = processMask(directGreen,'sesize',2);
      
mirror_projMask = projMaskFromTangentLines(mirror_mask, fundMat, [1,1,h-1,w-1], [h,w]);
direct_projMask = projMaskFromTangentLines(direct_mask, fundMat, [1,1,h-1,w-1], [h,w]);

% mirror_proj_overlap = (mirror_mask & direct_projMask);
direct_proj_overlap = (direct_mask & mirror_projMask);

initPawMask{1} = bwconvhull(direct_proj_overlap,'union');%imreconstruct(direct_proj_overlap, direct_mask);
initPawMask{2} = mirror_mask;

>>>>>>> origin/master
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
