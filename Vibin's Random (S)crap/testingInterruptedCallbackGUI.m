function varargout = testingInterruptedCallbackGUI(varargin)
% TESTINGINTERRUPTEDCALLBACKGUI MATLAB code for testingInterruptedCallbackGUI.fig
%      TESTINGINTERRUPTEDCALLBACKGUI, by itself, creates a new TESTINGINTERRUPTEDCALLBACKGUI or raises the existing
%      singleton*.
%
%      H = TESTINGINTERRUPTEDCALLBACKGUI returns the handle to a new TESTINGINTERRUPTEDCALLBACKGUI or the handle to
%      the existing singleton*.
%
%      TESTINGINTERRUPTEDCALLBACKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTINGINTERRUPTEDCALLBACKGUI.M with the given input arguments.
%
%      TESTINGINTERRUPTEDCALLBACKGUI('Property','Value',...) creates a new TESTINGINTERRUPTEDCALLBACKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testingInterruptedCallbackGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testingInterruptedCallbackGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testingInterruptedCallbackGUI

% Last Modified by GUIDE v2.5 05-Jun-2015 11:34:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testingInterruptedCallbackGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testingInterruptedCallbackGUI_OutputFcn, ...
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


% --- Executes just before testingInterruptedCallbackGUI is made visible.
function testingInterruptedCallbackGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testingInterruptedCallbackGUI (see VARARGIN)

% Choose default command line output for testingInterruptedCallbackGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testingInterruptedCallbackGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testingInterruptedCallbackGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 % disable the start button
 set(hObject,'Enable','off');
 % enable the halt button
 set(handles.halt,'Enable','on');
 % flag that the loop is running
 handles.doLoop = true;
 guidata(hObject,handles);
 % start loop
 fprintf('starting while loop\n');
 while true
   % do stuff 
   x = 0:(pi/10):2*pi;
   figure;
   plot(sin(x));
   % should we continue?
   handles = guidata(hObject);
   if ~handles.doLoop
       break;
   end
 end
 fprintf('exiting while loop\n');
 % enable the start button
 set(hObject,'Enable','on');
 % disable the halt button
 set(handles.halt,'Enable','off');
 
% --- Executes on button press in halt.
function halt_Callback(hObject, eventdata, handles)
% hObject    handle to halt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
