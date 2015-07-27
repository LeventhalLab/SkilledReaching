%% Create Fine Motor Movement Data
% Script guides user in placing specific markers on rat's paw and records
% their position in 8 consecutive frames, equally spaced within the 40
% frames that follow the start frame. Uses raw video recordings of trial
% made each day, and proceeds until all trials for all days are marked for
% the chosen rat.
%
%% Input
% * Rat's raw data folder (selected during script execution)
% * Start frame (also selected during script execution, defined as the
% first frame in which the rat's complete paw has passed the slot)
%
%% Output
% # RatData : Structure array containing the following fields
%
% * DateFolders: Listing of the paths of all date folders in rat's raw data folder
% * VideoFiles: Structural array containing info about all video files
% (.avi files) in a given date folder. Fields include name, data, bytes,
% isdir, datenum, ManualStartFrame (manually determined start frame), AutomaticTriggerFrame
% (automatically determined trigger frame by identifyTriggerFrame function 
% in createManualPawData script, may be removed later), AutomaticPeakFrame 
% (automatically determined peak frame by identifyTriggerFrame function 
% in createManualPawData script, may be removed later), Agree (0 if manual
% start frame and automatic peak frame do not agree, 1 if 
% they do), ROI_Used, Paw_Preference (encodes previous manually determined
% information about paw used in video, dominant/marked or non-dominant/unmarked)
% * Accuracy: Average accuracy of identifyTriggerFrame function for a given
% session, may be removed later

%% Open rat's raw data folder
%     clc;
clear;
uiwait(msgbox('Please navigate to your My Documents folder for saving data locally','modal'));
LocalSaveFolder = uigetdir('C:\Users');
uiwait(msgbox('Please select the rat''s RAW DATA FOLDER','modal'));
RatRawDataDirPath = uigetdir('\\172.20.138.143\RecordingsLeventhal04\SkilledReaching');
RatRawDataLookUp = dir(RatRawDataDirPath);
[pathstr,name,ext] = fileparts(RatRawDataDirPath);
RatID = pathstr(end-4:end);
uiwait(msgbox('Please select the SESSION (I.E. DATE) you would like to analyze','modal'));
    RatSessDir = uigetdir(RatRawDataDirPath);
    SessionName = RatSessDir((end-8):(end-1));


try
    PawPointFilename = fullfile(pathstr,[RatID '-processed'],[RatID 'Session' SessionName 'PawPointFiles.mat']);
    LocalPawPointFilename = fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName,[RatID 'Session' SessionName 'PawPointFiles.mat']);
    try
        fprintf('\nLoading local data\n');
        load(LocalPawPointFilename);
    catch      
        fprintf('\nLoading NAS data\n');
        load(PawPointFilename);
    end 
    AllRatDateFolders = {RatData.DateFolders}';
    SessNum = find(strcmpi(AllRatDateFolders,RatSessDir)==1);
%     try 
% %         VidReaderFileList = {RatData(SessNum).VideoFiles.Object}';
%     catch
%         for j = 1:(length(RatData(SessNum).VideoFiles));
%         fprintf('Working on video %d out of %d\n',j,(length(RatData(SessNum).VideoFiles)));
%         video = fullfile(RatData(SessNum).DateFolders,RatData(SessNum).VideoFiles(j).name);
% %         RatData(SessNum).VideoFiles(j).Object = VideoReader(video);
%         VidReaderFileList(j) = VideoReader(video);
%         end
%     end
catch
%% Pull video files for later use

% j = 1;
% for i = 1:length(RatRawDataLookUp)
%     startIndex = regexpi(RatRawDataLookUp(i).name,'[.]');
%     if ~isempty(startIndex);
%         DeleteIndex(j) = 1;
%         j = j+1;
%     else
%         DeleteIndex(j) = 0;
%         j = j+1;
%     end
% end
m = 1;
% RatData().DateFolders = zeros((length(RatRawDataLookUp)-3),1);
% RatData().VideoFiles = zeros((length(RatRawDataLookUp)-3),1);
% for iDate = 1:(length(RatRawDataLookUp))
%     fprintf('Working on folder %d out of %d\n',iDate,(length(RatRawDataLookUp)));
%     if DeleteIndex(iDate) == 0;
    RatData(m).DateFolders = RatSessDir;
    RatData(m).VideoFiles = dir(fullfile(RatData(m).DateFolders,'*.avi'));
