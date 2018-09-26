% script_assessReconstructionQuality

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
vidRootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

script_ratInfo_for_deepcut;
ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

isPointValid = cell(1,2);

reprojErrorThresh = 5;   % find points where reprojection error exceeds this many pixels

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx);
    pawPref = thisRatInfo.pawPref;
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = listFolders([ratID '_*']);
    numSessions = length(sessionDirectories);
    
    ratVidPath = fullfile(vidRootPath,ratID);   % root path for the original videos
    
    for iSession = 1 : numSessions
    
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        vidDirectory = fullfile(ratVidPath,sessionDirectories{iSession});
        
        cd(fullSessionDir);
        
        matList = dir([ratID '_*_3dtrajectory.mat']);
        
        load(matList(1).name);
        reproj_errors_idx = cell(length(matList),1);
        invalidPointError = cell(length(matList),1);
        % cell arrays that will contain indices of frames in each video for
        % each body part that may have errors

        for iVid = 1 : length(matList)
            
            if exist('reproj_error','var')
                clear reproj_error
                clear high_p_invalid
            end
            load(matList(iVid).name);
            vidStartTime = triggerTime + frameTimeLimits(1);
            
            if ~exist('reproj_error','var')
                pawPref = thisRatInfo.pawPref;
                [reproj_error,high_p_invalid] = assessReconstructionQuality(pawTrajectory, direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, bodyparts, ROIs, boxCal, pawPref);
                save(matList(iVid).name,'reproj_error','high_p_invalid','-append');
            end

            reproj_errors_idx{iVid} = cell(size(reproj_error,1),1);
            invalidPointError{iVid} = cell(size(reproj_error,1),1);
            % are there any points where we're off by more than
            % reprojErrorThresh in this video?
            for i_bp = 1 : size(reproj_error,1)
                largeErrorIdx = false(size(reproj_error,2),1);
                invalidErrorIdx = false(size(reproj_error,2),1);   
                for iView = 1 : 2
                    testErrors = squeeze(reproj_error(i_bp,:,:,iView));
                    errorDist = sqrt(sum(testErrors.^2,2));
                    
                    largeErrorIdx = largeErrorIdx | (errorDist > reprojErrorThresh);
                    invalidErrorIdx = invalidErrorIdx | squeeze(high_p_invalid(i_bp,:,iView))';
                end
                reproj_errors_idx{iVid}{i_bp} = find(largeErrorIdx);   % make note of frames in which this bodypart may be inaccurately localized
                invalidPointError{iVid}{i_bp} = find(invalidErrorIdx);
            end
            vidName = [matList(iVid).name(1:27) '.avi'];
            fullVidName = fullfile(vidDirectory,vidName);
            video = VideoReader(fullVidName);
            
            % WORKING HERE - FIND THE FRAME WHERE A MISTAKE WAS MADE AND
            % MARK THE "MISSED" POINTS
            
            % THE OTHER QUESTION IS ARE THERE OTHER TYPES OF ERRORS - LIKE
            % FRAMES WHERE POINTS SUDDENLY DISAPPEAR THAT NEED TO BE
            % ACCOUNTED FOR? OR CREATE INTERPOLATION FOR MISSING POINTS AND
            % SEE HOW THAT WORKS?
            
            vidOutName = [matList(iVid).name(1:27) '_marked'];
            fullVidOutName = fullfile(fullSessionDir, vidOutName);
            
            iFrame = 1;
            while hasFrame(vidIn)
                curFrame = readFrame(vidIn);

                % need to undistort vidIn frames and points to mark
                curFrame_ud = undistortImage(curFrame, boxCal.cameraParams);

                points3D = squeeze(pawTrajectory(iFrame,:,:))';
                direct_pt = squeeze(direct_pts(:,iFrame,:));
                mirror_pt = squeeze(mirror_pts(:,iFrame,:));
                frame_direct_p = squeeze(direct_p(:,iFrame));
                frame_mirror_p = squeeze(mirror_p(:,iFrame));
                isPointValid{1} = ~direct_invalid_points(:,iFrame);
                isPointValid{2} = ~mirror_invalid_points(:,iFrame);

                curFrame_out = overlayDLCreconstruction(curFrame_ud, points3D, ...
                    direct_pt, mirror_pt, frame_direct_p, frame_mirror_p, ...
                    direct_bp, mirror_bp, bodyparts, isPointValid, ROIs, ...
                    boxCal, pawPref);
                
                % summarize how many times high probability points are
                % declared invalid
                
%                 writeVideo(vidOut,curFrame_out);
                
                iFrame = iFrame + 1; 
            end

            close(vidOut);
            
        end
        
    end
    
end