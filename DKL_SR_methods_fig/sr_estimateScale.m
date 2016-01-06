function sf = sr_estimateScale(session_mp, P, K, varargin)
% 
% INPUTS:
%   session_mp - matched points structure for a single session
%   P - 4 x 3 x 2 array where P(:,:,1) is the camera matrix for the left
%       mirror view, P(:,:,2) is the camera matrix for the right mirror
%       view
%
% OUTPUTS:
%

rubikSpacing = 17.5;    % in mm

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'rubikspacing',
            rubikSpacing = varargin{iarg + 1};
    end
end
    
% first, find pairs of points that will be rubiksSpacing apart
rbk_edge_pairs = zeros(2,2,3, 4);    % 2 x 2 arrays of (x,y) pairs for each corner of a square
                                     % 3rd argument - index of each pair
                                  % 4th argument: 1 - left direct view, 
                                  % 2 - left mirror, 3 - right direct view,
                                  % 4 - right mirror
% left direct view                           
rbk_edge_pairs(1,:,1,1) = session_mp.direct.left_rbk_a;
rbk_edge_pairs(2,:,1,1) = session_mp.direct.left_rbk_b;

rbk_edge_pairs(1,:,2,1) = session_mp.direct.left_rbk_c;
rbk_edge_pairs(2,:,2,1) = session_mp.direct.left_rbk_d;

rbk_edge_pairs(1,:,3,1) = session_mp.direct.left_rbk_e;
rbk_edge_pairs(2,:,3,1) = session_mp.direct.left_rbk_f;

% left mirror view
rbk_edge_pairs(1,:,1,2) = session_mp.leftMirror.left_rbk_a;
rbk_edge_pairs(2,:,1,2) = session_mp.leftMirror.left_rbk_b;

rbk_edge_pairs(1,:,2,2) = session_mp.leftMirror.left_rbk_c;
rbk_edge_pairs(2,:,2,2) = session_mp.leftMirror.left_rbk_d;

rbk_edge_pairs(1,:,3,2) = session_mp.leftMirror.left_rbk_e;
rbk_edge_pairs(2,:,3,2) = session_mp.leftMirror.left_rbk_f;

% right direct view                           
rbk_edge_pairs(1,:,1,1) = session_mp.direct.right_rbk_a;
rbk_edge_pairs(2,:,1,1) = session_mp.direct.right_rbk_b;

rbk_edge_pairs(1,:,2,1) = session_mp.direct.right_rbk_c;
rbk_edge_pairs(2,:,2,1) = session_mp.direct.right_rbk_d;

rbk_edge_pairs(1,:,3,1) = session_mp.direct.right_rbk_e;
rbk_edge_pairs(2,:,3,1) = session_mp.direct.right_rbk_f;

% right mirror view                           
rbk_edge_pairs(1,:,1,1) = session_mp.rightMirror.right_rbk_a;
rbk_edge_pairs(2,:,1,1) = session_mp.rightMirror.right_rbk_b;

rbk_edge_pairs(1,:,2,1) = session_mp.rightMirror.right_rbk_c;
rbk_edge_pairs(2,:,2,1) = session_mp.rightMirror.right_rbk_d;

rbk_edge_pairs(1,:,3,1) = session_mp.rightMirror.right_rbk_e;
rbk_edge_pairs(2,:,3,1) = session_mp.rightMirror.right_rbk_f;


% now triangulate the points

for iView = 1 : 2
    if iView == 1
        direct_idx = 1;
        mirror_idx = 2;
    else
        direct_idx = 3;
        mirror_idx = 4;
    end
    
    for iPair = 1 : 3
        direct_norm = normalize_points(squeeze(