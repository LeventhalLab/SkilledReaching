function triggerTime = identifyTriggerTime_greenPaw( video, rat_metadata, session_mp, cameraParams, varargin )

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

targetMean = [0.5,0.2,0.5
              0.3,0.5,0.5];
    
targetSigma = [0.2,0.2,0.2
               0.2,0.2,0.2];
          
foregroundThresh = 45/255;

pixCountThresh = 2500;
minPixCount = 700;    % mininum number of green pixels to count as the paw being visible
maxFramesAfterThresh = 50;

ROIheight = 200;    % in pixels - how high above the shelf to look for the paw
ROIwidth = 100;

numBGframes = 50;    % don't look for the paw too early

pawHSVrange = [0.33, 0.10, 0.9, 1.0, 0.9, 1.0   % pick out anything that's green and bright
               0.00, 0.16, 0.8, 1.0, 0.8, 1.0     % pick out only red and bright
               0.33, 0.16, 0.6, 1.0, 0.6, 1.0]; % pick out anything green (only to be used just behind the front panel in the mirror view

for iarg = 1 : 2 : nargin - 4

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
    frameNum = frameNum + 1;
%     fprintf('frame number: %d\n', frameNum)
    
    % undistort image
    orig_image_ud = undistortImage(image, cameraParams);

    image_ud = color_adapthisteq(orig_image_ud);

    decorr_green = decorrstretch(image_ud,'targetmean',targetMean(1,:),'targetsigma',targetSigma(1,:));
    lo_hi = stretchlim(decorr_green);
    decorr_green = imadjust(decorr_green,lo_hi,[]);

    decorr_green = decorr_green(reach_bbox(2) : reach_bbox(2) + reach_bbox(4), ...
                                reach_bbox(1) : reach_bbox(1) + reach_bbox(3), :);

    decorr_hsv = rgb2hsv(decorr_green);
    res_mask = HSVthreshold(decorr_hsv, pawHSVrange(1,:));
    lib_mask = HSVthreshold(decorr_hsv, pawHSVrange(2,:));
    lib_mask = processMask(lib_mask,'sesize',1);
    res_mask = processMask(res_mask,'sesize',1);

    mask = imreconstruct(res_mask,lib_mask);
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