function trackGreenPaw_forward(video, BGimg_ud, sr_ratInfo, session_mp, triggerTime, boxCalibration, varargin)

h = video.Height;
w = video.Width;

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
    end
end

if strcmpi(class(BGimg_ud),'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = triggerTime;

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

cameraParams = boxCalibration.cameraParams;
K = cameraParams.IntrinsicMatrix;

switch pawPref
    case 'left',
        mirrorViewIdx = 3;    % right mirror
    case 'right',
        mirrorViewIdx = 2;    % left mirror
end

% first, initialize the track





while video.CurrentTime < video.Duration
    image = readFrame(video);
    frameNum = frameNum + 1;
    
    image_ud = undistortImage(image, cameraParams);
    
    image_ud = double(image_ud) / 255;