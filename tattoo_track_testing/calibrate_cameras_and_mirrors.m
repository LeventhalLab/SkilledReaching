function [R,t,H,Ri,Ti] = calibrate_cameras_and_mirrors(cb_path, impts, varargin)
%
% usage: 
%
% INPUTS:
%   cb_path - path to the checkerboard images. Only checkerboard images
%       should be contained in that folder.
%   impts - image points. m x 2 x p matrix, where m is the number of points
%       in each checkerboard and p is the number of checkerboards
%
% VARARGS:
%   K - if the intrinsic matrix is to be set externally (from the camera
%       data sheet, for example) instead of calibrating with checkerboard
%       images
%   worldPoints - m x 2 matrix containing checkerboard points in world
%       coordinates. Default is 5x5 with 8 mm spacing
%
% OUTPUTS:
%   

num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;

numImages = size(impts,3);

cameraParameters = cell(1,4);
K = [];

worldPoints = generateCheckerboardPoints([5,5],8);
worldPoints = fliplr(worldPoints);

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'k',
            K = varargin{iarg + 1};
        case 'worldPoints',
            worldPoints = varargin{iarg + 1};
    end
end
            
if isempty(K)
    [cp_intrinsics,~,~] = cb_calibration('cb_path',cb_path, ...
                                         'numradialdistortioncoefficients', num_rad_coeff, ...
                                         'estimatetangentialdistortion', est_tan_distortion, ...
                                         'estimateskew', estimateSkew);

    K = cp_intrinsics.IntrinsicMatrix;
end

R = zeros(3,3,numImages);
t = zeros(numImages, 3);

for ii = 1 : numImages
    [R(:,:,ii), t(ii,:)] = extrinsicsPlanar_DL(squeeze(impts(:,:,ii)),worldPoints, K);
    
end

