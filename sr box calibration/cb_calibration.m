function [cameraParams, imUsed, estimationErrors] = cb_calibration(varargin)
% estimate camera intrinsic parameters from a set of checkerboard images
%
% usage: [cameraParams, imUsed, estimationErrors] = ...
%           cb_calibration(varargin)
% 
% INPUTS: none
%
% VARARGs:
%   'cb_path' - path to the folder containing the checkerboard calibration
%       images
%   'num_rad_coeff' - number of radial distortion coefficients to calculate
%   'est_tan_distorion' - whether to estimate tangential distortion. In
%       general, this should be very close to zero and not necessary
%   'estimateskew' - should also be very close to zero and probably isn't
%       necessary
%
% OUTPUTS:
%   cameraParams - camera parameters object from the calibration
%   imUsed - vector indicating which images were used for the calibration.
%   estimationErrors - cameraCalibrationErrors object

cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;

for iarg = 1 : 2 : nargin
    switch lower(varargin{iarg})
        case 'cb_path',
            cb_path = varargin{iarg + 1};
        case 'numradialdistortioncoefficients',
            num_rad_coeff = varargin{iarg + 1};
        case 'estimatetangentialdistortion',
            est_tan_distortion = varargin{iarg + 1};
        case 'estimateskew',
            estimateSkew = varargin{iarg + 1};
    end
end

cd(cb_path);
cb_files = dir('*.png');

fname = fullfile(cb_path, cb_files(1).name);
im_test = imread(fname);
im = uint8(zeros(size(im_test,1),size(im_test,2),size(im_test,3),length(cb_files)));
im(:,:,:,1) = im_test;
for ii = 1 : length(cb_files)
    fname = fullfile(cb_path, cb_files(ii).name);
    
    im(:,:,:,ii) = imread(fname);
end

%%
[impts,bs] = detectCheckerboardPoints(im);
worldPoints = generateCheckerboardPoints(bs,20);
%%
[cameraParams,imUsed,estimationErrors] = estimateCameraParameters(impts,worldPoints,...
                                                                  'numradialdistortioncoefficients',num_rad_coeff, ...
                                                                  'estimatetangentialdistortion',est_tan_distortion, ...
                                                                  'estimateskew',estimateSkew);