function varargout = Main(varargin)
% MAIN M-file for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 01-Mar-2012 16:35:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Main_OpeningFcn, ...
    'gui_OutputFcn',  @Main_OutputFcn, ...
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
end


% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in autoguide.
function autoguide_Callback(hObject, eventdata, handles)
% hObject    handle to autoguide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of autoguide
global mag_guide_on
evalin('base','mag_guide82_rate=0;'); % clear rate calculation always
evalin('base','mag_guide82_offset_counter = 0;');
evalin('base','mag_guide82_offset = 0;');
evalin('base','mag_guide82_timer = tic;'); % restart 2-minute timer
mag_guide_on = fix(get(hObject,'Value'));
if mag_guide_on == 0
    set(hObject,'BackgroundColor',[0.9255    0.9137    0.8471]);
    set(handles.messages,'string','');
else
    set(hObject,'BackgroundColor','red');
end
end

% --- Executes on button press in repeat.
function repeat_Callback(hObject, eventdata, handles)
% hObject    handle to repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of repeat
global mag_exposure_on
set(handles.messages,'string',''); % Clear messages
if mag_exposure_on == 0 % allow repeat if we're not already repeating
    mag_exposure_on = 1; % allow entry into mag_start_exposure
    set(hObject,'Value',1); % force hilite to agree with mag_exposure_on
    set(hObject,'BackgroundColor','red');
else
    mag_exposure_on = 0; % Tell mag_start_exposure to bypass exposure
    set(hObject,'Value',0);
    set(hObject,'BackgroundColor',[0.9255    0.9137    0.8471]);
end
evalin('base','mag_stop_exposure=1;'); % interrupt exposure
end


function seconds_Callback(hObject, eventdata, handles)
% hObject    handle to seconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seconds as text
%        str2double(get(hObject,'String')) returns contents of seconds as a double
global mag_exposure_time mag_exposure_on
% N.B. internally negative exposure time means single exposure
mag_single = sign(mag_exposure_time);
mag_exposure_time = str2double(get(hObject,'String'));
if isnan(mag_exposure_time) || mag_exposure_time < 0 % just reset jibberish to startup value of 1
    set(hObject,'String','1');
    mag_exposure_time = 1;
end
if mag_exposure_time < 0.125 % force a minimum exposure time
    set(hObject,'String','0.125');
    mag_exposure_time = 0.125;
end
if mag_exposure_on == 1
    evalin('base','mag_stop_exposure=1;');
end
mag_exposure_time = mag_single*mag_exposure_time;
end


