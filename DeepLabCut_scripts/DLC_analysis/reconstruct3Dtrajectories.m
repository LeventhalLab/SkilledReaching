% by Dan Leventhal, updated 3/8/2019

% script to perform 3D reconstruction on videos acquired using an automated
% skilled reaching chamber (Ellens et al, "An automated rat single pellet
% reaching system with high-speed video capture", J Neuroscience Methods,
% 2016).

repeatCalculations = true;   % flag for whether to skip if .mat files
% storing results already exist, false = skip, true = repeat calculations

% file containing intrinsic camera parameters. This can be obtained using
% Matlab's computer vision toolbox
camParamFile = '/home/kkrista/Documents/SkilledReaching/cameraParameters_box1.mat';

% parameter for calc3D_DLC_trajectory
maxDistFromNeighbor = 40;   % maximum distance an estimated point can be from its neighbor
maxReprojError = 10;   % maximum allowable error when 3D reconstruction is
                       % reprojected back onto the original view. If they
                       % deviate too much, at least one of them was
                       % misidentified

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;     % 'p' is the certainty value output from deeplabcut
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

% master directory containing the deeplabcut output
labeledBodypartsFolder = '/media/kkrista/KRISTAEHD/DLCSR/rightPaw_Scored_Analyzed';
% ANTICIPATED DIRECTORY STRUCTURE:
%  For each rat, a folder called ratID (i.e., 'R0100'). Each of these
%  direcories should start with 'R' - that's what the code looks for.
%  Under that, a directory for each session (i.e., 'R0100_yyyymmdd')
%  Under that, a directory for each view (i.e., 'R0100_yyyymmdd_direct', 
%     'R0100_yyyymmdd_left', or 'R0100_yyyymmdd_right' )
%  In each of those folders, the appropriate deeplabcut output files. There
%  should be matching files in each folder for each video

% directory containing a .csv file, which contains a table of information
% about each rat (paw preference, training dates, etc.)
xlDir = '/home/kkrista/Desktop/';
csvfname = fullfile(xlDir,'mouseInfo.csv');

% directory containing the box calibration files
% ('boxCalibration_box#_DATE.mat')
calImageDir = '/home/kkrista/Documents/SkilledReaching/CalCube_imgs/box1/boxCalibration/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANGE THESE LINES DEPENDING ON PARAMETERS USED TO EXTRACT VIDEOS
% change this if the videos were cropped at different coordinates; these
% are the coordinates of the cropped videos fed into deeplabcut
vidROI = [820, 1268, 20, 952;
          282, 830, 220, 922;
          1272, 1760, 162, 976];
triggerTime = 1;    % seconds, time at which video trigger should have occurred during acquisition
frameTimeLimits = [-1,15];    % time around trigger to extract frames
frameRate = 59.995;

frameSize = [1080,1920];
% would be nice to have these parameters stored with DLC output so they can
% be read in directly. Someday...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
vidView = {'direct','right','left'};
numViews = length(vidView);

% END HEADER



% read in the table of rat information.
subInfo = readtable(csvfname);
subInfo_IDs = [subInfo.subID];

% load the intrinsic camera parameters
load(camParamFile);

cd(labeledBodypartsFolder)
subFolders = dir('M*');
numSubFolders = length(subFolders);

% find the list of calibration files
cd(calImageDir);
calFileList = dir('boxCalibration_*.mat');
calDateList = cell(1,length(calFileList));
calDateNums = zeros(length(calFileList),1);
for iFile = 1 : length(calFileList)
    C = textscan(calFileList(iFile).name,'boxCalibration_box%1c_%8c.mat');
    calDateList{iFile} = C{end};
    boxNumList{iFile}=C{1};
    calDateNums(iFile) = str2double(calDateList{iFile});
end

