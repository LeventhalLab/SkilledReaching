%% Create Position Data for Joints of Rat's Paw to Determine Fine Motor Movement
% This function creates a guided user interface (GUI) that instructs the
% user in placing markers on the various joints of a rat's paw. It proceeds
% through the 40 frames following the start frame (see
% GUIcreateManualPoints_2015_06_19_OpeningFcn), according to the interval set by the
% variable Interval (default setting is 10 frames, so 5 frames are shown in
% total when including the start frame). The GUI can be edited as needed by
% opening the .fig file in GUIDE. The format for calling the function is as
% follows:
%
%                  AllFramesMarkerLocData =
%                  GUIcreateManualPoints_2015_06_19(RatData,i,j,StartFrame,varargin)
%
% where...
%% Input
% # RatData: Structure created by createManualPawData.m with fields titled
%           Date Folders -- All the folders within a rat's raw data folder,
%           one for every day of experimentation Video Files -- Structural
%           array containing info about all
%               videofiles (.avi files) in a given date folder. Fields
%               include name, data, bytes, isdir, datenum, ManualStartFrame
%               (manually determined start frame), AutomaticTriggerFrame
%               (automatically determined trigger frame by
%               identifyTriggerFrame function in createManualPawData
%               script, may be removed later), AutomaticPeakFrame
%               (automatically determined peak frame by
%               identifyTriggerFrame function in createManualPawData
%               script, may be removed later), Agree (0 if manual start
%               frame and automatic peak frame do not agree, 1 if they do),
%               ROI_Used, Paw_Preference (encodes previous manually
%               determined information about paw used in video,
%               dominant/marked or non-dominant/unmarked)
%           Date -- The date for a given date folder, written out in
%           mm/dd/yy format
% # i: Indicates which date folder in RatData contains video to be analyzed
% (same as i in createManualPawData.m)
% # j: Indicates which video file in date folder will be analyzed (same as
% j in createManualPawData.m)
%% Varargs
% # start_frame -- User specifies start frame for video to analyze from.
%       Default is value specified in RatData.Videos.ManualStartFrame.
% # interval -- Interval from start frame to end frame for analyzing videos
%       Default is 10 frames.
% # end_frame -- User specifies end frame. Default is 40 frames after
%       start.
%% Output
% # AllFramesMarkerLocData: Cell array containing information about
% location for each marker, including which of the total marker numbers it
% is (Column 1), frame it was placed in (Column 2), region of the frame it
% is placed in (Column 3), which of the 16 markers for a given frame region
% it is (Column 4), its common name (Column 5), its anatomical name (Column
% 6),its X-coordinate (Column 7), its Y coordinate (Column 8),the number in
% the list of frames it has been placed in (Column 9), and the number in
% the list of regions it got placed in (Column 10).
%
%% Other Outputs to Base Workspace (but not the actual output of function)
%
% # LastMarkedMarkerData: Temporarily keeps track of the markers completed
% for a given region of a frame thus far. Resets when a frame region is
% completed. If function is completed correctly, it should match the data
% contained in the structure for the right region of the end frame.
% # LastMarkedFrameData: Temporarily keeps track of all the markers
% completed for a given frame thus far; resets when frame is completed. If
% the function is completed correctly, it should match the data contained
% in the final cell of the output (i.e. the data for the end frame).
% # CumFrameData: Temporarily keeps track of all the markers for all the
% frames completed thus far; ends when function ends. Thus, CumFrameData
% should look exactly like the output if the function is completed
% correctly.

%% Start of Code
function varargout = GUIcreateManualPoints_2015_06_19(varargin)
% GUIcreateManualPoints_2015_06_19 MATLAB code for GUIcreateManualPoints_2015_06_19.fig
%      GUIcreateManualPoints_2015_06_19, by itself, creates a new
%      GUIcreateManualPoints_2015_06_19 or raises the existing singleton*.
%
%      H = GUIcreateManualPoints_2015_06_19 returns the handle to a new
%      GUIcreateManualPoints_2015_06_19 or the handle to the existing singleton*.
%
%      GUIcreateManualPoints_2015_06_19('CALLBACK',hObject,eventData,handles,...)
%      calls the local function named CALLBACK in GUIcreateManualPoints_2015_06_19.M
%      with the given input arguments.
%
%      GUIcreateManualPoints_2015_06_19('Property','Value',...) creates a new
%      GUIcreateManualPoints_2015_06_19 or raises the existing singleton*.  Starting
%      from the left, property value pairs are applied to the GUI before
%      GUIcreateManualPoints_2015_06_19_OpeningFcn gets called.  An unrecognized
%      property name or invalid value makes property application stop.  All
%      inputs are passed to GUIcreateManualPoints_2015_06_19_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIcreateManualPoints_2015_06_19

% Last Modified by GUIDE v2.5 19-Jun-2015 16:31:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUIcreateManualPoints_2015_06_19_OpeningFcn, ...
    'gui_OutputFcn',  @GUIcreateManualPoints_2015_06_19_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%% Opening Function
% Establishes variables used in later parts of function.

% --- Executes just before GUIcreateManualPoints_2015_06_19 is made visible.
function GUIcreateManualPoints_2015_06_19_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn. hObject    handle to
% figure eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) varargin
% command line arguments to GUIcreateManualPoints_2015_06_19 (see % VARARGIN)

% Convert input variables into variables in function workspace.
if nargin > 0;
    RatData = varargin{1};
    i = varargin{2};
    j = varargin{3};
    StartFrame = varargin{4};
end
video = VideoReader(fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name));
ProcessedDataFolder = strrep(RatData(i).DateFolders,'-rawdata','-processed');
handles.ProcessedDataFolder = ProcessedDataFolder;

% Set default values for end frame and interval. Modify according to user
% input to function as appropriate. Determine number of frames.
EndFrame = StartFrame+40;
Interval = 10;

for iarg = 5 : 2 : nargin-4
    switch lower(varargin{iarg})
        case 'start_frame',
            StartFrame = varargin{iarg + 1};
        case 'interval',   
            Interval = varargin{iarg + 1};
        case 'end_frame',
            EndFrame = varargin{iarg + 1};
%         case 'marker_number'
%             MarkerNum = varargin{iarg+1};
%             handles.CurrentMarker = MarkerNum;
%             guidata(hObject,handles);
    end
end

NumOfFrames = 10+((EndFrame - (StartFrame+10))/Interval);

% Create cell array of frame numbers from video to be analyzed, based on
% start frame and interval
Frames = cell(NumOfFrames,1);
initframeCount = 0;
finframeCount = 1;
for i = 1:NumOfFrames;
    if i < 11;
        Frames{i} = num2str(StartFrame + initframeCount);
        initframeCount = initframeCount + 1;
    else
    Frames{i} = num2str(StartFrame + 9 + (finframeCount.*Interval));
    finframeCount = finframeCount+1;
    end
    
end
FrameInfo = cell(NumOfFrames,58);
FrameInfo(:,1) = Frames(:,1);

% Create cell array of marker names to be displayed in GUI and appear in
% Column 5 of output, AllFramesMarkerLocData. These are the 16 markers which are marked in every
% frame region. 
Finger = {'Pellet Center',...
    'Center of Back Surface of Paw',...    
    'Thumb',...
    'Thumb',...
    'Index Finger',...
    'Index Finger',...
    'Index Finger',...
    'Middle Finger',...
    'Middle Finger',...
    'Middle Finger',...
    'Ring Finger',...
    'Ring Finger',...
    'Ring Finger',...
    'Pinky Finger',...
    'Pinky Finger',...
    'Pinky Finger'}';

