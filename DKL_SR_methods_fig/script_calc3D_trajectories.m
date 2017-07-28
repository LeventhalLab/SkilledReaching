% script_checkPawTrack

% script to check that 3D locations stored in the processed data folder
% actually match with the video files

computeCamParams = false;
camParamFile = '/Users/dan/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
cb_path = '/Users/dan/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
                                    
sr_ratInfo = get_sr_RatList();
kinematics_rootDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';

xl_directory = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';
xlName = 'rubiks_matched_points_DL.xlsx';

markerSize = 1;

h = 1086; w = 2040;

for i_rat = 2 : 4%length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    processed_parentDir = sr_ratInfo(i_rat).directory.processed;
    
    matchedPoints = read_xl_matchedPoints_rubik( ratID, ...
                                                 'xldir', xl_directory, ...
                                                 'xlname', xlName);
    
    pawPref = sr_ratInfo(i_rat).pawPref;
    
    sessionList = sr_ratInfo(i_rat).sessionList;
    numSessions = length(sessionList);
    for iSession = 1 : numSessions

        sessionName = sessionList{iSession};
        fullSessionName = [ratID '_' sessionName];
        
        sessionDate = sessionName(1:8);
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
        
        if (strcmp(sessionName,'20140528a') && i_rat == 1) || ...
           (strcmp(sessionName,'20140427a') && i_rat == 2)
            session_mp = matchedPoints.([fullSessionName(1:end-1) 'a']);
        elseif isfield(matchedPoints,fullSessionName(1:end-1))
            session_mp = matchedPoints.(fullSessionName(1:end-1));
        else
            continue;
        end
        boxRegions = boxRegionsfromMatchedPoints(session_mp, [h,w]);
        
        rawDataDir = fullfile(rawData_parentDir, rawDataDirList.name);
        processedDir = fullfile(processed_parentDir, rawDataDirList.name);
        
        cd(rawDataDir);
        vidList = dir('*.avi');
        
        cd(processedDir);
        matList = dir('*rel_track.mat');
        if isempty(matList);continue;end
        
        for iMat = 1 : length(matList)
            fprintf('%s, %s, video %d of %d, %s\n', ratID, sessionDate, iMat, length(matList), matList(iMat).name);
            
            if strcmp(matList(iMat).name(1:2),'._');continue;end
            
            trialNum = matList(iMat).name(16:18);
            
            pawData = load(matList(iMat).name);
            matBaseName = matList(iMat).name(1:18);
            
            test_vidName = [ratID '_' sessionDate '_*_' trialNum '.avi'];
            cd(rawDataDir);
            currentVid = dir(test_vidName);
            vidName = currentVid.name;
            vidName = fullfile(rawDataDir, vidName);
            
            video = VideoReader(vidName);
            
            trialNum = str2num(trialNum);
            if isempty(pawData)
                continue;
            end
            
            points2d = pawData.points2d;
            isPawVisible_mirror = pawData.isPawVisible_mirror;
            timeList = pawData.timeList;
            track_metadata = pawData.track_metadata;
            
            boxCalibration = track_metadata.boxCalibration;
            cameraParams = boxCalibration.cameraParams;
            
            switch lower(pawPref)
                case 'right'
                    F = squeeze(boxCalibration.srCal.F(:,:,1));
%                     sf = sf(1);
                case 'left'
                    F = squeeze(boxCalibration.srCal.F(:,:,2));
%                     sf = sf(2);
                                                                               % looks like the columns are the view: 1 = left, 2 = right. The rows are the independent estimates for pairs of rubiks spacings. So, should take the mean across rows to estimate the scale factor in each mirror view                   
            end

            [~,epipole] = isEpipoleInImage(F,[h,w]);
            
            numFrames = size(points2d, 2);
            points3d = cell(numFrames,1);
            for iFrame = 431 : numFrames
                iFrame
                video.CurrentTime = iFrame / video.FrameRate;
                currentFrame = readFrame(video);
                currentFrame_ud = undistortImage(currentFrame, cameraParams);
                
                if ~isempty(points2d{1,iFrame}) && ~isempty(points2d{2,iFrame})
                    framePoints = cell(1,2);
                    for iView = 1 : 2
                        framePoints{iView} = points2d{iView,iFrame};
                    end
                    points3d{iFrame} = frame2d_to_3d_boundary(framePoints, boxCalibration, pawPref, [h,w], epipole, currentFrame_ud, 'showSilhouettes', false);
                end
            end
                % WORKING HERE...
            points3dName = [matBaseName '_3dpoints.mat'];
            points3dName = fullfile(processedDir,points3dName);
            save(points3dName,'points3d','points2d','isPawVisible_mirror','timeList','track_metadata');
            
        end
        
    end
end
%         end
%     end
% end