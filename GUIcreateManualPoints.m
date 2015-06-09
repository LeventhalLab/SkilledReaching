%% Create Position Data for Joints of Rat's Paw to Determine Fine Motor Movement
% This function creates a guided user interface (GUI) that instructs the
% user in placing markers on the various joints of a rat's paw. It proceeds
% through the 40 frames following the start frame (see
% GUIcreateManualPoints_OpeningFcn), according to the interval set by the
% variable Interval (default setting is 10 frames, so 5 frames are shown in
% total when including the start frame). The GUI can be edited as needed by
% opening the .fig file in GUIDE. The format for calling the function is as
% follows:
%
%                  AllFramesMarkerLocData =
%                  GUIcreateManualPoints(RatData,i,j,StartFrame,varargin)
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
% is placed in (Column 3), which of the 14 markers for a given frame region
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
function varargout = GUIcreateManualPoints(varargin)
% GUICREATEMANUALPOINTS MATLAB code for GUIcreateManualPoints.fig
%      GUICREATEMANUALPOINTS, by itself, creates a new
%      GUICREATEMANUALPOINTS or raises the existing singleton*.
%
%      H = GUICREATEMANUALPOINTS returns the handle to a new
%      GUICREATEMANUALPOINTS or the handle to the existing singleton*.
%
%      GUICREATEMANUALPOINTS('CALLBACK',hObject,eventData,handles,...)
%      calls the local function named CALLBACK in GUICREATEMANUALPOINTS.M
%      with the given input arguments.
%
%      GUICREATEMANUALPOINTS('Property','Value',...) creates a new
%      GUICREATEMANUALPOINTS or raises the existing singleton*.  Starting
%      from the left, property value pairs are applied to the GUI before
%      GUIcreateManualPoints_OpeningFcn gets called.  An unrecognized
%      property name or invalid value makes property application stop.  All
%      inputs are passed to GUIcreateManualPoints_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIcreateManualPoints

% Last Modified by GUIDE v2.5 09-Jun-2015 15:52:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUIcreateManualPoints_OpeningFcn, ...
    'gui_OutputFcn',  @GUIcreateManualPoints_OutputFcn, ...
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

% --- Executes just before GUIcreateManualPoints is made visible.
function GUIcreateManualPoints_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn. hObject    handle to
% figure eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) varargin
% command line arguments to GUIcreateManualPoints (see % VARARGIN)

% Convert input variables into variables in function workspace.
if nargin > 0;
    RatData = varargin{1};
    i = varargin{2};
    j = varargin{3};
    StartFrame = varargin{4};
end
video = VideoReader(fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name));

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
    end
end

NumOfFrames = (EndFrame - StartFrame)/Interval;

% Create cell array of frame numbers from video to be analyzed, based on
% start frame and interval
Frames = cell(NumOfFrames,1);
frameCount = 0;
for i = 1:NumOfFrames;
    Frames{i} = num2str(StartFrame + (frameCount.*Interval));
    frameCount = frameCount + 1;
end

% Create cell array of marker names to be displayed in GUI and appear in
% Column 5 of output, AllFramesMarkerLocData. These are the 14 markers which are marked in every
% frame region. 
MarkerPoints = {'Pellet Center',...
    'Center of Back Surface of Paw',...
    'Far Index Finger Joint',...
    'Middle Index Finger Joint',...
    'Near Index Finger Joint',...
    'Far Middle Finger Joint',...
    'Middle Middle Finger Joint',...
    'Near Middle Finger Joint',...
    'Far Ring Finger Joint',...
    'Middle Ring Finger Joint',...
    'Near Ring Finger Joint',...
    'Far Pinky Finger Joint',...
    'Middle Pinky Finger Joint',...
    'Near Pinky Finger Joint'};

% Create cell array of anatomical marker names to be displayed with
% corresponding common marker name in GUI and appear in Column 6 of
% AllFramesMarkerLocData 
AnatMarkerPoints = {'',...
    '',...
    '(Metacarpal-Proximal Phalanges Joint)',...
    '(Proximal-Middle Phalanges Joint)',...
    '(Middle-Distal Phalanges Joint)',...
    '(Metacarpal-Proximal Phalanges Joint)',...
    '(Proximal-Middle Phalanges Joint)',...
    '(Middle-Distal Phalanges Joint)',...
    '(Metacarpal-Proximal Phalanges Joint)',...
    '(Proximal-Middle Phalanges Joint)',...
    '(Middle-Distal Phalanges Joint)',...
    '(Metacarpal-Proximal Phalanges Joint)',...
    '(Proximal-Middle Phalanges Joint)',...
    '(Middle-Distal Phalanges Joint)'};

