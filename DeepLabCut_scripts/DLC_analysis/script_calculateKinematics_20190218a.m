% script_calculateKinematics_20190218

% REVIEW VELOCITY PROFILES

% UNDERSTAND WHAT CAUSES DIFFERENCES IN REACH DURATION

% template name for viable trajectory files (for searching)
trajectory_file_name = 'R*3dtrajectory_new.mat';

% parameter for function trajectory_wrt_pellet:
maxReprojError = 15;

% parameters for function interpolateTrajectories
num_pd_TrajectoryPoints = 100;
num_digit_TrajectoryPoints = 100;
start_z_pawdorsum = 46;
smoothWindow = 5;

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

% parameters for function findFirstPawDorsumFrames:
min_consec_frames = 5;
pThresh = 0.98; 
max_consecutive_misses = 50;
maxReprojError_pawDorsum = 10;    % if paw dorsum found in both views, only count it if they are more or less on the same epipolar line

% parameters for findReachEndpoint
min_z_diff_pre_reach = 1.5;     % minimum number of millimeters the paw must have moved since the previous reach to count as a new reach
min_z_diff_post_reach = 1;     
maxFramesPriorToAdvance = 10;   % if the paw extends further within this many frames after a local minimum, don't count it as a reach
pts_to_extract = 15;  % look pts_to_extract frames on either side of each z
smoothSize = 3;

% paramaeters for readReachScores
csvDateFormat = 'MM/dd/yyyy';
ratIDs_with_new_date_format = [284];

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
% 11 - started with paw through the slot

% parameter for initPelletLocation
time_to_average_prior_to_reach = 0.1;   % in seconds, the time prior to the reach over which to average pellet location

% calculate the following kinematic parameters:
% 1. max velocity
% 2. average trajectory for a session
% 3. deviation from that trajectory for a session
% 4. distance between trajectories
% 5. closest distance paw to pellet
% 6. minimum z

% use the pellet as the origin for all trajectories. That way it should be
% easy to make left vs right-pawed trajectories overlap - just reflect
% across x = 0. I think this will be OK. -DL 20181015

% labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/Leventhal_lab_HD01/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/SharedX-1/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';
labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_02/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');
ratInfo = readRatInfoTable(csvfname);

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 7:7%numRatFolders

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
    
    if any(ratIDs_with_new_date_format == ratIDnum)
        csvDateFormat = 'yyyyMMdd';
    end
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    reachScoresFile = [ratID '_scores.csv'];
    reachScoresFile = fullfile(ratRootFolder,reachScoresFile);
    reachScores = readReachScores(reachScoresFile,'csvdateformat',csvDateFormat);
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
    
    switch ratID
        case 'R0158'
            startSession = 1;
            endSession = numSessions;
        case 'R0159'
            startSession = 5;
            endSession = numSessions;
        case 'R0160'
            startSession = 1;
            endSession = 22;
        case 'R0169'
            startSession = 20;
            endSession = 20;
        case 'R0171'
            startSession = numSessions;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    for iSession = startSession : 4 : endSession
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        
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

        sessionReachScores = reachScores(allSessionIdx).scores;
        
        % find the pawTrajectory files
        pawTrajectoryList = dir(trajectory_file_name);
        if isempty(pawTrajectoryList)
            continue
        end
        
        fprintf('working on %s\n',sessionDirectories{iSession});
        numTrials = length(pawTrajectoryList);
        
        sessionSummaryName = [ratID '_' sessionDateString '_kinematicsSummary.mat'];
        if exist('isEndPtManuallyMarked','var')
            clear isEndPtManuallyMarked
        end
        if exist('is_paw_through_slot_frame_ManuallyMarked','var')
            clear is_paw_through_slot_frame_ManuallyMarked
        end
        if exist(sessionSummaryName,'file')
            load(sessionSummaryName);
        end
        if ~exist('isEndPtManuallyMarked','var')
            isEndPtManuallyMarked = false(numTrials,1);
        end
        if ~exist('is_paw_through_slot_frame_ManuallyMarked','var')
            is_paw_through_slot_frame_ManuallyMarked = false(numTrials,1);
        end
        
        load(pawTrajectoryList(1).name);
            
        % initialize variables to hold the various kinematic values
        all_mcpAngle = zeros(size(pawTrajectory,1),numTrials);
        all_pipAngle = zeros(size(pawTrajectory,1),numTrials);
        all_digitAngle = zeros(size(pawTrajectory,1),numTrials);
        all_pawAngle = zeros(size(pawTrajectory,1),numTrials);
        allTrajectories = NaN(size(pawTrajectory,1),size(pawTrajectory,2),size(pawTrajectory,3),numTrials);
        
        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
        numReachingPawParts = length(mcpIdx) + length(pipIdx) + length(digIdx) + length(pawDorsumIdx);
        all_endPts = zeros(numReachingPawParts, 3, numTrials);
        all_final_endPts = zeros(numReachingPawParts, 3, numTrials);
        all_partEndPts = zeros(numReachingPawParts, 3, numTrials);
        all_partFinalEndPts = zeros(numReachingPawParts, 3, numTrials);
        all_partFinalEndPtFrame = zeros(numReachingPawParts, numTrials);
        all_first_pawPart_outside_box = zeros(numReachingPawParts, numTrials);
        all_firstSlotBreak = zeros(numReachingPawParts, numTrials);
        all_firstPawDorsumFrame = zeros(numTrials,1);
        all_aperture = NaN(size(pawTrajectory,1),3,numTrials);
        all_maxDigitReachFrame = zeros(numTrials,1);
        all_initPellet3D = NaN(numTrials, 3);
        
        all_trialOutcomes = NaN(numTrials,1);
        all_isEstimate = false(size(isEstimate,1),size(isEstimate,2),size(isEstimate,3),numTrials);
        vidNum = zeros(numTrials,1);
        
        % if no reach endpoints have been manually marked, initialize the
        % following arrays; otherwise, use the arrays already in the file
        if ~any(isEndPtManuallyMarked)
            all_endPtFrame = NaN(numTrials,1);
            all_final_endPtFrame = NaN(numTrials,1);
            all_partEndPtFrame = zeros(numReachingPawParts, numTrials);
            all_reachFrameIdx = cell(numTrials,1);
        end
        % same for paw_through_slot_frame
        if ~any(is_paw_through_slot_frame_ManuallyMarked)
            all_paw_through_slot_frame = zeros(numTrials,1);
        end
                
        pelletMissingFlag = false(numTrials,1);
        % sometimes the session restarted and we get duplicate trial
        % numbers. The first column of trialNumbers will contain the trial
        % numbers from the file names. The second column will contain trial
        % numbers as recorded in the csv scoring tables.
        trialNumbers = zeros(numTrials,2);
        for iTrial = 1 : numTrials
            C = textscan(pawTrajectoryList(iTrial).name, [ratID '_' sessionDateString '_%d-%d-%d_%d_3dtrajectory.mat']); 
            trialNumbers(iTrial,1) = C{4};
        end
        % necessary because if the skilled reaching VI restarted, need to
        % account for renumbering the videos
        trialNumbers(:,2) = resolveDuplicateTrialNumbers(trialNumbers(:,1));
        invalid3Dpoints = false(size(pawTrajectory,3),size(pawTrajectory,1),numTrials);
        
        slot_z = find_slot_z(fullSessionDir,'trajectory_file_name',trajectory_file_name);
