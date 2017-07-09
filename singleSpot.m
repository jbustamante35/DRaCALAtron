function [cClick, hit] = singleSpot(userColumn, userRow, circleMask)
% singleSpot: Function for checkSpot_button in QuantDRaCALA
% Prompt user to click a location on mainFig_axis to assess spotData and
% spotProperties of desired spot
% User must first run through spotAnalyzer function to create outerMask
%
% [cClick, hit] = singleSpot(userColumn, userRow, outerMask)
%
% Input: userColumn, userRow, and outerMask
%        userColumn = x-axis coordinate of user's click
%        userRow    = y-axis coordinate of user's click
%        outerMask  = matrix array of masks for outer circles
%
% Output: cClick, hit
%       cClick     = boolean for inpolygon function
%       hit        = index number of polygon of user' click coordinate
%
% Search through all spots and determine if user's click is inside a spot
%       cClick == 0 if not in spot, and cClick == 1 if click was inside spot
%       If cClick == 1, then hit == index number of polygon

outerBounds = {};
for i = 1:length(circleMask)
    outerBounds{i} = bwboundaries(circleMask{i}); % Use outerMask to set polygon vectors
    cClick = inpolygon(userColumn, userRow, outerBounds{i}{1}(:,1), outerBounds{i}{1}(:,2));
    if (cClick == 1) % User clicked inside polygon
        hit = i;
        break; % Break out of loop when circle is found
    end
end

if (cClick == 0) % User clicked outside of polygon 
    msgbox('No spot found in location. Try again!');
end