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
postWidth = 85;         % in mm
boxWidth = 150;         % in mm
shelfWidth = 100;       % in mm, this seems to be fairly accurate
useShelfInsteadofRubiks = false;
usePostsInsteadofRubiks = false;

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'rubikspacing'
            rubikSpacing = varargin{iarg + 1};
        case 'boxwidth'
            boxWidth = varargin{iarg + 1};
        case 'shelfwidth'
            shelfWidth = varargin{iarg + 1};
        case 'forceshelf'
            useShelfInsteadofRubiks = varargin{iarg + 1};
        case 'forceposts'
            usePostsInsteadofRubiks = varargin{iarg + 1};
        case 'postwidth'
            postWidth = varargin{iarg + 1};
    end
end

skipRubiks = false;
if isfield(session_mp.direct,'left_rbk_a')
    if isnan(session_mp.direct.left_rbk_a)
        skipRubiks = true;
    end
else
    skipRubiks = true;
end
if ~skipRubiks && ~useShelfInsteadofRubiks
    % this session had a rubiks calibration image
    sf = estimateScale_rubik(session_mp, P, K, rubikSpacing);
end

if useShelfInsteadofRubiks
    sf = estimateScale_shelfWidth(session_mp, P, K, shelfWidth);
end

if (skipRubiks && ~useShelfInsteadofRubiks) || usePostsInsteadofRubiks
    sf = estimateScale_shelfPosts(session_mp, P, K, postWidth);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sf = estimateScale_rubik(session_mp, P, K, rubikSpacing)

P1 = eye(4,3);
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
rbk_edge_pairs(1,:,1,3) = session_mp.direct.right_rbk_a;
rbk_edge_pairs(2,:,1,3) = session_mp.direct.right_rbk_b;

rbk_edge_pairs(1,:,2,3) = session_mp.direct.right_rbk_c;
rbk_edge_pairs(2,:,2,3) = session_mp.direct.right_rbk_d;

rbk_edge_pairs(1,:,3,3) = session_mp.direct.right_rbk_e;
rbk_edge_pairs(2,:,3,3) = session_mp.direct.right_rbk_f;

% right mirror view                           
rbk_edge_pairs(1,:,1,4) = session_mp.rightMirror.right_rbk_a;
rbk_edge_pairs(2,:,1,4) = session_mp.rightMirror.right_rbk_b;

rbk_edge_pairs(1,:,2,4) = session_mp.rightMirror.right_rbk_c;
rbk_edge_pairs(2,:,2,4) = session_mp.rightMirror.right_rbk_d;

rbk_edge_pairs(1,:,3,4) = session_mp.rightMirror.right_rbk_e;
rbk_edge_pairs(2,:,3,4) = session_mp.rightMirror.right_rbk_f;


% now triangulate the points
sf = zeros(3,2);
for iView = 1 : 2   % 1 - left view, 2 - right view
    if iView == 1
        direct_idx = 1;
        mirror_idx = 2;
    else
        direct_idx = 3;
        mirror_idx = 4;
    end
    
    P2 = squeeze(P(:,:,iView));
    for iPair = 1 : 3
        direct_norm = normalize_points(squeeze(rbk_edge_pairs(:,:,iPair,direct_idx)), K);
        mirror_norm = normalize_points(squeeze(rbk_edge_pairs(:,:,iPair,mirror_idx)), K);
        
        [points3d,reprojectedPoints,errors] = triangulate_DL(direct_norm, mirror_norm, P1, P2);
        
        % calculate the euclidean distance between the 3d points
        xyz_dist = diff(points3d,1,1);
        euc_dist = sqrt(sum(xyz_dist.^2));
        
        sf(iPair,iView) = rubikSpacing / euc_dist;
    end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sf = estimateScale_shelfWidth(session_mp, P, K, shelfWidth)

sf = zeros(1,2);
P1 = eye(4,3);

