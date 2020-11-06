function new_trajectory = trajectory_wrt_pellet(pawTrajectory, initPellet3D, reproj_error, pawPref, varargin)
% calculate the trajectory of each body part with respect to the initial
% pellet location. For left-pawed rats, reflect the trajectories about the
% x-axis so that left and right-pawed trajectories should line up
%
% INPUTS
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFrames x 3
%       matrix contains x,y,z points for each bodypart
%   initPellet3D - [x,y,z] coordinates of the pellet with respect to the
%       camera lens
%   reproj_error - numBodyparts x numFrames x 2 array. reproj_error(:,:,1)
%       contains the reprojection error in the direct view (that is, the
%       Euclidean distances between reconstructed 3D points projected back
%       onto the original 2D image for the direct view. reproj_error(:,:,2)
%       is the same for the mirror view. The "bodypart" index is in
%       the same order as pawTrajectory
%   pawPref - 'left' or 'right'
%
% VARARGS:
%   maxreprojectionerror - maximum tolerated reprojection error
%
% OUTPUTS
%   new_trajectory - pawTrajectory transformed so that it is the paw
%       trajectory - the initial pellet location. Note that: 1) negative z
%       is closer to the camera, and 2) left-pawed reaches have the
%       x-dimension inverted so that all trajectories should "point" the
%       same direction

maxReprojError = 10;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'maxreprojectionerror'
            maxReprojError = varargin{iarg + 1};
    end
    
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


