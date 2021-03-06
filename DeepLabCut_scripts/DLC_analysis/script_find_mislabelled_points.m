% script_find_mislabelled_points

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20191028.csv');

ratInfo = readtable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 32 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    if istable(ratInfo)
        thisRatInfo = ratInfo(ratInfo_idx,:);
    else
        thisRatInfo = ratInfo(ratInfo_idx);
    end
    if iscell(thisRatInfo.pawPref)
        pawPref = thisRatInfo.pawPref{1};
    else
        pawPref = thisRatInfo.pawPref;
    end
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    switch ratID
        case 'R0159'
            startSession = 5;
            endSession = numSessions;
        case 'R0235'
            startSession = 1;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    
    for iSession = startSession : 1 : endSession
        
        if exist('manually_invalidated_points')
            clear manually_invalidated_points
        end
        
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
        sessionYear = sessionDate(1:4);
        sessionMonth = sessionDate(1:6);
        
        fprintf('working on session %s_%s\n',ratID,sessionDate);
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        cd(fullSessionDir);
        % find all the single trial .mat trajectory files
        trajFiles = dir([ratID '_' sessionDate '_*_3dtrajectory_new.mat']);
        numTrajFiles = length(trajFiles);
        
        for iTrial = 1 : numTrajFiles   
            
            load(trajFiles(iTrial).name);
            
            if ~exist('manually_invalidated_points','var')
                continue
            end
            
            q = squeeze(manually_invalidated_points(:,13,1));
            if any(q)
                fprintf('file: %s, trial index %03d\n',trajFiles(iTrial).name,iTrial)
                q_idx = find(q);
                if any(q_idx < 500)
                    q_idx
                    keyboard
                end
            end
        end
    end
end