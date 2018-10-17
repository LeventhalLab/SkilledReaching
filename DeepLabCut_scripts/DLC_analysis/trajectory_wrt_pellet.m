function new_trajectory = trajectory_wrt_pellet(pawTrajectory, bodyparts,frameRate,frameTimeLimits, reproj_error, pawPref, varargin)
% calculate the trajectory of each body part with respect to the initial
% pellet location. For left-pawed rats, reflect the trajectories about the
% x-axis so that left and right-pawed trajectories should line up
%
% INPUTS
%   pawTrajectory - 
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   frameRate - frame rate in frames per second
%   frameTimeLimits - 
%   reproj_error - numFrames x numBodyparts x 2 array. reproj_error(:,:,1)
%       contains the reprojection error in the direct view (that is, the
%       Euclidean distances between reconstructed 3D points projected back
%       onto the original 2D image for the direct view. reproj_error(:,:,2)
%       is the same for the mirror view. The second "bodypart" index is in
%       the same order as pawTrajectory
%   pawPref - 'left' or 'right'
%
% VARARGS:
%   'initpelletloc' - 3-element vector containing the presumed initial pellet
%       location. this is designed so that on trials where a pellet isn't
%       found, the algorithm can use the mean pellet location from the rest
%       of the trials as the presumed pellet location
%
% OUTPUTS
%   new_trajectory - pawTrajectory transformed so that it is the paw
%   trajectory - the initial pellet location

initPellet3D = [];
maxReprojError = 10;

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'initpelletloc'
            initPellet3D = varargin{iarg + 1};
        case 'maxreprojectionerror'
            maxReprojError = varargin{iarg + 1};
    end
    
end
if isempty(initPellet3D)
    initPellet3D = initPelletLocation(pawTrajectory,bodyparts,frameRate,frameTimeLimits);
end

if isempty(initPellet3D)
    disp('no pellet found for this trial')
    new_trajectory = [];
    return
end

NaN_pawTrajectory = nanPawTrajectory(pawTrajectory, reproj_error, maxReprojError);
new_trajectory = NaN_pawTrajectory - repmat(initPellet3D,size(pawTrajectory,1),1,size(pawTrajectory,3));

if strcmpi(pawPref,'left')
    % right-pawed trajectories will be the standard. Left pawed
    % trajectories are reflected around the pellet so that they should (I
    % think) match up with the right-pawed trajectories
    for i_part = 1 : size(new_trajectory,3)
        new_trajectory(:,1,i_part) = -new_trajectory(:,1,i_part);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NaN_pawTrajectory = nanPawTrajectory(pawTrajectory, reproj_error, maxReprojError)
% turn any pawTrajectory values equal to zero into NaNs. Also turn any
% pawTrajectory points whose reprojection is too far from the originally
% marked points into NaNs. This suggests that at least one of the points
% (direct or mirror view) was incorrectly identified.
% 

NaN_pawTrajectory = pawTrajectory;
NaN_pawTrajectory(pawTrajectory==0) = NaN;

num_bp = size(pawTrajectory,3);
for i_bp = 1 : num_bp
    cur_reproj_errors = squeeze(reproj_error(:,i_bp,:));
    
    % identify when direct or mirror reprojection errors are too great to
    % be considered valid reconstructions
    invalidReprojections = cur_reproj_errors(:,1) > maxReprojError | ...
                           cur_reproj_errors(:,1) > maxReprojError;
                       
	NaN_pawTrajectory(invalidReprojections,:,i_bp) = NaN;
    
end

end
