function v = pawVelocity(pawTrajectory,frameRate)
%
% find the closest distance between any point on the paw and the sugar
% pellet
%
% INPUTS:
%
% OUTPUTS:
%   v - numFrames x numBodyparts x 3 array containing the velocity (or
%       acceleration component in each direction
%



v = NaN(size(pawTrajectory,1)-1,3,size(pawTrajectory,3));
for i_bp = 1 : size(pawTrajectory,3)
    
    currentTrajectory = squeeze(pawTrajectory(:,:,i_bp));
    
    if ~any(isnan(currentTrajectory(:)))
        % not clear if invalid points will be represented by NaN's or zeros
        % This makes sure either can be accepted as input
        currentTrajectory(currentTrajectory == 0) = NaN;
    end
    
    cur_v = diff(currentTrajectory);
    
    v(:,:,i_bp) = cur_v * frameRate;
    
end

end