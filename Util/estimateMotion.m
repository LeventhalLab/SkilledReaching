function motionMask = estimateMotion(prevMask,curMask)
%
% usage:
%
% INPUTS:
%   prevMask - mask from the previous frame
%   curMask - mask from the current frame
%
% OUTPUTS:
%   motionMask - 

temp = prevMask & ~curMask;    % region in previous mask not in current mask


end