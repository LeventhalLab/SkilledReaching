function [J, newOrigin] = undistortImage(I, cameraParams, varargin)
%undistortImage Correct image for lens distortion.
%   [J, newOrigin] = undistortImage(I, cameraParams) removes lens distortion
%   from image I, and returns the result as image J. I can be a grayscale or
%   a truecolor image. cameraParams is a cameraParameters object.
%
%   newOrigin is a 2-element vector containing the [x,y] location of the 
%   origin of the output image J in the intrinsic coordinates of the input 
%   image I. Before using extrinsics, pointsToWorld, or triangulate 
%   functions you must add newOrigin to the coordinates of points detected 
%   in undistorted image J in order to transform them into the intrinsic 
%   coordinates of the original image I.
%   If 'OutputView' is set to 'same', then newOrigin is [0, 0]. 
%
%   [J, newOrigin] = undistortImage(..., interp) specifies interpolation
%   method to use. interp can be one of the strings 'nearest', 'linear', or
%   'cubic'. The default value for interp is 'linear'.
%
%   [J, newOrigin] = undistortImage(..., Name, Value) specifies additional 
%   name-value pairs described below:
%  
%   'OutputView'     Determines the size of the output image J. Possible 
%                    values are:
%                      'same'  - J is the same size as I
%                      'full'  - J includes all pixels from I
%                      'valid' - J is cropped to the size of the largest
%                                rectangle contained in I
%  
%                    Default: 'same'
%  
%   'FillValues'     An array containing one or several fill values.
%                    Fill values are used for output pixels when the
%                    corresponding inverse transformed location in the
%                    input image is completely outside the input image
%                    boundaries.
%  
%                    If I is a 2-D grayscale image then 'FillValues' 
%                    must be a scalar. If I is a truecolor image, then 
%                    'FillValues' can be a scalar or a 3-element vector
%                    of RGB values.
%
%                    Default: 0
%  
%   Class Support
%   -------------
%   The class of input I can be uint8, uint16, int16, double,
%   single. J is the same class as I.
%
%   Example - Correct an image for lens distortion
%   ----------------------------------------------
%   % Create a set of calibration images.
%   images = imageSet(fullfile(toolboxdir('vision'), 'visiondemos', ...
%       'calibration', 'fishEye'));
%
%   % Detect calibration pattern.
%   [imagePoints, boardSize] = detectCheckerboardPoints(images.ImageLocation);
%
%   % Generate world coordinates of the corners of the squares.
%   squareSize = 29; % square size in millimeters
%   worldPoints = generateCheckerboardPoints(boardSize, squareSize);
%
%   % Calibrate the camera.
%   cameraParams = estimateCameraParameters(imagePoints, worldPoints);
%
%   % Remove lens distortion and display results.
%   I = images.read(1);
%   J1 = undistortImage(I, cameraParams);
%
%   figure; imshowpair(I, J1, 'montage');
%   title('Original Image (left) vs. Corrected Image (right)');
%
%   J2 = undistortImage(I, cameraParams, 'OutputView', 'full');
%   figure; imshow(J2);
%   title('Full Output View');
%
%   See also undistortPoints, triangulate, extrinsics, cameraCalibrator,
%       estimateCameraParameters, cameraParameters 

%   Copyright 2013 The MathWorks, Inc.

[interp, outputView, fillValues] = parseInputs(I, cameraParams, varargin{:});

originalClass = class(I);
if ~(isa(I,'double') || isa(I,'single') || isa(I,'uint8'))
    I = single(I);
    fillValues = cast(fillValues, 'like', I);
end    

% Call the hidden method inside cameraParameters
[J, newOrigin] = undistortImageImpl(cameraParams, I, interp, outputView, fillValues);
J = cast(J, originalClass);

%------------------------------------------------------------------
function [interp, outputView, fillValues] = parseInputs(I, camParams, varargin)
import vision.internal.inputValidation.*;

validateImage(I);
checkCameraParameters(camParams);

parser = inputParser();
parser.addOptional('interp', 'bilinear', @validateInterpMethod);
parser.addParamValue('OutputView', 'same', @validateOutputView);
parser.addParamValue('FillValues', 0, @(v)validateFillValues(v, I));


parser.parse(varargin{:});
interp = validateInterp(parser.Results.interp);
outputView = validateOutputViewPartial(parser.Results.OutputView);
fillValues = scalarExpandFillValues(parser.Results.FillValues, I);

%--------------------------------------------------------------------------
function tf = validateInterpMethod(method)
vision.internal.inputValidation.validateInterp(method);
tf = true;

%--------------------------------------------------------------------------
function checkCameraParameters(camParams)
validateattributes(camParams, {'cameraParameters'}, ...
    {}, mfilename, 'cameraParams');

%--------------------------------------------------------------------------
function TF = validateOutputView(outputView)
validateattributes(outputView, {'char'}, {'vector'}, mfilename, 'OutputView');
validateOutputViewPartial(outputView);
TF = true;

%--------------------------------------------------------------------------
function outputView = validateOutputViewPartial(outputView)
outputView = ...
    validatestring(outputView, {'full', 'valid', 'same'}, mfilename, 'OutputView');

