function varargout = GUIcreateFrameStart_2015_06_19(varargin)
%% DELINEATE INPUT AND WAY FUNCTION MUST BE WRITTEN

%% GUIcreateFrameStart_2015_06_19 MATLAB code for GUIcreateFrameStart_2015_06_19.fig
%      GUIcreateFrameStart_2015_06_19, by itself, creates a new GUIcreateFrameStart_2015_06_19 or raises the existing
%      singleton*. It is used in 
%
%      H = GUIcreateFrameStart_2015_06_19 returns the handle to a new GUIcreateFrameStart_2015_06_19 or the handle to
%      the existing singleton*.
%
%      GUIcreateFrameStart_2015_06_19('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIcreateFrameStart_2015_06_19.M with the given input arguments.

%% INPUTS
% 
% # RatData : Structure array containing the following fields
%
    % * DateFolders: Listing of the paths of all date folders in rat's raw data folder
    % * VideoFiles: Structural array containing info about all video files (.avi files) in a given date folder. Fields include name, data, bytes, isdir, datenum, ManualStartFrame (manually determined start frame), AutomaticTriggerFrame(automatically determined trigger frame by identifyTriggerFrame function in createManualPawData script, may be removed later), AutomaticPeakFrame (automatically determined peak frame by identifyTriggerFrame function in createManualPawData script, may be removed later), Agree (0 if manual start frame and automatic peak frame do not agree, 1 if they do), ROI_Used, Paw_Preference (encodes previous manually determined information about paw used in video, dominant/marked or non-dominant/unmarked)
    % * Accuracy: Average accuracy of identifyTriggerFrame function for a given session, may be removed later
% 
% # i: Number representing session for a given rat, coded before use of function in createManualPawData script
% # j: Number representing video for given session, coded before use of function in createManualPawData script 
% # RatDir: Rat's raw data folder chosen by the user before function use in
% createManualPawData
% # RatLookUp: directory of files contained in RatDir
% # RatID: Rat's ID (e.g. R0027), determined from filepath for RatDir in 
% createManualPawData
%
%      GUIcreateFrameStart_2015_06_19('Property','Value',...) creates a new GUIcreateFrameStart_2015_06_19 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIcreateFrameStart_2015_06_19_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIcreateFrameStart_2015_06_19_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
     

% Edit the above text to modify the response to help GUIcreateFrameStart_2015_06_19

% Last Modified by GUIDE v2.5 19-Jun-2015 16:25:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIcreateFrameStart_2015_06_19_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIcreateFrameStart_2015_06_19_OutputFcn, ...
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


% --- Executes just before GUIcreateFrameStart_2015_06_19 is made visible.
function GUIcreateFrameStart_2015_06_19_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIcreateFrameStart_2015_06_19 (see VARARGIN)

if nargin > 0 ;
    RatData = varargin{1};
    i = varargin{2};
    j = varargin{3};
end

set(handles.video_path_txtbox,'string',fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name));

% Choose default command line output for GUIcreateFrameStart_2015_06_19
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIcreateFrameStart_2015_06_19 wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIcreateFrameStart_2015_06_19_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
try
    StartFrameOrNaN = str2double(get(handles.UI_start_frame_txtbox,'String'));
    varargout{1} = StartFrameOrNaN;
    uiresume(handles.figure1);
catch
    StartFrameOrNaN = NaN;
    varargout{1} = StartFrameOrNaN;
end        
close;

function UI_start_frame_txtbox_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to UI_start_frame_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UI_start_frame_txtbox as text
%        str2double(get(hObject,'String')) returns contents of UI_start_frame_txtbox as a double


% --- Executes during object creation, after setting all properties.
function UI_start_frame_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UI_start_frame_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on button press in redo_button.
function redo_button_Callback(hObject, eventdata, handles)
% hObject    handle to redo_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.UI_start_frame_txtbox,'String','NaN');
uiresume(handles.figure1);

% --- Executes on selection change in video_file_list.
function video_file_list_Callback(hObject, eventdata, handles)
% hObject    handle to video_file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns video_file_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from video_file_list


% --- Executes during object creation, after setting all properties.
function video_file_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function video_path_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_path_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function rat_date_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rat_date_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function UI_start_frame_txtbox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to UI_start_frame_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function video_path_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to video_path_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of video_path_txtbox as text
%        str2double(get(hObject,'String')) returns contents of video_path_txtbox as a double


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over done_button.
function done_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipanel1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
