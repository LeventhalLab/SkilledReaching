function [ img ] = readRandomFrame( video, varargin )
% function to read in a randomly selected video frame from a video.
%
% INPUTS:
%   video - a VideoReader object
%
% VARARGS:
%   frametimelimits - 1 x 2 vector containing start and end times relative
%       to tigger time (in seconds)
%   triggertime - time at which video was triggered (set to zero if just
%       want frametimelimits to count from the start of the video
%
% OUTPUTS:
%   img - the extracted frame

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

% fr = video.FrameRate;
% triggerFrame = round(triggerTime * fr);

randTime = rand * range(frameTimeLimits) + frameTimeLimits(1);
frameTime = max(triggerTime + randTime, 0);
frameTime = min(frameTime, video.Duration);

video.CurrentTime = frameTime;

img = readFrame(video);

end