%     m = m+1;
%     end
% end

%     PawPointFilename = fullfile(pathstr,[RatID '-processed'],[RatID 'PawPointFiles.mat']);
%     save(PawPointFilename);
    % Make VideoReader Objects for all the videos of a given session

%     uiwait(msgbox('Please select the SESSION (I.E. DATE) you would like to analyze','modal'));
%     RatSessDir = uigetdir(RatRawDataDirPath);
%     SessionName = RatSessDir((end-8):(end-1));

    PawPointFilename = fullfile(pathstr,[RatID '-processed'],[RatID 'Session' SessionName 'PawPointFiles.mat']);
    LocalDataFolderStatus = exist(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName),'file');
    while LocalDataFolderStatus == 0;
        mkdir(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName));
        LocalDataFolderStatus = exist(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName),'file');
    end
    LocalPawPointFilename = fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName,[RatID 'Session' SessionName 'PawPointFiles.mat']);
    AllRatDateFolders = {RatData.DateFolders}';
    SessNum = find(strcmpi(AllRatDateFolders,RatSessDir)==1);
    
%     for j = 1:(length(RatData(SessNum).VideoFiles));
%         fprintf('Working on video %d out of %d\n',j,(length(RatData(SessNum).VideoFiles)));
%         video = fullfile(RatData(SessNum).DateFolders,RatData(SessNum).VideoFiles(j).name);
% %         RatData(SessNum).VideoFiles(j).Object = VideoReader(video);
%         VidReaderFileList(j) = VideoReader(video);
%     end
   ProcessedDataFolder = strrep(RatSessDir,'-rawdata','-processed');
   uiwait(msgbox('Please select the .csv file with the video scores for this session','modal'));
   [CSVfilename,CSVpath] = uigetfile(fullfile(ProcessedDataFolder,'*.csv'),'Select .csv file with video scores');
   [nums,txt,raw] = xlsread(fullfile(CSVpath,CSVfilename));
   [r,c] = size(raw);
   
   o = 1;
   p = 1;
   try
       for n = 1:length(nums)
       if isnumeric(nums(n,2)) && isnan(nums(n,2))== 0;
           if (isnumeric(nums(n,3)) && isnan(nums(n,3)) == 0)
               RatData(SessNum).VideoFiles(o).ManualStartFrame = nums(n,3);
               o = o+1;
           else 
              RatData(SessNum).VideoFiles(o).ManualStartFrame = NaN;
              o = o+1; 
           end
           RatData(SessNum).VideoFiles(p).Score = nums(n,2);
           p = p + 1;      
       end
       end
   catch
   end
   

end

LocalDataFolderStatus = exist(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName),'file');
if LocalDataFolderStatus > 0;
    save(LocalPawPointFilename,'-v7.3');
else
    mkdir(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName));
    save(LocalPawPointFilename,'-v7.3');
end
save(PawPointFilename,'-v7.3');

%% Start marking function. Display dialog box indicating which marker and option for indicating not visible and instructions.
% AnalysisRound = 1;
% if AnalysisRound ~= 1;
uiwait(msgbox('Please select the VIDEO or TRIAL you would like to start analysis from','modal'));
VideoFilepath = fullfile(RatSessDir,'*.avi');
[VideoName,VideoFilePathName,~] = uigetfile(VideoFilepath);
VideoFileList = {RatData(SessNum).VideoFiles.name}';
iVideo = find(strcmpi(VideoFileList,VideoName)==1);
% elseif AnalysisRound == 1;
%     iVideo = 1; %:length(RatData(SessNum).VideoFiles); %1:length(RatData)
%     %for iVideo = 1; %1:length(RatData(i).VideoFiles);
%     end
VideoCount = 1;

