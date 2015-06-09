function varargout = GUImanualPointsChecklist(varargin)
% GUIMANUALPOINTSCHECKLIST MATLAB code for GUImanualPointsChecklist.fig
%      GUIMANUALPOINTSCHECKLIST, by itself, creates a new GUIMANUALPOINTSCHECKLIST or raises the existing
%      singleton*.
%
%      H = GUIMANUALPOINTSCHECKLIST returns the handle to a new GUIMANUALPOINTSCHECKLIST or the handle to
%      the existing singleton*.
%
%      GUIMANUALPOINTSCHECKLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIMANUALPOINTSCHECKLIST.M with the given input arguments.
%
%      GUIMANUALPOINTSCHECKLIST('Property','Value',...) creates a new GUIMANUALPOINTSCHECKLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUImanualPointsChecklist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUImanualPointsChecklist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUImanualPointsChecklist

% Last Modified by GUIDE v2.5 04-Jun-2015 12:07:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUImanualPointsChecklist_OpeningFcn, ...
                   'gui_OutputFcn',  @GUImanualPointsChecklist_OutputFcn, ...
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


% --- Executes just before GUImanualPointsChecklist is made visible.
function GUImanualPointsChecklist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUImanualPointsChecklist (see VARARGIN)

% Choose default command line output for GUImanualPointsChecklist
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUImanualPointsChecklist wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUImanualPointsChecklist_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function marker_name_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to marker_name_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of marker_name_txtbox as text
%        str2double(get(hObject,'String')) returns contents of marker_name_txtbox as a double


% --- Executes during object creation, after setting all properties.
function marker_name_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_name_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frame_region_in_focus_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to frame_region_in_focus_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_region_in_focus_txtbox as text
%        str2double(get(hObject,'String')) returns contents of frame_region_in_focus_txtbox as a double


% --- Executes during object creation, after setting all properties.
function frame_region_in_focus_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_region_in_focus_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function marker_anatomical_name_txtbox_Callback(hObject, eventdata, handles)
% hObject    handle to marker_anatomical_name_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of marker_anatomical_name_txtbox as text
%        str2double(get(hObject,'String')) returns contents of marker_anatomical_name_txtbox as a double


% --- Executes during object creation, after setting all properties.
function marker_anatomical_name_txtbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_anatomical_name_txtbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SlideNumberPopUpMenu.
function SlideNumberPopUpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SlideNumberPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SlideNumberPopUpMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SlideNumberPopUpMenu


% --- Executes during object creation, after setting all properties.
function SlideNumberPopUpMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SlideNumberPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in MarkerPopUpMenu.
function MarkerPopUpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to MarkerPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MarkerPopUpMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MarkerPopUpMenu


% --- Executes during object creation, after setting all properties.
function MarkerPopUpMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkerPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