% Create cell array of anatomical marker names to be displayed with
% corresponding common marker name in GUI and appear in Column 6 of
% AllFramesMarkerLocData 
AnatMarkerPoints = {'',...
    'Capitate-Middle Finger Metacarpal Joint',...
    'Metacarpal-Proximal Phalanges Joint',...
    'Proximal-Distal Phalanges Joint',...
    'Metacarpal-Proximal Phalanges Joint',...
    'Proximal-Middle Phalanges Joint',...
    'Middle-Distal Phalanges Joint',...
    'Metacarpal-Proximal Phalanges Joint',...
    'Proximal-Middle Phalanges Joint',...
    'Middle-Distal Phalanges Joint',...
    'Metacarpal-Proximal Phalanges Joint',...
    'Proximal-Middle Phalanges Joint',...
    'Middle-Distal Phalanges Joint',...
    'Metacarpal-Proximal Phalanges Joint',...
    'Proximal-Middle Phalanges Joint',...
    'Middle-Distal Phalanges Joint'}';

% Create cell array that will show in GUI which view the user should be
% placing markers in (left, center, or right)
FrameRegionInFocus = {'(Video) Left','Center','(Video) Right'}';

% Set total number of markers
TotMarkNum = NumOfFrames.*length(FrameRegionInFocus).*length(Finger);

% Create list of all markers (with frame, frame region, and common marker
% name info) and populate listbox in GUI to allow for re-doing markers
ReDoMarkerList = cell(TotMarkNum,1);
m = 1; %Represents marker number out of total
for i = 1:length(Frames); %Represents Frames element index
    for j = 1:length(FrameRegionInFocus); %Represents region of focus in frame
        for k = 1:length(Finger); %Represents marker number out of total marked (16) in every frame region
            ReDoMarkerList{m} = strjoin(cellstr(['Frame' Frames(i) FrameRegionInFocus(j) Finger(k) AnatMarkerPoints(k)]));
            m = m+1;
        end
    end
end

set(handles.redo_marker_listbox,'String',ReDoMarkerList);

% Create AllFramesMarkerLocData, a cell array with all marker information
% (see 'Output'). The variables m, i, j, and k represent the same things
% they do above. The x,y coordinates for all markers are set to the string 'Marker Not
% Yet Placed' and will be replaced with either numbers or NaN during
% marking. 
m = 1; 
AllFramesMarkerLocData = cell(TotMarkNum,10);
for i = 1:length(Frames);
    for j = 1:length(FrameRegionInFocus);
        for k = 1:length(Finger);
            AllFramesMarkerLocData{m,1} = m;
            AllFramesMarkerLocData{m,2} = Frames(i);
            AllFramesMarkerLocData{m,3} = FrameRegionInFocus(j);
            AllFramesMarkerLocData{m,4} = k;
            AllFramesMarkerLocData{m,5} = Finger(k);
            AllFramesMarkerLocData{m,6} = AnatMarkerPoints(k);
            AllFramesMarkerLocData{m,7} = 'Marker Not Yet Placed';
            AllFramesMarkerLocData{m,8} = 'Marker Not Yet Placed';
            AllFramesMarkerLocData{m,9} = i;
            AllFramesMarkerLocData{m,10} = j;
            m = m+1;
        end
    end
end

% Allows for the selection of more than 1 marker to be re-done
% (theoretically, all the markers can be selected to be re-done)
set(handles.redo_marker_listbox,'Max',TotMarkNum,'Min',0);

% Add necessary created variables to the handles structure so the later 
% callback functions for the various buttons and text boxes in the GUI can
% access it
handles.video = video;
handles.Finger = Finger;
handles.AnatMarkerPoints = AnatMarkerPoints;
handles.FrameRegionInFocus = FrameRegionInFocus;
handles.Frames = Frames;
handles.AllFramesMarkerLocData = AllFramesMarkerLocData;
handles.FrameInfo = FrameInfo;

% Choose default command line output for GUIcreateManualPoints_2015_06_19
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Position GUI in middle right part of screen
set(handles.figure1,'Position',[319.8000 17.6923 62.6000 53]);

%     output_fcn = @(hObject, eventdata, handles)GUIcreateManualPoints_2015_06_19_OutputFcn;


% UIWAIT makes GUIcreateManualPoints_2015_06_19 wait for user response (see UIRESUME).
% This is part of what forces the function to wait until all the markers
% for all the frames have been placed before producing
% AllFramesMarkerLocData.
uiwait(handles.figure1);


%% Function executed upon pressing Begin button
% Ultimately leads to creation of output, AllFramesMarkerLocData (see
% 'Output')

