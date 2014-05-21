function checkData(RatDir)
% Run without any input to select a folder
if(nargin == 0)
    RatDir = uigetdir('\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project');
end
% Go to R00##-rawdata
Data = sprintf('%s-rawdata',RatDir(end-4:end));
RatLookUp = dir(fullfile(RatDir,Data));
dates = {RatLookUp(4:end).name}.';

% Creates cell array with header to hold info
checkList = cell(length(dates)+1,4);
checkList{1,1} = 'Directory'; checkList{1,2} = 'Videos Processed?';
checkList{1,3} = 'XYZ Data?'; checkList{1,4} = 'Scored?';
checkList{1,5} = 'Frame rate'; checkList{1,6} = 'Trigger frame';

% Iterate through each date in the rawdata folder
for i = 1:length(dates)
   date = dates{i};
   currDir = fullfile(RatDir,Data,date);
   dateLookUp = dir(currDir);
   filenames = {dateLookUp(:).name}.'; % List of every file in the folder
   checkList{i+1,1} = fullfile(currDir); % Directory name 
   checkList{i+1,2} = and(and(any(strcmp('left',filenames)),... %Processed?
       any(strcmp('center',filenames))),any(strcmp('right',filenames)));
   checkList{i+1,3} = any(strcmp('_xyzData',filenames)); %contains XYZ data?
   checkList{i+1,4} = ~isempty(dir(fullfile(currDir,'*.csv')));
   
   %%% This part is kind of ugly because some folders have videos that get
   %%% formatted differently when read into matlab for some reason
   vids = dir(fullfile(currDir,'*.avi'));
   if(length(vids)==1)
        vidRead = VideoReader(fullfile(currDir,vids(1).name));
        checkList{i+1,5} = vidRead.FrameRat;
   elseif(length(vids)>1)
        vidRead = VideoReader(fullfile(currDir,vids(2).name));
        checkList{i+1,5} = vidRead.FrameRate;
   else
       checkList{i+1,5} = 0;
   end
   
   logInfo = readLogData(currDir);
   % In some folders, preTriggerFrames is an array of numbers for some
   % reason, so I'm ignoring those
   if(length(logInfo.preTriggerFrames)==1)
       checkList{i+1,6} = round(logInfo.preTriggerFrames);
   else
       checkList{i+1,6} = 0;
   end
end

% Writes out file name as R00##-info.csv

csvname = sprintf('%s-info.csv', fullfile(RatDir,RatDir(end-4:end))); 
fid = fopen(csvname,'wt');
[row,~] = size(checkList);
fprintf(fid,'%s, %s, %s, %s, %s, %s\n',checkList{1,:}); % Write Header to file
for r = 2: row
    fprintf(fid,'%s, %d, %d, %d, %d, %d\n',checkList{r,:});
end
fclose(fid);
winopen(csvname);
end
