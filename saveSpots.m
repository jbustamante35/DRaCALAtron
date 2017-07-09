function saveSpots(mySpots, filename)
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

mySpots_dataset = struct2dataset(mySpots(:));
save(filename, 'mySpots'); % Saves data as .mat file
export(mySpots_dataset, 'XLSfile', filename); % Saves data as .xls file