% --- Executes on button press in begin_button.
function begin_button_Callback(hObject, eventdata, handles)
% hObject    handle to begin_button (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB 
% handles    structure with handles and user data (see GUIDATA)

% begin_button_func = @(hObject,eventdata)GUIcreateManualPoints_2015_06_19('begin_button_Callback',hObject,eventdata,guidata(hObject));
% handles.begin_button_func = begin_button_func;
% guidata(hObject,handles);

% disp('Callback to Begin from Redo works');


    %Import relevant variables from handles structure which were created in
    %opening function
    video = handles.video;
    Finger = handles.Finger;
    AnatMarkerPoints = handles.AnatMarkerPoints;
    FrameRegionInFocus = handles.FrameRegionInFocus;
    Frames = handles.Frames;
    FrameInfo = handles.FrameInfo;
    AllFramesMarkerLocData = handles.AllFramesMarkerLocData;
    ProcessedDataFolder = handles.ProcessedDataFolder;
    
    % Check to see if the user re-did any markers. If so, resume from the
    % last marker completed before the re-do button was pushed
    % (CurrentMarker). If not, i.e. the user only pressed the Begin button
    % and is starting marking for the first time, start at the first marker
    % (CurrentMarker = 1).
    try
        Marker = handles.CurrentMarker;
    catch
        Marker = 1;
    end
       
    % NOTE: IF A MARKER'S LOCATION HAS NOT BEEN RECORDED, IT WILL APPEAR AS
    % 'Marker Not Yet Placed' IN THE FINAL OUTPUT. IF THE USER INDICATES IT
    % IS NOT VISIBLE IN A PARTICULAR REGION OF THE FRAME, IT WILL APPEAR AS
    % 'NaN' IN OUTPUT. IF IT IS CORRECTLY RECORDED, IT'S COORDINATES WILL
    % BE RECORDED BOTH IN THE FINAL OUTPUT AND THE "TEMPORARY" VARIABLE
    % CumMarkedMarkersLocations IN THE BASE WORKSPACE   
   
    % The code below is what controls marker placement, starting from
    % either 1 or the last marked marker, depending on the value of
    % CurrentMarker, through to all markers
    for MarkerNum = Marker:length(AllFramesMarkerLocData(:,1)); %[Marker Marker+47 Marker+48 Marker+49];
                
        %Set current marker to whichever marker is currently being worked
        %on, so user can resume from here after completing re-do's
        CurrentMarker = MarkerNum;
        
        % Update handles structure appropriately
        handles.CurrentMarker = CurrentMarker;
        guidata(hObject, handles);
        
        % Determine the position of the marker's frame number in the array
        % of frame numbers (e.x. the 4th frame for analysis)
        iFrame = AllFramesMarkerLocData{MarkerNum,9}; %length(Frames);     


%         fprintf('Marker contained in frame %d\n',str2double(Frames{iFrame}));
        
        % Determine the region of the frame where the marker should be
        % placed
        iFrameRegion = AllFramesMarkerLocData{MarkerNum,10};
        
        iMarker = AllFramesMarkerLocData{MarkerNum,4};
        
            fprintf('Working on marker %s %s\nin frame region %s of frame %d.\nThis is marker number %d out of %d total\n\n',...
            Finger{iMarker},...
            AnatMarkerPoints{iMarker},...
            FrameRegionInFocus{iFrameRegion},...
            str2double(Frames{iFrame}),...
            MarkerNum,...
            length(AllFramesMarkerLocData(:,1)));
        
        warning('off','images:initSize:adjustingMag');
        % Display the frame image on the left side of the screen
        
        %         BeginButton_Frame_handle = figure;
        %         handles.BeginButton_Frame_handle = BeginButton_Frame_handle;
        %         guidata(hObject,handles);
        %BeginButton_Frame_IMToolhandle = imtool(im);
        %uiwait(handles.begin_button);
        %         waitfor(BeginButton_Frame_IMToolHandle);
        %         BeginButton_Frame_handle = imshow(im);
        %         handles.BeginButton_Frame_handle = BeginButton_Frame_handle;
        %         guidata(hObject,handles);
        %[~,imMap] = frame2im(im);        
        
        try
            leftImg = FrameInfo{iFrame,4};
            leftRectPos = FrameInfo{iFrame,5};
            centerImg = FrameInfo{iFrame,6};
            centerRectPos = FrameInfo{iFrame,7};
            rightImg = FrameInfo{iFrame,8};
            rightRectPos = FrameInfo{iFrame,9};
            if isempty (leftImg) || isempty(leftRectPos) || isempty (centerImg) || isempty(centerRectPos) || isempty (rightImg) || isempty(rightRectPos)
                if iMarker == 1 && iFrameRegion == 1; %&& iFrame == 1;
                    % when starting a frame
                    im = read(video,str2double(Frames{iFrame}));
                    FrameInfo{iFrame,10} = im;
                    %imageName = sprintf('All_Markers_for_Frame_%s_of_%s',Frames{iFrame},video.Name(1:end-4));
                    figure;
                    BeginButton_Frame = imshow(im);
                    set(gcf,'units','normalized','outerposition',[0 .09 .85 .85]);
                    BeginButton_Frame_axis_handle = gca;
                    BeginButton_Frame_figure_handle = gcf;
                    uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the LEFT mirror of the frame'},'modal'));
                    leftRect = imrect(BeginButton_Frame_axis_handle);
                    leftRectPos = getPosition(leftRect);
                    uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the CENTER of the frame'},'modal'));
                    centerRect = imrect(BeginButton_Frame_axis_handle);
                    centerRectPos = getPosition(centerRect);
                    uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the RIGHT mirror of the frame'},'modal'));
                    rightRect = imrect(BeginButton_Frame_axis_handle);
                    rightRectPos = getPosition(rightRect);
                    leftImg = im(floor(leftRectPos(2)):ceil(leftRectPos(2)+leftRectPos(4)),...
                        floor(leftRectPos(1)):ceil(leftRectPos(1)+leftRectPos(3)),...
                        :);
                    FrameInfo{iFrame,4} = leftImg;
                    FrameInfo{iFrame,5} = leftRectPos;
                    centerImg = im(floor(centerRectPos(2)):ceil(centerRectPos(2)+centerRectPos(4)),...
                        floor(centerRectPos(1)):ceil((centerRectPos(1)+centerRectPos(3))),...
                        :);
                    FrameInfo{iFrame,6} = centerImg;
                    FrameInfo{iFrame,7} = centerRectPos;
                    rightImg = im(floor(rightRectPos(2)):ceil((rightRectPos(2)+rightRectPos(4))),...
                        floor(rightRectPos(1)):ceil((rightRectPos(1)+rightRectPos(3))),...
                        :);
                    FrameInfo{iFrame,8} = rightImg;
                    FrameInfo{iFrame,9} = rightRectPos;
                    %             handles.BeginButton_Frame = BeginButton_Frame;
                    %             handles.BeginButton_Frame_axis_handle = BeginButton_Frame_axis_handle;
                    %             handles.BeginButton_Frame_figure_handle = BeginButton_Frame_figure_handle;
                    %             handles.leftRect = leftRect;
                    %             handles.leftRectPos = leftRectPos;
                    %             handles.centerRect = centerRect;
                    %             handles.centerRectPos = centerRectPos;
                    %             handles.rightRect = rightRect;
                    %             handles.rightRectPos = rightRectPos;
                    guidata(hObject, handles);
                    close gcf;
                    uiwait(msgbox({'Generating figure with zoomed-in images' 'Use the original GUI window to know which marker to place' 'The window with the cropped images must be active to place markers'},'modal'));
                    BeginButtonFrameProcessedHandle = figure('units','normalized','outerposition',[0 .09 .85 .85]);
                    leftImgHandle = subplot(1,3,1); subimage(leftImg);
                    centerImgHandle = subplot(1,3,2); subimage(centerImg);
                    rightImgHandle = subplot(1,3,3); subimage(rightImg);
                    ProcessedFrameFilename = sprintf('%s\\%s_Frame_%s_ProcessedImage.fig',ProcessedDataFolder,video.name(1:end-4),Frames{iFrame});
                    savefig(BeginButtonFrameProcessedHandle,ProcessedFrameFilename);
                    handles.LastBeginButtonFrameProcessed = BeginButtonFrameProcessedHandle;
                    FrameInfo{iFrame,3} = ProcessedFrameFilename;
                    FrameInfo{iFrame,2} = im;
                    im_handle = figure;
                    imshow(im,'Border','tight');
                    set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                    handles.im_handle = im_handle;
                    handles.FrameInfo = FrameInfo;
                    guidata(hObject,handles);
                end
            else
                if exist('BeginButtonFrameProcessedHandle','var')
                    if BeginButtonFrameProcessedHandle ~= handles.LastBeginButtonFrameProcessed;
                        % when changing to a new frame
                        set(groot, 'CurrentFigure', BeginButtonFrameProcessedHandle);
                        leftImgHandle = subplot(1,3,1); subimage(leftImg);
                        centerImgHandle = subplot(1,3,2); subimage(centerImg);
                        rightImgHandle = subplot(1,3,3); subimage(rightImg);
                        savefig(BeginButtonFrameProcessedHandle,'BeginButtonFrameProcessed.fig');
                        handles.LastBeginButtonFrameProcessed = BeginButtonFrameProcessedHandle;
                        FrameInfo{iFrame,3} = BeginButtonFrameProcessedHandle.fig;
                        handles.FrameInfo = FrameInfo;
                        guidata(hObject,handles);
                        im_handle = handles.im_handle;
                        close(im_handle);
                        im = FrameInfo{iFrame,2};
                        im_handle = figure;
                        imshow(im,'Border','tight');
                        set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                        handles.im_handle = im_handle;
                        guidata(hObject,handles);
                    end
                else
                    % when returning from Redo Button
                    uiwait(msgbox({'Generating figure with zoomed-in images' 'Use the original GUI window to know which marker to place' 'The window with the cropped images must be active to place markers'},'modal'));
                    BeginButtonFrameProcessedHandle = figure('units','normalized','outerposition',[0 .09 .85 .85]);
                    leftImgHandle = subplot(1,3,1); subimage(leftImg);
                    centerImgHandle = subplot(1,3,2); subimage(centerImg);
                    rightImgHandle = subplot(1,3,3); subimage(rightImg);
                    ProcessedFrameFilename = sprintf('%s\\%s_Frame_%s_ProcessedImage.fig',ProcessedDataFolder,video.name(1:end-4),Frames{iFrame});
                    savefig(BeginButtonFrameProcessedHandle,ProcessedFrameFilename);
                    handles.LastBeginButtonFrameProcessed = BeginButtonFrameProcessedHandle;
                    FrameInfo{iFrame,3} = ProcessedFrameFilename;
                    handles.FrameInfo = FrameInfo;
                    guidata(hObject,handles);
%                     try
%                         close(2);
%                     catch ME
%                         disp(ME);
%                     end                                           
%                     im_handle = imgcf;
%                     close(im_handle);
                    im = FrameInfo{iFrame,2};
                    im_handle = figure;
                    imshow(im,'Border','tight');
                    set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                    handles.im_handle = im_handle;
                    guidata(hObject,handles);
                end
            end
        catch ME
            uiwait(msgbox({'Error has occurred, please select zoom in windows for frame again'},'modal'));
            disp(ME);
            dbstop in GUIcreateManualPoints_2015_06_19
            im = read(video,str2double(Frames{iFrame}));
            %imageName = sprintf('All_Markers_for_Frame_%s_of_%s',Frames{iFrame},video.Name(1:end-4));
            figure;
            BeginButton_Frame = imshow(im);
            set(gcf,'units','normalized','outerposition',[0 .09 .85 .85]);
            BeginButton_Frame_axis_handle = gca;
            BeginButton_Frame_figure_handle = gcf;
            uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the LEFT mirror of the frame'},'modal'));
            leftRect = imrect(BeginButton_Frame_axis_handle);
            leftRectPos = getPosition(leftRect);
            uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the CENTER of the frame'},'modal'));
            centerRect = imrect(BeginButton_Frame_axis_handle);
            centerRectPos = getPosition(centerRect);
            uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the RIGHT mirror of the frame'},'modal'));
            rightRect = imrect(BeginButton_Frame_axis_handle);
            rightRectPos = getPosition(rightRect);
            leftImg = im(floor(leftRectPos(2)):ceil(leftRectPos(2)+leftRectPos(4)),...
                floor(leftRectPos(1)):ceil(leftRectPos(1)+leftRectPos(3)),...
                :);
            FrameInfo{iFrame,4} = leftImg;
            FrameInfo{iFrame,5} = leftRectPos;
            centerImg = im(floor(centerRectPos(2)):ceil(centerRectPos(2)+centerRectPos(4)),...
                floor(centerRectPos(1)):ceil(centerRectPos(1)+centerRectPos(3)),...
                :);
            FrameInfo{iFrame,6} = centerImg;
            FrameInfo{iFrame,7} = centerRectPos;
            rightImg = im(floor(rightRectPos(2)):ceil(rightRectPos(2)+rightRectPos(4)),...
                floor(rightRectPos(1)):ceil(rightRectPos(1)+rightRectPos(3)),...
                :);
            FrameInfo{iFrame,8} = rightImg;
            FrameInfo{iFrame,9} = rightRectPos;
            %             handles.BeginButton_Frame = BeginButton_Frame;
            %             handles.BeginButton_Frame_axis_handle = BeginButton_Frame_axis_handle;
            %             handles.BeginButton_Frame_figure_handle = BeginButton_Frame_figure_handle;
            %             handles.leftRect = leftRect;
            %             handles.leftRectPos = leftRectPos;
            %             handles.centerRect = centerRect;
            %             handles.centerRectPos = centerRectPos;
            %             handles.rightRect = rightRect;
            %             handles.rightRectPos = rightRectPos;
            guidata(hObject, handles);
            close gcf;
            uiwait(msgbox({'Generating figure with zoomed-in images' 'Use the original GUI window to know which marker to place' 'The window with the cropped images must be active to place markers'},'modal'));
            BeginButtonFrameProcessedHandle = figure('units','normalized','outerposition',[0 .09 .85 .85]);
            leftImgHandle = subplot(1,3,1); subimage(leftImg);
            centerImgHandle = subplot(1,3,2); subimage(centerImg);
            rightImgHandle = subplot(1,3,3); subimage(rightImg);
            ProcessedFrameFilename = sprintf('%s\\%s_Frame_%s_ProcessedImage.fig',ProcessedDataFolder,video.name(1:end-4),Frames{iFrame});
            savefig(BeginButtonFrameProcessedHandle,ProcessedFrameFilename);
            handles.LastBeginButtonFrameProcessed = BeginButtonFrameProcessedHandle;
            FrameInfo{iFrame,3} = ProcessedFrameFilename;
            handles.FrameInfo = FrameInfo;
            guidata(hObject,handles);
        end
%         if iFrame == AllFramesMarkerLocData{MarkerNum-1,9}
%         elseif iFrame == 1;
%         leftImg = im(leftRectPos(2):(leftRectPos(2)+leftRectPos(4)),...
%             leftRectPos(1):(leftRectPos(1)+leftRectPos(3)),...
%             :);
%         centerImg = im(centerRectPos(2):(centerRectPos(2)+centerRectPos(4)),...
%             centerRectPos(1):(centerRectPos(1)+centerRectPos(3)),...
%             :);
%         rightImg = im(rightRectPos(2):(rightRectPos(2)+rightRectPos(4)),...
%             rightRectPos(1):(rightRectPos(1)+rightRectPos(3)),...
%             :);
%         BeginButtonFrameProcessed = figure;
%         leftImgHandle = subplot(1,3,1); subimage(leftImg);
%         centerImgHandle = subplot(1,3,2); subimage(centerImg);
%         rightImgHandle = subplot(1,3,3); subimage(rightImg);       
%           
                
        % Display in the GUI which region of the frame the user should be
        % marking
        set(handles.frame_reg_in_focus_txtbox,'String',FrameRegionInFocus{iFrameRegion})
        
        % Determine the name of the marker to be placed and display it,
        % along with its anatomical name, in GUI
        set(handles.marker_indicator_txtbox,'String',Finger{iMarker});
        set(handles.marker_indicator2_txtbox,'String',AnatMarkerPoints{iMarker});
        
%         display('Marker 1');
        
        % Start marking
        try
            if iFrameRegion == 1;
                [x,y] = getpts(leftImgHandle);
            elseif iFrameRegion == 2;
                [x,y] = getpts(centerImgHandle);
            elseif iFrameRegion == 3;
                [x,y] = getpts(rightImgHandle);
            end
        catch
            if iFrameRegion == 1;
                [x,y] = getpts(leftImgHandle);
            elseif iFrameRegion == 2;
                [x,y] = getpts(centerImgHandle);
            elseif iFrameRegion == 3;
                [x,y] = getpts(rightImgHandle);
            end
        end
            
%             display('Marker 2');
       
        % For the pellet center marker...
        if iMarker == 1;
        
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData 
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                
                % otherwise, function records position data and displays a
                % BLUE circle temporarily where the user indicated the
                % pellet center is
            else                
                if iFrameRegion == 1;
                    BigFigX = x+leftRectPos(1);
                    BigFigY = y+leftRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 2;
                    BigFigX = x+centerRectPos(1);
                    BigFigY = y+centerRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 3;
                    BigFigX = x+rightRectPos(1);
                    BigFigY = y+rightRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                end
                PelletMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Blue');
                im = PelletMarkerCircle;
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;                
                if BeginButtonFrameProcessedHandle ~= handles.LastBeginButtonFrameProcessed;
                    im_handle = figure;
                else
                    if MarkerNum == 1;
                        close(im_handle);
                        im_handle = figure;
                    else
                        set(groot, 'CurrentFigure', im_handle);
                    end
                end
                imshow(im,'Border','tight');
                set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                FrameInfo{iFrame,2} = im;
                handles.im_handle = im_handle;
                guidata(hObject,handles);
            end
            
            % for the paw center marker...
        elseif iMarker == 2;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
                % otherwise, function records position data and displays a
                % RED circle temporarily where the user indicated the paw
                % center is
            else                
                if iFrameRegion == 1;
                    BigFigX = x+leftRectPos(1);
                    BigFigY = y+leftRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 2;
                    BigFigX = x+centerRectPos(1);
                    BigFigY = y+centerRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 3;
                    BigFigX = x+rightRectPos(1);
                    BigFigY = y+rightRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                end
                PawCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Red');
                im = PawCenterMarkerCircle;
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                set(groot, 'CurrentFigure', im_handle);
                imshow(im,'Border','tight');
                set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                FrameInfo{iFrame,2} = im;
            end
            
            % for the metacarpal phalanges-proximal phalanges (McPh-pPh)
            % joints...
        elseif iMarker == 3 || iMarker == 5 || iMarker == 8 || iMarker == 11 || iMarker == 14;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData.
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
                % otherwise, function records position data and displays a
                % GREEN circle temporarily where the user indicated the
                % McPh-pPh joint center is.                
            else
                if iFrameRegion == 1;
                    BigFigX = x+leftRectPos(1);
                    BigFigY = y+leftRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 2;
                    BigFigX = x+centerRectPos(1);
                    BigFigY = y+centerRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 3;
                    BigFigX = x+rightRectPos(1);
                    BigFigY = y+rightRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                end
                McPh_pPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Green');
                im = McPh_pPhCenterMarkerCircle;
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                set(groot, 'CurrentFigure', im_handle);
                imshow(im,'Border','tight');
                set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                 FrameInfo{iFrame,2} = im;
            end
            
            % for the thumb's proximal phalanges-distal phalanges (pPh-dPh)
            % joint...
        elseif iMarker == 4;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData.
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                
                % otherwise, function records position data and displays a
                % WHITE circle temporarily where the user indicated the
                % pPh-dPh joint center is.
                
            else
                if iFrameRegion == 1;
                    BigFigX = x+leftRectPos(1);
                    BigFigY = y+leftRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 2;
                    BigFigX = x+centerRectPos(1);
                    BigFigY = y+centerRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 3;
                    BigFigX = x+rightRectPos(1);
                    BigFigY = y+rightRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                end
                pPh_dPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'White');
                im = pPh_dPhCenterMarkerCircle;
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                set(groot, 'CurrentFigure', im_handle);
                imshow(im,'Border','tight');
                set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                 FrameInfo{iFrame,2} = im;
            end
            
            % for the proximal phalanges-middle phalanges (pPh-mPh)
            % joints...
        elseif iMarker == 6 || iMarker == 9 || iMarker == 12 || iMarker == 15;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData.
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                
                % otherwise, function records position data and displays a
                % CYAN circle temporarily where the user indicated the
                % pPh-mPh joint center is.
                
            else
                if iFrameRegion == 1;
                    BigFigX = x+leftRectPos(1);
                    BigFigY = y+leftRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 2;
                    BigFigX = x+centerRectPos(1);
                    BigFigY = y+centerRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 3;
                    BigFigX = x+rightRectPos(1);
                    BigFigY = y+rightRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                end
                pPh_mPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Cyan');
                im = pPh_mPhCenterMarkerCircle;
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                set(groot, 'CurrentFigure', im_handle);
                imshow(im,'Border','tight');
                set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                 FrameInfo{iFrame,2} = im;
            end
            
            % for the middle phalanges-distal phalanges (mPh-dPh) joints...
        elseif iMarker == 7 || iMarker == 10 || iMarker == 13 || iMarker == 16;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData.
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
                % otherwise, function records position data and displays a
                % MAGENTA circle temporarily where the user indicated the
                % mPh-dPh joint center is.
            
                else
                if iFrameRegion == 1;
                    BigFigX = x+leftRectPos(1);
                    BigFigY = y+leftRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 2;
                    BigFigX = x+centerRectPos(1);
                    BigFigY = y+centerRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                elseif iFrameRegion == 3;
                    BigFigX = x+rightRectPos(1);
                    BigFigY = y+rightRectPos(2);
                    AllFramesMarkerLocData(MarkerNum,7) = num2cell(BigFigX);
                    AllFramesMarkerLocData(MarkerNum,8) = num2cell(BigFigY);
                end
                mPh_dPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Magenta');
                im = mPh_dPhCenterMarkerCircle;
                FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
                set(groot, 'CurrentFigure', im_handle);
                imshow(im,'Border','tight');
                set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
                FrameInfo{iFrame,2} = im;
            end