% --- Executes during object creation, after setting all properties.
function seconds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seconds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function width_Callback(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width as text
%        str2double(get(hObject,'String')) returns contents of width as a double

mag_width = fix(str2double(get(hObject,'String')));
if isnan(mag_width) || mag_width < 32 % minimum half window size
    set(hObject,'String','31');
end
if mag_width > 500 % Maximum window size is 511
    set(hObject,'String','511');
end
end


% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mag_average_adu mag_average_mf
mag_average_adu = 0; % reset
mag_average_mf = 0;
set(handles.avFWHM,'value',0,'string',0);
set(handles.avfloor,'value',0,'string',0);
set(handles.avpeak,'value',0,'string',0);
end


% --- Executes on button press in cooler.
function cooler_Callback(hObject, eventdata, handles)
% hObject    handle to cooler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cooler
global h mag_exposure_on mag_log mag_camera
if mag_camera==1 % Apogee
    if mag_exposure_on == 0 % ActiveX control is exclusive
        try
            h.ShowTempDialog; % ActiveX panel
        catch
            fprintf(mag_log,['Cooler dialog error.' sprintf('\n')]);
            questdlg('Cooler dialog error. Please pull the USB cable and plug it again. Guide82 will Quit.','Question','OK','OK');
            exit
        end
    end
end
if mag_camera==2 % SBIG
    evalin('base','mag_sbig_cooler'); % Deal with low level driver.
end
if mag_camera==3 % QSI
    evalin('base','mag_qsi_cooler'); % Deal with low level driver.
end
end


function delay_Callback(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay as text
%        str2double(get(hObject,'String')) returns contents of delay as a double
global mag_delay_time
mag_delay_time = str2double(get(hObject,'String'));
if isnan(mag_delay_time) || mag_delay_time < 0 % just reset jibberish to startup value of 1
    set(hObject,'String','1');
    mag_delay_time = 1;
end
end

% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in save_markers.
function save_markers_Callback(hObject, eventdata, handles)
% hObject    handle to save_markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','mag_save'); % run script in base workspace context
end

% --- Executes on button press in load_markers.
function load_markers_Callback(hObject, eventdata, handles)
% hObject    handle to load_markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','mag_load'); % run script in base workspace context
end


% --- Executes on button press in slit.
function slit_Callback(hObject, eventdata, handles)
% hObject    handle to slit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slit
evalin('base','mag_view_slit'); % run script in base workspace context
set(handles.field,'value',0);
end

% --- Executes on button press in field.
function field_Callback(hObject, eventdata, handles)
% hObject    handle to field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of field
evalin('base','mag_view_field'); % run script in base workspace context
set(handles.slit,'value',0);
end


% --- Executes on button press in inc_box.
function inc_box_Callback(hObject, eventdata, handles)
% hObject    handle to inc_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mag_width = fix(str2double(get(handles.width,'String')));
mag_width = mag_width + 10;
if isnan(mag_width) || mag_width < 31 % minimum half window size is 5
    mag_width = 31;
end
if mag_width > 511 % Maximum window size is 500
    mag_width = 511;
end
set(handles.width,'String',num2str(mag_width));
end


% --- Executes on button press in dec_box.
function dec_box_Callback(hObject, eventdata, handles)
% hObject    handle to dec_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mag_width = fix(str2double(get(handles.width,'String')));
mag_width = mag_width - 10;
if isnan(mag_width) || mag_width < 31 % minimum half window size is 5
    mag_width = 31;
end
if mag_width > 511 % Maximum window size is 500
    mag_width = 511;
end
set(handles.width,'String',num2str(mag_width));
end


% --- Executes on button press in inc_exp.
function inc_exp_Callback(hObject, eventdata, handles)
% hObject    handle to inc_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mag_exposure_time mag_exposure_on
% N.B. internally negative exposure time means single exposure
mag_single = sign(mag_exposure_time);
mag_exposure_time = str2double(get(handles.seconds,'String'));
mag_exposure_time = mag_exposure_time * 2;
if isnan(mag_exposure_time) || mag_exposure_time < 0 % just reset jibberish to startup value of 1
    mag_exposure_time = 1;
end
if mag_exposure_time < 0.125 % force a minimum exposure time
    mag_exposure_time = 0.125;
end
if mag_exposure_on == 1
    evalin('base','mag_stop_exposure=1;');
end
set(handles.seconds,'String',num2str(mag_exposure_time));
mag_exposure_time = mag_single*mag_exposure_time;
end


% --- Executes on button press in dec_exp.
function dec_exp_Callback(hObject, eventdata, handles)
% hObject    handle to dec_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mag_exposure_time mag_exposure_on
% N.B. internally negative exposure time means single exposure
mag_single = sign(mag_exposure_time);
mag_exposure_time = str2double(get(handles.seconds,'String'));
mag_exposure_time = mag_exposure_time / 2;
if isnan(mag_exposure_time) || mag_exposure_time < 0 % just reset jibberish to startup value of 1
    mag_exposure_time = 1;
end
if mag_exposure_time < 0.125 % force a minimum exposure time
    mag_exposure_time = 0.125;
end
if mag_exposure_on == 1
    evalin('base','mag_stop_exposure=1;');
end
set(handles.seconds,'String',num2str(mag_exposure_time));
mag_exposure_time = mag_single*mag_exposure_time;
end


% --- Executes on button press in inc_delay.
function inc_delay_Callback(hObject, eventdata, handles)
% hObject    handle to inc_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mag_delay_time
mag_delay_time = str2double(get(handles.delay,'String'));
mag_delay_time = mag_delay_time + 1;
if isnan(mag_delay_time) || mag_delay_time < 0 % just reset jibberish to startup value of 1
    set(handles.delay,'String','1');
    mag_delay_time = 1;
else
    set(handles.delay,'String',num2str(mag_delay_time));
end
end


% --- Executes on button press in dec_delay.
function dec_delay_Callback(hObject, eventdata, handles)
% hObject    handle to dec_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global mag_delay_time
mag_delay_time = str2double(get(handles.delay,'String'));
mag_delay_time = mag_delay_time - 1;
if isnan(mag_delay_time) || mag_delay_time < 0 % just reset jibberish to startup value of 1
    set(handles.delay,'String','1');
    mag_delay_time = 1;
else
    set(handles.delay,'String',num2str(mag_delay_time));
end
end


% --- Executes on button press in focus.
function focus_Callback(hObject, eventdata, handles)
% hObject    handle to focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','mag_focus_done=-1;'); % Tell event loop to make a window
end


% --- Executes on selection change in bin.
function bin_Callback(hObject, eventdata, handles)
% hObject    handle to bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bin contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bin
evalin('base','mag_m_clear=1;');
end

% --- Executes during object creation, after setting all properties.
function bin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
