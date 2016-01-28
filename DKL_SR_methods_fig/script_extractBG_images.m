% script_extractBG_images
%
% script to calculate and store background images for each session of
% interest

% ALSO NEED TO GET THE FUNDAMENTAL MATRIX FOR EACH RAT FOR BOTH MIRRORS

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

extractBGforAllVids = true;

for i_rat = 1 : length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    ratDir{i_rat} = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    
%     triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
%     cd(triDir{i_rat});
%     triDataFiles = dir('*.mat');
%     numSessions = length(triDataFiles);
    numSessions = length(sr_ratInfo(i_rat).sessionList);
    
    for iSession = 1 : numSessions
        
%         sessionDate = triDataFiles(iSession).name(7:14);
        sessionDate = sr_ratInfo(i_rat).sessionList{iSession}(1:8);
        shortDate = sessionDate(5:end);
        
        if ~extractBGforAllVids
            BGname = [ratID '_' sessionDate '_BG.' imFileType];
            BGname_ud = [ratID '_' sessionDate '_BG_ud.' imFileType];
        else
            BGname = '';
            BGname_ud = '';
        end
        
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
        
        if exist(BGname_ud,'file');continue;end
        
        file_list = dir('*.avi');
        
        for i_file = 1 : length(file_list)
            
            fname = file_list(i_file).name;
            if strcmp(fname(1:2),'._'); continue; end
            
            numString = fname(end-6:end-4);
            
            BGname = [ratID '_' sessionDate '_' numString '_BG.' imFileType];
            BGname_ud = [ratID '_' sessionDate '_' numString '_BG_ud.' imFileType];
            
            if exist(BGname_ud,'file');continue;end
            
            video = VideoReader(fname);
            
            BGimg = extractBGimg( video, 'numbgframes', 20);
            BGimg_ud = undistortImage(BGimg, cameraParams);
            
            imwrite(BGimg,BGname,imFileType);
            imwrite(BGimg_ud,BGname_ud,imFileType);

            if ~extractBGforAllVids
                break;
            end
        end

        
    end
    
end