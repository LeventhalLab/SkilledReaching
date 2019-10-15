function [interp_trajectory,frameRange] = extractSingleTrialKinematics(trajectory,bodyparts,varargin)
%
% INPUTS
%   trajectory - m x 3 x p array where m is the number of frames in each
%       video, the second dimension is (x,y,z) coordinates, and p is the
%       number of body parts
%
% OUTPUTS
%   interp_trajectory
%   frameRange - num_bodyparts x 2 array; first element in each row is the
%       first frame in which this "body part" was identified; 2nd element
%       is the last frame

windowLength = 10;
smoothMethod = 'gaussian';

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'windowlength'
            windowLength = varargin{iarg+1};
        case 'smoothmethod'
            smoothMethod = varargin{iarg+1};
    end
end

numFrames = size(trajectory,1);
num_bodyparts = size(trajectory,3);
interp_trajectory = NaN(numFrames,3,num_bodyparts);
frameRange = zeros(num_bodyparts,2);

% calculate trajectory for each identified "body part". start with the paw
% dorsum
[mcp_idx,pip_idx,digit_idx,pawdorsum_idx,~,pellet_idx,~] = group_DLC_bodyparts(bodyparts,pawPref);
fullTrajectory = squeeze(trajectory(:,:,pawdorsum_idx));
[frameRange(pawdorsum_idx,:),cur_trajectory] = ...
    smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);
interp_trajectory(frameRange(pawdorsum_idx,1):frameRange(pawdorsum_idx,2),:,pawdorsum_idx) = cur_trajectory;
any_digit_marker = [mcp_idx;pip_idx;digit_idx];
for i_part = 1 : 16
    if i_part == pellet_idx
        % this was already calculated
        continue;
    end
    fullTrajectory = squeeze(trajectory(:,:,i_part));
    numValidPoints = sum(~isnan(fullTrajectory(:,1)));
    if numValidPoints < 2
        continue;
    end
    % invalidate digit points that are too far from the paw dorsum - could
    % indicate digits on the non-reaching paw detected through the slot
    if any(any_digit_marker == i_part)
        
    end
    
    
    [frameRange(i_part,:),cur_trajectory] = ...
        smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);
    interp_trajectory(frameRange(i_part,1):frameRange(i_part,2),:,i_part) = cur_trajectory;
end