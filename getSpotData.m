function spotData = getSpotData(spotProps)
% Function spotData = getSpotData(spotProps)
% Function to get spotData structure
% % Fraction Bound Equation:
%   I = Mean Intensity
%   A = Area
%   inn = inner circle
%   out = total circle
%   bg  = background 
% 
%   Ibg = Ainn * ((Iout - Iinn)/(Aout - Ainn));
%   FB = (Iinn - Ibg)/ Iout; 

SpotNum = {};
Iinn = {};
Ainn = {};
Iout = {};
Aout = {};
Ibg = {};
fractionBound = {};       
for i = 1:length(spotProps)
    SpotNum{i} = i;
    Ainn{i} = length(spotProps(i).innerCircles);
    Aout{i} = length(spotProps(i).outerCircles);
    Iinn{i} = sum(spotProps(i).innerCircles);
    Iout{i} = sum(spotProps(i).outerCircles);
    Ibg{i} = Ainn{i} * ((Iout{i} - Iinn{i}) / (Aout{i} - Ainn{i}));
    fractionBound{i} = ((Iinn{i} - Ibg{i}) / Iout{i}); % Normally they analyze with NON-inverted image. I use inverted image.
end

spotData = struct('SpotNum', SpotNum,...            
    'Iinn', Iinn,...
    'Ainn', Ainn,...
    'Iout', Iout,...
    'Aout', Aout,...
    'Ibg' , Ibg,...
    'FractionBound', fractionBound);