boxNum='1';
% change this loop depending on which rats you want to process
for i_sub = 1:numSubFolders

    subID = subFolders(i_sub).name;
    subIDnum = str2double(subID(2:end));
    
    subInfo_idx = find(subInfo_IDs == subIDnum);
    if isempty(subInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    if istable(subInfo)
        thisSubInfo = subInfo(subInfo_idx,:);
    else
        thisSubInfo = subInfo(subInfo_idx);
    end
    if iscell(thisSubInfo.pawPref)
        pawPref = thisSubInfo.pawPref{1};
    else
        pawPref = thisSubInfo.pawPref;
    end
    
    subRootFolder = fullfile(labeledBodypartsFolder,subID);
    cd(subRootFolder);
    
    sessionDirectories = dir;
    sessionDirectories = sessionDirectories(3:end);
    numSessions = length(sessionDirectories);
    
    for iSession = 1 : numSessions
        
        subID=subID(2:end);
        C = textscan(sessionDirectories(iSession).name,[subID '_%8c']);
        sessionDate = C{1};
        
        fprintf('working on session %s_%s\n',subID,sessionDate);
        
        % find the calibration file for this date
        cd(calImageDir);
        curDateNum = str2double(sessionDate);
        dateDiff = curDateNum - calDateNums;

        % find the most recent date compared to the current file for which a
        % calibration file exists.

        lastValidCalDate = min(dateDiff(dateDiff >= 0));
        calFileIdx = find(dateDiff == lastValidCalDate);

        calibrationFileName = ['boxCalibration_box' boxNum '_' calDateList{calFileIdx} '.mat'];
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
                F = squeeze(boxCal.F(:,:,2));
            case 'left'
                ROIs = vidROI([1,3],:);
                Pn = squeeze(boxCal.Pn(:,:,3));
                sf = mean(boxCal.scaleFactor(3,:));
                F = squeeze(boxCal.F(:,:,3));
        end
    
        fullSessionDir = fullfile(subRootFolder,sessionDirectories(iSession).name);
        [directViewDir,mirrorViewDir,direct_csvList,mirror_csvList] = getDLC_csvList(fullSessionDir);

        %
        if isempty(direct_csvList)
            continue;
        end
        
        numMarkedVids = length(direct_csvList);
        % arrays to store ratID, date, etc. for each individual video
        directVidTime = cell(1, numMarkedVids);
        directVidNum = cell(numMarkedVids,1);

        % find all the direct view videos that are available
        uniqueDateList = {};
        for ii = 1 : numMarkedVids   

            [directVid_ratID(ii),directVidDate{ii},directVidTime{ii},directVidNum{ii}] = ...
                extractDLC_CSV_identifiers(direct_csvList(ii).name);

            if isempty(uniqueDateList)
                uniqueDateList{1} = directVidDate{ii};
            elseif ~any(strcmp(uniqueDateList,directVidDate{ii}))
                uniqueDateList{end+1} = directVidDate{ii};
            end
        end

        cd(mirrorViewDir)

        for i_mirrorcsv = 1 : length(mirror_csvList)

            % make sure we have matching mirror and direct view files
            [mirror_ratID,mirror_vidDate,mirror_vidTime,mirror_vidNum] = ...
                extractDLC_CSV_identifiers(mirror_csvList(i_mirrorcsv).name);
            foundMatch = false;
            for i_directcsv = 1 : numMarkedVids
                if mirror_ratID == subIDnum && ...      % match ratID
                   strcmp(mirror_vidDate, sessionDate) && ...  % match date
                   strcmp(mirror_vidTime, directVidTime{i_directcsv}) && ...  % match time
                   strcmp(mirror_vidNum, directVidNum{i_directcsv})                % match vid number
                    foundMatch = true;
                    break;
                end
            end
            if ~foundMatch
                continue;
            end

            % name for storing the reconstructed 3D trajectories and
            % metadata
            trajName = sprintf('%03d_%s_%s_%s_3dtrajectory.mat', directVid_ratID(i_directcsv),...
                directVidDate{i_directcsv},directVidTime{i_directcsv},directVidNum{i_directcsv});
            fullTrajName = fullfile(fullSessionDir, trajName);
            
            % skip this set of files if already done, unless the
            % repeatCalculations flag at the top was set to true
            if exist(fullTrajName,'file')
                % already did this calculation
                if repeatCalculations
                    load(fullTrajName)
                else
                    continue;
                end
            end
            
            cd(mirrorViewDir)
            [mirror_bp,mirror_pts,mirror_p] = read_DLC_csv(mirror_csvList(i_mirrorcsv).name);
            cd(directViewDir)
            [direct_bp,direct_pts,direct_p] = read_DLC_csv(direct_csvList(i_directcsv).name);
    
%             % this was added in so that the user can manually mark points
%             % that are mislabeled, if needed
%             if ~exist('manually_invalidated_points','var')
%                 numFrames = size(direct_p,2);
%                 num_bodyparts = length(direct_bp);
%                 manually_invalidated_points = false(numFrames,num_bodyparts,2);
%             end
                    
            % these should be the same
            numDirectFrames = size(direct_p,2);
            numMirrorFrames = size(mirror_p,2);
    
            if numDirectFrames ~= numMirrorFrames
                fprintf('number of frames in the direct and mirror views do not match for %s\n', direct_csvList(i_directcsv).name);
            end
    
            % find invalid points based on: low probability values from
            % DLC, jumping too far between frames, neighboring points being
            % too far from each other
            [invalid_mirror, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p,mirror_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
            [invalid_direct, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p,direct_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
            
%             frames_in_this_vid = size(invalid_mirror,2);
%             frames_in_other_vids = size(manually_invalidated_points,1);
%             if frames_in_this_vid < frames_in_other_vids
%                 % pad invalid_mirror and/or invalid_direct because of a
%                 % video that's too short for some reason
%                 invalid_mirror(:,frames_in_this_vid+1:frames_in_other_vids) = false;
%                 invalid_direct(:,frames_in_this_vid+1:frames_in_other_vids) = false;
%             elseif frames_in_other_vids < frames_in_this_vid
%                 % video is too long? I'm guessing this will be an issue
%                 % with the odd way I've done my pre-processing
%                 frameDiff=frames_in_this_vid-frames_in_other_vids;
%                 invalid_mirror = invalid_mirror(:,frameDiff+1:end);
%                 invalid_direct = invalid_direct(:,frameDiff+1:end);
%             end
%             invalid_mirror = invalid_mirror | squeeze(manually_invalidated_points(:,:,2))';
%             invalid_direct = invalid_direct | squeeze(manually_invalidated_points(:,:,1))';
            
            direct_pts_ud = reconstructUndistortedPoints(direct_pts,ROIs(1,:),boxCal.cameraParams,~invalid_direct);
            mirror_pts_ud = reconstructUndistortedPoints(mirror_pts,ROIs(2,:),boxCal.cameraParams,~invalid_mirror);
                        
            [pawTrajectory, bodyparts, final_direct_pts, final_mirror_pts] = ...
                calc3D_DLC_trajectory(direct_pts_ud, ...
                                      mirror_pts_ud, invalid_direct, invalid_mirror,...
                                      direct_bp, mirror_bp, ...
                                      boxCal, pawPref, frameSize,...
                                      'maxdistfromneighbor',maxDistFromNeighbor);
                                  
            [reproj_error,high_p_invalid,low_p_valid] = assessReconstructionQuality(pawTrajectory, final_direct_pts, final_mirror_pts, direct_p, mirror_p, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, pawPref);
            
            cd(fullSessionDir)
            save(fullTrajName, 'pawTrajectory', 'bodyparts','thisSubInfo','frameRate','frameSize','triggerTime','frameTimeLimits','ROIs','boxCal','direct_pts','mirror_pts','mirror_bp','direct_bp','mirror_p','direct_p','lastValidCalDate','final_direct_pts','final_mirror_pts','reproj_error','high_p_invalid','low_p_valid','manually_invalidated_points');
            
        end
        
    end
    
end
