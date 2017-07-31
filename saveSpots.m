function saveSpots(mySpots, myProps, filename)
% Activated when "Save Data" button is pressed. User is prompted to choose
% a filename for the exported .mat and .xls files to be saved in the
% desired directory. 
%
% This function converts the spotData in structure array type to an
% exportable dataset array type.
%
% Input:
%   - saveSpots  : spotData in structure array to be saved
%   - filename   : user-given name for .mat and .xls file 
%
% Output:
%   - outputSpots: exportable dataset array of converted saveSpots named as
%   filename


% save(filename, 'mySpots', 'myProps'); % Saves data as .mat file
tic;
mySpots_dataset = struct2dataset(mySpots(:));
mySpots_dataset.WellPosition = cellstr(mySpots_dataset.WellPosition); % Convert spotData.WellPositions to cellstring

if ispc == 1
    export(mySpots_dataset, 'XLSfile', filename); % Saves data as .xls file    
    save(filename, 'mySpots');
    save(filename, 'myProps', '-append');
elseif isunix == 1
    filename = char(filename);
    save(filename, 'mySpots');
    save(filename, 'myProps', '-append');
    export(mySpots_dataset, 'File', sprintf('%s.txt', filename));
else
    export(mySpots_dataset, 'File', filename);
end
fprintf('%.04 seconds to save spotData and spotProps.', toc);