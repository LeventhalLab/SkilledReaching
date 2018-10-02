% script_calculateKinematics


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

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders

    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
%     ratInfo_idx = find(ratInfo_IDs == ratIDnum);
%     if isempty(ratInfo_idx)
%         error('no entry in ratInfo structure for rat %d\n',C{1});
%     end
%     thisRatInfo = ratInfo(ratInfo_idx);
%     pawPref = thisRatInfo.pawPref;
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = dir([ratID '_*']);
    numSessions = length(sessionDirectories);
    
    for iSession = 1 : numSessions
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories(iSession).name);
        
        if ~isfolder(fullSessionDir)
            continue;
        end
        cd(fullSessionDir);
        C = textscan(sessionDirectories(iSession).name,[ratID '_%8c']);
        sessionDate = C{1};
        
        % find the pawTrajectory files
        pawTrajectoryList = dir('R*3dtrajectory.mat');
        numTrials = length(pawTrajectoryList);
        
        load(pawTrajectoryList(1).name);
        
        all_v = zeros(size(pawTrajectory,1)-1,3,size(pawTrajectory,3),numTrials);
        all_a = zeros(size(pawTrajectory,1)-2,3,size(pawTrajectory,3),numTrials);
        all_dist_from_pellet = zeros(size(pawTrajectory,1),size(pawTrajectory,3),numTrials);
        all_mcpAngle = zeros(size(pawTrajectory,1),numTrials);
        all_pipAngle = zeros(size(pawTrajectory,1),numTrials);
        all_digitAngle = zeros(size(pawTrajectory,1),numTrials);
        allTrajectories = NaN(size(pawTrajectory,1),size(pawTrajectory,2),size(pawTrajectory,3),numTrials);
        
        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
        numReachingPawParts = length(mcpIdx) + length(pipIdx) + length(digIdx) + length(pawDorsumIdx);
        all_endPts = zeros(numReachingPawParts, 3, numTrials);
        
        vidNum = zeros(numTrials,1);
        
        for iTrial = 1 : numTrials
            
            load(pawTrajectoryList(iTrial).name);
            pawPref = thisRatInfo.pawPref;
            
            dist_from_pellet = distFromPellet(pawTrajectory,bodyparts,frameRate,frameTimeLimits);
            all_dist_from_pellet(:,:,iTrial) = dist_from_pellet;
            
            % should velocity be calculated based on smoothed position?
            v = pawVelocity(pawTrajectory,frameRate);
            all_v(:,:,:,iTrial) = v;
            
            % should acceleration be calculated based on smoothed velocity?
            a = pawVelocity(v,frameRate);
            all_a(:,:,:,iTrial) = a;
            
            [mcpAngle,pipAngle,digitAngle] = determineDirectPawOrientation(direct_pts,direct_bp,direct_p,pawPref);
            all_mcpAngle(:,iTrial) = mcpAngle;
            all_pipAngle(:,iTrial) = pipAngle;
            all_digitAngle(:,iTrial) = digitAngle;
            
            allTrajectories(:,:,:,iTrial) = pawTrajectory;
            
            [partEndPts,partEndPtFrame,endPts,endPtFrame,pawPartsList] = findReachEndpoint(pawTrajectory, bodyparts,frameRate,frameTimeLimits,pawPref);
        
            all_endPts(:,:,iTrial) = partEndPts;
            
            save(pawTrajectoryList(iTrial).name,'dist_from_pellet',...
                'v','a','mcpAngle','pipAngle','digitAngle','partEndPts',...
                'partEndPtFrame','endPts','endPtFrame','pawPartsList','-append');
        end
        
        mean_v = zeros(size(all_v,1),size(all_v,2),size(all_v,3));
        mean_a = zeros(size(all_a,1),size(all_a,2),size(all_a,3));
        
        allTrajectories(allTrajectories == 0) = NaN;
%         mean_mcpAngle = zeros(size(pawTrajectory,1),1);
%         mean_pipAngle = zeros(size(pawTrajectory,1),1);
%         mean_digAngle = zeros(size(pawTrajectory,1),1);
        for i_bp = 1 : size(mean_v,3)
            v_bp = squeeze(all_v(:,:,i_bp,:));
            mean_v(:,:,i_bp) = nanmean(v_bp,3);
            
            a_bp = squeeze(all_a(:,:,i_bp,:));
            mean_a(:,:,i_bp) = nanmean(a_bp,3);
                        
        end
        
        mean_mcpAngle = NaNcircMean(all_mcpAngle,-pi,pi,2);
        mean_pipAngle = NaNcircMean(all_pipAngle,-pi,pi,2);
        mean_digAngle = NaNcircMean(all_digitAngle,-pi,pi,2);
        meanTrajectory = nanmean(allTrajectories,4);
        
%         mean_endPts = nanmean(all_endPts,3);

        sessionSummaryName = [ratID '_' sessionDate '_kinematicsSummary.mat'];
        
        save(sessionSummaryName,'bodyparts','meanTrajectory','mean_v','mean_a','mean_mcpAngle','mean_pipAngle','mean_digAngle','all_endPts')
        
    end
    
end