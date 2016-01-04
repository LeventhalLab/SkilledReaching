% script_matchBoxPoints
%
% script to load undistorted background images from each session so that
% matched points in the direct and mirror views can be extracted

cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;

[cameraParams, ~, ~] = cb_calibration(...
                       'cb_path', cb_path, ...
                       'num_rad_coeff', num_rad_coeff, ...
                       'est_tan_distortion', est_tan_distortion, ...
                       'estimateskew', estimateSkew);
                   
kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
imFileType = 'bmp';
sr_ratInfo = get_sr_RatList();

for i_rat = 1 : length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    ratDir{i_rat} = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    
    triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
    cd(triDir{i_rat});
    triDataFiles = dir('*.mat');
    numSessions = length(triDataFiles);
    
    for iSession = 1 : numSessions
    
        sessionDate = triDataFiles(iSession).name(7:14);
        shortDate = sessionDate(5:end);
        
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
        
        BGname = [ratID '_' sessionDate '_BG.' imFileType];
        BGname_ud = [ratID '_' sessionDate '_BG_ud.' imFileType];
        
        curImg = imread(BGname_ud,imFileType);
        
        figure(1);
        imshow(curImg);
        
        keyboard
        
    end
end