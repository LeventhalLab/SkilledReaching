function initPawMask = find_initPawMask_greenPaw( video, BGimg_ud, sr_ratInfo, session_mp, boxCalibration, triggerTime )

h = video.Height;
w = video.Width;

restrictive_pawHSVrange = [0.33, 0.05, 0.9, 1.0, 0.9, 1.0];
liberal_pawHSVrange = [0.2, 0.3, 0.7, 1.0, 0.6, 1.0];

initPawMask = cell(1,2);
foregroundThresh = 45/255;

ROIheight = 220;    % in pixels - how high above the shelf to look for the paw
ROIwidth = 120;

stretchTol = [0 1];

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'hsvlimits',
            pawHSVrange = varargin{iarg + 1};
    end
end

pawBlob = cell(1,2);
% blob parameters for direct view
pawBlob{1} = vision.BlobAnalysis;
pawBlob{1}.AreaOutputPort = true;
pawBlob{1}.CentroidOutputPort = true;
pawBlob{1}.BoundingBoxOutputPort = true;
% pawBlob{1}.ExtentOutputPort = true;
pawBlob{1}.LabelMatrixOutputPort = true;
pawBlob{1}.MinimumBlobArea = 100;
pawBlob{1}.MaximumBlobArea = 10000;

% blob parameters for mirror view
pawBlob{2} = vision.BlobAnalysis;
pawBlob{2}.AreaOutputPort = true;
pawBlob{2}.CentroidOutputPort = true;
pawBlob{2}.BoundingBoxOutputPort = true;
% pawBlob{2}.ExtentOutputPort = true;
pawBlob{2}.LabelMatrixOutputPort = true;
pawBlob{2}.MinimumBlobArea = 100;
pawBlob{2}.MaximumBlobArea = 10000;

% blob parameters for tight thresholding
restrictiveBlob = vision.BlobAnalysis;
restrictiveBlob.AreaOutputPort = true;
restrictiveBlob.CentroidOutputPort = true;
restrictiveBlob.BoundingBoxOutputPort = true;
% restrictiveBlob.ExtentOutputPort = true;
restrictiveBlob.LabelMatrixOutputPort = true;
restrictiveBlob.MinimumBlobArea = 20;
restrictiveBlob.MaximumBlobArea = 10000;

if strcmpi(class(BGimg_ud),'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = triggerTime;

cameraParams = boxCalibration.cameraParams;
% K = cameraParams.IntrinsicMatrix;
srCal = boxCalibration.srCal;

image = readFrame(video);
image_ud = undistortImage(image, cameraParams);
if strcmpi(class(image_ud),'uint8')
    image_ud = double(image_ud) / 255;
end

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

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
directMask(shelf_top:shelf_bot,shelf_left:shelf_right) = true;

switch pawPref
    case 'left',
        mirrorMask = rightMirrorMask;    % right mirror
        fundMat = srCal.F(:,:,2);
    case 'right',
        mirrorMask = leftMirrorMask;     % left mirror
        fundMat = srCal.F(:,:,1);
end

s = regionprops(mirrorMask, 'BoundingBox');
mirror_bbox = round(s.BoundingBox);
s = regionprops(directMask, 'BoundingBox');
direct_bbox = round(s.BoundingBox);

BGimg_mirror = BGimg_ud(mirror_bbox(2) : mirror_bbox(2) + mirror_bbox(4), ...
                mirror_bbox(1) : mirror_bbox(1) + mirror_bbox(3), :);
image_ud_mirror = image_ud(mirror_bbox(2) : mirror_bbox(2) + mirror_bbox(4), ...
                mirror_bbox(1) : mirror_bbox(1) + mirror_bbox(3), :);

BGimg_direct = BGimg_ud(direct_bbox(2) : direct_bbox(2) + direct_bbox(4), ...
                direct_bbox(1) : direct_bbox(1) + direct_bbox(3), :);
image_ud_direct = image_ud(direct_bbox(2) : direct_bbox(2) + direct_bbox(4), ...
                direct_bbox(1) : direct_bbox(1) + direct_bbox(3), :);
            
BGdiff_mirror = imabsdiff(image_ud_mirror, BGimg_mirror);
BGdiff_direct = imabsdiff(image_ud_direct, BGimg_direct);

BGdiff_gray_mirror = mean(BGdiff_mirror, 3);
BGdiff_gray_direct = mean(BGdiff_direct, 3);
image_masked_mirror = (BGdiff_gray_mirror > foregroundThresh);
image_masked_direct = (BGdiff_gray_direct > foregroundThresh);

fg_image_ud_mirror = repmat(double(image_masked_mirror),1,1,3) .* image_ud_mirror;
decorr_fg_mirror = decorrstretch(fg_image_ud_mirror,'tol',stretchTol);%, 'samplesubs', {y,x});
decorr_fg_mirror = decorr_fg_mirror .* repmat(double(image_masked_mirror),1,1,3);