for iVideo = iVideo:length(RatData(SessNum).VideoFiles);
    if rem(VideoCount,5) == 0;
        message = sprintf('\nWould you like to stop marking?\nIf yes, please type ''Yes'', with apostrophes\nIf no, please type ''No'', with apostrophes: ');    
        x = input(message);
    if strcmpi(x,'Yes');
        break
    else
    end
    end
    if RatData(SessNum).VideoFiles(iVideo).Score == 1 || RatData(SessNum).VideoFiles(iVideo).Score == 7
        VideoCount = VideoCount+1;
        fprintf('\nWorking on trial %d out of %d for this session\n',iVideo,length(RatData(SessNum).VideoFiles));
        try
            StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
            if isempty(StartFrame) || isnan(StartFrame)
                RatData(SessNum).VideoFiles(iVideo).ManualStartFrame = GUIcreateFrameStart_2015_06_19(RatData,SessNum,iVideo);
                %             ManualStartFrame(iVideo) = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
                StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
            end
        catch
            RatData(SessNum).VideoFiles(iVideo).ManualStartFrame = GUIcreateFrameStart_2015_06_19(RatData,SessNum,iVideo);
            StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
        end
        %     save(PawPointFilename);
        %     MarkerNum = input('Please enter the number of the marker you would like to start from. If you would like to start from the beginning, please enter 1: ');
        %     temp = GUIcreateManualPoints_2015_06_19(RatData,SessNum,iVideo,StartFrame,'interval',5,'marker_number',MarkerNum);
        temp = GUIcreateManualPoints_2015_06_19(RatData,SessNum,iVideo,StartFrame,'interval',8);
        close all;
        fprintf('\nDone with marking\n');
        RatData(SessNum).VideoFiles(iVideo).Paw_Points_Tracking_Data = CumMarkedMarkersLocations;
        %     FrameInfo = FrameInfo(:,[1:10 58]);
        %     RatData(SessNum).VideoFiles(iVideo).Paw_Points_Frame_Data = FrameInfo;
        fprintf('\nMarking data written to RatData file\n');
        %     AnalysisRound = AnalysisRound+1;
        %end
        fprintf('\nSaving data locally\n');
        save(LocalPawPointFilename,'RatData','-v7.3');
        
        if rem(VideoCount,10) == 0;
            fprintf('\nSaving data to NAS\n');
            save(PawPointFilename,'RatData','-v7.3');
        end
        %         msgbox('Saving all data to NAS and local folder. Please wait, this may take some time','modal')
        %         if LocalDataFolderStatus > 0;
        %             save(LocalPawPointFilename,'-v7.3');
        %         else
        %             mkdir(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName));
        %             save(LocalPawPointFilename,'-v7.3');
        %         end
        %         save(PawPointFilename,'-v7.3');
        %     end
    else
        RatData(SessNum).VideoFiles(iVideo).Paw_Points_Tracking_Data = [];
    end
end


fprintf('\nMarking complete\n');
fprintf('\nSaving data locally\n');
save(LocalPawPointFilename,'RatData','-v7.3');
fprintf('\nSaving data to NAS\n');
save(PawPointFilename,'RatData','-v7.3');

%%
% If left click is made after placing marker, record marker position
% externally.

% If right click is made after placing marker, prompt user to redo last
% marker

% If user selects Yes, display last marker placement dialog box, go
% back 1 in marking function and overwrite marker position data.

% If user selects No, continue with marker placement.

%% Save marker position data externally


%% Old code
% %% Reset
% close all
% clear all
% clc
%
% %% Pick of the dates from the processed folder
% disp('Select the directory for which you want to selec the manual points');
% RatDir = uigetdir('\\172.20.138.142\RecordingsLeventhal3\SkilledReaching');
%
% %% Begin Circling Through Data
% RatLookUp = dir(fullfile(RatDir));
% dates = {RatLookUp(3:end).name}.';%This pulls all the dates in the directory
%
%
%
%
%     for i = 1:length(dates)
%
%
%       videoFile = char(fullfile(RatDir,dates(i)));
%       [pathstr,name,ext] = fileparts(videoFile);
%
%       frameStart = 560;
% %       if i == 2
% %           frameStart =287;
% %            elseif i == 3
% %           frameStart = 292;
% %           elseif i == 4
% %           frameStart = 295;
% %           elseif i == 5
% %           frameStart = 290;
% %           elseif i == 6
% %           frameStart = 288;
% %           elseif i == 6
% %           frameStart = 288;
% %           elseif i == 8
% %           frameStart = 287;
% %           elseif i == 18
% %           frameStart = 280;
% %           elseif i == 20
% %           frameStart = 280;
% %           elseif i == 23
% %           frameStart = 272;
% %           elseif i == 25
% %           frameStart = 262;
% %           elseif i == 26
% %           frameStart = 280;
% %           elseif i == 28
% %           frameStart = 275
% %           elseif i == 32
% %           frameStart = 270;
% %           elseif i == 33
% %           frameStart = 280;
% %           elseif i == 34
% %           frameStart = 280
% %           elseif i == 35
% %           frameStart = 280;
% %           elseif i == 36
% %           frameStart = 280;
% %           else
% %           frameStart = 300;
% %
% %       end
%
%       [pellet_center_x, pellet_center_y,manual_paw_centers,mcp_hulls,mph_hulls,dph_hulls] = createManualPoints (videoFile,frameStart)
%        mkdir(fullfile(pathstr,'manual_trials'));
%       save(fullfile(pathstr,'manual_trials',name),'pellet_center_x','pellet_center_y','manual_paw_centers','mcp_hulls','mph_hulls','dph_hulls');
%
%
%     end

