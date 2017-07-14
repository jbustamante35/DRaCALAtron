function varargout = QuantDraCALA(varargin)
% INSERT HELP HERE
% - Functions that output plots/figures/etc. after post-analysis
% - Blah blah blah
% 
% 
% 
% QUANTDRACALA MATLAB code for QuantDraCALA.fig
%      QUANTDRACALA, by itself, creates a new QUANTDRACALA or raises the existing
%      singleton*.
%
%      H = QUANTDRACALA returns the handle to a new QUANTDRACALA or the handle to
%      the existing singleton*.
%
%      QUANTDRACALA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUANTDRACALA.M with the given input arguments.
%
%      QUANTDRACALA('Property','Value',...) creates a new QUANTDRACALA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QuantDraCALA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QuantDraCALA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QuantDraCALA

% Last Modified by GUIDE v2.5 13-Jul-2017 17:20:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QuantDraCALA_OpeningFcn, ...
                   'gui_OutputFcn',  @QuantDraCALA_OutputFcn, ...
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

% --- Executes just before QuantDraCALA is made visible.
function QuantDraCALA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QuantDraCALA (see VARARGIN)

% Choose default command line output for QuantDraCALA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using QuantDraCALA.

% Welcome messages from QuantDRaCALA and CuteDRaCALA
if strcmp(get(hObject,'Visible'),'off')
   
   axes(handles.mainFig_axis);
   
   %  Determine user's OS
   if (ispc == 1)
       im_default = imread('Images\countDracula.jpg');
       im_singleSpot_default = imread('Images\cuteDracula.png');

   elseif (isunix == 1)
       im_default = imread('Images/countDracula.jpg');
       im_singleSpot_default = imread('Images/cuteDracula.png');

   else
       im_default = imread('coins.png');
       im_singleSpot_default = imread('coins.png');

   end
   
   imagesc(im_default), colormap gray, axis image, axis off;
   text(350, 25, 'Press Load Images', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold');
   text(400, 45, 'to Starrrt!!!', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold');
   
   axes(handles.singleSpot_axis);
   imagesc(im_singleSpot_default), axis image, axis off;
end

% UIWAIT makes QuantDraCALA wait for user response (see UIRESUME)
% uiwait(handles.quantDracala_gui);
global radiusIn radiusOut default_RadiusIn default_RadiusOut

default_RadiusIn = 7.3;
default_RadiusOut = 19.9;

radiusIn = default_RadiusIn;
radiusOut = default_RadiusOut;

% --- Outputs from this function are returned to the command line.
function varargout = QuantDraCALA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% evalin('base','clear all');



% --- Executes on button press in loadImages_button.
function loadImages_button_Callback(hObject, eventdata, handles)
% - Pushbutton to load .gel or .tif image(s) for analysis
% - Goes to directory and sends filename(s) to loadedImages_menu

[imsName, imsPath, cCheck] = uigetfile({'*.tif;*.tiff;*.gel'}, 'Select DRaCALA Image(s)', 'MultiSelect', 'on'); 

cd(imsPath);

assignin('base', 'imsName', imsName);
assignin('base', 'imsName', imsPath);
assignin('base', 'imsName', cCheck);

% If user did not press Cancel
if (cCheck ~= 0)  
    set(handles.loadedImages_menu, 'Value', 1); % Set selection to first entry        
    set(handles.loadedImages_menu, 'String', imsName); % Send filenames to loadedImages_menu listbox    
else    
    disp('No Images to analyze!');
    return;
end



% --- Executes on selection change in loadedImages_menu.
function loadedImages_menu_Callback(hObject, eventdata, handles)
% Listbox menu to select and load multiple images
% After user clicks "Load Images" button, filename string (single) or cell array 
% (multiple) are inputted to this listbox
% User can change images loaded in main axis figure by selecting 
% filename from listbox. 
% Retrieve  string or cell array from loadImages_button and output 
% selected image into mainFig_axis

global im_adjusted im_original analysisType

% Get loadImages_button String and Value containing imsName
imsString = get(hObject, 'String');
imsValue = get(hObject, 'Value');

% Determine if single or multiple files to read
if (iscell(imsString)) % Single image loaded stored as a string
    filename = imsString{imsValue};
else                   % Multple files stored in cell array
    filename = imsString;
end

% Read, process, and display inverted image onto main figure axis
imageInfo = imfinfo(filename);
im_original = double(imread(filename));

% Convert raw image with QL pixel values to PSL pixel values
% Default parameters for QL2PSL conversion based on Fiji Manual
RESOLUTION = 200;
SENSITIIVITY = 10000;
LATITUDE = 5;

if imageInfo.BitDepth == 8
% For 8-bit image    
    GRADATION = 255; 
elseif imageInfo.BitDepth == 16
% For 16-bit image    
    GRADATION = 65535; 
else
% Can't determine image bit-depth. Default to 16-bit    
    GRADATION = 65535;
end

im_adjusted = ql2psl(im_original, RESOLUTION, SENSITIIVITY, LATITUDE, GRADATION);
% im_adjusted = PSL_image;
% PSL_image = im_raw; % If no QL-to-PSL conversion needed

% axes(handles.mainFig_axis);
% imagesc(im_adjusted), colormap gray, axis image, axis off;

% Output image properties into imageInfo_panel
imsInfo = imfinfo(filename);
analysisType = 'InitialAnalysis';

% Determine user's OS
if (isunix == 1)
    nameStartSite = strfind(imsInfo.Filename, '/');
elseif (ispc == 1)
    nameStartSite = strfind(imsInfo.Filename, '\');
else
    nameStartSite = strfind(imsInfo.Filename, 'DefaultImageName'); % Default to *.gel
end

shortName = imsInfo.Filename(nameStartSite(end) + 1:end);
set(handles.filename_outputbox, 'String', shortName);
set(handles.dimensionsX_outputbox, 'String', string(imsInfo.Width));
set(handles.dimensionsY_outputbox, 'String', string(imsInfo.Height));


minBrightness = min(im_adjusted(:));
maxBrightness = max(im_adjusted(:));
startBrightness = median(im_adjusted(:));
shortStep = maxBrightness / 10000;
longStep = maxBrightness / 1000;

set(handles.minumum_slider, 'Min', minBrightness);
set(handles.minumum_slider, 'Max', maxBrightness);
set(handles.minumum_slider, 'Value', startBrightness);
set(handles.minumum_slider, 'SliderStep', [shortStep longStep]);

set(handles.maximum_slider, 'Min', minBrightness);
set(handles.maximum_slider, 'Max', maxBrightness);
set(handles.maximum_slider, 'Value', maxBrightness);
set(handles.maximum_slider, 'SliderStep', [shortStep longStep]);

axes(handles.mainFig_axis);
imagesc(im_adjusted, [startBrightness maxBrightness]), colormap gray, axis image, axis off;


% --- Executes during object creation, after setting all properties.
function loadedImages_menu_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', 'Press Load Images to Start!');

% --- Executes on button press in update_button.
function update_button_Callback(hObject, eventdata, handles)
%{
- Analyze image, or update processed data
- Find spots and quantify properties with spotAnalyzer function
    Create mask
    
- If new spots called from Add Spot button: 
    Keep old data
    Skip spotFinder
	Add spot properties 
- If spots deleted:
    Keep old data
    Skip spotFinder
    Delete spot properties from spotIndex
%}

global im_adjusted spotData spotProps radiusOut radiusIn analysisType

axes(handles.mainFig_axis);
[spotData, spotProps] = spotAnalyzer(im_adjusted, radiusIn, radiusOut, analysisType);

% Create Circles
% w_centroids = cat(1, spotProps.WeightedCentroid); 
% radiis_out = zeros(1, length(w_centroids)) + radiusOut;
% radiis_in = zeros(1, length(w_centroids)) + radiusIn;   
% innCircle = viscircles(w_centroids, radiis_in,'Color','b');
% outCircle = viscircles(w_centroids, radiis_out,'Color','g');

spotData = getSpotData(spotProps);

% Output spotData and spotProperties into spotsInfo_panel
set(handles.totalSpots_outputbox, 'String', num2str(length(spotData)));
set(handles.radiusIn_outputbox, 'String', sprintf('%0.2f', radiusIn));
set(handles.radiusOut_outputbox, 'String', sprintf('%0.2f', radiusOut));
        

% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
%{
    -asdf 
%}
global im_adjusted radiusIn radiusOut default_RadiusIn default_RadiusOut analysisType
axes(handles.singleSpot_axis);
cla;
axes(handles.mainFig_axis);
cla;

imagesc(im_adjusted), colormap gray, axis image, axis off;

axes(handles.singleSpot_axis);

% Determine user's OS
if (ispc == 1)
    im_singleSpot_default = imread('Images\cuteDracula.png');
elseif (isunix == 1)
    im_singleSpot_default = imread('Images/cuteDracula.png');
else
    im_singleSpot_default = imread('coins.png');
end

imagesc(im_singleSpot_default), axis image, axis off;

radiusIn = default_RadiusIn;
radiusOut = default_RadiusOut;
analysisType = 'InitialAnalysis';

axes(handles.mainFig_axis);
set(handles.totalSpots_outputbox, 'String', '');
set(handles.radiusIn_outputbox, 'String', '');
set(handles.radiusOut_outputbox, 'String', '');

set(handles.spotNum_outputbox, 'String', '');
set(handles.areaInn_outputbox, 'String', '');
set(handles.intInn_outputbox, 'String', '');
set(handles.areaOut_outputbox, 'String', '');
set(handles.intOut_outputbox, 'String', '');
set(handles.intBG_outputbox, 'String', '');
set(handles.fractionBound_outputbox, 'String', '');


% --- Executes on button press in checkSpot_button.
function checkSpot_button_Callback(hObject, eventdata, handles)
%{ 
- User clicks coordinate on mainFig_axis
- Go through outerMasks of all spots
    Need to convert outerMasks matrix to bwboundaries        
- Check if click is inside spot boundary
- WeightedCentroid coordinates define location for outputted spot image
- Send spotData and spotProperties to singleSpot_axis
%}
global im_adjusted spotData spotProps radiusOut radiusIn imLimits

outerMasks = {1:length(spotProps)};
for i = 1:length(spotProps)
    outerMasks{i} = spotProps(i).outerMask;
end
w_centroids = cat(1, spotProps.WeightedCentroid);

axes(handles.mainFig_axis);
[userRow, userColumn] = getpts(handles.mainFig_axis);
[cClick, hit] = singleSpot(userColumn, userRow, outerMasks);

if (cClick == 1)
    rowPlane = round([w_centroids(hit,2)-radiusOut w_centroids(hit,2)+radiusOut]);
    columnPlane = round([w_centroids(hit,1)-radiusOut w_centroids(hit,1)+radiusOut]);
    buff = 8;

    axes(handles.singleSpot_axis); 
    imagesc(im_adjusted(rowPlane(1)-buff:rowPlane(2)+buff, columnPlane(1)-buff:columnPlane(2)+buff), imLimits),
    colormap gray, axis image, axis off;
    
    hold on;
    im_center = [radiusOut+buff radiusOut+buff];
    viscircles(im_center, radiusIn,'Color','b'); % Blue inner circle
    viscircles(im_center,radiusOut,'Color','g'); % Green outer circle
    hold off;
    
    % Load spotData and spotProperties into spotData_panel
    set(handles.spotNum_outputbox, 'String', sprintf('%0.0f', spotData(hit).SpotNum));
    set(handles.areaInn_outputbox, 'String', sprintf('%0.2f', spotData(hit).Ainn));
    set(handles.intInn_outputbox, 'String', sprintf('%0.2f', spotData(hit).Iinn));
    set(handles.areaOut_outputbox, 'String', sprintf('%0.2f', spotData(hit).Aout));
    set(handles.intOut_outputbox, 'String', sprintf('%0.2f', spotData(hit).Iout));
    set(handles.intBG_outputbox, 'String', sprintf('%0.2f', spotData(hit).Ibg));
    set(handles.fractionBound_outputbox, 'String', sprintf('%0.3f', spotData(hit).FractionBound));
end


% --- Executes on button press in changeRadii_button.
function changeRadii_button_Callback(hObject, eventdata, handles)
%{
- Change radiusIn and radiusOut sizes
- User pushes "Change Radius Size" button and is prompted to chose a spot
- Open new window with spot and current radiusIn/radiusOut setting
- 2 Sliders change size of radiusIn/radiusOut 
- User presses "Confirm New Radius Sizes" to return to Main Window 
%}
global im_adjusted spotProps radiusIn radiusOut analysisType imLimits

msgbox('Select a spot to use as a template', 'Change Radius Size', 'help');
uiwait(gcf);

outerMasks = {1:length(spotProps)};
for i = 1:length(spotProps)
    outerMasks{i} = spotProps(i).outerMask;
end
w_centroids = cat(1, spotProps.WeightedCentroid);

[userRow, userColumn] = getpts(handles.mainFig_axis);
[cClick, hit] = singleSpot(userColumn, userRow, outerMasks);

if (cClick == 1)
    rowPlane = round([w_centroids(hit,2)-radiusOut w_centroids(hit,2)+radiusOut]);
    columnPlane = round([w_centroids(hit,1)-radiusOut w_centroids(hit,1)+radiusOut]);
    buff = 8;
    
    templateSpot = im_adjusted(rowPlane(1)-buff:rowPlane(2)+buff, columnPlane(1)-buff:columnPlane(2)+buff);   
    setappdata(0, 'templateSpot', templateSpot);    
    setappdata(0, 'radiusIn', radiusIn);
    setappdata(0, 'radiusOut', radiusOut);
    setappdata(0, 'imLimits', imLimits);

    changeRadii;
    uiwait(gcf);   

    cla;
    axes(handles.mainFig_axis);
    imLimits = [0 max(im_adjusted(:))]; % Set scaling of cropped image to same as full image
    imagesc(im_adjusted, imLimits), colormap gray, axis image, axis off;
    radiusIn = getappdata(0, 'newRadiusIn');
    radiusOut = getappdata(0, 'newRadiusOut');
    analysisType = 'ChangeRadiiSizes';
    
    msgbox('Press Analyze/Update Button to quantify new sizes of radii', analysisType);

end




% --- Executes on button press in addSpot_button.
function addSpot_button_Callback(hObject, eventdata, handles)
%{
- Function to add an extra spot of current radii sizes 
- User clicks on a point that becomes coordinate for center of new spot
- Obtain new spotData and spotProps from a spot from that coordinate
- New spot appends to end of spot index as [length(spotData) + 1]

%}
global im_adjusted im_original spotData spotProps radiusIn radiusOut analysisType

% Ask user where to place new spot; point becomes new centroid coordinate
msgbox('Select location for spot', 'Add Spot', 'help');
uiwait(gcf);

[newRow, newColumn] = getpts(handles.mainFig_axis);
newCentroid = [newRow newColumn];
newIndex = length(spotProps) + 1;

% Create Circles
newInnCircle = viscircles(newCentroid, radiusIn,'Color','b');
newOutCircle = viscircles(newCentroid, radiusOut,'Color','g');

analysisType = 'AddSpots';
% [newData, newProps] = spotAnalyzer(im_adjusted, im_original, radiusIn, radiusOut, analysisType);
[newData, newProps] = addData_spotAnalyzer(im_original, newCentroid);

spotData{newIndex} = newData;
spotProps{newIndex} = newProps;

% Use meshgrid function to form new innerMask/outerMask from that position
[xgrid, ygrid] = meshgrid(1:size(im_original,2), 1:size(im_original,1));        
newOuterMask = ((xgrid - newCentroid(1)).^2 + (ygrid - newCentroid(2)).^2) <= (radiusOut).^2;
newInnerMask = ((xgrid - newCentroid(1)).^2 + (ygrid - newCentroid(2)).^2) <= (radiusIn).^2;
newOuterCircle = im_original(newOuterMask);
newInnerCircle = im_original(newInnerMask);         

% Add new properties to spotProps(end + 1) 
spotProps(newIndex).WeightedCentroid = newCentroid;
spotProps(newIndex).innerMask = newInnerMask;
spotProps(newIndex).innerCircles = newInnerCircle;
spotProps(newIndex).outerMask = newOuterMask;
spotProps(newIndex).outerCircles = newOuterCircle;       


innFactor = 1; % If I figure out scaling factor used by Image Quant
outFactor = 1;  
% Add new data to spotData(end + 1)        
spotData(newIndex).SpotNum = newIndex;
spotData(newIndex).Ainn = length(spotProps(newIndex).innerCircles);
spotData(newIndex).Aout = length(spotProps(newIndex).outerCircles);
spotData(newIndex).Iinn = sum(spotProps(newIndex).innerCircles/innFactor);
spotData(newIndex).Iout = sum(spotProps(newIndex).outerCircles/outFactor);
spotData(newIndex).Ibg = spotData(newIndex).Ainn * ((spotData(newIndex).Iout - spotData(newIndex).Iinn) / (spotData(newIndex).Aout - spotData(newIndex).Ainn));
spotData(newIndex).fractionBound = ((spotData(newIndex).Iinn - spotData(newIndex).Ibg) / spotData(newIndex).Iout);

text(spotProps(newIndex).WeightedCentroid(1,1)-12, spotProps(newIndex).WeightedCentroid(1,2)+25, sprintf('%0.2f', spotData(newIndex).fractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');   
text(spotProps(newIndex).WeightedCentroid(1,1)-35, spotProps(newIndex).WeightedCentroid(1,2)+35, num2str(spotData(newIndex).SpotNum), 'Color','white','FontSize',14);



% --- Executes on button press in saveData_button.
function saveData_button_Callback(hObject, eventdata, handles)
% Save spotData in a saveSpots.mat and saveSpots.xls file 
% User determines name for file 

global spotData spotProps
save_string = sprintf('The spotData and spotProps structure arays will be saved in a .mat file; spotData will be saved in a tab-delimited .xls (Windows) or .txt (Unix) file.\n\nEnter filename to save spot data:');
save_filename = inputdlg(save_string, 'Save Spot Data');
saveSpots(spotData, spotProps, string(save_filename));


% --- Executes on button press in splitMultiple_button.
function splitMultiple_button_Callback(hObject, eventdata, handles)
% UPDATE THIS HELP SECTION
% Goes to directory and sends filename(s) to loadedImages_menu
% Get loadImages_button String and Value containing imsName
selectedImage = get(handles.loadedImages_menu, 'String');
selectedIndex = get(handles.loadedImages_menu, 'Value');

% Determine if single or multiple files to read
if (iscell(selectedImage)) % Single image loaded stored as a string
    fullImage = selectedImage{selectedIndex};
else                   % Multple files stored in cell array
    fullImage = selectedImage;
end

fprintf('%s',string(fullImage));
[~, splitNames, ~] = splitFullPlate(fullImage);

set(handles.splitMultiple_menu, 'Value', 1); % Set selection to first entry        
set(handles.splitMultiple_menu, 'String', splitNames); % Send filenames to loadedImages_menu listbox    


% --- Executes during object creation, after setting all properties.
function splitMultiple_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', 'Split large plate into multiple files');


% --- Executes on selection change in splitMultiple_menu.
function splitMultiple_menu_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns splitMultiple_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from splitMultiple_menu

% When user loads a large image containing multiple plates, this button
% identifies each plate and splits them into multiple .tif files of the
% same bit-depth.
% Individual .tif files are then outputted into this listbox, and the user
% can click on individual files to load into mainFig_axis 

% Listbox menu to select and load multiple images
% After user clicks "Load Images" button, filename string (single) or cell array 
% (multiple) are inputted to this listbox
% User can change images loaded in main axis figure by selecting 
% filename from listbox. 
% Retrieve  string or cell array from loadImages_button and output 
% selected image into mainFig_axis

global im_adjusted im_original analysisType

% Get loadImages_button String and Value containing imsName
splitNames = get(hObject, 'String');
splitIndex = get(hObject, 'Value');

% Determine if single or multiple files to read
if (iscell(splitNames)) % Single image loaded stored as a string
    splitImage = splitNames{splitIndex};
else                   % Multple files stored in cell array
    splitImage = splitNames;
end

imageInfo = imfinfo(splitImage);
im_original = double(imread(splitImage));

RESOLUTION = 200;
SENSITIIVITY = 10000;
LATITUDE = 5;
if imageInfo.BitDepth == 8
% For 8-bit image    
    GRADATION = 255; 
elseif imageInfo.BitDepth == 16
% For 16-bit image    
    GRADATION = 65535; 
else
% Can't determine image bit-depth. Default to 16-bit    
    GRADATION = 65535;
end

im_adjusted = ql2psl(im_original, RESOLUTION, SENSITIIVITY, LATITUDE, GRADATION);

axes(handles.mainFig_axis);
imagesc(im_adjusted), colormap gray, axis image, axis off;

analysisType = 'InitialAnalysis';

% Determine user's OS
if (isunix == 1)
    nameStartSite = strfind(imageInfo.Filename, '/');
elseif (ispc == 1)
    nameStartSite = strfind(imageInfo.Filename, '\');
else
    nameStartSite = strfind(imageInfo.Filename, 'DefaultImageName');
end

% Output image properties into imageInfo_panel
shortName = imageInfo.Filename(nameStartSite(end) + 1:end);
set(handles.filename_outputbox, 'String', shortName);
set(handles.dimensionsX_outputbox, 'String', string(imageInfo.Width));
set(handles.dimensionsY_outputbox, 'String', string(imageInfo.Height));



% --- Executes on slider movement.
function minumum_slider_Callback(hObject, eventdata, handles)

global im_adjusted imLimits
minPos = get(hObject, 'Value');
maxPos = get(handles.maximum_slider, 'Value');
imLimits = [minPos maxPos];
if maxPos <= minPos
    minPos = 0;
end

axes(handles.mainFig_axis);
imagesc(im_adjusted, imLimits), colormap gray, axis image, axis off;

% --- Executes during object creation, after setting all properties.
function minumum_slider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function maximum_slider_Callback(hObject, eventdata, handles)

global im_adjusted imLimits
minPos = get(handles.minumum_slider, 'Value');
maxPos = get(hObject, 'Value');
imLimits = [minPos maxPos];
if maxPos <= minPos
    minPos = 0;
end

axes(handles.mainFig_axis);
imagesc(im_adjusted, imLimits), colormap gray, axis image, axis off;


% --- Executes during object creation, after setting all properties.
function maximum_slider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end








% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
printdlg(handles.quantDracala_gui)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ' get(handles.quantDracala_gui,'Name') '?'],...
                     ['Close ' get(handles.quantDracala_gui,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.quantDracala_gui)



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on button press in deleteSpot_button.
function deleteSpot_button_Callback(hObject, eventdata, handles)
% hObject    handle to deleteSpot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in analysis_button.
function analysis_button_Callback(hObject, eventdata, handles)
% hObject    handle to analysis_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function spotNum_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of spotNum_outputbox as text
%        str2double(get(hObject,'String')) returns contents of spotNum_outputbox as a double


% --- Executes during object creation, after setting all properties.
function spotNum_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalSpots_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of totalSpots_outputbox as text
%        str2double(get(hObject,'String')) returns contents of totalSpots_outputbox as a double


% --- Executes during object creation, after setting all properties.
function totalSpots_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filename_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of filename_outputbox as text
%        str2double(get(hObject,'String')) returns contents of filename_outputbox as a double


% --- Executes during object creation, after setting all properties.
function filename_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dimensionsX_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of dimensionsX_outputbox as text
%        str2double(get(hObject,'String')) returns contents of dimensionsX_outputbox as a double


% --- Executes during object creation, after setting all properties.
function dimensionsX_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dimensionsY_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of dimensionsY_outputbox as text
%        str2double(get(hObject,'String')) returns contents of dimensionsY_outputbox as a double


% --- Executes during object creation, after setting all properties.
function dimensionsY_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intBG_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of intBG_outputbox as text
%        str2double(get(hObject,'String')) returns contents of intBG_outputbox as a double


% --- Executes during object creation, after setting all properties.
function intBG_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function areaInn_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of areaInn_outputbox as text
%        str2double(get(hObject,'String')) returns contents of areaInn_outputbox as a double


% --- Executes during object creation, after setting all properties.
function areaInn_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function areaOut_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of areaOut_outputbox as text
%        str2double(get(hObject,'String')) returns contents of areaOut_outputbox as a double


% --- Executes during object creation, after setting all properties.
function areaOut_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intInn_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of intInn_outputbox as text
%        str2double(get(hObject,'String')) returns contents of intInn_outputbox as a double


% --- Executes during object creation, after setting all properties.
function intInn_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intOut_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of intOut_outputbox as text
%        str2double(get(hObject,'String')) returns contents of intOut_outputbox as a double


% --- Executes during object creation, after setting all properties.
function intOut_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fractionBound_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of fractionBound_outputbox as text
%        str2double(get(hObject,'String')) returns contents of fractionBound_outputbox as a double


% --- Executes during object creation, after setting all properties.
function fractionBound_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function radiusIn_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of radiusIn_outputbox as text
%        str2double(get(hObject,'String')) returns contents of radiusIn_outputbox as a double


% --- Executes during object creation, after setting all properties.
function radiusIn_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radiusOut_outputbox_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of radiusOut_outputbox as text
%        str2double(get(hObject,'String')) returns contents of radiusOut_outputbox as a double


% --- Executes during object creation, after setting all properties.
function radiusOut_outputbox_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background.
function quantDracala_gui_ButtonDownFcn(hObject, eventdata, handles)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function mainFig_axis_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate mainFig_axis


% --- Executes during object creation, after setting all properties.
function singleSpot_axis_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate singleSpot_axis



% --- Executes during object creation, after setting all properties.
function quantDracala_gui_CreateFcn(hObject, eventdata, handles)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over changeRadii_button.
function changeRadii_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to changeRadii_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function mainFig_axis_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to mainFig_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in segmentation_button.
function segmentation_button_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TBD_button.
function TBD_button_Callback(hObject, eventdata, handles)
% hObject    handle to TBD_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over minumum_slider.
function minumum_slider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to minumum_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
