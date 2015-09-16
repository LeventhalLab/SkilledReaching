%% Create Fine Motor Movement Data
% Script guides user in placing specific markers on rat's paw and records
% their position in 8 consecutive frames, equally spaced within the 40
% frames that follow the start frame. Uses raw video recordings of trial
% made each day, and proceeds until all trials with first-time successful
% reaches are marked for the chosen rat and session.
%
%% Input
% * None, prompts appear during script execution asking user for needed
% data
%
%% Output
% # RatData : Structure array containing the following fields
%
% * DateFolders: The paths to the session folder in rat's raw data folder
% * VideoFiles: Structural array containing info about all video files
% (.avi files) in a given date folder. Fields include name, data, bytes,
% isdir, datenum, ManualStartFrame (manually determined start frame, loaded
% from .csv file for a given rat and session in rat's processed data
% folder). 

%% Select rat and session for analysis
clear;
% Set local save folder. Creates folders and subfolders:
% Paw_Point_Marking_Data > RatID > Session.
uiwait(msgbox('Please navigate to your My Documents folder for saving data locally','modal'));
LocalSaveFolder = uigetdir('C:\Users');

% Select rat and session for analysis.
uiwait(msgbox('Please select the rat''s RAW DATA FOLDER','modal'));
RatRawDataDirPath = uigetdir('\\172.20.138.143\RecordingsLeventhal04\SkilledReaching');
RatRawDataLookUp = dir(RatRawDataDirPath);
[pathstr,name,ext] = fileparts(RatRawDataDirPath);
RatID = pathstr(end-4:end);
uiwait(msgbox('Please select the SESSION (I.E. DATE) you would like to analyze','modal'));
RatSessDir = uigetdir(RatRawDataDirPath);
SessionName = RatSessDir((end-8):(end-1));

% Attempt to load previously saved data, first from local save folder, then
% from NAS. PawPointFilename is the path to the NAS data,
% LocalPawPointFilename is the path to the local data. If data doesn't
% exist, see "catch" below.
try
    PawPointFilename = fullfile(pathstr,[RatID '-processed'],[RatID 'Session' SessionName 'PawPointFiles.mat']);
    LocalPawPointFilename = fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName,[RatID 'Session' SessionName 'PawPointFiles.mat']);
    try
        fprintf('\nLoading local data\nPlease wait, this may take some time.\n');
        load(LocalPawPointFilename);
    catch
        fprintf('\nLoading NAS data\nPlease wait, this may take some time.\n');
        load(PawPointFilename);
    end
    
    % Determine session number from list of folders in data structure (this
    % is leftover from the old code, the session number will always be 1
    % because the current data structure only contains data for one session
    % per file).
    AllRatDateFolders = {RatData.DateFolders}';
    SessNum = find(strcmpi(AllRatDateFolders,RatSessDir)==1);

% If data can't be loaded from either NAS or local save folder, create the
% data structure (RatData, with fields DateFolders, which is the path to
% the session folder, and VideoFiles, which is where all the data is
% stored).
catch  
    m = 1;
    RatData(m).DateFolders = RatSessDir;
    RatData(m).VideoFiles = dir(fullfile(RatData(m).DateFolders,'*.avi'));
    
    PawPointFilename = fullfile(pathstr,[RatID '-processed'],[RatID 'Session' SessionName 'PawPointFiles.mat']);
    
    % Check to see if local folder structure exists for saving the data to
    % (Local Save Folder > Paw_Point_Marking_Data > RatID > Session)
    LocalDataFolderStatus = exist(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName),'file');
    while LocalDataFolderStatus == 0;
        mkdir(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName));
        LocalDataFolderStatus = exist(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName),'file');
    end
    
    LocalPawPointFilename = fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName,[RatID 'Session' SessionName 'PawPointFiles.mat']);
    AllRatDateFolders = {RatData.DateFolders}';
    SessNum = find(strcmpi(AllRatDateFolders,RatSessDir)==1);
    
    % Load .csv file with scores and manually determined start frame data
    % from rat's processed data folder. If the score and start frame for a
    % given video is a number, include it in the data structure (start
    % frames were left blank for videos if they didn't exist or were not
    % good for analysis).
    ProcessedDataFolder = strrep(RatSessDir,'-rawdata','-processed');
    uiwait(msgbox('Please select the .csv file with the video scores for this session','modal'));
    [CSVfilename,CSVpath] = uigetfile(fullfile(ProcessedDataFolder,'*.csv'),'Select .csv file with video scores');
    [nums,txt,raw] = xlsread(fullfile(CSVpath,CSVfilename))
    [r,c] = size(raw)
    o = 1;
    p = 1;
    for i=1:length(nums)
        RatData(SessNum).VideoFiles(i).ManualStartFrame = nums(i,3)
        RatData(SessNum).VideoFiles(i).Score = nums(i,2)
    end
    