% Create cell array that will show in GUI which view the user should be
% placing markers in (left, center, or right)
FrameRegionInFocus = {'(Video) Left','Center','(Video) Right'};

% Set total number of markers
TotMarkNum = NumOfFrames.*length(FrameRegionInFocus).*length(MarkerPoints);

% Create list of all markers (with frame, frame region, and common marker
% name info) and populate listbox in GUI to allow for re-doing markers
ReDoMarkerList = cell(TotMarkNum,1);
m = 1; %Represents marker number out of total
for i = 1:length(Frames); %Represents Frames element index
    for j = 1:length(FrameRegionInFocus); %Represents region of focus in frame
        for k = 1:length(MarkerPoints); %Represents marker number out of total marked (14) in every frame region
            ReDoMarkerList{m} = strjoin(cellstr(['Frame' Frames(i) FrameRegionInFocus(j) MarkerPoints(k)]));
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
        for k = 1:length(MarkerPoints);
            AllFramesMarkerLocData{m,1} = m;
            AllFramesMarkerLocData{m,2} = Frames(i);
            AllFramesMarkerLocData{m,3} = FrameRegionInFocus(j);
            AllFramesMarkerLocData{m,4} = k;
            AllFramesMarkerLocData{m,5} = MarkerPoints(k);
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
handles.MarkerPoints = MarkerPoints;
handles.AnatMarkerPoints = AnatMarkerPoints;
handles.FrameRegionInFocus = FrameRegionInFocus;
handles.Frames = Frames;
handles.AllFramesMarkerLocData = AllFramesMarkerLocData;

% Choose default command line output for GUIcreateManualPoints
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Position GUI in middle right part of screen
set(handles.figure1,'Position',[319.8000 17.6923 62.6000 53]);

% UIWAIT makes GUIcreateManualPoints wait for user response (see UIRESUME).
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

