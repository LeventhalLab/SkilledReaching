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
% * RatData: Structure array containing two fields
% 
% # DateFolders: Listing of the paths of all date folders in rat's raw data
% folder
% # VideoFiles: Structural array containing info about all video files
% (.avi files) in a given date folder. Fields include name, data, bytes,
% isdir, and datenum. Only the name data is used in this script.

%% Open rat's raw data folder
clc; 
clear; 
uiwait(msgbox('Please select the rat''s raw data folder','modal'));
RatDir = uigetdir('\\172.20.138.143\RecordingsLeventhal04\SkilledReaching');
RatLookUp = dir(RatDir);
[pathstr,name,ext] = fileparts(RatDir);
RatID = pathstr(end-4:end);

%% Pull video files from all folders for later use
RatData().DateFolders = zeros(length(RatLookUp)-3);
RatData().VideoFiles = zeros(length(RatLookUp)-3);
for i = 1:(length(RatLookUp)-3)
     RatData(i).DateFolders = fullfile(RatDir,RatLookUp(i+3).name);  
     RatData(i).VideoFiles = dir(fullfile(RatData(i).DateFolders,'*.avi'));
     RatData(i).Date = datetime(RatData(i).DateFolders(end-8:end-1),'InputFormat','yyyyMMdd','Format','MM/dd/yy');     
end

%% Load video file, determine start frame. Save start frames externally.
for i = 27:27; %[27 38]; %1: length(RatData);
    for j = 1:1; %1:length(RatData(i).VideoFiles);        
        CSVfile = dir(fullfile(pathstr,[sprintf('%s',RatID) '-processed'],sprintf('%s',RatData(i).DateFolders(end-14:end)),'*.csv'));
        cd(fullfile(pathstr,[sprintf('%s',RatID) '-processed'],sprintf('%s',RatData(i).DateFolders(end-14:end))));
        CSVfile = xlsread(CSVfile(2).name);
        RatData(i).VideoFiles(j).ManualStartFrames = CSVfile(j,3);
        cd('C:\Users\Administrator\Documents\GitHub\SkilledReaching');
        video = fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name);
        RatData(i).VideoFiles(j).Object = VideoReader(video);
        if j == 1 && isnan(RatData(i).VideoFiles(j).ManualStartFrames) == 0;
            pawpref = input(sprintf('Please input paw preference for video file \n%s: ',video));
        end
        if exist('CSVfile(j,4)','var') == 1
            if strcmp(CSVfile(j,4),'non-dominant paw') == 1;
                if strcmpi(pawpref,'right') == 1;
                    pawpref = 'left';
                elseif strcmpi(pawpref,'left') == 1;
                    pawpref = 'right';
                end
            else            
            end
        else
        end
        AutomaticStartFrame = zeros(length(RatData(i).VideoFiles),1);
        [AutomaticStartFrame(i,j), ~] = identifyTriggerFrame(RatData(i).VideoFiles(j).Object,pawpref);
        RatData(i).VideoFiles(j).AutomaticStartFrame = AutomaticStartFrame(i,j);
        while abs(RatData(i).VideoFiles(j).AutomaticStartFrame - RatData(i).VideoFiles(j).ManualStartFrames) > 5;
            im = read(RatData(i).VideoFiles(j).Object,RatData(i).VideoFiles(j).ManualStartFrames);
            ROI_to_find_trigger_frame = zeros(2,4);
            if strcmpi(pawpref,'right') == 1; 
            uiwait(msgbox(sprintf('There is a significant discrepancy between the automatically determined start frame (%d)\nand the manually determined start frame (%d).\nPlease draw a rectangle over the correct ROI in the following image.\nThe ROI should be located in the left mirror',...
                RatData(i).VideoFiles(j).AutomaticStartFrame,...
                RatData(i).VideoFiles(j).ManualStartFrames,'modal')));
            imshow(im);
            ROI_to_find_trigger_frame(1,:) = getrect;
            elseif strcmpi(pawpref,'left') == 1; 
            uiwait(msgbox(sprintf('There is a significant discrepancy between the automatically determined start frame (%d)\nand the manually determined start frame (%d).\nPlease draw a rectangle over the correct ROI in the following image.\nThe ROI should be located in the right mirror',...
                RatData(i).VideoFiles(j).AutomaticStartFrame,...
                RatData(i).VideoFiles(j).ManualStartFrames,'modal')));
            imshow(im);
            ROI_to_find_trigger_frame(2,:) = getrect;
            close; 
            end         
        ROI_to_find_trigger_frame = round(ROI_to_find_trigger_frame);
        [AutomaticStartFrame(i,j), ~] = identifyTriggerFrame(RatData(i).VideoFiles(j).Object,pawpref,'trigger_roi',ROI_to_find_trigger_frame);
        RatData(i).VideoFiles(j).AutomaticStartFrame = AutomaticStartFrame(i,j);
        end            
%         StartFrame(i,j) = GUIcreateFrameStartVP2(RatData,i,j,RatDir,RatLookUp,RatID);        
        % Load video, save video data(frames, frame rate, height, width, etc.), and play it
%         vidObj = VideoReader(fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name));
%         vidHeight = vidObj.Height;
%         vidWidth = vidObj.Width;
%         s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
%             'colormap',[]);
%         k = 1;
%         while hasFrame(vidObj)
%             s(k).cdata = readFrame(vidObj);
%             k = k+1;
%         end
%         hf = figure;
%         set(hf,'position',[0 0 vidObj.Width vidObj.Height]);
%         set(gca,'units','pixels');
%         set(gca,'position',[0 0 vidObj.Width vidObj.Height]);
%         movie(hf,s,1,vidObj.FrameRate);
    end
end

%% Start marking function. Display dialog box indicating which marker and option for indicating not visible and instructions.

for i = 1:length(RatData)
    for j = 1:length(RatData(i).VideoFiles);
        [pellet_center_x{i,j}, pellet_center_y{i,j},manual_paw_centers{i,j},mcp_hulls{i,j},mph_hulls{i,j},dph_hulls{i,j}] = createManualPointsVPedits(fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name),StartFrame(i,j));
    end
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