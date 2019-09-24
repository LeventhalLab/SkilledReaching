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
    cur_reproj_errors = squeeze(reproj_error(i_bp,:,:));
    
    % identify when direct or mirror reprojection errors are too great to
    % be considered valid reconstructions
    invalidReprojections = cur_reproj_errors(:,1) > maxReprojError | ...
                           cur_reproj_errors(:,2) > maxReprojError;
                       
	NaN_pawTrajectory(invalidReprojections,:,i_bp) = NaN;
    
end

end