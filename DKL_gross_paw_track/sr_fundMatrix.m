function F = sr_fundMatrix(x1_left,x2_left,x1_right,x2_right)
%
% INPUTS:
%   x1_left,x2_left,x1_right,x2_right - cell vectors where each element is
%       an nx2 array of (x,y) pairs. "1" is for the direct view, "2" is for
%       the mirror view. "left" vs "right" refers to whether the vectors
%       contain matched points for the left or right mirrors.
%           ALTERNATIVELY
%       x1_left, etc. can be m x 2 arrays containing the matching points
%
% OUTPUTS:
%   F - 3x3x2xnumSessions array containing fundamental matrices. Third
%       argument is 1-left, 2-right

% computeCamParams = false;
% camParamFile = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
% cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
% cb_path is to checkerboard patterns for computing the camera parameters

if ~iscell(x1_left)
    temp = x1_left;
    clear x1_left;
    x1_left{1} = temp;
    
    temp = x2_left;
    clear x2_left;
    x2_left{1} = temp;
    
    temp = x1_right;
    clear x1_right;
    x1_right{1} = temp;
    
    temp = x2_right;
    clear x2_right;
    x2_right{1} = temp;
end

numSessions = length(x1_left);
F = zeros(3,3,2,numSessions);           % 3x3 x (left/right) x numSessions

for iSession = 1 : numSessions
    
    F(:,:,1,iSession) = fundMatrix_mirror(x1_left{iSession}, x2_left{iSession});
    F(:,:,2,iSession) = fundMatrix_mirror(x1_right{iSession}, x2_right{iSession});
    
end