begin_button_func = @(hObject,eventdata)GUIcreateManualPoints('begin_button_Callback',hObject,eventdata,guidata(hObject));
handles.begin_button_func = begin_button_func;
guidata(hObject,handles);


    %Import relevant variables from handles structure which were created in
    %opening function
    video = handles.video;
    MarkerPoints = handles.MarkerPoints;
    AnatMarkerPoints = handles.AnatMarkerPoints;
    FrameRegionInFocus = handles.FrameRegionInFocus;
    Frames = handles.Frames;
    AllFramesMarkerLocData = handles.AllFramesMarkerLocData;
    
    % Check to see if the user re-did any markers. If so, resume from the
    % last marker completed before the re-do button was pushed
    % (CurrentMarker). If not, i.e. the user only pressed the Begin button
    % and is starting marking for the first time, start at the first marker
    % (CurrentMarker = 1).
    try
        CurrentMarker = handles.CurrentMarker;
    catch
        CurrentMarker = 1;
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
    for MarkerNum = CurrentMarker:(CurrentMarker+6)%length(AllFramesMarkerLocData(:,1));
        
        %Set current marker to whichever marker is currently being worked
        %on, so user can resume from here after completing re-do's
        CurrentMarker = MarkerNum;
        
        % Update handles structure appropriately
        handles.CurrentMarker = CurrentMarker;
        guidata(hObject, handles);
        
        % Determine the position of the marker's frame number in the array
        % of frame numbers (e.x. the 4th frame for analysis)
        iFrame = AllFramesMarkerLocData{MarkerNum,9}; %length(Frames);
        
        % Determine the region of the frame where the marker should be
        % placed
        iFrameRegion = AllFramesMarkerLocData{MarkerNum,10};
        
        % Display the frame image on the left side of the screen
        im = read(video,str2double(Frames{iFrame}));
        figure;
        imshow(im);
        set(gcf,'Position',[34 141 1530 815]);
        
        % Display in the GUI which region of the frame the user should be
        % marking
        set(handles.frame_reg_in_focus_txtbox,'String',FrameRegionInFocus{iFrameRegion})
        
        % Determine the name of the marker to be placed and display it,
        % along with its anatomical name, in GUI
        iMarker = AllFramesMarkerLocData{MarkerNum,4};
        set(handles.marker_indicator_txtbox,'String',MarkerPoints{iMarker});
        set(handles.marker_indicator2_txtbox,'String',AnatMarkerPoints{iMarker});
        
        % Start marking
            [x,y] = getpts;
       
        % For the pellet center marker...
        if iMarker == 1;
        
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData 
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
            
                % otherwise, function records position data and displays a
                % BLUE circle temporarily where the user indicated the
                % pellet center is
            else                
                AllFramesMarkerLocData(MarkerNum,7) = num2cell(x);
                AllFramesMarkerLocData(MarkerNum,8) = num2cell(y);
                PelletMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Blue');
                imshow(PelletMarkerCircle);
            end
            
            % for the paw center marker...
        elseif iMarker == 2;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
            
                % otherwise, function records position data and displays a
                % RED circle temporarily where the user indicated the paw
                % center is
            else
                AllFramesMarkerLocData(MarkerNum,7) = num2cell(x);
                AllFramesMarkerLocData(MarkerNum,8) = num2cell(y);
                PawCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Red');
                imshow(PawCenterMarkerCircle);
            end
            
            % for the metacarpal phalanges-proximal phalanges (McPh-pPh)
            % joints...
        elseif iMarker == 3 || iMarker == 6 || iMarker == 9 || iMarker == 12;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData.
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
            
                % otherwise, function records position data and displays a
                % GREEN circle temporarily where the user indicated the
                % McPh-pPh joint center is. 
            else
                AllFramesMarkerLocData(MarkerNum,7) = num2cell(x);
                AllFramesMarkerLocData(MarkerNum,8) = num2cell(y);
                McPh_pPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Green');
                imshow(McPh_pPhCenterMarkerCircle);
            end
            
            % for the proximal phalanges-middle phalanges (pPh-mPh)
            % joints...
        elseif iMarker == 4 || iMarker == 7 || iMarker == 10 || iMarker == 13;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData.
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
            
                % otherwise, function records position data and displays a
                % cyan circle temporarily where the user indicated the
                % pPh-mPh joint center is.
            else
                AllFramesMarkerLocData(MarkerNum,7) = num2cell(x);
                AllFramesMarkerLocData(MarkerNum,8) = num2cell(y);
                pPh_mPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Cyan');
                imshow(pPh_mPhCenterMarkerCircle);
            end
            
            % for the middle phalanges-distal phalanges (mPh-dPh) joints...
        elseif iMarker == 5 || iMarker == 8 || iMarker == 11 || iMarker == 14;
            
            % if the user does not click and presses Enter (indicating the
            % marker is not visible), the function inserts a NaN into
            % AllFramesMarkerLocData.
            if isempty(x)||isempty(y);
                AllFramesMarkerLocData(MarkerNum,7) = {NaN};
                AllFramesMarkerLocData(MarkerNum,8) = {NaN};
            
                % otherwise, function records position data and displays a
                % magenta circle temporarily where the user indicated the
                % mPh-dPh joint center is.
            else
                AllFramesMarkerLocData(MarkerNum,7) = num2cell(x);
                AllFramesMarkerLocData(MarkerNum,8) = num2cell(y);
                mPh_dPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Magenta');
                imshow(mPh_dPhCenterMarkerCircle);
            end
        end
        
        % Once the marker's position has been determined and added to
        % AllFramesMarkerLocData, it is exported to the base workspace
        % (just in case the GUI is terminated early) and updated in the
        % handles structure. The frame image is then closed
        assignin('base','CumMarkedMarkersLocations', AllFramesMarkerLocData);
        handles.AllFramesMarkerLocData = AllFramesMarkerLocData;
        guidata(hObject, handles);
        close;
    end
    
    % Once all frames are completed, proceed to output function by allowing
    % the GUI to resume
    uiresume(handles.figure1);

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

% Import video from handles structure
video = handles.video;

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