%     try
%         for n = 1:length(nums)
%             %if isnumeric(nums(n,2)) && isnan(nums(n,2))== 0;
%                 if (isnumeric(nums(n,3)) && isnan(nums(n,3)) == 0)
%                     RatData(SessNum).VideoFiles(o).ManualStartFrame = nums(n,3);
%                     o = o+1
%                 else
%                     RatData(SessNum).VideoFiles(o).ManualStartFrame = NaN;
%                     o = o+1
%                 end
%                 RatData(SessNum).VideoFiles(p).Score = nums(n,2)
%                 p = p + 1
%            % end
%         end
%     catch
  %  end
    
    
end

% Check to see if local save directory exists (in case the data was loaded
% from the NAS and the local directory hadn't yet been created), then save
% the data both locally and to the NAS.
LocalDataFolderStatus = exist(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName),'file');
if LocalDataFolderStatus > 0;
    save(LocalPawPointFilename,'RatData');
else
    mkdir(fullfile(LocalSaveFolder,'Paw_Point_Marking_Data',RatID,SessionName));
    save(LocalPawPointFilename,'RatData');
end
save(PawPointFilename,'RatData');

%% Start marking function. Display dialog box indicating which marker and option for indicating not visible and instructions.

% In case the user would like to continue marking from where he/she left
% off last, the script prompts the user to select which video file they would
% like to start analysis from. 
uiwait(msgbox('Please select the VIDEO or TRIAL you would like to start analysis from','modal'));
VideoFilepath = fullfile(RatSessDir,'*.avi');
[VideoName,VideoFilePathName,~] = uigetfile(VideoFilepath);
VideoFileList = {RatData(SessNum).VideoFiles.name}';
iVideo = find(strcmpi(VideoFileList,VideoName)==1);

% Keep track of number of videos marked
VideoCount = 1;

