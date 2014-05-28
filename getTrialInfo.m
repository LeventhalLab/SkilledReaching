function trialInfo = getTrialInfo(workingDirectory)
% Creates a structure trialInfo which contains info from R00##-info.csv 
% for a particular rat and trial day. Make sure the .csv file is up to
% date befor running.
% workingDirectory is the folder containing data and videos from a specific
% date, i.e. \\141.214.45.212\RecordingsLeventhal1\Skilled Reaching
% Project\R00##\R00##-rawdata\R00##_YYYYmmdd
%
% trialInfo: 
    % directory - directory name, same as workingDirectory (string)
    % isProcessed - have the videos been processed? (boolean)
    % hasXyzData - has the data been analyzed? (boolean)
    % isScored - are the trials scored? (boolean)
    % frameRate - video frame rate (double)
    % triggerFrame - frame that camera is triggered (double)

[mainDirectory,~,~] = fileparts(workingDirectory);
[mainDirectory,~,~] = fileparts(mainDirectory);
infoLookup =  dir(fullfile(mainDirectory,'*.csv'));
csvfile = fullfile(mainDirectory, infoLookup.name);

fid = fopen(csvfile);
readInfo=textscan(fid,'%s %f %f %f %f %f','delimiter',',','HeaderLines',1);
for i = 1:length(readInfo{1})
    if(strcmp(readInfo{1}(i),workingDirectory) == 1)
        trialInfo = struct('directory',readInfo{1}(i),'isProcessed',...
            readInfo{2}(i),'hasXyzData',readInfo{3}(i),'isScored',...
            readInfo{4}(i),'frameRate',readInfo{5}(i),'triggerFrame',...
            readInfo{6}(i));
        break;
    end
end
fclose(fid);