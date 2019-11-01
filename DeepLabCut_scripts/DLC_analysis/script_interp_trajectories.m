% script_interp_trajectories

% template name for viable trajectory files (for searching)
trajectory_file_name = 'R*3dtrajectory_new.mat';

% parameter for function nanPawTrajectory:
maxReprojError = 15;

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

% parameters for extractSingleTrialKinematics
windowLength = 10;
smoothMethod = 'gaussian';

% parameter for initPelletLocation
time_to_average_prior_to_reach = 0.1;   % in seconds, the time prior to the reach over which to average pellet location

% paramaeters for readReachScores
csvDateFormat = 'MM/dd/yyyy';
ratIDs_with_new_date_format = [284];

% use the pellet as the origin for all trajectories. That way it should be
% easy to make left vs right-pawed trajectories overlap - just reflect
% across x = 0. I think this will be OK. -DL 20181015

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
sharedX_DLCoutput_path = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';
xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20191028.csv');
ratInfo = readRatInfoTable(csvfname);

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 33:numRatFolders

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
    sharedX_ratRootFolder = fullfile(sharedX_DLCoutput_path,ratID);
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    switch ratID
        case 'R0186'
            startSession = 1;
            endSession = numSessions;
        case 'R0159'
            startSession = 5;
            endSession = numSessions;
        case 'R0160'
            startSession = 1;
            endSession = 22;
        case 'R0189'
            startSession = 1;
            endSession = numSessions;
        case 'R0230'
            startSession = 16;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    for iSession = startSession : 1 : endSession
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        sharedX_fullSessionDir = fullfile(sharedX_ratRootFolder,sessionDirectories{iSession});
        
        if ~exist(sharedX_fullSessionDir,'dir')
            mkdir(sharedX_fullSessionDir)
        end
        if ~isfolder(fullSessionDir)
            continue;
        end
        cd(fullSessionDir);
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1}; % this will be in format yyyymmdd
                            % note date formats from the scores spreadsheet
                            % are in m/d/yy

        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        sessionDateNum = datenum(sessionDateString,'yyyymmdd');
        
        % find the pawTrajectory files
        pawTrajectoryList = dir(trajectory_file_name);
        if isempty(pawTrajectoryList)
            continue
        end
        
        fprintf('working on %s\n',sessionDirectories{iSession});
        numTrials = length(pawTrajectoryList);
        interpTrajectoryName = [ratID '_' sessionDateString '_interp_trajectories.mat'];
        sharedX_interpTrajectoryName = fullfile(sharedX_fullSessionDir,interpTrajectoryName);

        % find the maximum number of frames across videos
        maxFrames = 0;
        for iTrial = 1 : numTrials
            load(pawTrajectoryList(iTrial).name);
            maxFrames = max(size(pawTrajectory,1),maxFrames);
        end

        num_bodyparts = size(pawTrajectory,3);
        
        % initialize variables
%         all_isEstimate = false(num_bodyparts,maxFrames,2,numTrials);
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
        invalid3Dpoints = false(num_bodyparts,maxFrames,numTrials);
        
        slot_z = find_slot_z(fullSessionDir,'trajectory_file_name',trajectory_file_name);
        all_initPellet3D = NaN(numTrials,3);
        all_interp_trajectories = ...
            NaN(maxFrames,3,num_bodyparts,numTrials);
        all_frameRange = zeros(num_bodyparts,2,numTrials);
        all_didPawStartThroughSlot = false(numTrials,1);
        all_firstSlotBreachFrame = zeros(numTrials,1);
        all_firstPawPastSlotFrame = zeros(numTrials,1);
%         tic
        for iTrial = 1 : numTrials
            
            if exist('manually_invalidated_points','var')
                clear manually_invalidated_points
            end
            load(pawTrajectoryList(iTrial).name);

            % occasionally there's a video that's too short - truncated
            % during recording? maybe VI turned off in mid-recording?
            % if that's the case, pad with false values
