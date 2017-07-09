function [spotData, spotProps] = spotAnalyzer(im_psl, im_raw, innerRadius, outerRadius, switchMode)
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

sprintf('Running %s', switchMode);
txtDist = [(outerRadius + (innerRadius / 4)) outerRadius]; % x and y distances for text from centroid

switch switchMode    
    case 'InitialAnalysis'
% Create Mask and Boundaries
        [im_bounds, ~] = autoSegment(im_psl); % When I get interactive segmentation 
        im_bounds_refine = bwareaopen(im_bounds, 300, 8);        
%         
% Re-mask with Inner/Outer Circles and get Data from Spots
%         props_table = struct2table(regionprops(im_bounds_refine, im_psl, 'all'));
%         [props_table, ~] = sortrows(props_table, 'WeightedCentroid'); % Sort spotProps by column value
%         spotProps_unsorted = table2struct(props_table); % Reconvert table to structure
%         spotProps_unsorted = maskOnCircles(im_psl, spotProps_unsorted, innerRadius, outerRadius);
        
% % %         % Allow user to manually set inner/outer radii sizes
% % %         setRadiiSize = input('Set initial sizes for inner and outer radius?');
% % %         if setRadiiSize == 1 % Set size manually
% % %             innerRadius = input();
% % %             outerRadius = input();
% % %             txtDist = [(outerRadius + (innerRadius / 4)) outerRadius];
% % %         else                    %Use default sizes
% % %         end
           
        % Re-index spot index reflect grid coordinates
        spotProps_unsorted = regionprops(im_bounds_refine, im_psl, 'all');
        spotProps_unsorted = maskOnCircles(im_psl, spotProps_unsorted, innerRadius, outerRadius);
        [~, spotProps] = spotReIndex(spotProps_unsorted, outerRadius);
        spotData = getSpotData(spotProps);
                                       
        for i = 1:length(spotData)            
            text(spotProps(i).WeightedCentroid(1,1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), sprintf('%0.2f',spotData(i).FractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');   
            text(spotProps(i).WeightedCentroid(1,1)-txtDist(1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), num2str(spotData(i).SpotNum), 'Color','white','FontSize',14);            
        end
        
    case 'AddSpots'        
        disp('AddSpots');
        
        
        
% Figure out to add current spotData/spotProps
% Additional function parameter
% Just make a new function that this case calls            
        
        
        
    case 'DeleteSpots'
        disp('DeleteSpots');
        
        
        
        
        
    case 'ChangeRadiiSizes'
% Create Mask and Boundaries
        [im_bounds, ~] = autoSegment(im_psl); % When I get interactive segmentation 
        im_bounds_refine = bwareaopen(im_bounds, 300, 8);           
        
% Re-mask with Inner/Outer Circles and get Data from Spots
%         props_table = struct2table(regionprops(im_bounds_refine, im_psl, 'all'));
%         [props_table, ~] = sortrows(props_table, 'WeightedCentroid'); % Sort spotProps by column value
%         spotProps_unsorted = table2struct(props_table); % Reconvert table to structure
%         spotProps_unsorted = maskOnCircles(im_psl, spotProps_unsorted, innerRadius, outerRadius);
%         
        % Re-index spot index reflect grid coordinates
        spotProps_unsorted = regionprops(im_bounds_refine, im_psl, 'all');
        spotProps_unsorted = maskOnCircles(im_psl, spotProps_unsorted, innerRadius, outerRadius);
        [~, spotProps] = spotReIndex(spotProps_unsorted, outerRadius);
        spotData = getSpotData(spotProps);
                                       
        for i = 1:length(spotData)            
            text(spotProps(i).WeightedCentroid(1,1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), sprintf('%0.2f',spotData(i).FractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');   
            text(spotProps(i).WeightedCentroid(1,1)-txtDist(1), spotProps(i).WeightedCentroid(1,2)+txtDist(2), num2str(spotData(i).SpotNum), 'Color','white','FontSize',14);            
        end
end