%         display('Marker 3');    
        end
        
        % Once the marker's position has been determined and added to
        % AllFramesMarkerLocData, it is exported to the base workspace
        % (just in case the GUI is terminated early) and updated in the
        % handles structure. The frame image is then closed
%         display('Marker 4');
        assignin('base','CumMarkedMarkersLocations', AllFramesMarkerLocData);
        assignin('base','FrameInfo', FrameInfo);
%         display('Marker 5');
        handles.AllFramesMarkerLocData = AllFramesMarkerLocData;
        handles.FrameInfo = FrameInfo;
%         display('Marker 6');
        guidata(hObject, handles);
%         display('Marker 7');

if iMarker == length(Finger) && iFrameRegion == length(FrameRegionInFocus);        
close(BeginButtonFrameProcessedHandle);
close(im_handle);
end
    end
    
%     display('Marker 8');
    % Once all frames are completed, proceed to output function by allowing
    % the GUI to resume
   
    handles.output = AllFramesMarkerLocData;
%     handles.BeginButton_Frame_handle = BeginButton_Frame_handle;
%     guidata(hObject, handles);
    pause(.001);
    uiresume(handles.figure1);
% close(gcf);
% 
% %     display('Marker 9');
%     handles.output = GUIcreateManualPoints_2015_06_19_OutputFcn(hObject, eventdata, handles);
% %     display('Marker 10');
%     guidata(hObject, handles);
% %     display('Marker 11');
%     figure1_CloseRequestFcn(hObject, eventdata, handles);
% %     display('Marker 12');
%     delete(handles.figure1);
% %     display('Marker 13');
%     close all;

