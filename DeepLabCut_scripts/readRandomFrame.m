function [ img ] = readRandomFrame( video, varargin )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

frameTimeLimits = [-1,1];   %
triggerTime = 1;
for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'frametimelimits'
            frameTimeLimits = varargin{iarg + 1};
        case 'triggertime'
            triggerTime = varargin{iarg + 1};
    end
end

fr = video.FrameRate;
% triggerFrame = round(triggerTime * fr);

randTime = rand(1,1) * range(frameTimeLimits) + frameTimeLimits(1);
frameTime = max(triggerTime + randTime, 1);
frameTime = min(frameTime, video.Duration);

video.CurrentTime = frameTime;

img = readFrame(video);

end

