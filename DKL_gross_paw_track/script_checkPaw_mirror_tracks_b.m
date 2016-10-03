% script_checkPaw_mirror_tracks

% script to check that 3D locations stored in the processed data folder
% actually match with the video files

computeCamParams = false;
camParamFile = '/Users/dan/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
cb_path = '/Users/dan/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';

% if computeCamParams
%     [cameraParams, ~, ~] = cb_calibration(...
%                            'cb_path', cb_path, ...
%                            'num_rad_coeff', num_rad_coeff, ...
%                            'est_tan_distortion', est_tan_distortion, ...
%                            'estimateskew', estimateSkew);
% else
%     load(camParamFile);    % contains a cameraParameters object named cameraParams
% end
% K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
%                                     %       version - Hartley and Zisserman and the rest of the world seem to
%                                     %       use the transpose of matlab K)
                                    
sr_ratInfo = get_sr_RatList();
kinematics_rootDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';

markerSize = 1;

for i_rat = 3 : 3%length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    ratDir = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    processed_parentDir = sr_ratInfo(i_rat).directory.processed;
    
    triDir = fullfile(ratDir,'triData');
    
    cd(triDir);
    triDataFiles = dir('*.mat');
%     numSessions = length(triDataFiles);
    numSessions = length(sr_ratInfo(i_rat).sessionList);

    for iSession = 1:1%:numSessions
        
%         sessionDate = triDataFiles(iSession).name(7:14);
        sessionDate = sr_ratInfo(i_rat).sessionList{iSession}(1:8);
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
            tnum = str2num(trialNum);
            pawData = load_pawMirrorTrackData(processedDir, tnum);
            trialNum = str2num(trialNum);
            if isempty(pawData);
                continue;
            end
            
            cameraParams = pawData.track_metadata.boxCalibration.cameraParams;
            K = cameraParams.IntrinsicMatrix;
            
            cd(rawDataDir);
            
            video = VideoReader(vidList(iVid).name);
            video.CurrentTime = pawData.timeList(1);
            
            [~,baseName,~] = fileparts(vidList(iVid).name);
            writeName = [baseName '_mirror.avi'];
            writeName = fullfile(processedDir, writeName);
            if exist(writeName,'file');continue;end
            
            w_vid = VideoWriter(writeName, 'motion jpeg avi');
            w_vid.FrameRate = video.FrameRate;
            open(w_vid);
            
            iFrame = 0;
            while video.hasFrame
                iFrame = iFrame + 1;

                frm = readFrame(video);
%                 if isnan(pawData(iFrame,1,1)); continue; end
                
                frm_ud = undistortImage(frm,cameraParams);
                
                ud_pt = pawData.mirror_points2d{iFrame};
                if ~isempty(ud_pt)
                    frm_ud = insertMarker(frm_ud, ud_pt,'o',...
                                                        'size', markerSize, ...
                                                        'color','r');
                end
%                 for iView = 1 : 2
% %                     if isnan(pawData(iFrame,1,iView)); continue; end
% %                     ud_pt = undistortPoints(squeeze(pawData(iFrame,:,iView)),cameraParams);
%                     if isempty(pawData.points2d{iFrame});continue;end
%                     ud_pt = pawData.points2d{iFrame}(:,:,iView);
%                     if isempty(ud_pt);continue;end
%                     if all(isnan(ud_pt(:))); continue; end
%                     try
%                     frm_ud = insertMarker(frm_ud, ud_pt,'o',...
%                                                     'size', markerSize, ...
%                                                     'color','r');
%                     catch
%                         keyboard
%                     end
% %                     plot(ud_pt(1),ud_pt(2),...
% %                          'linestyle','none',...
% %                          'marker','o',...
% %                          'markersize',6,...
% %                          'markeredgecolor','r',...
% %                          'markerfacecolor','r');
%                 end
%                 imshow(frm_ud);
                writeVideo(w_vid, frm_ud);
            end
            close(w_vid);
        end
    end
end