fg_image_ud_direct = repmat(double(image_masked_direct),1,1,3) .* image_ud_direct;
decorr_fg_direct = decorrstretch(fg_image_ud_direct,'tol',stretchTol);%, 'samplesubs', {y,x});
decorr_fg_direct = decorr_fg_direct .* repmat(double(image_masked_direct),1,1,3);

decorr_hsv_mirror = rgb2hsv(decorr_fg_mirror);
decorr_hsv_mirror = decorr_hsv_mirror .* repmat(double(image_masked_mirror),1,1,3);
decorr_hsv_direct = rgb2hsv(decorr_fg_direct);
decorr_hsv_direct = decorr_hsv_direct .* repmat(double(image_masked_direct),1,1,3);

liberal_mask_mirror = HSVthreshold(decorr_hsv_mirror, liberal_pawHSVrange);
restrictive_mask_mirror = HSVthreshold(decorr_hsv_mirror, restrictive_pawHSVrange);
[~,~,~,resLabMat] = step(restrictiveBlob,restrictive_mask_mirror);
restrictive_mask_mirror = (resLabMat > 0);
[~,~,~,mirrorLabMat] = step(pawBlob{2},liberal_mask_mirror);
liberal_mask_mirror = (mirrorLabMat > 0);

liberal_mask_direct = HSVthreshold(decorr_hsv_direct, liberal_pawHSVrange);
restrictive_mask_direct = HSVthreshold(decorr_hsv_direct, restrictive_pawHSVrange);
[~,~,~,resLabMat] = step(restrictiveBlob,restrictive_mask_direct);
restrictive_mask_direct = (resLabMat > 0);
[~,~,~,directLabMat] = step(pawBlob{1},liberal_mask_direct);
liberal_mask_direct = (directLabMat > 0);

mask = processMask(liberal_mask_mirror, 2);
overlap_mask = mask & restrictive_mask_mirror;
mirror_mask = imreconstruct(overlap_mask, mask);
full_mirrorMask = false(h,w);
full_mirrorMask(mirror_bbox(2):mirror_bbox(2) + mirror_bbox(4),...
                mirror_bbox(1):mirror_bbox(1) + mirror_bbox(3)) = mirror_mask;

mask = processMask(liberal_mask_direct, 2);
overlap_mask = mask & restrictive_mask_direct;
direct_mask = imreconstruct(overlap_mask, mask);
full_directMask = false(h,w);
full_directMask(direct_bbox(2):direct_bbox(2) + direct_bbox(4),...
                direct_bbox(1):direct_bbox(1) + direct_bbox(3)) = direct_mask;
            
mirror_projMask = projMaskFromTangentLines(mirror_mask, fundMat, mirror_bbox, [h,w]);
direct_projMask = projMaskFromTangentLines(direct_mask, fundMat, direct_bbox, [h,w]);

mirror_proj_overlap = (full_mirrorMask & direct_projMask);
direct_proj_overlap = (full_directMask & mirror_projMask);

initPawMask{1} = imreconstruct(direct_proj_overlap, full_directMask);
initPawMask{2} = imreconstruct(mirror_proj_overlap, full_mirrorMask);
% [mirror_tpts, mirror_tlines] = findTangentToEpipolarLine(initPawMask{2}, fundMat, [1 1 w-1 h-1]);
% m_bpts = lineToBorderPoints(mirror_tlines, [h,w]);
% [direct_tpts, direct_tlines] = findTangentToEpipolarLine(initPawMask{1}, fundMat, [1 1 w-1 h-1]);
% d_bpts = lineToBorderPoints(direct_tlines, [h,w]);
% mask = HSVthreshold(decorr_hsv_direct, pawHSVrange);
% mask = processMask(mask, 2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
