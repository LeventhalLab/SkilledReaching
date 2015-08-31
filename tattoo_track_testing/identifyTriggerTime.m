function triggerTime = identifyTriggerTime( video, BGimg_ud, rat_metadata, boxCalibration, varargin )
%
% INPUTS:
%   video - a VideoReader object for the relevant video
%   boxMarkers - 
%   rat_metadata - 
%
% VARARGs:
%   numbgframes - number of frames to use at the beginning of the video to
%       calculate the background
%
% OUTPUTS:
%   triggerTime - the time at which the paw is fully through the slot

h = video.Height;
w = video.Width;

foregroundThresh = 45/255;
pawGrayLevels = [60 125] / 255;
pixCountThresh = 2000;

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

boxMarkers = boxCalibration.boxMarkers;

S = whos('BGimg_ud');
if strcmpi(S.class,'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
frameTime = ((numBGframes) / video.FrameRate);    % start looking after BG frame calculated
video.CurrentTime = frameTime;

pawPref = lower(rat_metadata.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

[mirrorMask,~] = reach_region_mask(boxMarkers, [h,w]);   % mask for region between shelf and checkerboards
rightHalfMask = false(h,w);
rightHalfMask(:,round(w/2):end) = true;
if strcmpi(pawPref,'left')
    mirrorMask = mirrorMask & rightHalfMask;
else
    mirrorMask = mirrorMask & ~rightHalfMask;
end

s = regionprops(mirrorMask, 'BoundingBox');
reach_bbox = round(s.BoundingBox);

BGimg_ud = BGimg_ud(reach_bbox(2) : reach_bbox(2) + reach_bbox(4), ...
              reach_bbox(1) : reach_bbox(1) + reach_bbox(3), :);
% identify the frames where the paw is visible over the shelf
pawPixelCount = 0;

while pawPixelCount < pixCountThresh
    image = readFrame(video);
    
    % undistort image
    image_ud = undistortImage(image, boxCalibration.cameraParams);
    
    image_ud = image_ud(reach_bbox(2) : reach_bbox(2) + reach_bbox(4), ...
                  reach_bbox(1) : reach_bbox(1) + reach_bbox(3), :);
    image_ud = double(image_ud) / 255;
    
    BGdiff = imabsdiff(image_ud, BGimg_ud);
    
    BGdiff_gray = mean(BGdiff, 3);
    BG_masked = (BGdiff_gray > foregroundThresh);
    
    fg_image_ud = repmat(double(BG_masked),1,1,3) .* image_ud;
    fg_grey = mean(fg_image_ud,3);
    
    BG_masked = (fg_grey > pawGrayLevels(1) & ...
                 fg_grey < pawGrayLevels(2));
             
    pawPixelCount = length(find(BG_masked(:)));

end

triggerTime = video.CurrentTime;