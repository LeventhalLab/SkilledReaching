function checkBoxCalibration(x1_left,x2_left,x1_right,x2_right, mp_metadata, srCal, varargin)
%
% check that box calibration yields 3D points that match with the fidelity
% points identified manually when the 3D estimates are projected back onto
% the undistorted background image
%
% INPUTS:
%
% OUTPUTS:
%   none

computeCamParams = false;
camParamFile = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
% cb_path is to checkerboard patterns for computing the camera parameters

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'computecamparams',
            computeCamParams = varargin{iarg};
        case 'camparamfile',
            camParamFile = varargin{iarg};
        case 'cbpath',
            cb_path = varargin{iarg};
    end
end

if computeCamParams
    [cameraParams, ~, ~] = cb_calibration(...
                           'cb_path', cb_path, ...
                           'num_rad_coeff', num_rad_coeff, ...
                           'est_tan_distortion', est_tan_distortion, ...
                           'estimateskew', estimateSkew);
else
    load(camParamFile);    % contains a cameraParameters object named cameraParams
end
K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
                                    %       version - Hartley and Zisserman and the rest of the world seem to
                                    %       use the transpose of matlab K)
                                    
sr_ratInfo = get_sr_RatList();
ratID = mp_metadata.sessionNames{1}(1:5);

for i_rat = 1 : length(sr_ratInfo)
    if strcmp(sr_ratInfo.ratID,ratID)
        cur_rat = sr_ratInfo(i_rat);
    end
end

rawData_parentDir = cur_rat.directory.rawdata;

numSessions = length(mp_metadata.sessionNames);

for iSession = 1 : numSessions
    
    sessionDate = mp_metadata.sessionNames(7:end);
    
    fprintf('%s, %s\n', ratID, sessionDate);
    
    cd(rawData_parentDir);
    rawDataDir = [ratID '_' sessionDate '*'];
    rawDataDir = dir(rawDataDir);
    if isempty(rawDataDir)
        fprintf('no data folder for %s, %s\n',ratID, sessionDate)
        continue
    end
    if length(rawDataDir) > 1
        fprintf('more than one data folder for %s, %s\n', ratID, sessionDate)
        continue;
    end
    
    rawDataDir = fullfile(rawData_parentDir, rawDataDir.name);
    cd(rawDataDir);
    
    BGname_ud = [ratID '_' sessionDate '_BG_ud.' imFileType];

    curImg = imread(BGname_ud,imFileType);
    
    figure(1);
    imshow(curImg);
    hold on;
    
%     x1_left_hom = [x1_left{iSession},ones(size(x1_left{iSession},1),1)];
%     x2_left_hom = [x2_left{iSession},ones(size(x2_left{iSession},1),1)];
%     
%     x1_right_hom = [x1_right{iSession},ones(size(x1_right{iSession},1),1)];
%     x2_right_hom = [x2_right{iSession},ones(size(x2_right{iSession},1),1)];
    
    x1_left_norm = normalize_points(x1_left);
    x2_left_norm = normalize_points(x2_left);
    
    x1_right_norm = normalize_points(x1_right);
    x2_right_norm = normalize_points(x2_right);
    
    left_P2 = squeeze(srCal.P(:,:,1,iSession));
    right_P2 = squeeze(srCal.P(:,:,2,iSession));
    [left_points3d,left_reprojPoints,left_errors] = triangulate_DL(x1_left_norm,x2_left_norm, eye(4,3), left_P2);
    [right_points3d,right_reprojPoints,right_errors] = triangulate_DL(x1_right_norm,x2_right_norm, eye(4,3), right_P2);
    
end
    