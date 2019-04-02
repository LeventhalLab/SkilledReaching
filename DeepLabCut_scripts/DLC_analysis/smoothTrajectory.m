function [normalized_trajectory,interp_trajectory,smoothed_trajectory] = smoothTrajectory(rawTrajectory,varargin)
% 
% smooth and interpolate the trajectory points into a standard number of
% divisions
%
% INPUTS
%   rawTrajectory - m x 3 array where each row m is the number of frames 
%       and each row is an (x,y,z) triple
%
% VARARGIN
%   numtrajectorypoints - number of points to divide the trajectory into
%   smoothwindow - width of the smoothing window the rawTrajectory is
%       passed through
%
% OUTPUTS
%   normalized_trajectory - numtrajectorypoints x 3 array containing
%       coordinates of each normalized trajectory point. This is
%       smoothed_trajectory divided 
%   interp_trajectory - m x 3 array where m is the number of frames in
%       rawTrajectory. This is with points interpolated to account for
%       missing points in the 3D rawTrajectory. Currently uses pchip
%       interpolation
%   smoothed_trajectory - m x 3 array where m is the number of frames in
%       rawTrajectory. the smoothed_trajectory is a smoothed version of
%       interp_trajectory

smoothWindow = 3;
numTrajectoryPoints = 100;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'numtrajectorypoints'
            numTrajectoryPoints = varargin{iarg + 1};
        case 'smoothwindow'
            smoothWindow = varargin{iarg + 1};
    end
end

% step1 = zeros(size(rawTrajectory));
% spline_interp = zeros(size(rawTrajectory));

% clip rawTrajectory to remove any NaN's from the beginning or end of the
% trajectory. This can be a problem especially for trials where the paw
% doesn't completely break through the reaching slot.
if isnan(rawTrajectory(1,1))
    firstValidFrame = find(~isnan(rawTrajectory(:,1)),1);
    rawTrajectory = rawTrajectory(firstValidFrame:end,:);
end
if isnan(rawTrajectory(end,1))
    lastValidFrame = find(~isnan(rawTrajectory(:,1)),1,'last');
    rawTrajectory = rawTrajectory(1:lastValidFrame,:);
end
interp_trajectory = zeros(size(rawTrajectory));
smoothed_trajectory = zeros(size(rawTrajectory));
num_x = size(rawTrajectory,1);

for iDim = 1 : size(rawTrajectory,2)
    interp_trajectory(:,iDim) = pchip(1:num_x,rawTrajectory(:,iDim),1:num_x);
    smoothed_trajectory(:,iDim) = smooth(interp_trajectory(:,iDim),smoothWindow);
end

normalized_trajectory = evenlySpacedPointsAlongTrajectory(smoothed_trajectory,numTrajectoryPoints);

end