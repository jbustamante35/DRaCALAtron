function [spotData, spotProps] = spotAnalyzer(im_psl, innerRadius, outerRadius, switchMode)
% function [spotData, spotProps] = spotAnalyzer(varargin)
%
% spotAnalyzer: Function to analyze DraCALA spot assays.
% 
% im: psl-converted image
% im_raw: unconverted ql-pixels
% Reads image and identifies regions corresponding to DraCALA spots. Identifies
% centers of spots and forms inner and outer circles. 
% Cycle through spots from upper-left to lower-right to renumber spots from
% 1 - 96 (IN PROGRESS). Take measurements of individual circles to quantify Fraction Bound (FB). 
% 
% Fraction Bound Equation:
%   I = Mean Intensity
%   A = Area
%   inn = inner circle
%   out = total circle
%   bg  = background 
% 
%   Ibg = Ainn * ((Iout - Iinn)/(Aout - Ainn));
%   FB = (Iinn - Ibg)/ Iout; 

% Function Overview
%{
- Read image from QuantDRaCALA GUI
- Run through initial analysis 
- Output spotData to QuantDRaCALA GUI

- Main Pipeline: 
    imbinarize inputted image
    boundarymask to assess quality of objects
    bwareaopen to exclude small objects 
    bwboundaries boundarymask_Refined_Binarized_Inverted_Image
    regionprops to obtain weighted centroid positions    

%}

%% Set-up various shared data for different cases 
sprintf('Running %s', switchMode);
txtDist = [(outerRadius + (innerRadius / 4)) outerRadius]; % x and y distances for text from centroid

switch switchMode    
    case 'InitialAnalysis'     
%% Initial Analysis Mode: used to identify initial spots
        
%Allow user to manually set inner/outer radii sizes for initial analysis
%         setRadiiSize = input('Set initial sizes for inner and outer radius?');
%         if setRadiiSize == 1 % Set size manually
%             innerRadius = input();
%             outerRadius = input();
%             txtDist = [(outerRadius + (innerRadius / 4)) outerRadius];
%         else                    %Use default sizes
%         end          
tic;        
% Create Mask and Boundaries
        [im_bounds, ~] = autoSegment(im_psl); % Still need to set up interactive segmentation 
        im_bounds_refine = bwareaopen(im_bounds, 300, 8);        

