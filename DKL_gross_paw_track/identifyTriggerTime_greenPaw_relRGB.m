function triggerTime = identifyTriggerTime_greenPaw_relRGB( video, rat_metadata, session_mp, cameraParams, varargin )

%
% INPUTS:
%   video - a VideoReader object for the relevant video
%   BGimg_ud - undistorted background image
%   rat_metadata - 
%
% VARARGs:
%   pawgraylevels - 
%   pixelcountthreshold - 
%   foregroundthresh - 
%
% OUTPUTS:
%   triggerTime - the time at which the paw is fully through the slot

h = video.Height;
w = video.Width;

grThresh = 0.2;
gbThresh = 0.1;
darkThresh = 0.05;    % pixels darker than this threshold in R, G, AND B should be discarded

pixCountThresh = 2500;
minPixCount = 700;    % mininum number of green pixels to count as the paw being visible
maxFramesAfterThresh = 50;

ROIheight = 200;    % in pixels - how high above the shelf to look for the paw
ROIwidth = 100;

numBGframes = 50;    % don't look for the paw too early

for iarg = 1 : 2 : nargin - 4

    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
    end
end

% session_srCal = sr_calibration_mp(session_mp,'intrinsicmatrix',K);

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
firstFrameTime = ((numBGframes) / video.FrameRate);    % start looking after BG frame calculated
video.CurrentTime = firstFrameTime;

pawPref = lower(rat_metadata.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

leftMirrorMask = false(h,w);
shelf_bot = session_mp.leftMirror.left_back_shelf_corner(2);
shelf_top = shelf_bot - ROIheight;
shelf_right = session_mp.leftMirror.left_back_shelf_corner(1);
shelf_left = max(1,shelf_right - ROIwidth);
leftMirrorMask(shelf_top:shelf_bot,shelf_left:shelf_right) = true;

rightMirrorMask = false(h,w);
shelf_bot = session_mp.rightMirror.right_back_shelf_corner(2);
shelf_top = shelf_bot - ROIheight;
shelf_left = session_mp.rightMirror.right_back_shelf_corner(1);
shelf_right = min(w,shelf_left + ROIwidth);
rightMirrorMask(shelf_top:shelf_bot,shelf_left:shelf_right) = true;
    
if strcmpi(pawPref,'left')
    mirrorMask = rightMirrorMask;
else
    mirrorMask = leftMirrorMask;
end

s = regionprops(mirrorMask, 'BoundingBox');
reach_bbox = round(s.BoundingBox);

% identify the frames where the paw is visible over the shelf
pawPixelCount = 0;
frameNum = 0;
pixCount = [];
while pawPixelCount < pixCountThresh && video.CurrentTime < video.Duration
    image = readFrame(video);
    if strcmpi(class(image),'uint8')
        image = double(image) / 255;
    end
    frameNum = frameNum + 1;
%     fprintf('frame number: %d\n', frameNum)
    
    % undistort image
    image_ud = undistortImage(image, cameraParams);
    
    im_ROI = image_ud(reach_bbox(2):reach_bbox(2)+reach_bbox(4),...
                      reach_bbox(1):reach_bbox(1)+reach_bbox(3),:);
                  
    drkmsk = true(size(im_ROI,1),size(im_ROI,2));
    for jj = 1 : 3
        drkmsk = drkmsk & im_ROI(:,:,jj) < darkThresh;
    end
    
	ROI_relRGB = relativeRGB(im_ROI);
    
    r = ROI_relRGB(:,:,1);
    g = ROI_relRGB(:,:,2);
    b = ROI_relRGB(:,:,3);
    
    gr_diff = g - r;
    gb_diff = g - b;
    
    grMask = gr_diff > grThresh;
    gbMask = gb_diff > gbThresh;
    
    mask = grMask & gbMask & ~drkmsk;

%     image_ud = color_adapthisteq(orig_image_ud);

%     decorr_green = decorrstretch(image_ud,'targetmean',targetMean(1,:),'targetsigma',targetSigma(1,:));
%     lo_hi = stretchlim(decorr_green);
%     decorr_green = imadjust(decorr_green,lo_hi,[]);
% 
%     decorr_green = decorr_green(reach_bbox(2) : reach_bbox(2) + reach_bbox(4), ...
%                                 reach_bbox(1) : reach_bbox(1) + reach_bbox(3), :);

%     decorr_hsv = rgb2hsv(decorr_green);
%     res_mask = HSVthreshold(decorr_hsv, pawHSVrange(1,:));
%     lib_mask = HSVthreshold(decorr_hsv, pawHSVrange(2,:));
%     lib_mask = processMask(lib_mask,'sesize',1);
%     res_mask = processMask(res_mask,'sesize',1);
% 
%     mask = imreconstruct(res_mask,lib_mask);
%     
%     figure(1)
%     imshow(image_ud)
%     set(gcf,'name',num2str(frameNum));
%     
%     figure(2)
%     imshow(BGdiff)
%     set(gcf,'name',num2str(frameNum));
% 
%     figure(3)
%     imshow(decorr_hsv)
%     set(gcf,'name',num2str(frameNum));
%     
%     figure(4)
%     imshow(mask)
% 	set(gcf,'name',num2str(frameNum));
    
    pawPixelCount = length(find(mask(:)));
    pixCount(frameNum) = pawPixelCount;

end

if max(pixCount) > minPixCount
    firstReach = find(pixCount > minPixCount,1);
    temp = pixCount;
    idx1 = firstReach - 1;
    idx2 = min(firstReach + maxFramesAfterThresh + 1, length(pixCount));
    temp(1:idx1) = 0;
    temp(idx2:end) = 0;
    threshFrame = find(temp == max(temp),1,'first');
    triggerTime = firstFrameTime + threshFrame / video.FrameRate;
elseif max(pixCount) > 0
    threshFrame = find(pixCount == max(pixCount),1,'first');
    triggerTime = firstFrameTime + threshFrame / video.FrameRate;
else
    triggerTime = video.CurrentTime;
end

end