%     uiwait(msgbox({'Marking complete' 'Please exit out of the program' 'by pressing the red x button'},'modal'));

%     uiresume(handles.figure1);
% close;

%break

% If an error occurs while assigning the marker, a dialog box will
% pop-up to let the user know
%     uiwait(msgbox({'Error in placing marker points. Please restart program'}));



%% Function executed upon pressing Redo button
% --- Executes on button press in redo_button.
function redo_button_Callback(hObject, eventdata, handles)
% hObject    handle to redo_button (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)
% display('Marker A');

% close;
LastBeginButtonFrameProcessed = handles.LastBeginButtonFrameProcessed;
close(LastBeginButtonFrameProcessed);
OverallMarkedImgHandle = handles.im_handle;
close(OverallMarkedImgHandle);


% Import video from handles structure
video = handles.video;

Finger = handles.Finger;

FrameInfo = handles.FrameInfo;

ProcessedDataFolder = handles.ProcessedDataFolder;

Frames = handles.Frames;

    AnatMarkerPoints = handles.AnatMarkerPoints;
    FrameRegionInFocus = handles.FrameRegionInFocus;


% The numbers of user-selected markers to redo are placed in a vector
% SelectedRedoMarkerNum
try
    SelectedRedoMarkerNum = handles.redo_marker_listbox.Value;
