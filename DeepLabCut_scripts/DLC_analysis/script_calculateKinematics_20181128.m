% script_calculateKinematics_20181128

maxReprojError = 10;

% slot_z = 200;    % distance from camera of slot in mm. hard coded for now
% time_to_average_prior_to_reach = 0.1;   % in seconds, the time prior to the reach over which to average pellet location

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

% use the pellet as the origin for all trajectories. That way it should be
% easy to make left vs right-pawed trajectories overlap - just reflect
% across x = 0. I think this will be OK. -DL 20181015

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');
ratInfo = readtable(csvfname);
ratInfo = cleanUpRatTable(ratInfo);

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders

    ratID = ratFolders(i_rat).name
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx,:);
    pawPref = thisRatInfo.pawPref;
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = dir([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    for iSession = 1 : numSessions
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories(iSession).name)
        
        if ~isfolder(fullSessionDir)
            continue;
        end
        cd(fullSessionDir);
        C = textscan(sessionDirectories(iSession).name,[ratID '_%8c']);
        sessionDate = C{1};
        
        % find the pawTrajectory files
        pawTrajectoryList = dir('R*3dtrajectory.mat');
        if isempty(pawTrajectoryList)
            continue
        end
        
        numTrials = length(pawTrajectoryList);
        
        load(pawTrajectoryList(1).name);
        
        all_v = zeros(size(pawTrajectory,1)-1,3,size(pawTrajectory,3),numTrials);
        all_a = zeros(size(pawTrajectory,1)-2,3,size(pawTrajectory,3),numTrials);
%         all_dist_from_pellet = zeros(size(pawTrajectory,1),size(pawTrajectory,3),numTrials);
        all_mcpAngle = zeros(size(pawTrajectory,1),numTrials);
        all_pipAngle = zeros(size(pawTrajectory,1),numTrials);
        all_digitAngle = zeros(size(pawTrajectory,1),numTrials);
        allTrajectories = NaN(size(pawTrajectory,1),size(pawTrajectory,2),size(pawTrajectory,3),numTrials);
        
        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
        numReachingPawParts = length(mcpIdx) + length(pipIdx) + length(digIdx) + length(pawDorsumIdx);
        all_endPts = zeros(numReachingPawParts, 3, numTrials);
        all_partEndPtFrame = zeros(numReachingPawParts, numTrials);
        all_paw_through_slot_frame = zeros(numTrials,1);
        all_firstPawDorsumFrame = zeros(numTrials,1);
        all_initPellet3D = NaN(numTrials, 3);
        all_endPtFrame = NaN(numTrials,1);
        all_trialOutcomes = NaN(numTrials,1);
        all_isEstimate = false(size(isEstimate,1),size(isEstimate,2),size(isEstimate,3),numTrials);
        
        vidNum = zeros(numTrials,1);
        
        pelletMissingFlag = false(numTrials,1);
        trialNumbers = zeros(numTrials,1);
        
        invalid3Dpoints = false(size(pawTrajectory,3),size(pawTrajectory,1),numTrials);
        for iTrial = 1 : numTrials
            
            load(pawTrajectoryList(iTrial).name);
            all_isEstimate(:,:,:,iTrial) = isEstimate;
            C = textscan(pawTrajectoryList(iTrial).name, [ratID '_' sessionDate '_%d-%d-%d_%d_3dtrajectory.mat']); 
            trialNumbers(iTrial) = C{4};
            
            invalid_direct = find_invalid_DLC_points(direct_pts, direct_p);
            invalid_mirror = find_invalid_DLC_points(mirror_pts, mirror_p);
            invalid3Dpoints(:,:,iTrial) = invalid_direct & invalid_mirror;   % if both direct and indirect points are invalid, 3D point can't be valid
            
            if ~isempty(initPellet3D)
                % most likely, pellet wasn't brought up by the delivery arm
                % on this trial
                all_initPellet3D(iTrial,:) = initPellet3D;
            end
            
            [mcpAngle,pipAngle,digitAngle] = determineDirectPawOrientation(direct_pts,direct_bp,invalid_direct,pawPref);
            all_mcpAngle(:,iTrial) = mcpAngle;
            all_pipAngle(:,iTrial) = pipAngle;
            all_digitAngle(:,iTrial) = digitAngle;
            
            paw_through_slot_frame = min(firstSlotBreak);
            firstPawDorsumFrame = findFirstPawDorsumFrame(trajectory,mirror_p,mirror_bp,paw_through_slot_frame,pawPref,0.95);
            all_paw_through_slot_frame(iTrial) = paw_through_slot_frame;
            try
            all_firstPawDorsumFrame(iTrial) = firstPawDorsumFrame;
            catch
                keyboard
            end
            
            trajectory = trajectory_wrt_pellet(pawTrajectory, initPellet3D, reproj_error, pawPref,'maxreprojectionerror',maxReprojError);
            
            if isempty(trajectory)
                pelletMissingFlag(iTrial) = true;
                fprintf('%s, trial %d\n',sessionDirectories(iSession).name, trialNumbers(iTrial));
            else
                for i_bp = 1 : size(invalid3Dpoints,1)
                    for iFrame = 1 : size(invalid3Dpoints,2)
                        if invalid3Dpoints(i_bp,iFrame,iTrial)
                            trajectory(iFrame,:,i_bp) = NaN;
                        end
                    end
                end
                allTrajectories(:,:,:,iTrial) = trajectory;
            end
        end
        
        mean_initPellet3D = nanmean(all_initPellet3D);
            
        for iTrial = 1 : numTrials
            if pelletMissingFlag(iTrial)
                trajectory = trajectory_wrt_pellet(pawTrajectory, mean_initPellet3D, reproj_error, pawPref,'maxreprojectionerror',maxReprojError);
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
            v = pawVelocity(trajectory,frameRate);
            all_v(:,:,:,iTrial) = v;
            
            % should acceleration be calculated based on smoothed velocity?
            a = pawVelocity(v,frameRate);
            all_a(:,:,:,iTrial) = a;
            
            
            [partEndPts,partEndPtFrame,endPts,endPtFrame,pawPartsList,] = ...
                findReachEndpoint(trajectory, bodyparts,frameRate,frameTimeLimits,pawPref,all_paw_through_slot_frame(iTrial),squeeze(all_isEstimate(:,:,:,iTrial)));
            all_endPts(:,:,iTrial) = partEndPts;
            all_partEndPtFrame (:,iTrial) = partEndPtFrame;
            all_endPtFrame(iTrial) = endPtFrame;
            
            
            % NEED TO READ IN TRIAL OUTCOME
            save(pawTrajectoryList(iTrial).name,'trajectory',...
                'v','a','mcpAngle','pipAngle','digitAngle','partEndPts',...
                'partEndPtFrame','endPts','endPtFrame','pawPartsList',...
                'firstPawDorsumFrame','-append');
        end

        allTrajectories(allTrajectories == 0) = NaN;

        sessionSummaryName = [ratID '_' sessionDate '_kinematicsSummary.mat'];
        
        save(sessionSummaryName,'bodyparts','allTrajectories','all_v',...
            'all_a','all_mcpAngle','all_pipAngle','all_digitAngle',...
            'all_endPts','all_partEndPtFrame','pawPartsList','all_initPellet3D','trialNumbers',...
            'frameRate','frameTimeLimits','all_paw_through_slot_frame','all_isEstimate','all_endPtFrame','all_firstPawDorsumFrame','thisRatInfo');
        
    end
    
end