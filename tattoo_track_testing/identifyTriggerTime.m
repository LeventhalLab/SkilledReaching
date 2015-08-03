function triggerTime = identifyTriggerTime( video, rat_metadata, boxMarkers, varargin )
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
%   triggerFrame - the frame at which the paw is fully through the slot
tic
numBGframes = 50;
BGimg = [];

h = video.Height;
w = video.Width;

foregroundThresh = 45/255;
pawGrayLevels = [60 125] / 255;
pixCountThresh = 2000;

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGframes = varargin{iarg + 1};
        case 'bgimg',
            BGimg = varargin{iarg + 1};
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
    end
end

if isempty(BGimg)
    BGimg = extractBGimg( video, 'numbgframes', numBGframes);
end
S = whos('BGimg');
if strcmpi(S.class,'uint8')
    BGimg = double(BGimg) / 255;
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

BGimg = BGimg(reach_bbox(2) : reach_bbox(2) + reach_bbox(4), ...
              reach_bbox(1) : reach_bbox(1) + reach_bbox(3), :);
% identify the frames where the paw is visible over the shelf
pawPixelCount = 0;

while pawPixelCount < pixCountThresh
    image = readFrame(video);
    
    image = image(reach_bbox(2) : reach_bbox(2) + reach_bbox(4), ...
                  reach_bbox(1) : reach_bbox(1) + reach_bbox(3), :);
    image = double(image) / 255;
    
    BGdiff = imabsdiff(image, BGimg);
    
    BGdiff_gray = mean(BGdiff, 3);
    BG_masked = (BGdiff_gray > foregroundThresh);
    
    fg_image = repmat(double(BG_masked),1,1,3) .* image;
    fg_grey = mean(fg_image,3);
    
    BG_masked = (fg_grey > pawGrayLevels(1) & ...
                 fg_grey < pawGrayLevels(2));
             
    pawPixelCount = length(find(BG_masked(:)));

end

triggerTime = video.CurrentTime;