% script_undistort_rubiks
%
% script to calculate and store background images for each session of
% interest

% ALSO NEED TO GET THE FUNDAMENTAL MATRIX FOR EACH RAT FOR BOTH MIRRORS

cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;

% [cameraParams, ~, ~] = cb_calibration(...
%                        'cb_path', cb_path, ...
%                        'num_rad_coeff', num_rad_coeff, ...
%                        'est_tan_distortion', est_tan_distortion, ...
%                        'estimateskew', estimateSkew);
                   
kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
imFileType = 'bmp';
sr_ratInfo = get_sr_RatList();

for i_rat = 1 : length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    fprintf('%s\n',ratID);
    
    ratDir{i_rat} = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    
%     triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
%     cd(triDir{i_rat});
%     triDataFiles = dir('*.mat');
%     numSessions = length(triDataFiles);
    
%     for iSession = 1 : numSessions
        
%         sessionDate = triDataFiles(iSession).name(7:14);
%         shortDate = sessionDate(5:end);
        
        cd(rawData_parentDir);
        rawDataDir = [ratID '_*'];
        rawDataDir = dir(rawDataDir);
        if isempty(rawDataDir)
            fprintf('no data folder for %s\n',ratID)
            continue
        end
        
        for iDir = 1 : length(rawDataDir)
            currentDir = fullfile(rawData_parentDir, rawDataDir(iDir).name);
            if ~isdir(currentDir); continue;end
            
            sprintf('%s\n', rawDataDir(iDir).name);
            
            cd(currentDir);
        
            file_list = dir('rubik*');
            if isempty(file_list); continue; end
            
            % check if any are already undistorted
            alreadyUndistorted = false;
            for i_file = 1 : length(file_list)
                if ~isempty(strfind(file_list(i_file).name,'ud'))
                    alreadyUndistorted = true;
                end
            end
            if alreadyUndistorted; continue; end
            
            for i_file = 1 : length(file_list)
            
                fullname = file_list(i_file).name;
                
                [~,fname,fext] = fileparts(fullname);
                if strcmp(fname(1:2),'._'); continue; end

                rbkImg = imread(fullname,fext(2:end));

                rbkImg_ud = undistortImage(rbkImg, cameraParams);

                rbkName_ud = [fname '_ud' fext];
                
                imwrite(rbkImg_ud,rbkName_ud,fext(2:end));
            end
            
        end    % for iDir...
        
%     end
    
end