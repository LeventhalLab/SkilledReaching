% script_checkPawTrack

% script to check that 3D locations stored in the processed data folder
% actually match with the video files

computeCamParams = false;
camParamFile = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';

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
kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';

markerSize = 10;

for i_rat = 1 : length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    ratDir = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    processed_parentDir = sr_ratInfo(i_rat).directory.processed;
    
    triDir = fullfile(ratDir,'triData');
    
    cd(triDir);
    triDataFiles = dir('*.mat');
    numSessions = length(triDataFiles);
    
    for iSession = 1 : numSessions
        
        sessionDate = triDataFiles(iSession).name(7:14);
        shortDate = sessionDate(5:end);
        
        cd(rawData_parentDir);
        rawDataDirList = [ratID '_' sessionDate '*'];
        rawDataDirList = dir(rawDataDirList);
        if isempty(rawDataDirList)
            fprintf('no data folder for %s, %s\n',ratID, sessionDate)
            continue
        end
        if length(rawDataDirList) > 1
            fprintf('more than one data folder for %s, %s\n', ratID, sessionDate)
            continue;
        end
        
        rawDataDir = fullfile(rawData_parentDir, rawDataDirList.name);
        processedDir = fullfile(processed_parentDir, rawDataDirList.name);
        
        cd(rawDataDir);
        
        vidList = dir('*.avi');
        
        for iVid = 1 : length(vidList)
            fprintf('%s, %s, video %d of %d, %s\n', ratID, sessionDate, iVid, length(vidList), vidList(iVid).name);
            
            if strcmp(vidList(iVid).name(1:2),'._');continue;end
            
            trialNum = vidList(iVid).name(end-6:end-4);
            trialNum = str2num(trialNum);
            
            pawData = load_pawTrackData(processedDir, trialNum);
            if isempty(pawData);
                continue;
            end
            cd(rawDataDir);
            
            video = VideoReader(vidList(iVid).name);
            [~,baseName,~] = fileparts(vidList(iVid).name);
            writeName = [baseName '_udmark.avi'];
            writeName = fullfile(processedDir, writeName);
            if exist(writeName,'file');continue;end
            
            w_vid = VideoWriter(writeName, 'motion jpeg avi');
            w_vid.FrameRate = video.FrameRate;
            open(w_vid);
            
            iFrame = 0;
            while video.hasFrame
                iFrame = iFrame + 1;

                frm = readFrame(video);
                if isnan(pawData(iFrame,1,1)); continue; end
                
                frm_ud = undistortImage(frm,cameraParams);
                
%                 figure(1)
%                 imshow(frm);
%                 hold on
%                 for iView = 1 : 3
%                     plot(pawData(iFrame,1,iView),pawData(iFrame,2,iView),...
%                          'linestyle','none',...
%                          'marker','o',...
%                          'markersize',6,...
%                          'markeredgecolor','r',...
%                          'markerfacecolor','r');
%                 end
                
%                 figure(2)
%                 imshow(frm_ud);
%                 hold on
%                 set(gcf,'name',[vidList(iVid).name ', undistorted']);
                for iView = 1 : 3
                    if isnan(pawData(iFrame,1,iView)); continue; end
                    ud_pt = undistortPoints(squeeze(pawData(iFrame,:,iView)),cameraParams);
                    frm_ud = insertMarker(frm_ud, ud_pt,'star',...
                                                    'size', markerSize, ...
                                                    'color','r');
%                     plot(ud_pt(1),ud_pt(2),...
%                          'linestyle','none',...
%                          'marker','o',...
%                          'markersize',6,...
%                          'markeredgecolor','r',...
%                          'markerfacecolor','r');
                end
%                 imshow(frm_ud);
                writeVideo(w_vid, frm_ud);
            end
            close(w_vid);
        end
    end
end
            