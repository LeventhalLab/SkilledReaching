function F = sr_fundMatrix(x1_left,x2_left,x1_right,x2_right)
%
% INPUTS:
%   x1_left,x2_left,x1_right,x2_right - cell vectors where each element is
%       an nx2 array of (x,y) pairs. "1" is for the direct view, "2" is for
%       the mirror view. "left" vs "right" refers to whether the vectors
%       contain matched points for the left or right mirrors.
%
% OUTPUTS:
%   F - 3x3x2xnumSessions array containing fundamental matrices. Third
%       argument is 1-left, 2-right

% computeCamParams = false;
% camParamFile = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
% cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
% cb_path is to checkerboard patterns for computing the camera parameters

% if computeCamParams
%     [cameraParams, ~, ~] = cb_calibration(...
%                            'cb_path', cb_path, ...
%                            'num_rad_coeff', num_rad_coeff, ...
%                            'est_tan_distortion', est_tan_distortion, ...
%                            'estimateskew', estimateSkew);
% else
%     load(camParamFile);    % contains a cameraParameters object named cameraParams
% end
% k = cameraParams.IntrinsicMatrix;

numSessions = length(x1_left);
F = zeros(3,3,2,numSessions);           % 3x3 x (left/right) x numSessions
% F_norm = zeros(3,3,2,numSessions);      % 3x3 x (left/right) x numSessions
for iSession = 1 : numSessions
    
    F(:,:,1,iSession) = fundMatrix_mirror(x1_left{iSession}, x2_left{iSession});
    F(:,:,2,iSession) = fundMatrix_mirror(x1_right{iSession}, x2_right{iSession});
    
%     x1_hom = [x1_left{iSession},ones(size(x1_left{iSession},1),1)]';
%     x2_hom = [x2_left{iSession},ones(size(x2_left{iSession},1),1)]';
%     
%     x1_norm = (k' \ x1_hom)';
%     x2_norm = (k' \ x2_hom)';
%     
%     x1_norm(:,3) = [];
%     x2_norm(:,3) = [];
%     
%     F_norm(:,:,1,iSession) = fundMatrix_mirror(x1_norm, x2_norm);
%     
%     x1_hom = [x1_right{iSession},ones(size(x1_right{iSession},1),1)]';
%     x2_hom = [x2_right{iSession},ones(size(x2_right{iSession},1),1)]';
%     
%     x1_norm = (k' \ x1_hom)';
%     x2_norm = (k' \ x2_hom)';
%     
%     x1_norm(:,3) = [];
%     x2_norm(:,3) = [];
%     
%     F_norm(:,:,2,iSession) = fundMatrix_mirror(x1_norm, x2_norm);
end