catch
    % If no markers are chosen and the redo button is pressed, an error
    % message pops up
    uiwait(msgbox({'No markers have been chosen to redo.' 'Please choose one or more markers' 'before attempting to redo'},'modal'));
end

% AllFramesMarkerLocData (the GUI output) is imported. If, for some reason,
% the user attempts to re-do markers before placing any at all, an error
% message pops up
try
    AllFramesMarkerLocData = handles.AllFramesMarkerLocData;
catch
    uiwait(msgbox({'No markers have been placed.' 'Please place and confirm a marker' 'before attempting to redo'},'modal'));
end


% Change string on Begin button to Resume
set(handles.begin_button,'String','Resume');

warning('off','images:initSize:adjustingMag');

% Start marking and re-writing selected redo markers
for iSelectedRedoMarkerNum = 1:length(SelectedRedoMarkerNum)
    iMarker = cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),4));
    iFrame = cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),9));
    iFrameRegion = cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),10));
    
    fprintf('Working on marker %s %s\nin frame region %s of frame %d.\nThis is marker number %d out of %d selected for re-do\n\n',...
            Finger{iMarker},...
            AnatMarkerPoints{iMarker},...
            FrameRegionInFocus{iFrameRegion},...
            str2double(Frames{iFrame}),...
            iSelectedRedoMarkerNum,...
            length(SelectedRedoMarkerNum));
    
%     beginButton_im = FrameInfo{iFrame,2};
%     close(beginButton_im);
    
    if strcmpi(AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7},'Marker Not Yet Placed')
        uiwait(msgbox({'This marker has not yet been completed' 'Please resume marker placement' 'by pressing the "Resume" button' 'Or choose completed markers to re-do again' 'and press the "Re-do" button'},'modal'));
        break
    end
    
    try        
        if iSelectedRedoMarkerNum == 1 || iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum-1),9));
            RedoButton_Frame_handle = figure;
            set(gcf,'units','normalized','outerposition',[0 .09 .85 .85]);
            leftImg = FrameInfo{iFrame,4};
            leftRectPos = FrameInfo{iFrame,5};
            centerImg = FrameInfo{iFrame,6};
            centerRectPos = FrameInfo{iFrame,7};
            rightImg = FrameInfo{iFrame,8};
            rightRectPos = FrameInfo{iFrame,9};
            leftImgHandle = subplot(1,3,1); subimage(leftImg);
            centerImgHandle = subplot(1,3,2); subimage(centerImg);
            rightImgHandle = subplot(1,3,3); subimage(rightImg);
            ProcessedFrameFilename = FrameInfo{iFrame,3};
            handles.LastRedoButton_Frame_handle = RedoButton_Frame_handle;
%             FrameInfo{iFrame,3} = RedoButton_Frame_handle;
            handles.FrameInfo = FrameInfo;
            guidata(hObject,handles)
            im = FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker};
        else
            if RedoButton_Frame_handle ~= handles.LastRedoButton_Frame_handle
                set(groot, 'CurrentFigure', RedoButton_Frame_handle);
                leftImg = FrameInfo{iFrame,4};
                leftRectPos = FrameInfo{iFrame,5};
                centerImg = FrameInfo{iFrame,6};
                centerRectPos = FrameInfo{iFrame,7};
                rightImg = FrameInfo{iFrame,8};
                rightRectPos = FrameInfo{iFrame,9};
                leftImgHandle = subplot(1,3,1); subimage(leftImg);
                centerImgHandle = subplot(1,3,2); subimage(centerImg);
                rightImgHandle = subplot(1,3,3); subimage(rightImg);
                ProcessedFrameFilename = FrameInfo{iFrame,3};
                handles.LastRedoButton_Frame_handle = RedoButton_Frame_handle;
%                                 FrameInfo{iFrame,3} = RedoButton_Frame_handle;
                handles.FrameInfo = FrameInfo;
                guidata(hObject,handles);
                im = FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker};
            else
            end
        end
    catch ME
        uiwait(msgbox({'Error has occurred, please please select zoom in windows for frame again'},'modal'));
        disp(ME);
%         dbstop if caught error;
        im = read(video,str2double(AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),2}));
        figure;
        RedoButton_Frame = imshow(im);
        set(gcf,'units','normalized','outerposition',[0 .09 .85 .85]);
        RedoButton_Frame_axis_handle = gca;
        RedoButton_Frame_figure_handle = gcf;
        uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the LEFT mirror of the frame'},'modal'));
        leftRect = imrect(RedoButton_Frame_axis_handle);
        leftRectPos = getPosition(leftRect);
        uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the CENTER of the frame'},'modal'));
        centerRect = imrect(RedoButton_Frame_axis_handle);
        centerRectPos = getPosition(centerRect);
        uiwait(msgbox({'Place a rectangle over where you would like to zoom to for marker placement in the RIGHT mirror of the frame'},'modal'));
        rightRect = imrect(RedoButton_Frame_axis_handle);
        rightRectPos = getPosition(rightRect);
        leftImg = im(floor(leftRectPos(2)):ceil(leftRectPos(2)+leftRectPos(4)),...
            floor(leftRectPos(1)):ceil(leftRectPos(1)+leftRectPos(3)),...
            :);
        FrameInfo{iFrame,4} = leftImg;
        FrameInfo{iFrame,5} = leftRectPos;
        centerImg = im(floor(centerRectPos(2)):ceil(centerRectPos(2)+centerRectPos(4)),...
            floor(centerRectPos(1)):ceil(centerRectPos(1)+centerRectPos(3)),...
            :);
        FrameInfo{iFrame,6} = centerImg;
        FrameInfo{iFrame,7} = centerRectPos;
        rightImg = im(floor(rightRectPos(2)):ceil(rightRectPos(2)+rightRectPos(4)),...
            floor(rightRectPos(1)):ceil(rightRectPos(1)+rightRectPos(3)),...
            :);
        FrameInfo{iFrame,8} = rightImg;
        FrameInfo{iFrame,9} = rightRectPos;
        %         handles.RedoButton_Frame = RedoButton_Frame;
        %         handles.RedoButton_Frame_axis_handle = RedoButton_Frame_axis_handle;
        %         handles.RedoButton_Frame_figure_handle = RedoButton_Frame_figure_handle;
        %         handles.leftRect = leftRect;
        %         handles.leftRectPos = leftRectPos;
        %         handles.centerRect = centerRect;
        %         handles.centerRectPos = centerRectPos;
        %         handles.rightRect = rightRect;
        %         handles.rightRectPos = rightRectPos;
        guidata(hObject, handles);
        close gcf;
        uiwait(msgbox({'Generating figure with zoomed-in images' 'Use the original GUI window to know which marker to place' 'The window with the cropped images must be active to place markers'},'modal'));
        RedoButton_Frame_handle = figure('units','normalized','outerposition',[0 .09 .85 .85]);
        leftImgHandle = subplot(1,3,1); subimage(leftImg);
        centerImgHandle = subplot(1,3,2); subimage(centerImg);
        rightImgHandle = subplot(1,3,3); subimage(rightImg);
        ProcessedFrameFilename = sprintf('%s\\%s_Frame_%s_ProcessedImage.fig',ProcessedDataFolder,video.name(1:end-4),Frames{iFrame});
        savefig(RedoButton_Frame_handle,ProcessedFrameFilename);
        handles.LastRedoButton_Frame_handle = RedoButton_Frame_handle;
        FrameInfo{iFrame,3} = ProcessedFrameFilename;
        handles.FrameInfo = FrameInfo;
        guidata(hObject,handles);
    end
    
    
    % The marker's current position is diplayed in the GUI, and the
    % relevant text lines indicating the marker info (region of frame,
    % name, anatomical name).
    if strcmpi(AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7},'Marker Not Yet Placed')
        set(handles.redo_marker_position_edit_txtbox,'String','Marker Not Yet Placed');
    else
        set(handles.redo_marker_position_edit_txtbox,'String',[num2str(AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7}),', ',num2str(AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8})]);
    end
    set(handles.marker_indicator_txtbox,'String',AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),5});
    set(handles.marker_indicator2_txtbox,'String',AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),6});
            set(handles.frame_reg_in_focus_txtbox,'String',FrameRegionInFocus{iFrameRegion})

    
    % Load and show frame in left side of screen
    
    % Start marking selected marker(s)
    try
        if iFrameRegion == 1;
            [x,y] = getpts(leftImgHandle);
        elseif iFrameRegion == 2;
            [x,y] = getpts(centerImgHandle);
        elseif iFrameRegion == 3;
            [x,y] = getpts(rightImgHandle);
        end
    catch
        if iFrameRegion == 1;
            [x,y] = getpts(leftImgHandle);
        elseif iFrameRegion == 2;
            [x,y] = getpts(centerImgHandle);
        elseif iFrameRegion == 3;
            [x,y] = getpts(rightImgHandle);
        end
    end
    
    % For the pellet center marker...
    if iMarker == 1;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
            % otherwise, function records position data and displays a
            % BLUE circle temporarily where the user indicated the
            % pellet center is
        else
            if iFrameRegion == 1;
                BigFigX = x+leftRectPos(1);
                BigFigY = y+leftRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 2;
                BigFigX = x+centerRectPos(1);
                BigFigY = y+centerRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 3;
                BigFigX = x+rightRectPos(1);
                BigFigY = y+rightRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            end
            PelletMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Blue');
            im = PelletMarkerCircle;
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            if RedoButton_Frame_handle ~= handles.LastRedoButton_Frame_handle;
                im_handle = figure;
            else
                if iSelectedRedoMarkerNum == 1 || iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum-1),9));
                    im_handle = figure;
                else
                    set(groot, 'CurrentFigure', im_handle);
                end
            end
            imshow(im,'Border','tight');
            set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
