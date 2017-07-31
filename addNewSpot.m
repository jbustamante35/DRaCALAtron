function [newSpots, newProps] = addNewSpot(im, centroid_position, innerRadius, outerRadius, newIndex, h)
% addNewSpot: function to add a new inner/outer circle to main image. 
%
% Input: 
%   - im:           PSL-converted main image
%   - centroid_position:  coordinates of new spot chosen by user
%   - newIndex:     index number of new spot
%   - innerRadius:  inner circle radius in pixels
%   - outerRadius:  outer circle radius in pixels
%   - h: object handle for main axis figure
%
% Output:
%   - newSpots: new spotData to append to main data structure
%   - newProps: new spotProps to append to main data structure

%% Set new structure to append to newProps
newProps = struct();                        
newProps.WeightedCentroid = centroid_position;

% Set up outer circle ellipse parameters and properties
outMin = newProps.WeightedCentroid - outerRadius; % Position for ellipse (doesn't use centroid position)
outerDiameter = 2 * outerRadius;
outPosParams = [outMin(1) outMin(2) outerDiameter outerDiameter]; % Position and Size parameters for imellipse

newProps.outerObject = imellipse(h, outPosParams); % Create draggable, re-sizable outer circle at user-defined location
newProps.outerObject.setColor('g');
newProps.outerObject.setFixedAspectRatioMode('on');
newProps.outerMask = newProps.outerObject.createMask;
newProps.outerCircles = im(newProps.outerMask); % Map pixel values within circular mask from inputted image

% Set up inner circle
innMin = newProps.WeightedCentroid - innerRadius; % Position for ellipse (doesn't use centroid position)
innerDiameter = 2 * innerRadius;
innPosParams = [innMin(1) innMin(2) innerDiameter innerDiameter]; % Position and Size parameters for imellipse

newProps.innerObject = imellipse(h, innPosParams); % Create draggable, re-sizable inner circle at user-defined location
newProps.innerObject.setColor('b');
newProps.innerObject.setFixedAspectRatioMode('on');
newProps.innerMask = newProps.innerObject.createMask;
newProps.innerCircles = im(newProps.innerMask); % Map pixel values within circular mask from inputted image


%% Add new data to spotData(end + 1)
newSpots = struct();
newSpots.WellPosition = {};
newSpots.SpotNum = newIndex;
newSpots.Ainn = length(newProps.innerCircles);
newSpots.Aout = length(newProps.outerCircles);
newSpots.Iinn = sum(newProps.innerCircles);
newSpots.Iout = sum(newProps.outerCircles);
newSpots.Ibg = newSpots.Ainn * ((newSpots.Iout - newSpots.Iinn) / (newSpots.Aout - newSpots.Ainn));
newSpots.FractionBound = ((newSpots.Iinn - newSpots.Ibg) / newSpots.Iout);
