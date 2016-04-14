function E = sr_EssentialMatrix(x1_left,x2_left,x1_right,x2_right, K)
%
% INPUTS:
%   x1_left,x2_left,x1_right,x2_right - cell vectors where each element is
%       an nx2 array of (x,y) pairs. "1" is for the direct view, "2" is for
%       the mirror view. "left" vs "right" refers to whether the vectors
%       contain matched points for the left or right mirrors.
%           ALTERNATIVELY
%       x1_left, etc. can be m x 2 arrays containing the matching points
%   K - 
%
% OUTPUTS:
%   E - 3x3x2xnumSessions array containing essential matrices. Third
%       argument is 1-left, 2-right

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
E = zeros(3,3,2,numSessions);           % 3x3 x (left/right) x numSessions

for iSession = 1 : numSessions
    
    x1_left_norm = normalize_points(x1_left{iSession}, K);
    x2_left_norm = normalize_points(x2_left{iSession}, K);
    
    x1_right_norm = normalize_points(x1_right{iSession}, K);
    x2_right_norm = normalize_points(x2_right{iSession}, K);
    
    E(:,:,1,iSession) = fundMatrix_mirror(x1_left_norm, x2_left_norm);
    E(:,:,2,iSession) = fundMatrix_mirror(x1_right_norm, x2_right_norm);

end