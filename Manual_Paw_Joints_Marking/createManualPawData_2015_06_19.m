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
clc;
clear;
uiwait(msgbox('Please select the rat''s raw data folder','modal'));
RatRawDataDirPath = uigetdir('\\172.20.138.143\RecordingsLeventhal04\SkilledReaching');
RatRawDataLookUp = dir(RatRawDataDirPath);
[pathstr,name,ext] = fileparts(RatRawDataDirPath);
RatID = pathstr(end-4:end);

%% Pull video files for later use
RatData().DateFolders = zeros(length(RatRawDataLookUp)-3);
RatData().VideoFiles = zeros(length(RatRawDataLookUp)-3);
for iDate = 1:(length(RatRawDataLookUp)-3)
    fprintf('Working on folder %d out of %d\n',iDate,(length(RatRawDataLookUp)-3));
    RatData(iDate).DateFolders = fullfile(RatRawDataDirPath,RatRawDataLookUp(iDate+3).name);
    RatData(iDate).VideoFiles = dir(fullfile(RatData(iDate).DateFolders,'*.avi'));    
end

PawPointFilename = fullfile(pathstr,[RatID '-processed'],[RatID 'PawPointFiles.mat']);
save(PawPointFilename);
% Make VideoReader Objects for all the videos of a given session
uiwait(msgbox('Please select the session you would like to analyze','modal'));
RatSessDir = uigetdir(RatRawDataDirPath);
AllRatDateFolders = {RatData.DateFolders}';
SessNum = find(strcmpi(AllRatDateFolders,RatSessDir)==1);

for j = 1:(length(RatData(SessNum).VideoFiles));
    fprintf('Working on video %d out of %d\n',j,(length(RatData(SessNum).VideoFiles)));
    video = fullfile(RatData(SessNum).DateFolders,RatData(SessNum).VideoFiles(j).name);
    RatData(SessNum).VideoFiles(j).Object = VideoReader(video);
end
save(PawPointFilename);
%% for iDate = 1:(length(RatRawDataLookUp)-3)
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
%% Start marking function. Display dialog box indicating which marker and option for indicating not visible and instructions.

for iVideo = 1:length(RatData(SessNum).VideoFiles); %1:length(RatData)
    %for iVideo = 1; %1:length(RatData(i).VideoFiles);
    fprintf('Working on trial %d out of %d for this session\n',iVideo,length(RatData(SessNum).VideoFiles));
    try
        StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
        if isempty(StartFrame)
            RatData(SessNum).VideoFiles(iVideo).ManualStartFrame = GUIcreateFrameStart_2015_06_19(RatData,SessNum,iVideo);
            StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
        end
    catch
        RatData(SessNum).VideoFiles(iVideo).ManualStartFrame = GUIcreateFrameStart_2015_06_19(RatData,SessNum,iVideo);
        StartFrame = RatData(SessNum).VideoFiles(iVideo).ManualStartFrame;
    end
    save(PawPointFilename);
    temp = GUIcreateManualPoints_2015_06_19(RatData,SessNum,iVideo,StartFrame,'interval',5);
    disp('Done with marking');
    RatData(SessNum).VideoFiles(iVideo).Paw_Points_Tracking_Data = CumMarkedMarkersLocations;
    RatData(SessNum).VideoFiles(iVideo).Paw_Points_Frame_Data = FrameInfo;
    disp('Marking data written to RatData file');
    %end
    save(PawPointFilename);
end

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