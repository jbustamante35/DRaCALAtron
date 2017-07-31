function varargout = changeRadii(varargin)
% CHANGERADII MATLAB code for changeRadii.fig
%      CHANGERADII, by itself, creates a new CHANGERADII or raises the existing
%      singleton*.
%
%      H = CHANGERADII returns the handle to a new CHANGERADII or the handle to
%      the existing singleton*.
%
%      CHANGERADII('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANGERADII.M with the given input arguments.
%
%      CHANGERADII('Property','Value',...) creates a new CHANGERADII or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before changeRadii_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to changeRadii_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help changeRadii

% Last Modified by GUIDE v2.5 28-Jul-2017 15:24:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @changeRadii_OpeningFcn, ...
                   'gui_OutputFcn',  @changeRadii_OutputFcn, ...
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


% --- Executes just before changeRadii is made visible.
function changeRadii_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to changeRadii (see VARARGIN)

% Choose default command line output for changeRadii
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using changeRadii.

% global im_default
if strcmp(get(hObject,'Visible'),'off')
    if (ispc == 1)        
        im_default = imread('Images\QD_logoBlack.jpg');
    elseif (isunix == 1)
        im_default = imread('Images/QD_logoBlack.jpg');
    else
        im_default = imread('coins.png');
    end    
    imagesc(im_default), axis image, axis off;    
end

% UIWAIT makes changeRadii wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global cCoords oldCircInn oldCircOut oldRadiusIn oldRadiusOut
 
im_spot = getappdata(0, 'spotHit_image');
imageLimits = getappdata(0, 'imLimits');
imagesc(im_spot, imageLimits), colormap gray, axis image, axis off;
[cRow, cColumn, ~] = size(im_spot);

cCoords = [cColumn/2 cRow/2];

oldRadiusIn = getappdata(0, 'radiusIn');
oldRadiusOut = getappdata(0, 'radiusOut');

oldCircInn = viscircles(cCoords, oldRadiusIn, 'color', 'b'); % Blue inner circle
oldCircOut = viscircles(cCoords, oldRadiusOut, 'color', 'g'); % Green outer circle

oldRadiusIn = getappdata(0, 'radiusIn');
oldRadiusOut = getappdata(0, 'radiusOut');
set(handles.innerRadiusAdjust_slider, 'Value', oldRadiusIn);
set(handles.outerRadiusAdjust_slider, 'Value', oldRadiusOut);

chosenSpot = getappdata(0, 'hit'); % Get Spot index # from main GUI
set(handles.templateSpot_outputbox, 'String', num2str(chosenSpot));
set(handles.oldInner_outputbox, 'String', num2str(oldRadiusIn));
set(handles.oldOuter_outputbox, 'String', num2str(oldRadiusOut));
set(handles.changeRadiusIn_outputbox, 'String', num2str(oldRadiusIn));
set(handles.changeRadiusOut_outputbox, 'String', num2str(oldRadiusOut));


% --- Outputs from this function are returned to the command line.
function varargout = changeRadii_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function radiusAdjust_axis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiusAdjust_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate radiusAdjust_axis

% global cCoords oldCircInn oldCircOut oldRadiusIn oldRadiusOut
%  
% im_spot = getappdata(0, 'spotHit_image');
% imageLimits = getappdata(0, 'imLimits');
% imagesc(im_spot, imageLimits), colormap gray, axis image, axis off;
% [cRow, cColumn, ~] = size(im_spot);
% 
% cCoords = [cColumn/2 cRow/2];
% 
% oldRadiusIn = getappdata(0, 'radiusIn');
% oldRadiusOut = getappdata(0, 'radiusOut');
% 
% oldCircInn = viscircles(cCoords, oldRadiusIn, 'color', 'b'); % Blue inner circle
% oldCircOut = viscircles(cCoords, oldRadiusOut, 'color', 'g'); % Green outer circle
% 
% oldRadiusIn = getappdata(0, 'radiusIn');
% oldRadiusOut = getappdata(0, 'radiusOut');
% set(handles.innerRadiusAdjust_slider, 'Value', oldRadiusIn);
% set(handles.outerRadiusAdjust_slider, 'Value', oldRadiusOut);
% 
% chosenSpot = getappdata(0, 'hit'); % Get Spot index # from main GUI
% set(handles.templateSpot_outputbox, 'Value', chosenSpot);
% set(handles.oldInner_outputbox, 'String', num2str(oldRadiusIn));
% set(handles.oldOuter_outputbox, 'String', num2str(oldRadiusOut));





% --- Executes on slider movement.
function innerRadiusAdjust_slider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global newRadiusIn cCoords oldCircInn newCircInn

axes(handles.radiusAdjust_axis);
delete(oldCircInn);
newRadiusIn = get(hObject, 'Value');
set(handles.changeRadiusIn_outputbox, 'String', num2str(newRadiusIn));

newCircInn = viscircles(cCoords, newRadiusIn, 'color', 'b');
oldCircInn = newCircInn;



% --- Executes during object creation, after setting all properties.
function innerRadiusAdjust_slider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% Adjust size of Inner Radius
initialValueInn = getappdata(0, 'radiusIn');
set(hObject, 'Value', initialValueInn);
set(hObject, 'Min', 0);
set(hObject, 'Max', 50);



function changeRadiusIn_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of changeRadiusIn_outputbox as text
%        str2double(get(hObject,'String')) returns contents of changeRadiusIn_outputbox as a double


% --- Executes during object creation, after setting all properties.
function changeRadiusIn_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on slider movement.
function outerRadiusAdjust_slider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global newRadiusOut cCoords oldCircOut newCircOut

axes(handles.radiusAdjust_axis);
delete(oldCircOut);
newRadiusOut = get(hObject, 'Value');
set(handles.changeRadiusOut_outputbox, 'String', num2str(newRadiusOut));

newCircOut = viscircles(cCoords, newRadiusOut, 'color', 'g');
oldCircOut = newCircOut;

% --- Executes during object creation, after setting all properties.
function outerRadiusAdjust_slider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% Adjust size of Outer Radius
initialValueOut = getappdata(0, 'radiusOut');
set(hObject, 'Value', initialValueOut);
set(hObject, 'Min', 0);
set(hObject, 'Max', 50);

function changeRadiusOut_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of changeRadiusOut_outputbox as text
%        str2double(get(hObject,'String')) returns contents of changeRadiusOut_outputbox as a double



% --- Executes during object creation, after setting all properties.
function changeRadiusOut_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in confirmNewRadii_button.
function confirmNewRadii_button_Callback(hObject, eventdata, handles)
global newRadiusOut newRadiusIn oldRadiusIn oldRadiusOut
% Clear all app data from root handle [better yet, change handle with this data
allAppData = fieldnames(getappdata(0));
for i = 1:length(allAppData)
    rmappdata(0, allAppData{i});
end
delete(findall(handles.radiusAdjust_axis, 'Type', 'hggroup'));
delete(findall(handles.radiusAdjust_axis, 'Type', 'image'));
delete(findall(handles.radiusAdjust_axis, 'Type', 'text'));

newRadiusIn = str2double(get(handles.changeRadiusIn_outputbox, 'String'));
newRadiusOut = str2double(get(handles.changeRadiusOut_outputbox, 'String'));
setappdata(0, 'newRadiusIn', newRadiusIn);
setappdata(0, 'newRadiusOut', newRadiusOut);
questdlg(sprintf('Old Inner Radius: %0.0f \t \t New Inner Radius: %0.0f\nOld Outer Radius: %0.0f \t \t New Outer Radius: %0.0f', oldRadiusIn, newRadiusIn, oldRadiusOut, newRadiusOut),...
            'Confirm New Radii Sizes', 'warn');


% uiwait(gcf);
close(gcf);

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end


function templateSpot_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of templateSpot_outputbox as text
%        str2double(get(hObject,'String')) returns contents of templateSpot_outputbox as a double


% --- Executes during object creation, after setting all properties.
function templateSpot_outputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to templateSpot_outputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function oldInner_outputbox_Callback(hObject, eventdata, handles)
% hObject    handle to oldInner_outputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of oldInner_outputbox as text
%        str2double(get(hObject,'String')) returns contents of oldInner_outputbox as a double


% --- Executes during object creation, after setting all properties.
function oldInner_outputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldInner_outputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function oldOuter_outputbox_Callback(hObject, eventdata, handles)
% hObject    handle to oldOuter_outputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of oldOuter_outputbox as text
%        str2double(get(hObject,'String')) returns contents of oldOuter_outputbox as a double


% --- Executes during object creation, after setting all properties.
function oldOuter_outputbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldOuter_outputbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
