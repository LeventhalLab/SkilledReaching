function smoothed_trajectory = smoothTrajectory(rawTrajectory,varargin)
%
% INPUTS
%
% OUTPUTS
%

numTrajectoryPoints = 100;

if nargin > 1
    numTrajectoryPoints = varargin{1};
end

step1 = zeros(size(rawTrajectory));

for iDim = 1 : size(rawTrajectory,2)
    step1(:,iDim) = smooth(rawTrajectory(:,iDim),'rlowess');
end

smoothed_trajectory = evenlySpacedPointsAlongTrajectory(step1,numTrajectoryPoints);

% MAYBE THERE'S SOME FANCY STUFF STILL TO DO FOR INTERPOLATING...WE'LL SEE
end

