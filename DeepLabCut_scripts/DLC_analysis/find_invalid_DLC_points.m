function [invalidPoints,diff_per_frame] = find_invalid_DLC_points(parts_loc, p, varargin)
%
% function to find points that are likely to be invalid in DLC output.
% Strategy is to 1) find points with 
%
% INPUTS:
%   parts_loc - m x n x 2 array where m is the number of body parts, n is
%       the number of frames in the video. each bodypart-frame entry is an
%       x,y coordinate pair
%
% OUTPUTS:
%   invalidPoints - 
%   diff_per_frame - num_bodyparts x numframes-1 array containing the
%       distance (in pixels) that a point moved on each frame

maxDistPerFrame = 30;
min_valid_p = 0.8;
min_certain_p = 0.95;
%maxNeighborSeparation = 30;   % to be used to make sure points that should
%be near each other are near each other

for iarg = 1 : nargin - 2
    switch lower(varargin{iarg})
        case 'maxdistperframe'
            maxDistPerFrame = varargin{iarg + 1};
        case 'min_valid_p'
            min_valid_p = varargin{iarg + 1};   % p values below this are considered to indicate poorly determined points (and exclude from subsequent analysis)
        case 'min_certain_p'
            min_certain_p = varargin{iarg + 1};   % p values above this are considered to be well-determined points (and include in subsequent analysis)
    end
end


num_frames = size(parts_loc, 2);
num_bodyparts = size(parts_loc, 1);

invalidPoints = p < min_valid_p;   % first pass - anything with p-value too small, ignore
certainPoints = p > min_certain_p;

diff_per_frame = zeros(num_bodyparts, num_frames-1);
poss_too_far = false(num_bodyparts,num_frames);

for iBodyPart = 1 : num_bodyparts
    
%     invalidPoints_bp = squeeze(invalidPoints(iBodyPart,:,:));
    
    individual_part_loc = squeeze(parts_loc(iBodyPart,:,:));
    individual_part_loc(invalidPoints(iBodyPart,:)',:) = NaN;
    
    diff_per_frame(iBodyPart,:) = vecnorm(diff(individual_part_loc),2,2);
    
    poss_too_far(iBodyPart,1:end-1) = diff_per_frame(iBodyPart,:) > maxDistPerFrame;
    poss_too_far(iBodyPart,2:end) = poss_too_far(iBodyPart,1:end-1) | poss_too_far(iBodyPart,2:end);
    % logic is that either the point before or point after could be the bad
    % point if there was too big a location jump between frames
    
    poss_too_far(iBodyPart,:) = poss_too_far(iBodyPart,:) | isnan(invalidPoints(iBodyPart,:));
    % also, any NaNs from low probability parts should be included as
    % potentially too big a jump

    % any poss_too_far points that have very high certainty should be
    % considered to be accurate
    poss_too_far(iBodyPart, certainPoints(iBodyPart,:)) = false;
    % keep any points with p > min_certain_p even if it apparently traveled
    % too far in one frame
    
end

invalidPoints = invalidPoints | poss_too_far;

% could also add a check to see if points that should be near each other
% are near each other