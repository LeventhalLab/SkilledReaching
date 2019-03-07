function [invalidPoints,diff_per_frame] = find_invalid_DLC_points(parts_loc, p, bodyparts, pawPref, varargin)
%
% function to find points that are likely to be invalid in DLC output.
% Strategy is to 1) find points with p-values that are very high and are
% certainly correct IDs, 2) find points with p-values that are very low and
% are certainly incorrect IDs, and 3) find points with intermediate
% p-values that made large spatial jumps between frames (and are likely
% therefore misidentified in at least one of the frames)
%
% INPUTS:
%   parts_loc - m x n x 2 array where m is the number of body parts, n is
%       the number of frames in the video. each bodypart-frame entry is an
%       x,y coordinate pair
%   p - number of body parts x number of frames array
%       containing p-values for how confident DLC is that a body part was
%       correctly identified
%   bodyparts - cell array containing lis of body part descriptors
%   pawPref - 'left' or 'right'
%
% VARARGS:
%   maxdistperframe - maximum distance a point can travel per frame before
%       flagging as a possible mistake
%   min_valid_p - minimum certainty score from DLC above which the point
%       may (or may not) be accurate
%   min_certain_p - minimum certainty score from DLC above which the point
%       is assumed to be accurate
%   maxneighbordist - maximum distance a point can be from a neighboring
%       point before flagging as a possible mistake
%
% OUTPUTS:
%   invalidPoints - bodyparts x numframes boolean array where true values
%       indicate that a bodypart in a given frame was (probably) not
%       correctly identified
%   diff_per_frame - num_bodyparts x numframes-1 array containing the
%       distance (in pixels) that a point moved on each frame

maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxNeighborDist = 70;

for iarg = 1 : nargin - 4
    switch lower(varargin{iarg})
        case 'maxdistperframe'
            maxDistPerFrame = varargin{iarg + 1};
        case 'min_valid_p'
            min_valid_p = varargin{iarg + 1};   % p values below this are considered to indicate poorly determined points (and exclude from subsequent analysis)
        case 'min_certain_p'
            min_certain_p = varargin{iarg + 1};   % p values above this are considered to be well-determined points (and include in subsequent analysis)
        case 'maxneighbordist'
            maxNeighborDist = varargin{iarg + 1};
    end
end

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
reachingPawParts = [mcpIdx;pipIdx;digIdx;pawDorsumIdx];

num_frames = size(parts_loc, 2);
num_bodyparts = size(parts_loc, 1);

invalidPoints = p < min_valid_p;   % first pass - anything with p-value too small, ignore
certainPoints = p > min_certain_p;

diff_per_frame = zeros(num_bodyparts, num_frames-1);
poss_too_far = false(num_bodyparts,num_frames);

numFrames = size(parts_loc,2);
for iBodyPart = 1 : num_bodyparts
    
    individual_part_loc = squeeze(parts_loc(iBodyPart,:,:));
    individual_part_loc(invalidPoints(iBodyPart,:)',:) = NaN;
    
    diff_per_frame(iBodyPart,:) = vecnorm(diff(individual_part_loc),2,2);   % euclidean distance traveled between frames for each bodypart
    
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

% throw out any points on the reaching paw that are too far away from the
% cluster of other points, except for the paw dorsum
for iFrame = 1 : numFrames
    
    curValidIdx = find(~invalidPoints(reachingPawParts,iFrame));
    numValidPoints = length(curValidIdx);
    
    if numValidPoints > 3   % if at least 4 points found, discard any point that is an outlier
    
        curReachingPawCoords = squeeze(parts_loc(reachingPawParts,iFrame,:));
    	validPawCoords = curReachingPawCoords(curValidIdx,:);
        
        for iPoint = 1 : numValidPoints
            testIdx = false(numValidPoints,1);
            testIdx(iPoint) = true;
            testPoint = validPawCoords(testIdx,:);
            otherPoints = validPawCoords(~testIdx,:);
        
            [nndist,~] = findNearestNeighbor(testPoint,otherPoints);
            
            if nndist > maxNeighborDist
                
                invalidateIdx = curValidIdx(iPoint);
                if invalidateIdx ~= pawDorsumIdx
                    invalidPoints(reachingPawParts(invalidateIdx),iFrame) = true;
                end
                
            end
        end
    end
    
    
end