% leftShelfEdge and rightShelfEdge are the estimated locations of the shelf
% corner in the mirror views - either directy measured or estimated by
% extending the shelf edges in the mirror view until they intersect
[leftShelfEdge, rightShelfEdge] = estimateShelfIntersect(session_mp);

direct_shelf_corners = [session_mp.direct.left_top_shelf_corner;...
                        session_mp.direct.right_top_shelf_corner];
direct_norm = normalize_points(direct_shelf_corners, K);

% left mirror first
P2 = squeeze(P(:,:,1));
leftMirror_shelf_corners = [leftShelfEdge;...
                            session_mp.leftMirror.right_top_shelf_corner];
leftMirror_norm = normalize_points(leftMirror_shelf_corners, K);

if any(isnan(direct_norm(:))) || any(isnan(leftMirror_norm(:)))
    points3d = NaN(2,3);
else
    [points3d,reprojectedPoints,errors] = triangulate_DL(direct_norm, leftMirror_norm, P1, P2);
end

% calculate the euclidean distance between the 3d points
xyz_dist = diff(points3d,1,1);
euc_dist = sqrt(sum(xyz_dist.^2));
sf(1) = shelfWidth / euc_dist;

% now right mirror
P2 = squeeze(P(:,:,2));
rightMirror_shelf_corners = [rightShelfEdge;...
                            session_mp.rightMirror.left_top_shelf_corner];
rightMirror_norm = normalize_points(rightMirror_shelf_corners, K);

if any(isnan(direct_norm(:))) || any(isnan(rightMirror_norm(:)))
    points3d = NaN(2,3);
else
    [points3d,reprojectedPoints,errors] = triangulate_DL(direct_norm, rightMirror_norm, P1, P2);
end

% calculate the euclidean distance between the 3d points
xyz_dist = diff(points3d,1,1);
euc_dist = sqrt(sum(xyz_dist.^2));
sf(2) = shelfWidth / euc_dist;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sf = estimateScale_shelfPosts(session_mp, P, K, postWidth)

sf = zeros(1,2);
P1 = eye(4,3);

% leftShelfEdge and rightShelfEdge are the estimated locations of the shelf
% corner in the mirror views - either directy measured or estimated by
% extending the shelf edges in the mirror view until they intersect
% [leftShelfEdge, rightShelfEdge] = estimateShelfIntersect(session_mp);

direct_shelf_bolts = [session_mp.direct.left_shelf_bolt;...
                        session_mp.direct.right_shelf_bolt];
direct_norm = normalize_points(direct_shelf_bolts, K);

% left mirror first
P2 = squeeze(P(:,:,1));
leftMirror_bolts = [session_mp.leftMirror.left_shelf_bolt;...
                    session_mp.leftMirror.right_shelf_bolt];
leftMirror_norm = normalize_points(leftMirror_bolts, K);

if any(isnan(direct_norm(:))) || any(isnan(leftMirror_norm(:)))
    points3d = NaN(2,3);
else
    [points3d,reprojectedPoints,errors] = triangulate_DL(direct_norm, leftMirror_norm, P1, P2);
end

% calculate the euclidean distance between the 3d points
xyz_dist = diff(points3d,1,1);
euc_dist = sqrt(sum(xyz_dist.^2));
sf(1) = postWidth / euc_dist;

% now right mirror
P2 = squeeze(P(:,:,2));
rightMirror_bolts = [session_mp.rightMirror.left_shelf_bolt;...
                     session_mp.rightMirror.right_shelf_bolt];
rightMirror_norm = normalize_points(rightMirror_bolts, K);

if any(isnan(direct_norm(:))) || any(isnan(rightMirror_norm(:)))
    points3d = NaN(2,3);
else
    [points3d,reprojectedPoints,errors] = triangulate_DL(direct_norm, rightMirror_norm, P1, P2);
end

% calculate the euclidean distance between the 3d points
xyz_dist = diff(points3d,1,1);
euc_dist = sqrt(sum(xyz_dist.^2));
sf(2) = postWidth / euc_dist;

end