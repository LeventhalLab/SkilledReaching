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

vidView = {'direct','right','left'};
numViews = length(vidView);

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
        cd(fullSessionDir);
        
        % find the pawTrajectory files
        pawTrajectoryList = dir('R*3dtrajectory.mat');
        numTrials = length(pawTrajectoryList);
        
        for iTrial = 1 : numTrials
            
            load(pawTrajectoryList(iTrial).name);
            d = distFromPellet(pawTrajectory,bodyparts,frameRate,frameTimeLimits,triggerTime);
            
        end
        
    end
    
end