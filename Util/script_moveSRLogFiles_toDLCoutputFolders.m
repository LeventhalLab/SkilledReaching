% script_moveSRLogFiles_toDLCoutputFolders

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';
sharedX_DLCoutput_path = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/DLC output/';

cd(labeledBodypartsFolder)

ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 35 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    rat_vidRootPath = fullfile(vidRootPath,ratID);
    rat_sharedX_DLCoutput_path = fullfile(sharedX_DLCoutput_path,ratID);
    rat_labeledBodypartsFolder = fullfile(labeledBodypartsFolder,ratID);
    
    for iSession = 1 : numSessions
        
        session_vidRootPath = fullfile(rat_vidRootPath,sessionDirectories{iSession});
        session_sharedX_DLCoutput_path = fullfile(rat_sharedX_DLCoutput_path,sessionDirectories{iSession});
        session_labeledBodypartsFolder = fullfile(rat_labeledBodypartsFolder,sessionDirectories{iSession});
        if ~isfolder(session_vidRootPath)
            continue; 
        end
        
        cd(session_vidRootPath);
        
        logFiles = dir('*.log');
        
        for i_log = 1 : length(logFiles)
            
            sharedX_DLC_log = fullfile(session_sharedX_DLCoutput_path,logFiles(i_log).name);
            DLC_log = fullfile(session_labeledBodypartsFolder,logFiles(i_log).name);
            
            copyfile(logFiles(i_log).name,sharedX_DLC_log);
            copyfile(logFiles(i_log).name,DLC_log);
        end
        
    end
    
end