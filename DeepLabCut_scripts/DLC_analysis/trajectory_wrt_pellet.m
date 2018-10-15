function new_trajectory = trajectory_wrt_pellet(pawTrajectory, bodyparts,frameRate,frameTimeLimits, pawPref, varargin)
% calculate the trajectory of each body part with respect to the initial
% pellet location. For left-pawed rats, reflect the trajectories about the
% x-axis so that left and right-pawed trajectories should line up
%
% INPUTS
%   pawTrajectory - 
%   bodyparts -
%   frameRate - frame rate in frames per second
%   frameTimeLimits - 
%   pawPref - 'left' or 'right'
%
% VARARGS:
%   1st argument - 3-element vector containing the presumed initial pellet
%       location. this is designed so that on trials where a pellet isn't
%       found, the algorithm can use the mean pellet location from the rest
%       of the trials as the presumed pellet location
%
% OUTPUTS
%   new_trajectory

if nargin > 5
    initPellet3D = varargin{1};
else
    initPellet3D = initPelletLocation(pawTrajectory,bodyparts,frameRate,frameTimeLimits);
end

if isempty(initPellet3D)
    disp('no pellet found for this trial')
    new_trajectory = [];
    return
end

new_trajectory = pawTrajectory - repmat(initPellet3D,size(pawTrajectory,1),1,size(pawTrajectory,3));

if strcmpi(pawPref,'left')
    % right-pawed trajectories will be the standard. Left pawed
    % trajectories are reflected around the pellet so that they should (I
    % think) match up with the right-pawed trajectories
    for i_part = 1 : size(new_trajectory,3)
        new_trajectory(:,1,i_part) = -new_trajectory(:,1,i_part);
    end
end

end