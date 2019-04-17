%%
%

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
summariesFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output/kinematics_summaries';
ratFolders = findRatFolders(labeledBodypartsFolder);
numRatFolders = length(ratFolders);

for i_rat = 4:17%:numRatFolders
    
    ratID = ratFolders{i_rat};
    ratIDnum = str2double(ratID(2:end));
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    destFolder = fullfile(summariesFolder,ratID);
    if ~exist(destFolder,'dir')
        mkdir(destFolder);
    end
    
    
    cd(ratRootFolder);
    
    sessionDirectories = listFolders([ratID '_2*']);   % all were recorded after the year 2000
    numSessions = length(sessionDirectories);
    
    for iSession = 1:numSessions
        
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1};
        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        sessionDates{iSession} = sessionDate;
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        cd(fullSessionDir);
        
        sessionSummaryName = [ratID '_' sessionDateString '_kinematicsSummary.mat'];
        destName = fullfile(destFolder,sessionSummaryName);
        if exist(sessionSummaryName,'file')
            copyfile(sessionSummaryName,destName);
        end
    end
end