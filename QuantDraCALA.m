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
%      QUANTDRACALA('CALLBACK',hObject,~,handles,...) calls the local
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

% Last Modified by GUIDE v2.5 27-Jul-2017 23:40:59

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
function QuantDraCALA_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QuantDraCALA (see VARARGIN)
% Choose default command line output for QuantDraCALA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%  
% delete(hObject.Children(end-1).Children); % DELETE INITIAL DATA ON AXIS
% delete(hObject.Children(end).Children); % DELETE INITIAL DATA ON AXIS

% This sets up the initial plot - only do when we are invisible
% so window can get raised using QuantDraCALA.

% Welcome messages from QuantDRaCALA and CuteDRaCALA
if strcmp(get(hObject,'Visible'),'off')

   axes(handles.mainFig_axis);

   %  Determine user's OS
   if (ispc == 1)
       im_default = imread('Images\QD_logoBlack.jpg');
       im_singleSpot_default = imread('Images\QD_logoBlack.jpg');

   elseif (isunix == 1)
       im_default = imread('Images/QD_logoGreen.png');
       im_singleSpot_default = imread('Images/QD_logoBlack.jpg');

   else
       im_default = imread('coins.png');
       im_singleSpot_default = imread('coins.png');

   end
   
   imagesc(im_default), colormap gray, axis image, axis off;
