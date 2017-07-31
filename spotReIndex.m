function [columnCollect, spotProps_update] = spotReIndex(spotProps, radOut)
% spotReIndex function: Adjust unsorted spot number index. 
% Iterate through spots and sort columns based on x-coordinate (column value). 
% Iterate through columns and sort by y-coordinate (row value).
% Update spotData with new index number. 
%
% Usage:
% [columnCollect, spotProps_update] = spotReIndex(spotProps, radOut)
%
% Spots with centroid_distance < 1.5x outerRadius are considered to be part 
% of the same column. If centroid_distance >= 1.5x outerRadius, then 
% SpotNum(i) is considered to be in the next column. Column indeces are 
% stored in the columnCollect structure that holds individual spotData/spotProps. 
%
% Function then iterates through each index of columnCollect{i} and sorts
% spotData by y-coordinate (row value). Top-to-Bottom sorting is done
% via increasing row value. Newly-indexed values are stored in the
% new slot spotData.NewIndex, thereby retaining original spotData.SpotNum.
% to avoid any conflicts with iterating through spots in further analyses. 
%
% Input: 
%   spotProps       : physical properties of DRaCALA spots
%   radOut          : outer circle radius (in pixels)
%
% Output:
%   columnCollect   : structure containing spotData_old and spotProps_old
%   spotProps_update: updated spotData containing re-indexed spotData.NewIndex

%% Store data by columns
% columnCollect = cell({1:length(spotProps)}); % 2D cell array (multidimensional data structure) 
tic;
columnCollect{:} = cell({}); % Unknown size of columns 
colNumber = 1; % Index for collecting by columns
colIndex = 1; % Index for spots in colNum 

for i = 1:length(spotProps)
    % y-coordinate difference between current and previous spot
    if i == 1
        centroid_distance = 0; % For spot at index 1, set to 0
    else
        centroid_distance = abs(spotProps(i).WeightedCentroid(1) - spotProps(i-1).WeightedCentroid(1));
    end
    
    if centroid_distance < (1.5 * radOut) % Distance less than 1.5x the outer radius        
        columnCollect{colNumber}{colIndex,1} = spotProps(i);
        colIndex = colIndex + 1;
    else
        colNumber = colNumber + 1; % Large distance between columns, so start new column index
        colIndex = 1; % colIndex resets        
        columnCollect{colNumber}{colIndex,1} = spotProps(i);
        colIndex = colIndex + 1; % Add first data indexed at new column
    end
end

%% Sort each column in columnCollect by y-coordinate (row value)
%{
Basic Algorithm:
    Collect columnCollect index and y-coordinate in an array
    Sort array by y-coordinate while maintaining index order
    Re-index column order by finding index of matching array value
    Concatenate all spotProps with updated order 
%}

% For labelling by 96-wellplate positions
wellRows = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"]; % All 8 rows, but make 12 for ease
wellColumns = ["01", "02", "03", "04", "05", "06", "07" ,"08", "09", "10", "11", "12"]; % All 12 columns
wellLabels = [wellRows; wellColumns];

oldColumn = columnCollect;
for i = 1:length(columnCollect)    
    % Create temporary table containing row value
    columnArray = [1:length(columnCollect{i}); 1:length(columnCollect{i})]';
    
    for ii = 1:length(columnCollect{i})                
        columnArray(ii,1) = ii;
        columnArray(ii,2) = columnCollect{i}{ii}.WeightedCentroid(2); % Row value        
    end
    % Sort table by Row value and store sorted array
    [updatedArray, ~] = sort(columnArray, 1);   
   
    % Re-index collected columns by searching for a matching Row value in sorted array
    for iii = 1:length(oldColumn{i})
        match_found = 0;
        arrIndex = 1;
        while match_found == 0
            if updatedArray(arrIndex,2) == oldColumn{i}{iii}.WeightedCentroid(2)
                columnCollect{i}{updatedArray(arrIndex,1)} = oldColumn{i}{iii};
                match_found = 1;
                columnCollect{i}{updatedArray(arrIndex,1)}.wellPosition = wellLabels(1,iii) + wellLabels(2,i); % Set well position
            else
                arrIndex = arrIndex + 1;
                match_found = 0;
            end
        end
    end            
end

columnCollect_all = cat(1, columnCollect{:});
spotProps_update = cat(1, columnCollect_all{:});
fprintf("%0.4f seconds to re-index spotProps.\n", toc);