for iVideo = iVideo:length(RatData(SessNum).VideoFiles);
    %Every 5 videos, script prompts user in command window if they would
    %like to quit marking, so they can stop marking for the day/take a
    %break in between if they would like. 
    if rem(VideoCount,5) == 0;
        message = sprintf('\nWould you like to stop marking?\nIf yes, please type ''Yes'', with apostrophes\nIf no, please type ''No'', with apostrophes: ');
        x = input(message);
        if strcmpi(x,'Yes');
            break
        else
        end
    end
    
    % Currently script is set to load only videos where the rat made a
    % successful reach the first time (score = 1).
    if RatData(SessNum).VideoFiles(iVideo).Score == 1  || RatData(SessNum).VideoFiles(iVideo).Score == 7
        VideoCount = VideoCount+1;
        
        % The trial/video number being marked is displayed in the command
        % window. 
        % NOTE: THIS DOES NOT ALWAYS CORRESPOND TO THE VIDEO NUMBER SHOWN
        % AT THE END OF THE FILENAME (E.G. THE '001' AT THE END OF
        % R0030_20140424_14-37-36_001.avi). VIDEOS ARE DELETED SOMETIMES,
        % SO, FOR EXAMPLE, THE FILE THAT ENDS IN '003' MAY BE THE 2ND VIDEO
        % IN THE LIST. THE SCRIPT WILL DISPLAY THE NUMBER OF THE VIDEO IN
        % THE LIST (I.E. 2, NOT 3 IN THE PREVIOUS SCENARIO). The filename
        % is always displayed in RatData.VideoFiles.name though. 
        fprintf('\nWorking on trial %d out of %d for this session\n',iVideo,length(RatData(SessNum).VideoFiles));
        
        % Load the start frame if available. If not, a window appears with
        % the video's filepath and prompts the user to input the start
        % frame
        try
            StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
            if isempty(StartFrame) || isnan(StartFrame)
                RatData(SessNum).VideoFiles(iVideo).ManualStartFrame = GUIcreateFrameStart_2015_06_19(RatData,SessNum,iVideo); %#ok<*SAGROW>
                StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
            end
        catch
            RatData(SessNum).VideoFiles(iVideo).ManualStartFrame = GUIcreateFrameStart_2015_06_19(RatData,SessNum,iVideo);
            StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
        end
        
        % Mark paw points for video
        temp = GUIcreateManualPoints_2015_06_19(RatData,SessNum,iVideo,StartFrame,'interval',8);
        
        % Close all open windows, save position data written to
        % RatData.Video.Paw_Points_Tracking_Data, save RatData locally and
        % (every 10 videos marked) to NAS. 
        close all;
        fprintf('\nDone with marking\n');
        RatData(SessNum).VideoFiles(iVideo).Paw_Points_Tracking_Data = CumMarkedMarkersLocations;
        fprintf('\nMarking data written to RatData file\n');
        fprintf('\nSaving data locally\nPlease wait, this may take some time.\n');
        save(LocalPawPointFilename,'RatData');        
        if rem(VideoCount,10) == 0;
            fprintf('\nSaving data to NAS\nPlease wait, this may take some time.\n');
            save(PawPointFilename,'RatData');
        end
        
    % If video score is not 1, skip it.     
    else
        RatData(SessNum).VideoFiles(iVideo).Paw_Points_Tracking_Data = [];
    end
end

% After all videos are marked for a given session, or the user decides to
% quit early, save data locally and to NAS.
fprintf('\nMarking complete\n');
fprintf('\nSaving data locally\nPlease wait, this may take some time.\n');
save(LocalPawPointFilename,'RatData');
fprintf('\nSaving data to NAS\nPlease wait, this may take some time.\n');
save(PawPointFilename,'RatData');

%% Developer Notes:
% - Don't load videos (using VideoReader) in any loops, takes far too long.
% Don't include videos or too many images/MATLAB figures in output data
% structure, takes up way too much space.
% - Used to load all folders for all sessions in rat raw data folder to
% data, but noticed some folders weren't relevant, so used the following
% code to prune those. May be useful for some future application, so
% included below:
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
        % m = 1;
        % RatData().DateFolders = zeros((length(RatRawDataLookUp)-3),1);
        % RatData().VideoFiles = zeros((length(RatRawDataLookUp)-3),1);
        % for iDate = 1:(length(RatRawDataLookUp))
        %     fprintf('Working on folder %d out of %d\n',iDate,(length(RatRawDataLookUp)));
        %     if DeleteIndex(iDate) == 0;
        %         RatData(m).DateFolders = RatSessDir;
        %         RatData(m).VideoFiles = dir(fullfile(RatData(m).DateFolders,'*.avi'));
        %         m = m+1;
        %     end
        % end
% - May want to modify code so it doesn't ask you every time you start the
% program where you would like to save the data locally.
% - May want to add functionality to specify which marker you'd like to
% start from as well

%% Old code (from Titus)
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

%% More old code (from Vibin)
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