%             if size(isEstimate,2) < size(all_isEstimate,2)
%                 isEstimate(:,end+1:size(all_isEstimate,2),:) = false;
%             end 
%             % sometimes it happens to the first video...
%             if size(isEstimate,2) > size(all_isEstimate,2)
%                 all_isEstimate(:,end+1:size(isEstimate,2),:,:) = false;
%             end
%             all_isEstimate(:,:,:,iTrial) = isEstimate;
            
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
                
                temp_manually_invalidated = false(size(manually_invalidated_points,2),num_session_frames);
                temp_manually_invalidated(:,1:num_trial_frames) = squeeze(manually_invalidated_points(:,:,1))' | squeeze(manually_invalidated_points(:,:,2))';

                invalid_direct(:,1:num_trial_frames) = invalid_direct(:,1:num_trial_frames) | squeeze(manually_invalidated_points(:,:,1))';
                invalid_mirror(:,1:num_trial_frames) = invalid_mirror(:,1:num_trial_frames) | squeeze(manually_invalidated_points(:,:,2))';
            end

            [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,~,pellet_idx,~] = group_DLC_bodyparts(bodyparts,pawPref);
            reachingPartIdx = [mcp_idx;pip_idx;digit_idx;pawdorsum_idx];
            
            trialTrajectory = nanPawTrajectory(pawTrajectory, reproj_error, maxReprojError);
            trialTrajectory(trialTrajectory==0) = NaN;
            for i_bp = 1 : size(invalid3Dpoints,1)
                for iFrame = 1 : size(invalid3Dpoints,2)
                    if invalid3Dpoints(i_bp,iFrame,iTrial)
                        trialTrajectory(iFrame,:,i_bp) = NaN;
                    end
                end
            end
            
            [interp_pawTrajectory,frameRange] = extractSingleTrialKinematics(trialTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);
            
            [part_through_slot_frames,all_firstSlotBreachFrame(iTrial),all_firstPawPastSlotFrame(iTrial),all_didPawStartThroughSlot(iTrial)] = ...
                findPawThroughSlotFrames(interp_pawTrajectory(:,:,reachingPartIdx), slot_z);

            if ~all_didPawStartThroughSlot(iTrial)
                pellet_reproj_error = squeeze(reproj_error(pellet_idx,:,:));
                pellet_direct_p = direct_p(pellet_idx,:);
                [initPellet3D,pelletMissingFlag(iTrial)] = initPelletLocation(interp_pawTrajectory,bodyparts,frameRate,all_firstSlotBreachFrame(iTrial),pellet_reproj_error,pellet_direct_p,...
                    'time_to_average_prior_to_reach',time_to_average_prior_to_reach);
                if ~isempty(initPellet3D)
                    % most likely, pellet wasn't brought up by the delivery arm
                    % on this trial
                    if ~isnan(initPellet3D(1))
                        all_initPellet3D(iTrial,:) = initPellet3D;
                    end
                end
            end
            
            all_interp_trajectories(:,:,:,iTrial) = interp_pawTrajectory;
            all_frameRange(:,:,iTrial) = frameRange;
        end
%         toc
        
        % calculate trajectories with respect to the pellet's initial
        % location
        all_slot_z_wrt_pellet = zeros(numTrials,1);
        all_interp_traj_wrt_pellet = NaN(maxFrames,3,num_bodyparts,numTrials);
        for iTrial = 1 : numTrials
            % if a pellet was not found OR the paw started outside the box
            if pelletMissingFlag(iTrial) || all_didPawStartThroughSlot(iTrial) || isnan(all_initPellet3D(iTrial,1))
                all_initPellet3D(iTrial,:) = nanmean(all_initPellet3D);
            end
            
            all_slot_z_wrt_pellet(iTrial) = slot_z - all_initPellet3D(iTrial,3);
            interp_traj_wrt_pellet = NaN(maxFrames,3,num_bodyparts);
            for iDim = 1 : 3
                for i_bodypart = 1 : num_bodyparts
                    interp_traj_wrt_pellet(:,iDim,i_bodypart) = ...
                        squeeze(all_interp_trajectories(:,iDim,i_bodypart,iTrial)) - all_initPellet3D(iTrial,iDim);
                end
            end
            all_interp_traj_wrt_pellet(:,:,:,iTrial) = interp_traj_wrt_pellet;
        end
            
        save(interpTrajectoryName,'all_interp_traj_wrt_pellet','all_frameRange','all_didPawStartThroughSlot',...
            'all_initPellet3D','all_firstPawPastSlotFrame','all_firstSlotBreachFrame','pelletMissingFlag','trialNumbers',...
            'bodyparts','invalid3Dpoints','slot_z','all_slot_z_wrt_pellet','frameRate');
        
        save(sharedX_interpTrajectoryName,'all_interp_traj_wrt_pellet','all_frameRange','all_didPawStartThroughSlot',...
            'all_initPellet3D','all_firstPawPastSlotFrame','all_firstSlotBreachFrame','pelletMissingFlag','trialNumbers',...
            'bodyparts','invalid3Dpoints','slot_z','all_slot_z_wrt_pellet','frameRate');
        
    end
    
end