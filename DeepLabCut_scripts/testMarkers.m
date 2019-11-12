%%
labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
% vidRootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_20191028.csv');
ratInfo = readRatInfoTable(csvfname);

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

i_rat = 33;
iSession = 15;
iVid = 29;
iFrame = 284;

ratID = ratFolders(i_rat).name;
ratIDnum = str2double(ratID(2:end));

ratInfo_idx = find(ratInfo_IDs == ratIDnum);
if isempty(ratInfo_idx)
    error('no entry in ratInfo structure for rat %d\n',C{1});
end
if istable(ratInfo)
    thisRatInfo = ratInfo(ratInfo_idx,:);
else
    thisRatInfo = ratInfo(ratInfo_idx);
end
if iscell(thisRatInfo.pawPref)
    pawPref = thisRatInfo.pawPref{1};
else
    pawPref = thisRatInfo.pawPref;
end

ratRootFolder = fullfile(labeledBodypartsFolder,ratID);

cd(ratRootFolder);

sessionDirectories = listFolders([ratID '_2*']);
numSessions = length(sessionDirectories);

ratVidPath = fullfile(vidRootPath,ratID);   % root path for the original videos



fprintf('working on session %s\n', sessionDirectories{iSession});
C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
sessionDate = C{1};

fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
vidDirectory = fullfile(ratVidPath,sessionDirectories{iSession});

cd(fullSessionDir);

matList = dir([ratID '_*_3dtrajectory_new.mat']);
matList(iVid).name

load(matList(iVid).name); 
pawPref = thisRatInfo.pawPref;
if iscell(pawPref)
    pawPref = pawPref{1};
end

% find the appropriate box calibration for this session
temp = boxCal.boxCal_fromSession;
calibratedSessionNames = {temp.sessionName};
if any(strcmpi(calibratedSessionNames,sessionDirectories{iSession}))
    sessionIdx = find(strcmpi(calibratedSessionNames,sessionDirectories{iSession}));
    activeBoxCal = boxCal.boxCal_fromSession(sessionIdx);
else
    activeBoxCal = boxCal;
end
% activeBoxCal = boxCal;
            
[mirror_invalid_points, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p,mirror_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p);
[direct_invalid_points, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p,direct_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p);
            
vidName = [matList(iVid).name(1:27) '.avi'];
fullVidName = fullfile(vidDirectory,vidName);
cd(vidDirectory);
vidIn = VideoReader(fullVidName);



%%
while hasFrame(vidIn)
    vidIn.CurrentTime = (iFrame)/vidIn.FrameRate;
    curFrame = readFrame(vidIn);

    % need to undistort vidIn frames and points to mark
    curFrame_ud = undistortImage(curFrame, boxCal.cameraParams);

    points3D = squeeze(pawTrajectory(iFrame,:,:))';
    direct_pt = squeeze(final_direct_pts(:,iFrame,:));
    mirror_pt = squeeze(final_mirror_pts(:,iFrame,:));
    frame_direct_p = squeeze(direct_p(:,iFrame));
    frame_mirror_p = squeeze(mirror_p(:,iFrame));
    isPointValid{1} = ~direct_invalid_points(:,iFrame);
    isPointValid{2} = ~mirror_invalid_points(:,iFrame);
    frameEstimate = squeeze(isEstimate(:,iFrame,:));

%     curFrame_out = overlayDLCreconstruction(curFrame_ud, points3D, ...
%         direct_pt, mirror_pt, frame_direct_p, frame_mirror_p, ...
%         direct_bp, mirror_bp, bodyparts, isPointValid, ROIs, ...
%         boxCal, pawPref);
    
%     curFrame_out = overlayDLCreconstruction_b(curFrame_ud, points3D, ...
%         direct_pt, mirror_pt, frame_direct_p, frame_mirror_p, ...
%         direct_bp, mirror_bp, bodyparts, frameEstimate, ...
%         boxCal, pawPref,isPointValid);
    
    curFrame_out2 = overlayDLCreconstruction_b(curFrame_ud, points3D, ...
        direct_pt, mirror_pt, frame_direct_p, frame_mirror_p, ...
        direct_bp, mirror_bp, bodyparts, frameEstimate, ...
        activeBoxCal, pawPref,isPointValid);
    
    figure(3)
    imshow(curFrame_out2);
    set(gcf,'name',sprintf('%s, frame %d',vidName,iFrame));
    
%         figure(2)
%     imshow(curFrame_out2);
%     set(gcf,'name',sprintf('%s, frame %d',vidName,iFrame));

    % summarize how many times high probability points are
    % declared invalid

%                 writeVideo(vidOut,curFrame_out);
keyboard
    iFrame = iFrame + 1; 
    
end


