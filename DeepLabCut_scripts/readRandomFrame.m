function [ img ] = readRandomFrame( video, varargin )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

frameLimits = 
for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'framelimits'
            frameLimits = varargin{iarg + 1};
    end
end

fr = video.FrameRate;
numFrames = video.Duration * fr;



end

