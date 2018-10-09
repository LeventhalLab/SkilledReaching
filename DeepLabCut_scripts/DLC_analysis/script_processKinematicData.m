% script_processKinematicData

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');

ratInfo = readExcelDB(xlfname, 'well learned');
ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx);
    pawPref = thisRatInfo.pawPref;
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    % load in info about each session
    sessionDBfile = dir([ratID '_sessions*.csv']);
    if isempty(sessionDBfile)
        fprintf('no session database file for %s\n',ratID);
        continue;
    elseif length(sessionDBfile) > 1
        fprintf('more than one session database file for %s\n',ratID);
        continue
    end
    sessionInfo = readExcelDB(sessionDBfile.name,sessionDBfile.name);
    
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    for iSession = 1 : numSessions
    
        fprintf('working on session %s\n', sessionDirectories{iSession});
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
        
    end
    
end
        
        