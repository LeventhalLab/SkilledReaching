function d = distFromPellet(pawTrajectory,bodyparts,frameRate,frameTimeLimits)
%
% find the closest distance between any point on the paw and the sugar
% pellet
%
% INPUTS:
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%
% OUTPUTS:
%   d - numFrames x numBodyparts array containing the euclidean distance of
%       each body part from the pellet's initial condition
%
% hard code strings that only occur in bodyparts that are part of the
% reaching paw
% reachingPawParts = {'mcp','pip','digit',[pawPref 'dorsum']};
initPellet3D = initPelletLocation(pawTrajectory,bodyparts,frameRate,frameTimeLimits);

d = NaN(size(pawTrajectory,1),size(pawTrajectory,3));
if isempty(initPellet3D)
    % most likely a trial in which a pellet wasn't grabbed, just return a
    % matrix of NaNs
    return
end

for i_bp = 1 : length(bodyparts)
    
    currentTrajectory = squeeze(pawTrajectory(:,:,i_bp));
    pellet_traj_diff = repmat(initPellet3D,size(currentTrajectory,1),1) - currentTrajectory;

    pellet_dist = sqrt(sum(pellet_traj_diff.^2,2));
    
    d(currentTrajectory(:,1)>0,i_bp) = pellet_dist(currentTrajectory(:,1)>0);
    
end

end