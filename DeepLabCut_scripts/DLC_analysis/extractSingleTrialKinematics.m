function [interp_trajectory,frameRange] = extractSingleTrialKinematics(trajectory,varargin)
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

for iarg = 1 : 2 : nargin - 1
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

% calculate trajectory for each identified "body part"
for i_part = 1 : 16
    fullTrajectory = squeeze(trajectory(:,:,i_part));
    [frameRange(i_part,:),cur_trajectory] = ...
        smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);
    interp_trajectory(frameRange(i_part,1):frameRange(i_part,2),:,i_part) = cur_trajectory;
end