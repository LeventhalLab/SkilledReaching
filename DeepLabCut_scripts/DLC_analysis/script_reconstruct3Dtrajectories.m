% script to perform 3D reconstruction on videos

% hard-coded in info about each rat including handedness
script_ratInfo_for_deepcut;
ratInfo_IDs = [ratInfo.ratID];

labeledVidsFolder = '/Volumes/Tbolt_01/Skilled Reaching/Labeled Videos';
vidType = 'left_paw_gpybr';
vidView = {'direct_view','right_view','left_view'};
numViews = length(vidView);

rootVidFolder = fullfile(labeledVidsFolder, vidType);
dirViewFolder = fullfile(rootVidFolder,'direct_view');

% calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/Users/dleventh/Documents/deeplabcut images/cal images to review';
calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

% change this if the videos were cropped at different coordinates
vidROI = [750,450,550,550;
          1,450,450,400;
          1650,435,390,400];

cd(dirViewFolder)
direct_csvList = dir('R*.csv');
numMarkedVids = length(direct_csvList);
% ratID, date, etc. for each individual video
directVid_ratID = zeros(numMarkedVids,1);
directVidDate = cell(1, numMarkedVids);
directVidTime = cell(1, numMarkedVids);
directVidNum = zeros(numMarkedVids,1);

uniqueDateList = {};
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

cd(rootVidFolder);
for iView = 1 : numViews
    
    if ~exist(vidView{iView},'dir') || strcmpi(vidView{iView},'direct_view')
        % if this view doesn't exist or if it's the direct view, skip
        % forward (already found the direct view files)
        continue;
    end
    mirViewFolder = fullfile(rootVidFolder, vidView{iView});
    break
end

cd(mirViewFolder)
mirror_csvList = dir('R*.csv');
for i_mirrorcsv = 1 : length(mirror_csvList)
    
    % make sure we have matching mirror and direct view files
    C = textscan(mirror_csvList(i_mirrorcsv).name,'R%04d_%8c_%8c_%03d');
    foundMatch = false;
    for i_directcsv = 1 : numMarkedVids
        if C{1} == directVid_ratID(i_directcsv) && ...      % match ratID
           strcmp(C{2}, directVidDate{i_directcsv}) && ...  % match date
           strcmp(C{3}, directVidTime{i_directcsv}) && ...  % match time
           C{4} == directVidNum(i_directcsv)                % match vid number
            foundMatch = true;
            break;
        end
    end
    if ~foundMatch
        continue;
    end
    ratInfo_idx = find(ratInfo_IDs == C{1});
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    pawPref = ratInfo(ratInfo_idx).pawPref;

    cd(mirViewFolder)
    [mirror_bp,mirror_pts,mirror_p] = read_DLC_csv(mirror_csvList(i_mirrorcsv).name);
    cd(dirViewFolder)
    [direct_bp,direct_pts,direct_p] = read_DLC_csv(direct_csvList(i_directcsv).name);
    
    % find the calibration file
    cd(calImageDir);
    calibrationFileName = ['SR_boxCalibration_' directVidDate{i_directcsv} '.mat'];
    if exist(calibrationFileName,'file')
        boxCal = load(calibrationFileName);
    else
        error('no calibration file for %s\n',directVidDate{i_directcsv});
    end
    K = boxCal.cameraParams.IntrinsicMatrix;
    
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
    
    numDirectFrames = size(direct_p,1);
    numMirrorFrames = size(mirror_p,1);
    
    if numDirectFrames ~= numMirrorFrames
        fprintf('number of frames in the direct and mirror views do not match for %s\n', direct_csvList(i_directcsv).name);
    end
    
    [mirror_invalid_points, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p);
    [direct_invalid_points, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p);
    
    [pawTrajectory,bodyparts] = calc3D_DLC_trajectory(direct_pts, mirror_pts, ...
        direct_bp, mirror_bp, ...
        direct_p, mirror_p, ROIs, K, Pn, sf);
    
end


