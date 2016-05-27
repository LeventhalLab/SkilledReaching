% script_plot_green_3Dtrajectory

sr_ratInfo = get_sr_RatList();

for i_rat = 1 : 1%length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    processed_parentDir = sr_ratInfo(i_rat).directory.processed;

    numSessions = length(sr_ratInfo(i_rat).sessionList);
    
    for iSession = 1 : numSessions
        
        sessionDate = sr_ratInfo(i_rat).sessionList{iSession}(1:8);
        shortDate = sessionDate(5:end);
        
        cd(processed_parentDir);
        processedDataDirList = [ratID '_' sessionDate '*'];
        processedDataDirList = dir(processedDataDirList);
        
        if isempty(processedDataDirList)
            fprintf('no processed data folder for %s, %s\n',ratID, sessionDate)
            continue 
        end
        if length(processedDataDirList) > 1
            fprintf('more than one data folder for %s, %s\n', ratID, sessionDate)
            continue;
        end
        
        processedDir = fullfile(processed_parentDir, processedDataDirList.name);
        
        cd(processedDir);
        
        fullTrackFiles = dir('*_full_track.mat');
        numTrials = length(fullTrackFiles);
        pawData = struct();   % create either a structure array or cell array for all the tracking data and metadata
        for iTrial = 1 : numTrials
            
            trialNum = % WORKING HERE - NEED TO GET THE TRIAL NUMBER FOR THE INDEXED VIDEO AND LOAD THE 3D TRACKING DATA ALONG WITH METADATA
            pawData = load_pawTrackData_DL(processedDir, trialNum);
            
            
        end
        
    end
    
end