% script_calculateKinematics_20181128

% template name for viable trajectory files (for searching)
trajectory_file_name = 'R*3dtrajectory_new.mat';

max3Ddist_perFrame = 10;   % mm
maxPawSpan = 20;

% REACHING SCORES:
%
% 0 - No pellet, mechanical failure
% 1 -  First trial success (obtained pellet on initial limb advance)
% 2 -  Success (obtain pellet, but not on first attempt)
% 3 -  Forelimb advance -pellet dropped in box
% 4 -  Forelimb advance -pellet knocked off shelf
% 5 -  Obtain pellet with tongue
% 6 -  Walk away without forelimb advance, no forelimb advance
% 7 -  Reached, pellet remains on shelf
% 8 - Used only contralateral paw
% 9 - Laser fired at the wrong time
% 10 ?Used preferred paw after obtaining or moving pellet with tongue


% calculate the following kinematic parameters:
% 1. max velocity
% 2. average trajectory for a session
% 3. deviation from that trajectory for a session
% 4. distance between trajectories
% 5. closest distance paw to pellet
% 6. minimum z

% hard-coded in info about each rat including handedness
% script_ratInfo_for_deepcut;
% ratInfo_IDs = [ratInfo.ratID];

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');
ratInfo = readRatInfoTable(csvfname);
% ratInfo = cleanUpRatTable(ratInfo);

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 4 : 4%numRatFolders

    ratID = ratFolders(i_rat).name
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx,:);
    pawPref = thisRatInfo.pawPref;
    if iscategorical(pawPref)
        pawPref = char(pawPref);
    end
    if iscell(pawPref)
        pawPref = pawPref{1};
    end
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    reachScoresFile = [ratID '_scores.csv'];
    reachScoresFile = fullfile(ratRootFolder,reachScoresFile);
    reachScores = readReachScores(reachScoresFile);
    allSessionDates = [reachScores.date]';
    
    
    numTableSessions = length(reachScores);
    dateNums_from_scores_table = zeros(numTableSessions,1);
    for iSession = 1 : numTableSessions
        dateNums_from_scores_table(iSession) = datenum(reachScores(iSession).date);
%         dateNums_from_scores_table(iSession) = datenum(reachScores(iSession).date,'mm/dd/yy');
    end
        
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    sessionType = determineSessionType(thisRatInfo, allSessionDates);
    for iSession = 1 : numSessions
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession})
        
        if ~isfolder(fullSessionDir)
            continue;
        end
        cd(fullSessionDir);
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1}; % this will be in format yyyymmdd
                            % note date formats from the scores spreadsheet
                            % are in m/d/yy

        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        allSessionIdx = find(sessionDate == allSessionDates);
        sessionDateNum = datenum(sessionDateString,'yyyymmdd');
        % figure out index of reachScores array for this session

        sessionReachScores = reachScores(dateNums_from_scores_table == sessionDateNum).scores;
        
        % find the pawTrajectory files
        pawTrajectoryList = dir(trajectory_file_name);
        if isempty(pawTrajectoryList)
            continue
        end
        
        numTrials = length(pawTrajectoryList);
        
        for iTrial = 1 : numTrials
            
            load(pawTrajectoryList(iTrial).name);
            numFrames = size(direct_p,2);
            num_bodyparts = length(bodyparts);
            nanTrajectory = pawTrajectory;
            
            nanTrajectory(nanTrajectory == 0) = NaN;
            % calculate distance between points in adjacent frames; if
            % point jumped too far, flag as a possible error
            distMoved = zeros(numFrames-1,num_bodyparts);
%             move_too_far_flag = false(numFrames,num_bodyparts);
            for i_bp = 1 : num_bodyparts
                partTrajectory = squeeze(nanTrajectory(:,:,i_bp));
                distMoved(:,i_bp) = sqrt(sum(diff(partTrajectory).^2,2));
%                 move_too_far_flag(2:end,i_bp) = distMoved(:,i_bp) > max3Ddist_perFrame;
            end
                
            [mcpIdx,pipIdx,digIdx,pawdorsum_idx] = findReachingPawParts(bodyparts,pawPref);
            pawParts = [mcpIdx;pipIdx;digIdx;pawdorsum_idx];
            % are there frames where the paw is too big (presumably because
            % at least one of the identified points is a mistake)?
            partsTrajectory = nanTrajectory(:,:,pawParts);
            pawSpan = zeros(numFrames,1);
            maxSpanIdx = false(length(pawParts),numFrames);
            for iFrame = 1 : numFrames
                temp = squeeze(partsTrajectory(iFrame,:,:))';
                [pawSpan(iFrame),maxSpanIdx(:,iFrame)]= findFarthestPoints(temp);
            end
            
            save(pawTrajectoryList(iTrial).name,'pawSpan',...
                'maxSpanIdx','distMoved','-append');
        end


    end
    
end