%             FrameInfo{iFrame,2} = im;
        end
        
        % for the paw center marker...
    elseif iMarker == 2;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
            % otherwise, function records position data and displays a
            % RED circle temporarily where the user indicated the paw
            % center is
        else
            if iFrameRegion == 1;
                BigFigX = x+leftRectPos(1);
                BigFigY = y+leftRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 2;
                BigFigX = x+centerRectPos(1);
                BigFigY = y+centerRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 3;
                BigFigX = x+rightRectPos(1);
                BigFigY = y+rightRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            end
            PawCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Red');
            im = PawCenterMarkerCircle;
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            if RedoButton_Frame_handle ~= handles.LastRedoButton_Frame_handle || iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum-1),9));
                im_handle = figure;
            else
                if iSelectedRedoMarkerNum == 1;
                    im_handle = figure;
                else
                    set(groot, 'CurrentFigure', im_handle);
                end
            end
            imshow(im,'Border','tight');
            set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
%             FrameInfo{iFrame,2} = im;
        end
        
        % for the metacarpal phalanges-proximal phalanges (McPh-pPh)
        % joints...
    elseif iMarker == 3 || iMarker == 5 || iMarker == 8 || iMarker == 11 || iMarker == 14;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData.
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
            % otherwise, function records position data and displays a
            % GREEN circle temporarily where the user indicated the
            % McPh-pPh joint center is.
        else
            if iFrameRegion == 1;
                BigFigX = x+leftRectPos(1);
                BigFigY = y+leftRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 2;
                BigFigX = x+centerRectPos(1);
                BigFigY = y+centerRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 3;
                BigFigX = x+rightRectPos(1);
                BigFigY = y+rightRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            end
            McPh_pPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Green');
            im = McPh_pPhCenterMarkerCircle;
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            if RedoButton_Frame_handle ~= handles.LastRedoButton_Frame_handle || iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum-1),9));
                im_handle = figure;
            else
                if iSelectedRedoMarkerNum == 1;
                    im_handle = figure;
                else
                    set(groot, 'CurrentFigure', im_handle);
                end
            end
            imshow(im,'Border','tight');
            set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
%             FrameInfo{iFrame,2} = im;
        end
        
        % for the thumb's proximal phalanges-distal phalanges (pPh-dPh)
        % joint...
    elseif iMarker == 4;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData.
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
            % otherwise, function records position data and displays a
            % WHITE circle temporarily where the user indicated the
            % pPh-dPh joint center is.
            
        else
            if iFrameRegion == 1;
                BigFigX = x+leftRectPos(1);
                BigFigY = y+leftRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 2;
                BigFigX = x+centerRectPos(1);
                BigFigY = y+centerRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 3;
                BigFigX = x+rightRectPos(1);
                BigFigY = y+rightRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            end
            pPh_dPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'White');
            im = pPh_dPhCenterMarkerCircle;
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            if RedoButton_Frame_handle ~= handles.LastRedoButton_Frame_handle || iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum-1),9));
                im_handle = figure;
            else
                if iSelectedRedoMarkerNum == 1;
                    im_handle = figure;
                else
                    set(groot, 'CurrentFigure', im_handle);
                end
            end
            imshow(im,'Border','tight');
            set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
%             FrameInfo{iFrame,2} = im;
        end
        
        % for the proximal phalanges-middle phalanges (pPh-mPh)
        % joints...
    elseif iMarker == 6 || iMarker == 9 || iMarker == 12 || iMarker == 15;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData.
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
            % otherwise, function records position data and displays a
            % CYAN circle temporarily where the user indicated the
            % pPh-mPh joint center is.
            
        else
            if iFrameRegion == 1;
                BigFigX = x+leftRectPos(1);
                BigFigY = y+leftRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 2;
                BigFigX = x+centerRectPos(1);
                BigFigY = y+centerRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 3;
                BigFigX = x+rightRectPos(1);
                BigFigY = y+rightRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            end
            pPh_mPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Cyan');
            im = pPh_mPhCenterMarkerCircle;
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            if RedoButton_Frame_handle ~= handles.LastRedoButton_Frame_handle || iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum-1),9));
                im_handle = figure;
            else
                if iSelectedRedoMarkerNum == 1;
                    im_handle = figure;
                else
                    set(groot, 'CurrentFigure', im_handle);
                end
            end
            imshow(im,'Border','tight');
            set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
