% script_summarizeReachEndPoints

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';

% need some sort of flag for which day is which trial type - e.g., laser
% day 1, occlusion day 5, last day of training, etc.

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');

ratInfo = ratInfoFromExcel(xlfname, 'well learned');

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = dir([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    for iSession = 1 : numSessions
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories(iSession).name);
        
        if ~isfolder(fullSessionDir)
            continue;
        end
        cd(fullSessionDir);
        C = textscan(sessionDirectories(iSession).name,[ratID '_%8c']);
        sessionDate = C{1};
        
        % we want to compare reach endpoints for each rat on the last day
        % of retraining, first day of laser, last day of laser, first day
        % of occlusion, last day of occlusion (as a first pass, I think).
        
        % NEED TO CONSIDER HOW TO ORGANIZE THESE RESULTS INTO VARIOUS
        % ARRAYS
        
        % ALSO, NEED TO REVIEW PAW IDENTIFICATION PROBABILITIES FOR EACH
        % RAT IN THE MIRROR VIEWS