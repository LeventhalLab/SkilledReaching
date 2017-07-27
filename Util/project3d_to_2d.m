function proj_pts = project3d_to_2d(points3d,boxCalibration,pawPref)
%
% function to project 3d points obtained by triangulation back onto the
% original image
%
% INPUTS:
%   points3d - M x 3 matrix with points in real world units
%   boxCalibtation - boxCalibration structure.
%       .cameraParams - matlab camera parameters structure
%       .srCal - contains info on mirror geometry (fundamental matrix,
%           essential matrix, camera matrices, scale factor, etc)
%   pawPref - 'right' or 'left'
%
% OUTPUTS:
%   proj_pts - 


K = boxCalibration.cameraParams.IntrinsicMatrix;
num_points = size(points3d,1);

P = zeros(4,3,2);
P(:,:,1) = eye(4,3);
switch pawPref
    case 'left'
        P(:,:,2) = squeeze(boxCalibration.srCal.P(:,:,2)); 
        scale3D = mean(boxCalibration.srCal.sf(:,2));
    case 'right'
        P(:,:,2) = squeeze(boxCalibration.srCal.P(:,:,1));
        scale3D = mean(boxCalibration.srCal.sf(:,1));
end

norm_points3d = points3d / scale3D;
hom_3d = [norm_points3d, ones(num_points,1)];
proj_pts = zeros(num_points,2,2);

for iView = 1 : 2
    
    hom_proj = hom_3d * squeeze(P(:,:,iView));
    hom_proj = bsxfun(@rdivide,hom_proj,hom_proj(:,3));
    
    norm_proj = hom_proj * K;
    
    proj_pts(:,:,iView) = bsxfun(@rdivide,norm_proj(:,1:2),norm_proj(:,3));
end