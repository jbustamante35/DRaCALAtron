function [cClick, hit] = singleSpot(userColumn, userRow, spotProps)
% singleSpot: function for checkSpot_button in QuantDRaCALA to examine
% image and data of individual spots.
%
% Usage:
%   [cClick, hit] = singleSpot(userColumn, userRow, outerMask)
%
% Prompt user to click a location on mainFig_axis to assess spotData and
% spotProperties of desired spot
% User must first run through spotAnalyzer function to create outerMask
%
% Search through all spots and determine if user's click is inside a spot
%       cClick == 0 if not in spot, and cClick == 1 if click was inside spot
%       If cClick == 1, then hit == index number of chosen polygon
%
% Input:
%        userColumn = x-axis coordinate of user's click
%        userRow    = y-axis coordinate of user's click
%        outerMask  = matrix array of masks for outer circles
%
% Output:
%       cClick     = boolean for inpolygon function
%       hit        = index number of polygon of user's click coordinate
%

tic;
tableProps = struct2table(spotProps);
outerBounds = cellfun(@(x) bwboundaries(x), tableProps.outerMask);
cClick = cellfun(@(x) inpolygon(userColumn, userRow, x(:,1), x(:,2)), outerBounds);
hit = find(cClick == 1);

if isempty(hit) % User clicked outside of polygon 
    msgbox('No spot found in location. Try again!');
    uiwait(gcf);
end 
fprintf("%0.4f seconds to locate hit.\n", toc);