%% More old code
%for iDate = 1:(length(RatRawDataLookUp)-3)
%         for iVideo = 1:(length(RatData(iDate).VideoFiles));
%             fprintf('Working on video %d out of %d\n',iVideo,(length(RatData(iDate).VideoFiles)));
%             video = fullfile(RatData(iDate).DateFolders,RatData(iDate).VideoFiles(iVideo).name);
%             RatData(iDate).VideoFiles(iVideo).Object = VideoReader(video);
%             %clc;
%         end
%     %  Using code commented out above causes following error: Caught
%     %  "std::exception" Exception message is: Message Catalog MATLAB:services was not loaded from the file. Please check file location, format or contents
%     %  And you cannot open variables from the workspace. Looked online and it
%     %  said this is likely because Matlab is trying to open too many files at
%     %  once.
% end
% %% Load video file, determine start frame. Save start frames externally.
% %for i = [27 38]; %1: length(RatData);
% i = 27;
%     CSVfile = dir(fullfile(pathstr,[sprintf('%s',RatID) '-processed'],sprintf('%s',RatData(i).DateFolders(end-14:end)),'*.csv'));
%     cd(fullfile(pathstr,[sprintf('%s',RatID) '-processed'],sprintf('%s',RatData(i).DateFolders(end-14:end))));
%     fileID = fopen(CSVfile(2).name,'r');
%     formatSpec = '%d %*d %d %s';
%     CSVfile = textscan(fileID,formatSpec,'HeaderLines',1,'Delimiter',',','CollectOutput',1);
%     DomPawOrNo = cell(CSVfile{1,2});
%     AutomaticTriggerFrame = zeros(length(RatData(i).VideoFiles),1);
%     AutomaticPeakFrame = zeros(length(RatData(i).VideoFiles),1);
%     cd('C:\Users\Administrator\Documents\GitHub\SkilledReaching');
%     meta_ROI_to_find_trigger_frame = [0030         0570         0120         0095
%         1880         0550         0120         0095];
%     AccuracyData = zeros(1,length(RatData(i).VideoFiles));
%     for iVideo = [1,6,7,11,13:20,22:27,30:37,39:48];%1:length(RatData(i).VideoFiles);
%         fprintf('Working on trial %d out of %d\n',iVideo,length(RatData(i).VideoFiles));
%         RatData(i).VideoFiles(iVideo).ManualStartFrame = CSVfile{1,1}(iVideo,2);
%         if RatData(i).VideoFiles(iVideo).ManualStartFrame == 0;
%             RatData(i).VideoFiles(iVideo).ManualStartFrame = NaN;
%         end
%         if iVideo == 1 && (isnan(RatData(i).VideoFiles(iVideo).ManualStartFrame) == 0);
%             video = strrep(fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(iVideo).name),'\','\\');
%             pawpref_master = input(sprintf('Please input paw preference for video file \n%s: ',video));
%             video = fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(iVideo).name);
%         end
%         if ischar(DomPawOrNo{iVideo}) && (isempty(DomPawOrNo{iVideo})==0);
%             if strcmp(DomPawOrNo{iVideo},'non-dominant paw') == 1;
%                 if strcmpi(pawpref_master,'right') == 1;
%                     pawpref = 'left';
%                 elseif strcmpi(pawpref_master,'left') == 1;
%                     pawpref = 'right';
%                 end
%             else
%                 pawpref = pawpref_master;                
%             end
%         else
%             pawpref = pawpref_master;
%         end
%         
%         [AutomaticTriggerFrame(iVideo), AutomaticPeakFrame(iVideo)] = identifyTriggerFrame(RatData(i).VideoFiles(iVideo).Object,pawpref,'trigger_roi',meta_ROI_to_find_trigger_frame,'firstdiffthreshold',240);
%         RatData(i).VideoFiles(iVideo).AutomaticTriggerFrame = AutomaticTriggerFrame(iVideo);
%         RatData(i).VideoFiles(iVideo).AutomaticPeakFrame = AutomaticPeakFrame(iVideo);
%         k = 1;
%         RatData(i).VideoFiles(iVideo).Agree = 1;
%         while (abs(RatData(i).VideoFiles(iVideo).AutomaticPeakFrame - RatData(i).VideoFiles(iVideo).ManualStartFrame) > 5) || isnan(RatData(i).VideoFiles(iVideo).AutomaticPeakFrame);
%             im = read(RatData(i).VideoFiles(iVideo).Object,RatData(i).VideoFiles(iVideo).ManualStartFrame);
%             if k == 3;
%                 RatData(i).VideoFiles(iVideo).Agree = 0;
%                 break                
%             end
%             if strcmpi(pawpref,'right') == 1;
%                 dbstop createManualPawDataVPedits2015_05_08.m;
%                 uiwait(msgbox(sprintf('There is a significant discrepancy between the automatically determined start frame (%d) and the manually determined start frame (%d).\nPlease draw a rectangle over the correct ROI in the following image.\nThe ROI should be located in the left mirror',...
%                     RatData(i).VideoFiles(iVideo).AutomaticPeakFrame,...
%                     RatData(i).VideoFiles(iVideo).ManualStartFrame),'modal'));
%                 imshow(im);
%                 meta_ROI_to_find_trigger_frame(1,:) = getrect;
%                 close;
%                 k = k+1;
%             elseif strcmpi(pawpref,'left') == 1;
%                 dbstop createManualPawDataVPedits2015_05_08.m;
%                 uiwait(msgbox(sprintf('There is a significant discrepancy between the automatically determined start frame (%d) and the manually determined start frame (%d).\nPlease draw a rectangle over the correct ROI in the following image.\nThe ROI should be located in the right mirror',...
%                     RatData(i).VideoFiles(iVideo).AutomaticPeakFrame,...
%                     RatData(i).VideoFiles(iVideo).ManualStartFrame),'modal'));
%                 imshow(im);
%                 meta_ROI_to_find_trigger_frame(2,:) = getrect;
%                 close;
%                 k = k+1;
%             end
%             meta_ROI_to_find_trigger_frame = round(meta_ROI_to_find_trigger_frame);
%             [AutomaticTriggerFrame(iVideo), AutomaticPeakFrame(iVideo)] = identifyTriggerFrame(RatData(i).VideoFiles(iVideo).Object,pawpref,'trigger_roi',meta_ROI_to_find_trigger_frame,'firstdiffthreshold',240);
%             RatData(i).VideoFiles(iVideo).AutomaticTriggerFrame = AutomaticTriggerFrame(iVideo);
%             RatData(i).VideoFiles(iVideo).AutomaticPeakFrame = AutomaticPeakFrame(iVideo);
%         end
%         RatData(i).VideoFiles(iVideo).ROI_Used = meta_ROI_to_find_trigger_frame;
%         RatData(i).VideoFiles(iVideo).Paw_Preference = pawpref;
%         AccuracyData(iVideo) = RatData(i).VideoFiles(iVideo).Agree;
%         
%         
%         % StartFrame(i,j) = GUIcreateFrameStartVP2(RatData,i,j,RatDir,RatLookUp,RatID);
%         
%         
%         % Load video, save video data(frames, frame rate, height, width, etc.), and play it
%         %         vidObj = VideoReader(fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name));
%         %         vidHeight = vidObj.Height;
%         %         vidWidth = vidObj.Width;
%         %         s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
%         %             'colormap',[]);
%         %         k = 1;
%         %         while hasFrame(vidObj)
%         %             s(k).cdata = readFrame(vidObj);
%         %             k = k+1;
%         %         end
%         %         hf = figure;
%         %         set(hf,'position',[0 0 vidObj.Width vidObj.Height]);
%         %         set(gca,'units','pixels');
%         %         set(gca,'position',[0 0 vidObj.Width vidObj.Height]);
%         %         movie(hf,s,1,vidObj.FrameRate);
%     end
%     RatData(i).Accuracy = 100.*(mean(AccuracyData,2));