% script to calculate calibration matrices given points labelled in Fiji
% these are distorted images, so all points need to be undistorted using
% the camera matrix before calculating 3D transformations

% will need the camera matrix to remove distortion

% 
calibrationFileLabel = 'GridCalibration';

% first, load in the marked points

% any x-coordinate less than 400 is from the left mirror
% any x-coordinate greater than 1600 is the right mirror
% any y-coordinate less than 400 is the top mirror


cal_imgList = dir([calibrationFileLabel '_*_.png']);
csvList = dir([calibrationFileLabel '_*_.csv']);


% extract session dates from cal_imgList names
