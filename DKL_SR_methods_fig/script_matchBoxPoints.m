% script_matchBoxPoints
%
% script to load undistorted background images from each session so that
% matched points in the direct and mirror views can be extracted

cb_path = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/tattoo_track_testing/mirror calibration images';
kinematics_rootDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;

camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
load(camParamFile);

% [cameraParams, ~, ~] = cb_calibration(...
%                        'cb_path', cb_path, ...
%                        'num_rad_coeff', num_rad_coeff, ...
%                        'est_tan_distortion', est_tan_distortion, ...
%                        'estimateskew', estimateSkew);
                   
% kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
imFileType = 'bmp';
sr_ratInfo = get_sr_RatList();

clear BGname
clear BGname_ud

for i_rat = 1 : length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
%     ratDir{i_rat} = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    
%     triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
%     cd(triDir{i_rat});
%     triDataFiles = dir('*.mat');
%     numSessions = length(triDataFiles);
    
    sessionList = sr_ratInfo(i_rat).sessionList;
    numSessions = length(sessionList);
    
    for iSession = 14 : numSessions
    
%         sessionDate = triDataFiles(iSession).name(7:14);
        sessionDate = sessionList{iSession}(1:8);
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
        
        if strcmp(sessionDate,'20140528')    % because mirror moved during trial 004
            BGname{1} = [ratID '_' sessionDate 'a_BG.' imFileType];
            BGname_ud{1} = [ratID '_' sessionDate 'a_BG_ud.' imFileType];
            
            BGname{2} = [ratID '_' sessionDate 'b_BG.' imFileType];
            BGname_ud{2} = [ratID '_' sessionDate 'b_BG_ud.' imFileType];
        else
            BGname{1} = [ratID '_' sessionDate '_BG.' imFileType];
            BGname_ud{1} = [ratID '_' sessionDate '_BG_ud.' imFileType];
        end
        numBG = length(BGname);
        
        for iBG = 1 : numBG
%         BGname = [ratID '_' sessionDate '_BG.' imFileType];
%         BGname_ud = [ratID '_' sessionDate '_BG_ud.' imFileType];
        
            curImg = imread(BGname_ud{iBG},imFileType);

            figure(1);
            imshow(curImg);

            keyboard
        end
        
    end
end