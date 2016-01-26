function mirror_cb_calibration(cb_folder, cameraParams, varargin)

leftMirrorEdge = 400;
rightMirrorEdge = 1600;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'leftmirroredge',
            leftMirrorEdge = varargin{iarg + 1};
        case 'rightmirroredge',
            rightMirrorEdge = varargin{iarg + 1};
    end
end

prevDir = pwd;

cd(cb_folder);

calibrationFiles = dir('GridCalibration*');

numCalibrationImages = length(calibrationFiles);

for iFile = 1 : numCalibrationImages
    
    if ~exist(calibrationFiles(iFile).name,'file'); continue; end
    
    mp = mirror_cb_matchPoints(calibrationFiles(iFile).name, cameraParams);
    
    cal_image = imread(calibrationFiles(iFile).name, 'png');
    cal_image_ud = undistortImage(cal_image, cameraParams);
    h = size(cal_image_ud,1);
    w = size(cal_image_ud,2);
    for iView = 1 : 3    % 1 is the direct view, 2 is the left mirror, 3 is the right mirror
        
        switch iView
            case 1,
                leftEdge = leftMirrorEdge;
                rightEdge = rightMirrorEdge;
            case 2,
                leftEdge = 1;
                rightEdge = leftMirrorEdge;
            case 3,
                leftEdge = rightMirrorEdge;
                rightEdge = w;    % image width
                
        imSegment = cal_image_ud(1:h,leftEdge:rightEdge,:);
        [cb_points, boardSize