%         if slot_z < 160 || slot_z > 230
%             keyboard
%         end
        
        for iTrial = 1 : numTrials
            
            if exist('manually_invalidated_points','var')
                clear manually_invalidated_points
            end
            load(pawTrajectoryList(iTrial).name);

            % occasionally there's a video that's too short - truncated
            % during recording? maybe VI turned off in mid-recording?
            % if that's the case, pad with false values
            if size(isEstimate,2) < size(all_isEstimate,2)
                isEstimate(:,end+1:size(all_isEstimate,2),:) = false;
            end 
            % sometimes it happens to the first video...
            if size(isEstimate,2) > size(all_isEstimate,2)
                all_isEstimate(:,end+1:size(isEstimate,2),:,:) = false;
            end
            all_isEstimate(:,:,:,iTrial) = isEstimate;

            trialOutcome = sessionReachScores(trialNumbers(iTrial,2));
            all_trialOutcomes(iTrial) = trialOutcome;
            
            [invalid_mirror, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p,mirror_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
            [invalid_direct, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p,direct_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
            
            if size(invalid_direct,2) < size(invalid3Dpoints,2)
                % make any points that aren't in a truncated video invalid
                invalid_direct(:,end+1:size(invalid3Dpoints,2)) = true;
                invalid_mirror(:,end+1:size(invalid3Dpoints,2)) = true;
            end
            if size(invalid_direct,2) > size(invalid3Dpoints,2)
                % make any points that aren't in a truncated video invalid
                % (sometimes this happens on the first video)
                invalid3Dpoints(:,end+1:size(invalid_direct,2),:) = true;
            end
            invalid3Dpoints(:,:,iTrial) = invalid_direct & invalid_mirror;   % if both direct and indirect points are invalid, 3D point can't be valid
            
            if exist('manually_invalidated_points','var')
                num_session_frames = size(invalid3Dpoints,2);              % number of frames recorded in other trials for this session (actually, based on 1st trial right now)
                num_trial_frames = size(manually_invalidated_points,1);    % number of frames recorded for this trial
                
%                 num_frames = min(size(invalid3Dpoints,2),size(manually_invalidated_points,1));
%                 if num_trial_frames < num_session_frames
                temp_manually_invalidated = false(size(manually_invalidated_points,2),num_session_frames);
                temp_manually_invalidated(:,1:num_trial_frames) = squeeze(manually_invalidated_points(:,:,1))' | squeeze(manually_invalidated_points(:,:,2))';

%                 invalid3Dpoints(:,:,iTrial) = invalid3Dpoints(:,:,iTrial) | temp_manually_invalidated;
                invalid_direct(:,1:num_trial_frames) = invalid_direct(:,1:num_trial_frames) | squeeze(manually_invalidated_points(:,:,1))';
                invalid_mirror(:,1:num_trial_frames) = invalid_mirror(:,1:num_trial_frames) | squeeze(manually_invalidated_points(:,:,2))';
            end
            
            [mcpAngle,pipAngle,digitAngle,pawAngle] = determineDirectPawOrientation(final_direct_pts,direct_bp,invalid_direct,pawPref);
            if length(mcpAngle) < size(all_mcpAngle,1)
                mcpAngle(end+1:size(all_mcpAngle,1)) = 0;
                pipAngle(end+1:size(all_pipAngle,1)) = 0;
                digitAngle(end+1:size(all_digitAngle,1)) = 0;
                pawAngle(end+1:size(all_pawAngle,1)) = 0;
            end
            if length(mcpAngle) > size(all_mcpAngle,1)
                all_mcpAngle(end+1:length(mcpAngle),:) = 0;
                all_pipAngle(end+1:length(pipAngle),:) = 0;
                all_digitAngle(end+1:length(digitAngle),:) = 0;
                all_pawAngle(end+1:length(pawAngle),:) = 0;
            end
            all_mcpAngle(:,iTrial) = mcpAngle;
            all_pipAngle(:,iTrial) = pipAngle;
            all_digitAngle(:,iTrial) = digitAngle;
            all_pawAngle(:,iTrial) = pawAngle;
            
            [~,~,~,mirror_pawdorsum_idx,~,pellet_idx,~] = group_DLC_bodyparts(mirror_bp,pawPref);
            [mcpIdx,pipIdx,digIdx,pawdorsum_idx] = findReachingPawParts(bodyparts,pawPref);
            pawParts = [mcpIdx;pipIdx;digIdx;pawdorsum_idx];
            
            
            [paw_through_slot_frame,firstSlotBreak,first_pawPart_outside_box,maxDigitReachFrame] = findPawThroughSlotFrame(pawTrajectory, bodyparts, pawPref, invalid_direct, invalid_mirror, reproj_error, 'slot_z',slot_z,'maxReprojError',maxReprojError);
            
            all_maxDigitReachFrame(iTrial) = maxDigitReachFrame;
            
            pellet_reproj_error = squeeze(reproj_error(pellet_idx,:,:));
            initPellet3D = initPelletLocation(pawTrajectory,bodyparts,frameRate,paw_through_slot_frame,pellet_reproj_error,...
                'time_to_average_prior_to_reach',time_to_average_prior_to_reach);

            if ~isempty(initPellet3D)
                % most likely, pellet wasn't brought up by the delivery arm
                % on this trial
                all_initPellet3D(iTrial,:) = initPellet3D;
            end

            pawDorsum_p = squeeze(mirror_p(mirror_pawdorsum_idx,:));
            paw_z = squeeze(pawTrajectory(:,3,pawdorsum_idx));
            pawDorsum_reproj_error = squeeze(reproj_error(pawdorsum_idx,:,:));
            firstPawDorsumFrame = findFirstPawDorsumFrame(pawDorsum_p,paw_z,paw_through_slot_frame,pawDorsum_reproj_error,...
                'pthresh',pThresh,'min_consec_frames',min_consec_frames,'max_consecutive_misses',max_consecutive_misses,...
                'slot_z',slot_z,'maxreprojerror',maxReprojError_pawDorsum);
            if ~is_paw_through_slot_frame_ManuallyMarked
                all_paw_through_slot_frame(iTrial) = paw_through_slot_frame;
            end
            all_first_pawPart_outside_box(:,iTrial) = first_pawPart_outside_box;
            all_firstSlotBreak(:,iTrial) = firstSlotBreak;
            
%             if isempty(firstPawDorsumFrame)
%                 all_firstPawDorsumFrame(iTrial) = NaN;
%             else
                all_firstPawDorsumFrame(iTrial) = firstPawDorsumFrame;
%             end
            
            trajectory = trajectory_wrt_pellet(pawTrajectory, initPellet3D, reproj_error, pawPref,'maxreprojectionerror',maxReprojError);
            
            if isempty(trajectory)
                pelletMissingFlag(iTrial) = true;
                fprintf('%s, trial %d\n',sessionDirectories{iSession}, trialNumbers(iTrial,1));
            else
                for i_bp = 1 : size(invalid3Dpoints,1)
                    for iFrame = 1 : size(invalid3Dpoints,2)
                        if invalid3Dpoints(i_bp,iFrame,iTrial)
                            trajectory(iFrame,:,i_bp) = NaN;
                        end
                    end
                end
                if size(trajectory,1) > size(allTrajectories,1)
                    allTrajectories(end+1:size(trajectory,1),:,:,:) = 0;
                end
                allTrajectories(:,:,:,iTrial) = trajectory;
            end
            save(pawTrajectoryList(iTrial).name,'mcpAngle','pipAngle','digitAngle',...
                'firstPawDorsumFrame','trialOutcome','firstSlotBreak','paw_through_slot_frame','first_pawPart_outside_box',...
                'initPellet3D','-append');
        end
        
        mean_initPellet3D = nanmean(all_initPellet3D,1);
            
        for iTrial = 1 : numTrials
%             iTrial
            if pelletMissingFlag(iTrial)
                load(pawTrajectoryList(iTrial).name);
                trajectory = trajectory_wrt_pellet(pawTrajectory, mean_initPellet3D, reproj_error, pawPref,'maxreprojectionerror',maxReprojError);
                all_initPellet3D(iTrial,:) = mean_initPellet3D;
                for i_bp = 1 : size(invalid3Dpoints,1)
                    for iFrame = 1 : size(invalid3Dpoints,2)
                        if invalid3Dpoints(i_bp,iFrame,iTrial)
                            trajectory(iFrame,:,i_bp) = NaN;
                        end
                    end
                end

                allTrajectories(:,:,:,iTrial) = trajectory;
            else
                trajectory = squeeze(allTrajectories(:,:,:,iTrial));
            end
            
            % should velocity be calculated based on smoothed position?
%             v = pawVelocity(trajectory,frameRate);
%             all_v(:,:,:,iTrial) = v;
            
            % should acceleration be calculated based on smoothed velocity?
%             a = pawVelocity(v,frameRate);
%             all_a(:,:,:,iTrial) = a;
            
            aperture = calcAperture(trajectory,bodyparts,pawPref);
            slot_z_wrt_pellet = slot_z - mean_initPellet3D(3);
            
            if ~isEndPtManuallyMarked(iTrial)
                % did not go through and manually mark part end points
                [partEndPts,partEndPtFrame,partFinalEndPts,partFinalEndPtFrame,endPts,endPtFrame,final_endPts,final_endPtFrame,pawPartsList,reachFrameIdx] = ...
                    findReachEndpoint_20190319(trajectory, bodyparts,pawPref,all_paw_through_slot_frame(iTrial),squeeze(all_isEstimate(:,:,:,iTrial)),...
                    'smoothsize',smoothSize,'slot_z',slot_z_wrt_pellet,'min_dist_pre_reach',min_z_diff_pre_reach,'min_dist_post_reach',min_z_diff_post_reach,...
                    'maxframespriortoadvance',maxFramesPriorToAdvance,'pts_to_extract',pts_to_extract);
            else
                % the endpoints for this reach were marked manually; don't
                % overwrite them
                endPtFrame = all_endPtFrame(iTrial);
                final_endPtFrame = all_final_endPtFrame(iTrial);
                partEndPtFrame = NaN(numReachingPawParts,1);
                reachFrameIdx = all_reachFrameIdx{iTrial};
                
%                 [partEndPts,partEndPtFrame
                
                partEndPts = zeros(numReachingPawParts,3);
                endPts = zeros(numReachingPawParts,3);
                final_endPts = zeros(numReachingPawParts,3);
                partFinalEndPts = NaN(numReachingPawParts,3);
                partFinalEndPtFrame = NaN(numReachingPawParts,1);
            end

            all_endPts(:,:,iTrial) = endPts;
            all_final_endPts(:,:,iTrial) = final_endPts;
            all_partEndPts(:,:,iTrial) = partEndPts;
            all_partFinalEndPts(:,:,iTrial) = partFinalEndPts;
            all_partEndPtFrame(:,iTrial) = partEndPtFrame;
            all_partFinalEndPtFrame(:,iTrial) = partFinalEndPtFrame;
            all_endPtFrame(iTrial) = endPtFrame;
            all_final_endPtFrame(iTrial) = final_endPtFrame;
            all_reachFrameIdx{iTrial} = reachFrameIdx;
            
            % in case this video is shorter than the others (happens every
            % now and then within a session)
            if size(aperture,1) < size(all_aperture,1)
                aperture(end+1:size(all_aperture,1),:) = NaN;
            end 
            if size(aperture,1) > size(all_aperture,1)
                all_aperture(end+1:size(aperture,1),:,:) = NaN;
            end 
            all_aperture(:,:,iTrial) = aperture;
            
            num_bodyparts = length(bodyparts);
            nanTrajectory = trajectory;
            numFrames = size(nanTrajectory,1);
            
            nanTrajectory(nanTrajectory == 0) = NaN;
            distMoved = zeros(numFrames-1,num_bodyparts);

            for i_bp = 1 : num_bodyparts
                partTrajectory = squeeze(nanTrajectory(:,:,i_bp));
                distMoved(:,i_bp) = sqrt(sum(diff(partTrajectory).^2,2));
            end
            % are there frames where the paw is too big (presumably because
            % at least one of the identified points is a mistake)?
            partsTrajectory = nanTrajectory(:,:,pawParts);
            pawSpan = zeros(numFrames,1);
            maxSpanIdx = false(length(pawParts),numFrames);
            for iFrame = 1 : numFrames
                temp = squeeze(partsTrajectory(iFrame,:,:))';
                [pawSpan(iFrame),maxSpanIdx(:,iFrame)]= findFarthestPoints(temp);
            end
            
            save(pawTrajectoryList(iTrial).name,'trajectory',...
                'mcpAngle','pipAngle','digitAngle','partEndPts','partFinalEndPts',...
                'partEndPtFrame','partFinalEndPtFrame','endPts','final_endPts','endPtFrame','final_endPtFrame','pawPartsList',...
                'reachFrameIdx','firstPawDorsumFrame','trialOutcome','firstSlotBreak','paw_through_slot_frame','first_pawPart_outside_box',...
                'initPellet3D','aperture','pawSpan','maxSpanIdx','distMoved','-append');
        end

        allTrajectories(allTrajectories == 0) = NaN;
        try
        [normalized_pd_trajectories,smoothed_pd_trajectories,interp_pd_trajectories,normalized_digit_trajectories,smoothed_digit_trajectories,interp_digit_trajectories] = ...
            interpolateTrajectories(allTrajectories,pawPartsList,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,pawPref,...
            'num_pd_TrajectoryPoints',num_pd_TrajectoryPoints,'num_digit_TrajectoryPoints',num_digit_TrajectoryPoints,'start_z_pawdorsum',start_z_pawdorsum,'smoothwindow',smoothWindow,...
            'start_z_digits',slot_z-mean_initPellet3D(3));
        trajectoryLengths = calculateTrajectoryLengths(normalized_pd_trajectories,normalized_digit_trajectories,slot_z_wrt_pellet);
        catch
            keyboard
        end
%         smoothed_pawOrientations = calcSmoothedPawOrientations(smoothed_pd_trajectories,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,pawPref);
        
        [all_paw_xyz_v,all_paw_tangential_v] = calculatePawVelocity(smoothed_pd_trajectories,frameRate);
        sessionSummaryName = [ratID '_' sessionDateString '_kinematicsSummary.mat'];
        thisSessionType = sessionType(allSessionIdx);
        
        [all_reachEndPoints,all_numReaches_byPart,all_numReaches,all_reachFrames,all_reach_endPoints] = ...
            collectall_reachEndPoints(all_reachFrameIdx,allTrajectories,{0:10},all_trialOutcomes,digIdx);
        
        if exist(sessionSummaryName,'file')
            save(sessionSummaryName,'bodyparts','allTrajectories','all_paw_xyz_v','all_paw_tangential_v',...
                'normalized_pd_trajectories','normalized_digit_trajectories',...
                'smoothed_pd_trajectories','smoothed_digit_trajectories',...
                'interp_pd_trajectories','interp_digit_trajectories',...
                'all_mcpAngle','all_pipAngle','all_digitAngle','all_pawAngle','all_aperture',...
                'all_endPts','all_final_endPts','all_partEndPts','all_partFinalEndPts','all_partEndPtFrame','all_partFinalEndPtFrame',...
                'pawPartsList','all_initPellet3D','trialNumbers','all_trialOutcomes',...
                'frameRate','frameTimeLimits','all_paw_through_slot_frame','all_firstSlotBreak','all_first_pawPart_outside_box',...
                'all_isEstimate','all_endPtFrame','all_final_endPtFrame','all_reachFrameIdx','all_firstPawDorsumFrame','all_maxDigitReachFrame',...
                'trajectoryLengths','thisRatInfo','thisSessionType','slot_z','isEndPtManuallyMarked',...
                'all_reachEndPoints','all_numReaches_byPart','all_numReaches','all_reachFrames','all_reach_endPoints','is_paw_through_slot_frame_ManuallyMarked','-append');
        else
            save(sessionSummaryName,'bodyparts','allTrajectories','all_paw_xyz_v','all_paw_tangential_v',...
                'normalized_pd_trajectories','normalized_digit_trajectories',...
                'smoothed_pd_trajectories','smoothed_digit_trajectories',...
                'interp_pd_trajectories','interp_digit_trajectories',...
                'all_mcpAngle','all_pipAngle','all_digitAngle','all_pawAngle','all_aperture',...
                'all_endPts','all_final_endPts','all_partEndPts','all_partFinalEndPts','all_partEndPtFrame','all_partFinalEndPtFrame',...
                'pawPartsList','all_initPellet3D','trialNumbers','all_trialOutcomes',...
                'frameRate','frameTimeLimits','all_paw_through_slot_frame','all_firstSlotBreak','all_first_pawPart_outside_box',...
                'all_isEstimate','all_endPtFrame','all_final_endPtFrame','all_reachFrameIdx','all_firstPawDorsumFrame','all_maxDigitReachFrame',...
                'trajectoryLengths','thisRatInfo','thisSessionType','slot_z','isEndPtManuallyMarked',...
                'all_reachEndPoints','all_numReaches_byPart','all_numReaches','all_reachFrames','all_reach_endPoints','is_paw_through_slot_frame_ManuallyMarked');
        end
        
    end
    
end