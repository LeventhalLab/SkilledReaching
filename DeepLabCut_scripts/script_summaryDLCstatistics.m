% script_summaryDLCstatistics

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';

script_ratInfo_for_deepcut;
ratInfo_IDs = [ratInfo.ratID];

ratFolders = findRatFolders(labeledBodypartsFolder);
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders{i_rat};
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx);
    pawPref = thisRatInfo.pawPref;
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = listFolders([ratID '_*']);
    numSessions = length(sessionDirectories);
    
    for iSession = 1 : numSessions
    
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        
        cd(fullSessionDir);
        
        matList = dir([ratID '_*_3dtrajectory.mat']);
        numTrials = length(matList);
        
        load(matList(1).name);
        
        all_p_direct = zeros(size(direct_p,1),size(direct_p,2),numTrials);
        all_p_mirror = zeros(size(mirror_p,1),size(mirror_p,2),numTrials);
        
        for iTrial = 1 : numTrials
            
            load(matList(iTrial).name);
            
            all_p_direct(:,:,iTrial) = direct_p;
            all_p_mirror(:,:,iTrial) = mirror_p;
            
        end
        
        mean_p_direct = mean(all_p_direct,3);
        mean_p_mirror = mean(all_p_mirror,3);
        
        % TO DO:
        %   1) set up a sheet to make a mean_p heat map for the direct and
        %   mirror views for each session
        %   2) label the vertical axis with the bodyparts instead of
        %   numbers
        %   3) make at least one colorbar
    end
    
end
% mean p-value as a function of frame number