%    text(350, 25, 'Press Load Images', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold');
%    text(400, 45, 'to Starrrt!!!', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold');
   
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
function varargout = QuantDraCALA_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% evalin('base','clear all');






% --- Executes on button press in loadImages_button.
function loadImages_button_Callback(~, ~, handles)
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
function loadedImages_menu_Callback(hObject, ~, handles)
% Listbox menu to select and load multiple images
% After user clicks "Load Images" button, filename string (single) or cell array 
% (multiple) are inputted to this listbox
% User can change images loaded in main axis figure by selecting 
% filename from listbox. 
% Retrieve  string or cell array from loadImages_button and output 
% selected image into mainFig_axis

global im_adjusted im_original analysisType imLimits
delete(findall(handles.mainFig_axis, 'type', 'image'));
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
CONVERSION_DIRECTION = 'QL2PSL';
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

im_adjusted = ql2psl(im_original, RESOLUTION, SENSITIIVITY, LATITUDE, GRADATION, CONVERSION_DIRECTION);

process_loadingImages = {};
process_loadingImages{1} = sprintf('Loaded %d images...', length(imsString));
process_loadingImages{2} = sprintf('Converting pixel values with %s mode...', CONVERSION_DIRECTION); 
process_loadingImages{3} = sprintf('Showing %s', filename); 
set(handles.currentProcess_textbox, 'String', process_loadingImages);

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
function loadedImages_menu_CreateFcn(hObject, ~, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', 'Press Load Images to Start!');

% --- Executes on button press in update_button.
function update_button_Callback(~, ~, handles)
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
setappdata(gca, 'handles', handles); % Send figure handles to spotAnalyzer
% setappdata(gca, 'mainFigHandle', handles.mainFig_axis); % Send figure handles to spotAnalyzer
% setappdata(gca, 'currentProcessHandle', handles.currentProcess_textbox);
process_updateAnalysis = {};
process_updateAnalysis{1} = sprintf("Analyzing Image...\nCurrent Analysis Mode: %s", analysisType);
set(handles.currentProcess_textbox, 'String', process_updateAnalysis{1});

fullTime = cputime;
[spotData, spotProps] = spotAnalyzer(im_adjusted, radiusIn, radiusOut, analysisType);
process_updateAnalysis{2} = sprintf('Analysis Complete! Found %d spots.', length(spotData));

if strcmp(analysisType,'UpdateAnalysis')
    process_updateAnalysis{3} = sprintf('%0.4f seconds to re-analyze with new spot locations.', cputime-fullTime);
else
    process_updateAnalysis{3} = sprintf('%0.4f seconds to identify and analyze spots.', cputime-fullTime);
end

analysisType = 'UpdateAnalysis';
process_updateAnalysis{4} = sprintf('Current Analysis Mode: %s', analysisType);
set(handles.currentProcess_textbox, 'String', process_updateAnalysis);

% Send figure handles and spotProps to deal with different Analysis Modes
setappdata(gca, 'spotProps', spotProps);
setappdata(gca, 'handles', handles);

% Output spotData and spotProperties into spotsInfo_panel
set(handles.totalSpots_outputbox, 'String', num2str(length(spotData)));
set(handles.radiusIn_outputbox, 'String', sprintf('%0.2f', radiusIn));
set(handles.radiusOut_outputbox, 'String', sprintf('%0.2f', radiusOut));
        

% --- Executes on button press in reset_button.
function reset_button_Callback(~, ~, handles)
%{
    -asdf 
%}
global im_adjusted radiusIn radiusOut default_RadiusIn default_RadiusOut analysisType
set(handles.currentProcess_textbox, 'String', 'Resetting Current Analysis...');

% Clear image in Single Spot Window and replace with default image
axes(handles.singleSpot_axis);
delete(findall(handles.singleSpot_axis, 'type', 'image'));
delete(findall(handles.singleSpot_axis, 'type', 'hggroup'));
delete(findall(handles.singleSpot_axis, 'type', 'text'));
set(handles.currentProcess_textbox, 'String', 'Single Spot Window cleared...');

% Determine user's OS
if (ispc == 1)
    im_singleSpot_default = imread('Images\QD_logoBlack.jpg');
elseif (isunix == 1)
    im_singleSpot_default = imread('Images/QD_logoBlack.jpg');
else
    im_singleSpot_default = imread('coins.png');
end

imagesc(im_singleSpot_default), axis image, axis off;

% Clear objects from main image
axes(handles.mainFig_axis);
delete(findall(handles.mainFig_axis, 'type', 'image'));
delete(findall(handles.mainFig_axis, 'type', 'hggroup'));
delete(findall(handles.mainFig_axis, 'type', 'text'));
set(handles.currentProcess_textbox, 'String', 'Objects cleared from Main Image...');
imagesc(im_adjusted), colormap gray, axis image, axis off;

% Reset radii and analysis mode to default
radiusIn = default_RadiusIn;
radiusOut = default_RadiusOut;
analysisType = 'InitialAnalysis';

% Clear text from all text boxes
axes(handles.mainFig_axis);
set(handles.totalSpots_outputbox, 'String', '');
set(handles.radiusIn_outputbox, 'String', '');
set(handles.radiusOut_outputbox, 'String', '');
set(handles.spotNum_outputbox, 'String', '');
set(handles.wellPosition_editbox, 'String', '');
set(handles.areaInn_outputbox, 'String', '');
set(handles.intInn_outputbox, 'String', '');
set(handles.areaOut_outputbox, 'String', '');
set(handles.intOut_outputbox, 'String', '');
set(handles.intBG_outputbox, 'String', '');
set(handles.fractionBound_outputbox, 'String', '');

% GUI message output
process_resetAll = {};
process_resetAll{1} = 'Reset Complete!';
process_resetAll{2} = sprintf('Current Inner Radius: %.02f pixels', radiusIn);
process_resetAll{3} = sprintf('Current Outer Radius: %.02f pixels', radiusOut);
process_resetAll{4} = sprintf('Current Analysis Mode: %s', analysisType);
set(handles.currentProcess_textbox, 'String', process_resetAll);


% --- Executes on button press in checkSpot_button.
function checkSpot_button_Callback(~, ~, handles)
%{ 
- User clicks coordinate on mainFig_axis
- Go through outerMasks of all spots
    Need to convert outerMasks matrix to bwboundaries        
- Check if click is inside spot boundary
- WeightedCentroid coordinates define location for outputted spot image
- Send spotData and spotProperties to singleSpot_axis
%}
global im_adjusted spotData spotProps radiusOut radiusIn imLimits analysisType
axes(handles.mainFig_axis);
process_singleSpot = {};
process_singleSpot{1} = sprintf('Double-click on a spot to check data and properties');
set(handles.currentProcess_textbox, 'String', process_singleSpot);

[userRow, userColumn] = getpts(handles.mainFig_axis);
tic;

[cClick, hit] = singleSpot(userColumn, userRow, spotProps);
process_singleSpot{2} = sprintf('Searching through pixel index of %d spots...', length(spotProps));
axes(handles.singleSpot_axis); 
if (cClick(hit) == 1) 
    spotHit = spotProps(hit).WeightedCentroid;
    rowPlane = round([spotHit(2)-radiusOut spotHit(2)+radiusOut]);
    columnPlane = round([spotHit(1)-radiusOut spotHit(1)+radiusOut]);
    buff = 8;
       
    imagesc(im_adjusted(rowPlane(1)-buff:rowPlane(2)+buff, columnPlane(1)-buff:columnPlane(2)+buff), imLimits),
    colormap gray, axis image, axis off;
    
    hold on;
    im_center = [radiusOut+buff radiusOut+buff];
    viscircles(im_center, radiusIn,'Color','b'); % Blue inner circle
    viscircles(im_center,radiusOut,'Color','g'); % Green outer circle
    hold off;
    
    process_singleSpot{3} = sprintf('%.04f seconds to locate spot.', toc);
    process_singleSpot{4} = sprintf('Spot %d found at location (%.00f, %.00f)', hit, spotHit(2), spotHit(1));
    process_singleSpot{5} = sprintf('Current Analysis Mode: %s', analysisType);
    set(handles.currentProcess_textbox, 'String', '');
    set(handles.currentProcess_textbox, 'String', process_singleSpot);

    % Load spotData and spotProperties into spotData_panel
    set(handles.spotNum_outputbox, 'String', sprintf('%0.0f', spotData(hit).SpotNum));
    set(handles.wellPosition_editbox, 'String', spotData(hit).WellPosition);
    set(handles.areaInn_outputbox, 'String', sprintf('%0.2f', spotData(hit).Ainn));
    set(handles.intInn_outputbox, 'String', sprintf('%0.2f', spotData(hit).Iinn));
    set(handles.areaOut_outputbox, 'String', sprintf('%0.2f', spotData(hit).Aout));
    set(handles.intOut_outputbox, 'String', sprintf('%0.2f', spotData(hit).Iout));
    set(handles.intBG_outputbox, 'String', sprintf('%0.2f', spotData(hit).Ibg));
    set(handles.fractionBound_outputbox, 'String', sprintf('%0.3f', spotData(hit).FractionBound));
end


% --- Executes on button press in changeRadii_button.
function changeRadii_button_Callback(~, ~, handles)
%{
- Change radiusIn and radiusOut sizes
- User pushes "Change Radius Size" button and is prompted to chose a spot
- Open new window with spot and current radiusIn/radiusOut setting
- 2 Sliders change size of radiusIn/radiusOut 
- User presses "Confirm New Radius Sizes" to return to Main Window 
%}
global im_adjusted spotProps radiusIn radiusOut analysisType imLimits
axes(handles.mainFig_axis);
msgbox('Select a spot to use as a template', 'Change Radius Size', 'help');
uiwait(gcf);

[userRow, userColumn] = getpts(handles.mainFig_axis);
[cClick, hit] = singleSpot(userColumn, userRow, spotProps);

if (cClick(hit) == 1)
    spotHit = spotProps(hit).WeightedCentroid;
    rowPlane = round([spotHit(2)-radiusOut spotHit(2)+radiusOut]);
    columnPlane = round([spotHit(1)-radiusOut spotHit(1)+radiusOut]);
    buff = 8;
    
    spotHit_image = im_adjusted(rowPlane(1)-buff:rowPlane(2)+buff, columnPlane(1)-buff:columnPlane(2)+buff);   
    setappdata(0, 'hit', hit);
    setappdata(0, 'spotHit_image', spotHit_image);    
    setappdata(0, 'radiusIn', radiusIn);
    setappdata(0, 'radiusOut', radiusOut);
    setappdata(0, 'imLimits', imLimits);

    changeRadii;
    uiwait(gcf);
    
% Change this to clear text data only, then change sizes of radii using Object.setPosition(newPositions)
    axes(handles.mainFig_axis);    
    delete(findall(handles.mainFig_axis, 'type', 'text')); % Delete old data

% Send old radii values to spotAnalyzer to retain centroid positions when
% updating spot data
    oldRadiusOut = radiusOut; 
    oldRadiusIn = radiusIn;    
    setappdata(gca, 'oldRadiusOut', oldRadiusOut);
    setappdata(gca, 'oldRadiusIn', oldRadiusIn);    
    
    radiusIn = getappdata(0, 'newRadiusIn');
    radiusOut = getappdata(0, 'newRadiusOut');
    analysisType = 'ChangeRadiiSizes';
    
    msgbox('Press Analyze/Update Button to quantify data with new radii sizes.', analysisType);

end



% --- Executes on button press in addSpot_button.
function addSpot_button_Callback(~, ~, handles)
%{
- Function to add an extra spot of current radii sizes 
- User clicks on a point that becomes coordinate for center of new spot
- Obtain new spotData and spotProps from a spot from that coordinate
- New spot appends to end of spot index as [length(spotData) + 1]

%}
global im_adjusted  spotData spotProps radiusIn radiusOut analysisType

% Export data to addNewSpot() function 
setappdata(gca, 'spotData', spotData);
setappdata(gca, 'spotProps', spotProps);
setappdata(gca, 'handles', handles);

% spotData and spotProps will contain newly-indexed spot
analysisType = 'AddSpots';
[spotData, spotProps] = spotAnalyzer(im_adjusted, radiusIn, radiusOut, analysisType);

% Re-index spot designations incorporating new spot
[~, spotProps] = spotReIndex(spotProps, radiusOut);
spotData(end).WellPosition = spotProps(end).wellPosition;

analysisType = 'UpdateAnalysis';



% --- Executes on button press in saveData_button.
function saveData_button_Callback(~, ~, handles)
% Save spotData in a saveSpots.mat and saveSpots.xls file 
% User determines name for file 

global spotData spotProps
tic;
process_saveData = {};
process_saveData{1} = 'Processing spot data for export...';
set(handles.currentProcess_textbox, 'String', process_saveData);

tableProps = struct2table(spotProps);
tableProps.outerObject = [];
tableProps.innerObject = [];
spotProps = table2struct(tableProps);
process_saveData{2} = 'Data successfully processed! Saving to file...';
set(handles.currentProcess_textbox, 'String', process_saveData);

save_string = sprintf('The spotData and spotProps structure arays will be saved in a .mat file; spotData will be saved in a tab-delimited .xls (Windows) or .txt (Unix) file.\n\nEnter filename to save spot data:');
save_filename = inputdlg(save_string, 'Save Spot Data');
saveSpots(spotData, spotProps, string(save_filename));
    
process_saveData{3} = sprintf('%.04f seconds to process and save data.', toc);
set(handles.currentProcess_textbox, 'String', process_saveData);


% --- Executes on button press in splitMultiple_button.
function splitMultiple_button_Callback(~, ~, handles)
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
function splitMultiple_menu_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', 'Split large plate into multiple files');


% --- Executes on selection change in splitMultiple_menu.
function splitMultiple_menu_Callback(hObject, ~, handles)
% When user loads a large image containing multiple plates, this button
% identifies each plate and splits them into multiple .tif files of the
% same bit-depth.
% Individual .tif files are then outputted into this listbox, and the user
% can click on individual files to load into mainFig_axis 
%
% Listbox menu to select and load multiple images
% After user clicks "Load Images" button, filename string (single) or cell array 
% (multiple) are inputted to this listbox
% User can change images loaded in main axis figure by selecting 
% filename from listbox. 
% Retrieve  string or cell array from loadImages_button and output 
% selected image into mainFig_axis

global im_adjusted im_original analysisType
delete(findall(handles.mainFig_axis, 'type', 'image'));
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
CONVERSION_DIRECTION = 'QL2PSL';

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

im_adjusted = ql2psl(im_original, RESOLUTION, SENSITIIVITY, LATITUDE, GRADATION, CONVERSION_DIRECTION);

axes(handles.mainFig_axis);
imagesc(im_adjusted), colormap gray, axis image, axis off;

analysisType = 'InitialAnalysis';

set(handles.currentProcess_textbox, 'String', '');
process_splittingImages = {};
process_splittingImages{1} = sprintf('Identified %d images...', length(splitNames));
process_splittingImages{2} = sprintf('Converting pixel values with %s mode...', CONVERSION_DIRECTION); 
process_splittingImages{3} = sprintf('Showing %s', splitImage); 
process_splittingImages{4} = sprintf('Current Analysis Mode: %s', analysisType);
set(handles.currentProcess_textbox, 'String', process_splittingImages);

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
function minumum_slider_Callback(hObject, ~, handles)

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
function minumum_slider_CreateFcn(hObject, ~, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function maximum_slider_Callback(hObject, ~, handles)

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
function maximum_slider_CreateFcn(hObject, ~, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes during object creation, after setting all properties.
function uitoolbar2_CreateFcn(hObject, eventdata, handles)
% Change the default color of the toolbar to the secondary color of the GUI
% Uses undocumented java classes from AWT 

% lightblue_background = java.awt.Color(0,0.45,0.74); % Technically correct color
lightblue_background = java.awt.Color(0,0.5,0.9); % Better color
hToolbar = findall(hObject,'Tag','uitoolbar2');
pause(0.5); % For some reason it needs a very short pause to get data
jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');
jToolbar.setBackground(lightblue_background);








% --------------------------------------------------------------------
function FileMenu_Callback(~, ~, handles)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(~, ~, handles)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(~, ~, handles)
printdlg(handles.quantDracala_gui)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(~, ~, handles)
selection = questdlg(['Close ' get(handles.quantDracala_gui,'Name') '?'],...
                     ['Close ' get(handles.quantDracala_gui,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.quantDracala_gui)



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(~, ~, handles)
% hObject    handle to pushbutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(~, ~, handles)
% hObject    handle to pushbutton3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)











% --- Executes on button press in deleteSpot_button.
function deleteSpot_button_Callback(~, ~, handles)
% hObject    handle to deleteSpot_button (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in analysis_button.
function analysis_button_Callback(~, ~, handles)
% hObject    handle to analysis_button (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function spotNum_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of spotNum_outputbox as text
%        str2double(get(hObject,'String')) returns contents of spotNum_outputbox as a double


% --- Executes during object creation, after setting all properties.
function spotNum_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalSpots_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of totalSpots_outputbox as text
%        str2double(get(hObject,'String')) returns contents of totalSpots_outputbox as a double


% --- Executes during object creation, after setting all properties.
function totalSpots_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filename_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of filename_outputbox as text
%        str2double(get(hObject,'String')) returns contents of filename_outputbox as a double


% --- Executes during object creation, after setting all properties.
function filename_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dimensionsX_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of dimensionsX_outputbox as text
%        str2double(get(hObject,'String')) returns contents of dimensionsX_outputbox as a double


% --- Executes during object creation, after setting all properties.
function dimensionsX_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dimensionsY_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of dimensionsY_outputbox as text
%        str2double(get(hObject,'String')) returns contents of dimensionsY_outputbox as a double


% --- Executes during object creation, after setting all properties.
function dimensionsY_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intBG_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of intBG_outputbox as text
%        str2double(get(hObject,'String')) returns contents of intBG_outputbox as a double


% --- Executes during object creation, after setting all properties.
function intBG_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function areaInn_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of areaInn_outputbox as text
%        str2double(get(hObject,'String')) returns contents of areaInn_outputbox as a double


% --- Executes during object creation, after setting all properties.
function areaInn_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function areaOut_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of areaOut_outputbox as text
%        str2double(get(hObject,'String')) returns contents of areaOut_outputbox as a double


% --- Executes during object creation, after setting all properties.
function areaOut_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intInn_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of intInn_outputbox as text
%        str2double(get(hObject,'String')) returns contents of intInn_outputbox as a double


% --- Executes during object creation, after setting all properties.
function intInn_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intOut_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of intOut_outputbox as text
%        str2double(get(hObject,'String')) returns contents of intOut_outputbox as a double


% --- Executes during object creation, after setting all properties.
function intOut_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fractionBound_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of fractionBound_outputbox as text
%        str2double(get(hObject,'String')) returns contents of fractionBound_outputbox as a double


% --- Executes during object creation, after setting all properties.
function fractionBound_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(~, ~, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, ~, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(~, ~, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, ~, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(~, ~, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, ~, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function radiusIn_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of radiusIn_outputbox as text
%        str2double(get(hObject,'String')) returns contents of radiusIn_outputbox as a double


% --- Executes during object creation, after setting all properties.
function radiusIn_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radiusOut_outputbox_Callback(~, ~, handles)
% Hints: get(hObject,'String') returns contents of radiusOut_outputbox as text
%        str2double(get(hObject,'String')) returns contents of radiusOut_outputbox as a double


% --- Executes during object creation, after setting all properties.
function radiusOut_outputbox_CreateFcn(hObject, ~, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background.
function quantDracala_gui_ButtonDownFcn(~, ~, handles)





% --- Executes during object creation, after setting all properties.
function mainFig_axis_CreateFcn(~, ~, handles)
% Hint: place code in OpeningFcn to populate mainFig_axis


% --- Executes during object creation, after setting all properties.
function singleSpot_axis_CreateFcn(~, ~, handles)
% Hint: place code in OpeningFcn to populate singleSpot_axis



% --- Executes during object creation, after setting all properties.
function quantDracala_gui_CreateFcn(~, ~, handles)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over changeRadii_button.
function changeRadii_button_ButtonDownFcn(~, ~, handles)
% hObject    handle to changeRadii_button (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function mainFig_axis_ButtonDownFcn(~, ~, handles)
% hObject    handle to mainFig_axis (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in segmentation_button.
function segmentation_button_Callback(~, ~, handles)
% hObject    handle to segmentation_button (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TBD_button.
function TBD_button_Callback(~, ~, handles)
% hObject    handle to TBD_button (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over minumum_slider.
function minumum_slider_ButtonDownFcn(~, ~, handles)
% hObject    handle to minumum_slider (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function currentProcess_textbox_CreateFcn(~, ~, handles)
% hObject    handle to currentProcess_textbox (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function wellPosition_editbox_Callback(~, ~, handles)
% hObject    handle to wellPosition_editbox (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wellPosition_editbox as text
%        str2double(get(hObject,'String')) returns contents of wellPosition_editbox as a double


% --- Executes during object creation, after setting all properties.
function wellPosition_editbox_CreateFcn(hObject, ~, handles)
% hObject    handle to wellPosition_editbox (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% Functions for Menu Functions: TO BE CONTINUED
% --------------------------------------------------------------------
function fileItem_menuItem_Callback(~, ~, handles)

% --------------------------------------------------------------------
function editItem_menuItem_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function modeSelect_menuItem_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function changeAnalysisMode_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to changeAnalysisMode_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function segmentationMenu_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to segmentationMenu_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function adjustImage_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to adjustImage_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function loadImage_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to loadImage_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function change2InitialAnalysis_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to change2InitialAnalysis_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function change2UpdateAnalysis_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to change2UpdateAnalysis_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function change2RadiiSizes_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to change2RadiiSizes_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function change2AddSpots_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to change2AddSpots_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function change2DeleteSpots_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to change2DeleteSpots_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function changeRadii_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to changeRadii_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function exitGUI_menuItem_Callback(~, ~, handles)
% Delete all objects, clear all variables, close all figures, and exit.

allAppData = fieldnames(getappdata(0));
for i = 1:length(allAppData)
    rmappdata(0, allAppData{i});
end
delete(findall(handles.mainFig_axis, 'Type', 'hggroup'));
delete(findall(handles.mainFig_axis, 'Type', 'image'));
delete(findall(handles.mainFig_axis, 'Type', 'text'));
close all force;

% --------------------------------------------------------------------
function brightnessMenu_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to brightnessMenu_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function contrastMenu_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to contrastMenu_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function manualSegmentation_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to manualSegmentation_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function adjustSegmentation_menuItem_Callback(hObject, eventdata, handles)
% hObject    handle to adjustSegmentation_menuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