%             FrameInfo{iFrame,2} = im;
        end
        
        % for the middle phalanges-distal phalanges (mPh-dPh) joints...
    elseif iMarker == 7 || iMarker == 10 || iMarker == 13 || iMarker == 16;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData.
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            
            % otherwise, function records position data and displays a
            % MAGENTA circle temporarily where the user indicated the
            % mPh-dPh joint center is.
            
        else
            if iFrameRegion == 1;
                BigFigX = x+leftRectPos(1);
                BigFigY = y+leftRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 2;
                BigFigX = x+centerRectPos(1);
                BigFigY = y+centerRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            elseif iFrameRegion == 3;
                BigFigX = x+rightRectPos(1);
                BigFigY = y+rightRectPos(2);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(BigFigX);
                AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(BigFigY);
            end
            mPh_dPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [BigFigX,BigFigY,8], 'Color', 'Magenta');
            im = mPh_dPhCenterMarkerCircle;
            FrameInfo{iFrame,10+((iFrameRegion-1)*length(Finger))+iMarker} = im;
            if RedoButton_Frame_handle ~= handles.LastRedoButton_Frame_handle || iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum-1),9));
                im_handle = figure;
            else
                if iSelectedRedoMarkerNum == 1;
                    im_handle = figure;
                else
                    set(groot, 'CurrentFigure', im_handle);
                end
            end
            imshow(im,'Border','tight');
            set(im_handle,'units','normalized','outerposition',[-0.0005    0.0361    0.2161    0.2806]);
%             FrameInfo{iFrame,2} = im;
        end
        %         display('Marker 3');
    end
    
    % Once the marker's position has been determined and added to
    % AllFramesMarkerLocData, it is exported to the base workspace
    % (just in case the GUI is terminated early) and updated in the
    % handles structure. The frame image is then closed
    assignin('base','CumMarkedMarkersLocations', AllFramesMarkerLocData);
    assignin('base','FrameInfo', FrameInfo);
    
    handles.AllFramesMarkerLocData = AllFramesMarkerLocData;
    handles.FrameInfo = FrameInfo;
    
    %     handles.RedoButton_Frame_handle = RedoButton_Frame_handle;
    guidata(hObject, handles);
    %     uiresume;
    if iSelectedRedoMarkerNum == length(SelectedRedoMarkerNum);
        close(RedoButton_Frame_handle);
        close(im_handle);
    elseif iFrame ~= cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum+1),9))
        close(RedoButton_Frame_handle);
        close(im_handle);
    end
end

% When all the re-do markers are completed, the user must hit resume to
% continue marking points or finish the marking.
handles.output = AllFramesMarkerLocData;
pause(.001);
% uiresume(handles.figure1);

uiwait(msgbox({'Please press resume' 'on the Paw Point Creation Tool' 'to continue or finish marking' 'BE CAREFUL' 'DO NOT PRESS ANYTHING ELSE'},'modal'));

% disp('UIBox works');
% return
% begin_button_func = handles.begin_button_func;
% begin_button_func(handles.begin_button, eventdata);

%% Output Function
% Tells function to close the GUI and export output,
% AllFramesMarkerLocData (created in begin_button_Callback function).

% --- Outputs from this function are returned to the command line.
function varargout = GUIcreateManualPoints_2015_06_19_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT); hObject
% handle to figure eventdata  reserved - to be defined in a future version
% of MATLAB handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure varargout{1} =
% handles.output; 

try 
   AllFramesMarkerLocData = handles.AllFramesMarkerLocData;
   varargout{1} = AllFramesMarkerLocData;
   uiresume(handles.figure1);
   close;
%    close;
%    close all;
%     varargout{1} = handles.ouput;
%     %close(handles.figure1);
%     close(hObject);
%     delete(hObject);
%     close all;
catch ME
   varargout{1} = ME;
%    uiresume(handles.figure1);
   close;
    % If the program is closed unexpectedly, data recorded up to that point
    % is saved in CumMarkedMarkersLocations on base workspace.
    % AllFramesMarkerLocData is set to a string that conveys the error message.
%     varargout{1} = 'Program closed unexpectedly. Data saved under CumMarkedMarkersLocations A';
%     uiwait(msgbox({'Program closed unexpectedly' 'Data saved under CumMarkedMarkersLocations A'},'modal'));
%     close all
end

%% Closing figure (without or without completion of AllFramesMarkerLocData)
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure delete(hObject);
try
%      delete(hObject);
%     close(handles.figure1);
uiresume;
handles.output = handles.AllFramesMarkerLocData;
delete(hObject);
clf;   

%     varargout{1} = handles.output;
%     delete(hObject);
     close all;
catch ME
    
    % If the user attempts to close the function early, an error message
    % pops up, letting the user know program closed and where the data was
    % saved.
    varargout{1} = 'Program closed unexpectedly. Data saved under CumMarkedMarkersLocations'; %#ok<*NASGU>
    delete(hObject);
    clf;
     close all
end

function figure1_DeleteFcn(hObject,eventdata,handles)
delete(hObject);

%% Unimportant functions (with respect to user and GUI output)
% needed for creating and setting properties of objects in GUI

function marker_indicator_txtbox_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to marker_indicator_txtbox (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles
% structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of marker_indicator_txtbox
% as text
%        str2double(get(hObject,'String')) returns contents of
%        marker_indicator_txtbox as a double

% --- Executes during object creation, after setting all properties.

function marker_indicator_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_indicator_txtbox (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles    empty -
% handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function frame_reg_in_focus_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to frame_reg_in_focus_txtbox (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles
% structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of
% frame_reg_in_focus_txtbox as text
%        str2double(get(hObject,'String')) returns contents of
%        frame_reg_in_focus_txtbox as a double


% --- Executes during object creation, after setting all properties.
function frame_reg_in_focus_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_reg_in_focus_txtbox (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles    empty -
% handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function marker_indicator2_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to marker_indicator2_txtbox (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles
% structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of marker_indicator2_txtbox
% as text
%        str2double(get(hObject,'String')) returns contents of
%        marker_indicator2_txtbox as a double


% --- Executes during object creation, after setting all properties.
function marker_indicator2_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_indicator2_txtbox (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles    empty -
% handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function redo_marker_position_edit_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to redo_marker_position_edit_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB handles
% structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of
% redo_marker_position_edit_txtbox as text
%        str2double(get(hObject,'String')) returns contents of
%        redo_marker_position_edit_txtbox as a double


% --- Executes during object creation, after setting all properties.
function redo_marker_position_edit_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to redo_marker_position_edit_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB handles
% empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function redo_marker_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to redo_marker_listbox (see GCBO) eventdata  reserved -
% to be defined in a future version of MATLAB handles    empty - handles
% not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function redo_marker_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to redo_marker_listbox (see GCBO) eventdata  reserved -
% to be defined in a future version of MATLAB handles    empty - handles
% not created until after all CreateFcns called

%% Developer Notes
% -Check Other Outputs to Base Workspace Section in Intro 
% -WHAT IF THEY SPECIFY # OF FRAMES WITHOUT SPECIFYING END FRAME AND/OR INTERVAL? Incorporate check for at least 2/3. 
% -Export output to Excel in processed data folder
% -Remove limiters to marker placement put in for testing
% -DONE-Frame image shouldn't keep loading, just load once for a given set of
% markers
% -DONE-Keep circles on screen for duration of marking a given region of the
% frame
% - Remove references to Finger and AnatMarkerPoints and other arrays
% that are already contained in AllFramesMarkerLocData
% - Center text in dialog boxes and dialog boxes on screen
% - remove white border on frame images with all markers
% - replace 3 images in processed with magnification box (immagbox)
% - limit marker placement to respective window
