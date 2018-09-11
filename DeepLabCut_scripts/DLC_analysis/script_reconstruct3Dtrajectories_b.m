% script to perform 3D reconstruction on videos

% hard-coded in info about each rat including handedness
script_ratInfo_for_deepcut;
ratInfo_IDs = [ratInfo.ratID];

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANGE THESE LINES DEPENDING ON PARAMETERS USED TO EXTRACT VIDEOS
% change this if the videos were cropped at different coordinates
vidROI = [750,450,550,550;
          1,450,450,400;
          1650,435,390,400];
triggerTime = 1;    % seconds
frameTimeLimits = [-1/2,1];    % time around trigger to extract frames
frameRate = 300;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

vidView = {'direct','right','left'};
numViews = length(vidView);

% find the list of calibration files
cd(calImageDir);
calFileList = dir('SR_boxCalibration_*.mat');
calDateList = cell(1,length(calFileList));
calDateNums = zeros(length(calFileList),1);
for iFile = 1 : length(calFileList)
    C = textscan(calFileList(iFile).name,'SR_boxCalibration_%8c.mat');
    calDateList{iFile} = C{1};
    calDateNums(iFile) = str2double(calDateList{iFile});
end

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
    
    sessionDirectories = dir([ratID '_*']);
    numSessions = length(sessionDirectories);
    
    for iSession = 1 : numSessions
        
        C = textscan(sessionDirectories(iSession).name,[ratID '_%8c']);
        sessionDate = C{1};
        
        % find the calibration file for this date
        % find the calibration file
        cd(calImageDir);
        curDateNum = str2double(sessionDate);
        dateDiff = curDateNum - calDateNums;

        % find the most recent date compared to the current file for which a
        % calibration file exists. Later, write code so files are stored by
        % date so that this file can be found before entering the loop through
        % DLC csv files
        lastValidCalDate = min(dateDiff(dateDiff >= 0));
        calFileIdx = find(dateDiff == lastValidCalDate);
    %     calibrationFileName = ['SR_boxCalibration_' directVidDate{i_directcsv} '.mat'];
        calibrationFileName = ['SR_boxCalibration_' calDateList{calFileIdx} '.mat'];
        if exist(calibrationFileName,'file')
            boxCal = load(calibrationFileName);
        else
            error('no calibration file found on or prior to %s\n',directVidDate{i_directcsv});
        end
        
        switch pawPref
            case 'right'
                ROIs = vidROI(1:2,:);
                Pn = squeeze(boxCal.Pn(:,:,2));
                sf = mean(boxCal.scaleFactor(2,:));
            case 'left'
                ROIs = vidROI([1,3],:);
                Pn = squeeze(boxCal.Pn(:,:,3));
                sf = mean(boxCal.scaleFactor(3,:));
        end
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories(iSession).name);
        cd(fullSessionDir);
        
        directViewDir = fullfile(fullSessionDir, [sessionDirectories(iSession).name '_direct']);
        
        cd(directViewDir);
        direct_csvList = dir('R*.csv');
        numMarkedVids = length(direct_csvList);
        % ratID, date, etc. for each individual video
        directVidTime = cell(1, numMarkedVids);
        directVidNum = zeros(numMarkedVids,1);

        % find all the direct view videos that are available
        for ii = 1 : numMarkedVids
            C = textscan(direct_csvList(ii).name,'R%04d_%8c_%8c_%03d');

            directVid_ratID(ii) = C{1};
            directVidDate{ii} = C{2};
            directVidTime{ii} = C{3};
            directVidNum(ii) = C{4};

            if isempty(uniqueDateList)
                uniqueDateList{1} = directVidDate{ii};
            elseif ~any(strcmp(uniqueDateList,directVidDate{ii}))
                uniqueDateList{end+1} = directVidDate{ii};
            end
        end
    
        sessionViewDirs = dir([sessionDirectories(iSession).name '_*']);
        cd(fullSessionDir);
        for iView = 1 : numViews
            possibleMirrorDir = [sessionDirectories(iSession).name '_' vidView{iView}];
            if ~exist(possibleMirrorDir,'dir') || ~isempty(strfind(lower(possibleMirrorDir),'direct'))
                % if this view doesn't exist or if it's the direct view, skip
                % forward (already found the direct view files)
                continue;
            end
            mirViewFolder = fullfile(fullSessionDir, possibleMirrorDir);
            break
        end

        cd(mirViewFolder)
        mirror_csvList = dir('R*.csv');

        for i_mirrorcsv = 1 : length(mirror_csvList)

            % make sure we have matching mirror and direct view files
            C = textscan(mirror_csvList(i_mirrorcsv).name,'R%04d_%8c_%8c_%03d');
            foundMatch = false;
            for i_directcsv = 1 : numMarkedVids
                if C{1} == ratIDnum && ...      % match ratID
                   strcmp(C{2}, sessionDate) && ...  % match date
                   strcmp(C{3}, directVidTime{i_directcsv}) && ...  % match time
                   C{4} == directVidNum(i_directcsv)                % match vid number
                    foundMatch = true;
                    break;
                end
            end
            if ~foundMatch
                continue;
            end

            cd(mirViewFolder)
            [mirror_bp,mirror_pts,mirror_p] = read_DLC_csv(mirror_csvList(i_mirrorcsv).name);
            cd(directViewDir)
            [direct_bp,direct_pts,direct_p] = read_DLC_csv(direct_csvList(i_directcsv).name);
    
            numDirectFrames = size(direct_p,1);
            numMirrorFrames = size(mirror_p,1);
    
            if numDirectFrames ~= numMirrorFrames
                fprintf('number of frames in the direct and mirror views do not match for %s\n', direct_csvList(i_directcsv).name);
            end
    
            [mirror_invalid_points, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p);
            [direct_invalid_points, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p);

            direct_pts_toPlot = zeros(size(direct_pts));
            mirror_pts_toPlot = zeros(size(mirror_pts));
            for i_coord = 1 : 2
                direct_pts_toPlot(:,:,i_coord) = direct_pts(:,:,i_coord) .* double(~direct_invalid_points);
                mirror_pts_toPlot(:,:,i_coord) = mirror_pts(:,:,i_coord) .* double(~mirror_invalid_points);
            end
            direct_pts_toPlot(direct_pts_toPlot==0) = NaN;
            mirror_pts_toPlot(mirror_pts_toPlot==0) = NaN;
            [pawTrajectory,bodyparts] = calc3D_DLC_trajectory(direct_pts_toPlot, mirror_pts_toPlot, ...
                direct_bp, mirror_bp, ...
                ROIs, boxCal.cameraParams, Pn, sf);

            cd(fullSessionDir)

            trajName = sprintf('R%04d_%s_%s_%03d_3dtrajectory.mat', directVid_ratID(i_directcsv),...
                directVidDate{i_directcsv},directVidTime{i_directcsv},directVidNum(i_directcsv));
            save(trajName, 'pawTrajectory', 'bodyparts','thisRatInfo','frameRate','triggerTime','frameTimeLimits','ROIs','boxCal','direct_pts','mirror_pts','mirror_bp','direct_bp','mirror_p','direct_p');
            
        end
        
    end
    
end


