function varargout = GUIcreateManualPointsVP(varargin)
%% USAGE:
% Used within createManualPawData script in the following format:
% [pellet_center_x{i,j}, pellet_center_y{i,j},manual_paw_centers{i,j},mcp_hulls{i,j},mph_hulls{i,j},dph_hulls{i,j}] = GUIcreateManualPointsVP(VideoFilePath,StartFrame)

%% INPUTS
% 
% # VideoFilePath: filepath to video under analysis 
% # StartFrame: manually determined start frame ****(NEEDS TO BE UPDATED IN
% CREATEMANUALPAWDATAVPEDITS2015_05_08)****
%
%% OUTPUTS
% # pellet_center_x:
% # pellet_center_y:
% # manual_paw_centers: 
% # mcp_hulls:
% # mph_hulls:
% # dph_hulls:

%% GUICREATEMANUALPOINTSVP MATLAB code for GUIcreateManualPointsVP.fig
%      GUICREATEMANUALPOINTSVP, by itself, creates a new GUICREATEMANUALPOINTSVP or raises the existing
%      singleton*. It is used in the createManualPawData script to load a GUI which helps the user mark the paw points used in later analysis.
%
%      H = GUICREATEMANUALPOINTSVP returns the handle to a new GUICREATEMANUALPOINTSVP or the handle to
%      the existing singleton*.
%
%      GUICREATEMANUALPOINTSVP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUICREATEMANUALPOINTSVP.M with the given input arguments.
%
%      GUICREATEMANUALPOINTSVP('Property','Value',...) creates a new GUICREATEMANUALPOINTSVP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIcreateManualPointsVP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIcreateManualPointsVP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIcreateManualPointsVP

% Last Modified by GUIDE v2.5 12-May-2015 23:47:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIcreateManualPointsVP_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIcreateManualPointsVP_OutputFcn, ...
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


% --- Executes just before GUIcreateManualPointsVP is made visible.
function GUIcreateManualPointsVP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIcreateManualPointsVP (see VARARGIN)

% if nargin > 0 ;
%     RatData = varargin{1};
%     i = varargin{2};
%     j = varargin{3};
%     StartFrame = varargin{4};
% end
% EndFrame = StartFrame+40;
% video = VideoReader(fullfile(RatData(i).DateFolders,RatData(i).VideoFiles(j).name));
% 
% handles.RatData = RatData;
% handles.i = i;
% handles.j = j;
% handles.StartFrame = StartFrame;
% handles.EndFrame = EndFrame;
% handles.video = video;
% for k = StartFrame:10:EndFrame;
%     im = read(video,k);
%     imshow(im);
%     for m = 1:length(MarkerPoints);
%         set(handles.marker_indicator_txtbox,'String',MarkerPoints{m});
%     end        
% end
% MarkerPoints = {'Pellet Center',...
%     'Center of Back Surface of Paw',...
%     'Far Thumb Joint (Metacarpal-Proximal Phalanges)',...
%     'Near Thumb Joint (Proximal-Distal Phalanges)',...
%     'Far Index Finger Joint (Metacarpal-Proximal Phalanges)',...
%     'Middle Index Finger Joint (Proximal-Middle Phalanges)',...
%     'Near Index Finger Joint (Middle-Distal Phalanges)',...
%     'Far Middle Finger Joint (Metacarpal-Proximal Phalanges)',...
%     'Middle Middle Finger Joint (Proximal-Middle Phalanges)',...
%     'Near Middle Finger Joint (Middle-Distal Phalanges)',...
%     'Far Ring Finger Joint (Metacarpal-Proximal Phalanges)',...
%     'Middle Ring Finger Joint (Proximal-Middle Phalanges)',...
%     'Near Ring Finger Joint (Middle-Distal Phalanges)',...
%     'Far Pinky Finger Joint (Metacarpal-Proximal Phalanges)',...
%     'Middle Pinky Finger Joint (Proximal-Middle Phalanges)',...
%     'Near Pinky Finger Joint (Middle-Distal Phalanges)'};
% for k = 1:length(MarkerPoints);
%     set(hObject,'String',MarkerPoints{k});
%     [MarkerPoints_x{k},MarkerPoints_y{k}] = getpts
% end
handles.ref = 'blarg';

% Choose default command line output for GUIcreateManualPointsVP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIcreateManualPointsVP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIcreateManualPointsVP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


% --- Executes on button press in not_visible_button.
function not_visible_button_Callback(hObject, eventdata, handles)
% hObject    handle to not_visible_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
