function status = copyLogToDLCOutput(sessionName,DLCoutput_folder,vidRootPath)

ratID = sessionName(1:5);

vidRatPath = fullfile(vidRootPath,ratID);
vidSessionFolder = fullfile(vidRatPath,sessionName);

cd(vidSessionFolder);
logFiles = dir('*.log');

if isempty(logFiles)
    fprintf('no log file found for %s\n',sessionName);
    return;
end

DLC_session_folder = fullfile(DLCoutput_folder,ratID,sessionName);

fullLogName = fullfile(vidSessionFolder,logFiles(1).name);
fullDestLogName = fullfile(DLC_session_folder,logFiles(1).name);

status = copyfile(fullLogName,fullDestLogName);