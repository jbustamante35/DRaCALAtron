function spotData = getSpotData(spotProps)
% spotData: function to calculate data from all spots from inputted image
% using object properties stored in spotProps.
% 
% Usage: 
%   spotData = getSpotData(spotProps)
%
% % Fraction Bound Equation:
%   I = Summed Intensity
%   A = Area
%   inn = inner circle
%   out = outer circle
%   bg  = background 
%   FB = Fraction Bound
% 
%   Ibg = Ainn * ((Iout - Iinn)/(Aout - Ainn));
%   FB = (Iinn - Ibg)/ Iout; 

tic;
%% Convert to table to use vector functions. Improved speed by 2-fold! [0.10 sec to 0.04 sec]
tableProps = struct2table(spotProps);

% Get all data from properties from spotProps
WellPosition = cellstr(tableProps.wellPosition);
SpotNum = num2cell(1:length(tableProps.wellPosition))';
Aout = cellfun(@length, tableProps.outerCircles, 'UniformOutput', 0);
Iout = cellfun(@sum, tableProps.outerCircles, 'UniformOutput', 0);
Ainn = cellfun(@length, tableProps.innerCircles, 'UniformOutput', 0);
Iinn = cellfun(@sum, tableProps.innerCircles, 'UniformOutput', 0);

%% Subtract background fluoescence due to unbound ligand in protein spot, then calculate total fraction bound 
Ibg = cellfun(@(Io, Ii, Ao, Ai) (Ai *((Io - Ii) / (Ao - Ai))), Iout, Iinn, Aout, Ainn, 'UniformOutput', 0);
FractionBound = cellfun(@(Ii,bg,Io) ((Ii - bg) / Io), Iinn, Ibg, Iout, 'UniformOutput', 0);

%% Store all data into spotData structure 
spotData = struct('WellPosition', WellPosition,...
    'SpotNum', SpotNum,...            
    'Iinn', Iinn,...
    'Ainn', Ainn,...
    'Iout', Iout,...
    'Aout', Aout,...
    'Ibg' , Ibg,...
    'FractionBound', FractionBound);

fprintf("%0.4f seconds to calculate spotData.\n", toc);