% Start marking and re-writing selected redo markers
for iSelectedRedoMarkerNum = 1:length(SelectedRedoMarkerNum)
    iMarker = cell2mat(AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),4));
    
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
    
    % Load and show frame in left side of screen
    im = read(video,str2double(AllFramesMarkerLocData{SelectedRedoMarkerNum(iSelectedRedoMarkerNum),2}));
    figure;
    imshow(im);
    set(gcf,'Position',[34 141 1530 815]);
    
    % Start marking selected marker(s)
    [x,y] = getpts;
    
    % for the pellet marker...
    if iMarker == 1;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
        
            % otherwise, function records position data and displays a BLUE
            % circle temporarily where the user indicated the pellet center
            % is
        else
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(x);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(y);
            PelletMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Blue');
            imshow(PelletMarkerCircle);
        end
        
        % for the paw center marker...
    elseif iMarker == 2;

        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            
            % otherwise, function records position data and displays a RED
            % circle temporarily where the user indicated the paw center is
        else
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(x);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(y);
            PawCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Red');
            imshow(PawCenterMarkerCircle);
        end
        
        % for the metacarpal phalanges-proximal phalanges (McPh-pPh)
        % joints...
    elseif iMarker == 3 || iMarker == 6 || iMarker == 9 || iMarker == 12;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData.
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};

            % otherwise, function records position data and displays a
            % GREEN circle temporarily where the user indicated the
            % McPh-pPh joint center is.
        else
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(x);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(y);
            McPh_pPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Green');
            imshow(McPh_pPhCenterMarkerCircle);
        end
        
        % for the proximal phalanges-middle phalanges (pPh-mPh) joints...
    elseif iMarker == 4 || iMarker == 7 || iMarker == 10 || iMarker == 13;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData.
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            
            % otherwise, function records position data and displays a cyan
            % circle temporarily where the user indicated the pPh-mPh joint
            % center is.
        else
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(x);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(y);
            pPh_mPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Cyan');
            imshow(pPh_mPhCenterMarkerCircle);
        end
        
        % for the middle phalanges-distal phalanges (mPh-dPh) joints...
    elseif iMarker == 5 || iMarker == 8 || iMarker == 11 || iMarker == 14;
        
        % if the user does not click and presses Enter (indicating the
        % marker is not visible), the function inserts a NaN into
        % AllFramesMarkerLocData 
        if isempty(x)||isempty(y);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = {NaN};
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = {NaN};
            
            % otherwise, function records position data and displays a
            % magenta circle temporarily where the user indicated the
            % mPh-dPh joint center is.
        else
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),7) = num2cell(x);
            AllFramesMarkerLocData(SelectedRedoMarkerNum(iSelectedRedoMarkerNum),8) = num2cell(y);
            mPh_dPhCenterMarkerCircle = insertShape(im, 'FilledCircle', [x,y,8], 'Color', 'Magenta');
            imshow(mPh_dPhCenterMarkerCircle);
        end
    end  
        
    % Once the marker's position has been determined and added to
    % AllFramesMarkerLocData, it is exported to the base workspace
    % (just in case the GUI is terminated early) and updated in the
    % handles structure. The frame image is then closed
    assignin('base','CumMarkedMarkersLocations', AllFramesMarkerLocData);
    handles.AllFramesMarkerLocData = AllFramesMarkerLocData;
    guidata(hObject, handles);
    close;
end

% When all the re-do markers are completed, the user must hit resume to
% continue marking points or finish the marking.
uiwait(msgbox({'Please press resume' 'on the Paw Point Creation Tool' 'to continue or finish marking'},'modal'));
return
% begin_button_func = handles.begin_button_func;
% begin_button_func(handles.begin_button, eventdata);

%% Output Function
% Tells function to close the GUI and export output,
% AllFramesMarkerLocData (created in begin_button_Callback function).

% --- Outputs from this function are returned to the command line.
function varargout = GUIcreateManualPoints_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT); hObject
% handle to figure eventdata  reserved - to be defined in a future version
% of MATLAB handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure varargout{1} =
% handles.output; 

try
    close(handles.figure1);
    varargout{1} = handles.AllFramesMarkerLocData;
    delete(handles.figure1);
    close all;
catch
    
    % If the program is closed unexpectedly, data recorded up to that point
    % is saved in CumMarkedMarkersLocations on base workspace.
    % AllFramesMarkerLocData is set to a string that conveys the error message.
    varargout{1} = 'Program closed unexpectedly. Data saved under CumMarkedMarkersLocations';
    uiwait(msgbox({'Program closed unexpectedly' 'Data saved under CumMarkedMarkersLocations'},'modal'));
    close all
end

%% Closing figure (without or without completion of AllFramesMarkerLocData)
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure delete(hObject);
try
    varargout{1} = handles.CumMarkedMarkersLocations;
    delete(hObject);
    close all;
catch
    
    % If the user attempts to close the function early, an error message
    % pops up, letting the user know program closed and where the data was
    % saved.
    varargout{1} = 'Program closed unexpectedly. Data saved under CumMarkedMarkersLocations'; %#ok<*NASGU>
    delete(hObject);
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
% -Check Other Outputs to Base Workspace Section in Intro -WHAT IF THEY
% SPECIFY # OF FRAMES WITHOUT SPECIFYING END FRAME AND/OR INTERVAL?
% Incorporate check for at least 2/3. 
% -Export output to Excel in processed data folder
% -Remove limiters to marker placement put in for testing
% -Frame image shouldn't keep loading, just load once for a given set of
% markers
% -Keep circles on screen for duration of marking a given region of the
% frame
% - Remove references to MarkerPoints and AnatMarkerPoints and other arrays
% that are already contained in AllFramesMarkerLocData