% Re-mask with Inner/Outer Circles and get Data from Spots       
        spotProps_raw= regionprops(im_bounds_refine, im_psl, 'WeightedCentroid');
        spotProps_unsorted = getSpotProps(im_psl, spotProps_raw, innerRadius, outerRadius);
        [~, spotProps] = spotReIndex(spotProps_unsorted, outerRadius);
        spotData = getSpotData(spotProps);
 
        for i = 1:length(spotData)            
            text(spotProps(i).WeightedCentroid(1,1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), sprintf('%0.2f',spotData(i).FractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');   
            text(spotProps(i).WeightedCentroid(1,1)-txtDist(1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), spotData(i).WellPosition, 'Color','white','FontSize',10);            
        end
        
fprintf("%0.4f seconds to analyze spot data.\n", toc);
        
    case 'UpdateAnalysis'  
%% Update Analysis Mode: update after moving/resizing spots         
% Simply update spotProps.WeightedCentroid positions and spotData using
% getSpotData(spotProps) with newly-defined spot properties
        
% Get spotProps positions
        spotProps = getappdata(gca, 'spotProps');
        handles = getappdata(gca, 'handles');
        mainImage_handle = findobj(handles.mainFig_axis.Children, 'type', 'image'); % Object handle for main image
        tableProps = struct2table(spotProps); % Convert to table to use vectorized arrayfun and cellfun
        
% Re-mask at new position        
        tableProps.outerMask = arrayfun(@(x) createMask(x, mainImage_handle), tableProps.outerObject, 'UniformOutput', 0);        
        tableProps.outerCircles = cellfun(@(x) im_psl(x), tableProps.outerMask, 'UniformOutput', 0);
        tableProps.innerMask = arrayfun(@(x) createMask(x, mainImage_handle), tableProps.innerObject, 'UniformOutput', 0);        
        tableProps.innerCircles = cellfun(@(x) im_psl(x), tableProps.innerMask, 'UniformOutput', 0);
        
        spotProps = table2struct(tableProps);
        for i = 1:length(spotProps)
            spotProps(i).WeightedCentroid = spotProps(i).innerObject.getPosition + innerRadius; % Centroid based on inner circle
        end        

% Re-Index spot numbers and use spotData with updated spot position and masks
        [~, spotProps] = spotReIndex(spotProps, outerRadius);
        spotData = getSpotData(spotProps);
        delete(findobj(handles.mainFig_axis.Children, 'flat', 'Type', 'text'));
        for i = 1:length(spotData)
            text(spotProps(i).WeightedCentroid(1,1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), sprintf('%0.2f',spotData(i).FractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');        
            text(spotProps(i).WeightedCentroid(1,1)-txtDist(1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), spotData(i).WellPosition, 'Color','white','FontSize',10);            
        end

    case 'AddSpots'
%% Add Spots Mode: incorporates added spot into spotProps/spotData data structures         
        
tic;
    % Import spotData, spotProps, and mainFig_axis object handle
        spotData = getappdata(gca, 'spotData');
        spotProps = getappdata(gca, 'spotProps');
        h = getappdata(gca, 'handles');
        
    % Ask user where to place new spot; point becomes new centroid coordinate
        msgbox('Select location for spot', 'Add Spot', 'help');
        uiwait(gcf);
        [newRow, newColumn] = getpts(h.mainFig_axis);
        newCentroid = [newRow newColumn];
     
    % Append new index to end of spotData and spotProps
        newIndex = length(spotData) + 1;
        [newSpots, newProps] = addNewSpot(im_psl, newCentroid, innerRadius, outerRadius, newIndex, h.mainFig_axis);
        
        spotProps(newIndex) = spotProps(newIndex - 1);
        spotProps(newIndex).WeightedCentroid = newProps.WeightedCentroid;
        spotProps(newIndex).outerObject = newProps.outerObject;
        spotProps(newIndex).outerMask = newProps.outerMask;
        spotProps(newIndex).outerCircles = newProps.outerCircles;
        spotProps(newIndex).innerObject = newProps.innerObject;
        spotProps(newIndex).innerMask = newProps.innerMask;
        spotProps(newIndex).innerCircles = newProps.innerCircles;                
        
        spotData(newIndex) = spotData(newIndex - 1);
        spotData(newIndex).WellPosition = spotProps(newIndex).wellPosition;
        spotData(newIndex) = newSpots;
        
        % Add text data to figure
        text(spotProps(newIndex).WeightedCentroid(1,1), spotProps(newIndex).WeightedCentroid(1,2)+txtDist(2), sprintf('%0.2f', spotData(newIndex).FractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');   
        text(spotProps(newIndex).WeightedCentroid(1,1)-txtDist(1), spotProps(newIndex).WeightedCentroid(1,2)+txtDist(2), spotData(newIndex).WellPosition, 'Color','white','FontSize',10);       
fprintf("%0.4f seconds to add new spot.\n", toc);

    case 'DeleteSpots'
%% Delete Spots Mode: removes deleted spot from spotProps/spotData data structures
        
        disp('DeleteSpots');
        
        
        
        
    
    case 'ChangeRadiiSizes'
%% Change Radii Sizes Mode: Re-do analysis after changing radii sizes    
tic;
% New version to keep spots on main axis. Just set new radii to adjusted sizes
% Get object handles from spotProps
        tableProps = struct2table(getappdata(gca, 'spotProps'));

% Keep same xMin yMin positions, but change size to new diameters
        newOutDiameter = ceil(outerRadius * 2);
        newInnDiameter = ceil(innerRadius * 2);
        
% Figure out if setNewRadii will be faster with 1 or 2 separate functions
%         arrayfun(@(x) setNewRadii(x, newOutDiameter), tableProps.outerObject, 'UniformOutput', 0');
%         arrayfun(@(y) setNewRadii(y, newInnDiameter), tableProps.innerObject, 'UniformOutput', 0');
        arrayfun(@(x,y) setNewRadii(x, newOutDiameter, y, newInnDiameter), tableProps.outerObject, tableProps.innerObject, 'UniformOutput', 0); 
        
        tableProps.outerMask = arrayfun(@(x) createMask(x), tableProps.outerObject, 'UniformOutput', 0);
        tableProps.innerMask = arrayfun(@(y) createMask(y), tableProps.innerObject, 'UniformOutput', 0);   
       
        tableProps.outerCircles = cellfun(@(x) im_psl(x), tableProps.outerMask, 'UniformOutput', 0);
        tableProps.innerCircles = cellfun(@(y) im_psl(y), tableProps.innerMask, 'UniformOutput', 0);
        
        spotProps = table2struct(tableProps);
        spotData = getSpotData(spotProps);
                                       
        for i = 1:length(spotData)       
            text(spotProps(i).WeightedCentroid(1,1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), sprintf('%0.2f',spotData(i).FractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');
            text(spotProps(i).WeightedCentroid(1,1)-txtDist(1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), spotData(i).WellPosition, 'Color','white','FontSize',10);            
        end
fprintf("%0.4f seconds for radii size change.\n", toc);
end

end

%% Change so I get entire tableProps for access to all parameters
%% xMinInn and yMinInn should be xMin-outerRadius and yMin-outerRadius innDiameter innDiameter
function setNewRadii(outerSpotObject, newOutDiameter, innerSpotObject, newInnDiameter)
    positionParametersOut = outerSpotObject.getPosition();
    oldRadiusOut = getappdata(gca, 'oldRadiusOut');
    centroidPosition = positionParametersOut(1:2) + oldRadiusOut;    

    xMinOut = centroidPosition(1) - (0.5 * newOutDiameter);
    yMinOut = centroidPosition(2) - (0.5 * newOutDiameter);
    outerSpotObject.setPosition([xMinOut yMinOut newOutDiameter newOutDiameter]);
       
    xMinInn = centroidPosition(1) - (0.5 * newInnDiameter);
    yMinInn = centroidPosition(2) - (0.5 * newInnDiameter);
    innerSpotObject.setPosition([xMinInn yMinInn newInnDiameter newInnDiameter]);
end


