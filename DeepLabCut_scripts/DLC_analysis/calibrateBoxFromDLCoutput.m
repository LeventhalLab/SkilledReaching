function [boxCal_fromVid,mp_direct,mp_mirror,bp_idx,frameList] = calibrateBoxFromDLCoutput(direct_pts_ud,mirror_pts_ud,direct_p,mirror_p,invalid_direct,invalid_mirror,direct_bp,mirror_bp,cameraParams,boxCal,pawPref,varargin)

min_valid_p = 1;
boxCal_fromVid = boxCal;

imSize = [1024,2040];

for iarg = 1 : 2 : nargin - 11
    switch lower(varargin{iarg})
        case 'min_valid_p'
            min_valid_p = varargin{iarg + 1};
        case 'imsize'
            imSize = varargin{iarg + 1};
    end
end

% match body parts between direct and mirror views
mirror_bpMatch_idx = [];
direct_bpMatch_idx = [];
num_direct_bp = length(direct_bp);
numValid_bp = 0;
bodyparts = {};
for i_bp = 1 : num_direct_bp
    
    if isempty(strcmpi(mirror_bp, direct_bp{i_bp}))
        continue;
    end
    numValid_bp = numValid_bp + 1;
    mirror_bpMatch_idx(numValid_bp) = find(strcmpi(mirror_bp, direct_bp{i_bp}));
    direct_bpMatch_idx(numValid_bp) = i_bp;
    bodyparts{numValid_bp} = direct_bp{i_bp};
end

switch pawPref
    case 'right'
        cam_matrix_idx = 2;
    case 'left'
        cam_matrix_idx = 3;
end
K = cameraParams.IntrinsicMatrix;

valid_direct = (direct_p >= min_valid_p) & ~isnan(direct_pts_ud(:,:,1)) & ~invalid_direct;
valid_mirror = (mirror_p >= min_valid_p) & ~isnan(mirror_pts_ud(:,:,1)) & ~invalid_mirror;

validPoints = (valid_direct & valid_mirror);

% create arrays of confidently matched points between the views
mp_direct = squeeze(direct_pts_ud(1,validPoints(1,:),:));
mp_mirror = squeeze(mirror_pts_ud(mirror_bpMatch_idx(1),validPoints(mirror_bpMatch_idx(1),:),:));
if iscolumn(mp_direct);mp_direct = mp_direct';end
if iscolumn(mp_mirror);mp_mirror = mp_mirror';end
    
bp_idx = ones(size(mp_direct,1),1);
frameList = find(validPoints(1,:))';
for i_bp = 2 : num_direct_bp

    if ~any(validPoints(i_bp,:));continue;end
    
    new_direct = squeeze(direct_pts_ud(i_bp,validPoints(i_bp,:),:));
    new_mirror = squeeze(mirror_pts_ud(mirror_bpMatch_idx(i_bp),validPoints(mirror_bpMatch_idx(i_bp),:),:));
    
    if iscolumn(new_direct);new_direct = new_direct';end
    if iscolumn(new_mirror);new_mirror = new_mirror';end

    mp_direct = [mp_direct;new_direct];
    mp_mirror = [mp_mirror;new_mirror];
    
    bp_idx = [bp_idx;i_bp*ones(size(new_direct,1),1)];
    
    frameList = [frameList;find(validPoints(i_bp,:))'];
    
end

[F,maxError] = refineFundMatrixMirror(mp_direct,mp_mirror,imSize);
% F = fundMatrix_mirror(mp_direct, mp_mirror);

E = K * F * K';
[rot,t] = EssentialMatrixToCameraMatrix(E);
[cRot,cT,~] = SelectCorrectEssentialCameraMatrix_mirror(...
    rot,t,mp_mirror',mp_direct',K');
Ptemp = [cRot,cT];
Pn = Ptemp';

boxCal_fromVid.F(:,:,cam_matrix_idx) = F;
boxCal_fromVid.E(:,:,cam_matrix_idx) = E;
boxCal_fromVid.Pn(:,:,cam_matrix_idx) = Pn;
end