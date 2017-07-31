function spotProps_update = getSpotProps(im, spotProps_old, innerRadius, outerRadius)
% getSpotProps: function to obtain properties of re-masked inner and outer
% circles using the raw output from the regionprops function. New circles
% are re-masked using the weighted centroid positions of the raw object.
%
% Usage:
%   spotProps = maskOnCircles(im, spotProps, innerRadius, outerRadius)
% 
% This function will take an image with pre-defined objects and re-mask
% those objects with inner and outer circles of inputted radii.
% The spotProps_old structure array contains the Weighted Centroid
% parameter that is used to designate the center of the circles. 
%
% The posititions for the circle centers are determined by the original
% centroid (x,y) positions - the inner/outer radius. This is because the
% imellipse() function uses minumum (x,y) positions rather than the position
% for the center of the circle itself. A new mask is created from the inner
% and outer circles, then the pixel values from that mask are used to
% define the ROI properties on that inputted image.  
%
% As of version 1.3 (7/21/2017), getSpotProps() creates draggable and 
% resizable circles so that the user can refine the shape and positions of 
% the original objects. Running the output with getSpotData() will update 
% the spotData structure array with the newly-defined spot properties.
%
% It is important to note that because of the large amount of pixel
% information on the figure, this new method is extremely heavy
% computationally. I need to find a more efficient method that still allows
% the flexibility of revising spot sizes and positions. [As of version 1.5
% (7/27/2017), I've implemented a considerable amount of vectorized
% functions and reduced the analysis time by ~40%!]
%
% Input:
%                 im: inputted 8-bit or 16-bit image. 
%      spotProps_old: original regionprops() output structure containing
%                     properties of identified objects
%        outerRadius: user-defined radius for the outer circle
%        innerRadius: user-defined radius for the inner circle
%
% Output:
%   spotProps_update: updated spotProps structure array containing updated
%                     inner and outer object handle, masks, and circle properties

% NOTE: version 1.5 (07/27/2017)
% I frequently encounter this stochastic bug where the spots are draggable
% but not re-sizeable. The setResizable method is is already set to 'on', 
% and doing so nonetheless does not solve the issue. My best guess is 
% that the imellipse() function is for some reason placing the spots 
% "behind" the main image, making it inaccessible to the user. However,
%  this doesn't explain why I can still drag the spots. 

%% Set up data structures of spotProps and main figure handle 
fullTime = cputime;
tableProps = struct2table(spotProps_old);
h = getappdata(gca, 'handles'); % Figure handle for mainFig_axis

%% The meat of the entire analysis: 
% Create circles of user-defined radii size at weighted centroid positions, 
% then place them on the main figure axis 

tic; % Calculate Outer Circles
% Re-configure weighted centroids to reflect ellipses position parameters 
        fprintf('Started analysis of outer circles...\n');
        outerMin = ceil(tableProps.WeightedCentroid - outerRadius);
        outerD = ceil(2*outerRadius);
        outerPositionParams = [outerMin(:,1) outerMin(:,2)];
% Create ellipses onto main figure, then re-mask circles from main image
        tableProps.outerObject = arrayfun(@(x, y) imellipse(h.mainFig_axis, [x y outerD outerD]), outerPositionParams(:,1), outerPositionParams(:,2), 'UniformOutput', 0);
        cellfun(@(x) configureCircle(x, 'g'), tableProps.outerObject, 'UniformOutput', 0);
        tableProps.outerMask = cellfun(@(x) createMask(x), tableProps.outerObject, 'UniformOutput', 0);
        tableProps.outerCircles = cellfun(@(x) im(x), tableProps.outerMask, 'UniformOutput', 0);
fprintf('%.04f to create %d Outer Circles.\n', toc, length(tableProps.outerObject));

tic; % Calculate Inner Circles   
fprintf('Started analysis of inner circles...\n');
% Re-configure weighted centroids to reflect ellipses position parameters 
        innerMin = ceil(tableProps.WeightedCentroid - innerRadius);
        innerD = ceil(2*innerRadius);
        innerPositionParams = [innerMin(:,1) innerMin(:,2)];
% Create ellipses onto main figure, then re-mask circles from main image
        tableProps.innerObject = arrayfun(@(x, y) imellipse(h.mainFig_axis, [x y innerD innerD]), innerPositionParams(:,1), innerPositionParams(:,2), 'UniformOutput', 0);
        cellfun(@(x) configureCircle(x, 'b'), tableProps.innerObject, 'UniformOutput', 0);
        tableProps.innerMask = cellfun(@(x) createMask(x), tableProps.innerObject, 'UniformOutput', 0);
        tableProps.innerCircles = cellfun(@(x) im(x), tableProps.innerMask, 'UniformOutput', 0);                
fprintf('%.04f to create %d Inner Circles.\n', toc, length(tableProps.innerObject));

%% Re-convert spot properties table to structure array to pass back to main GUI 
hold on;
spotProps_update = table2struct(tableProps);
totalObjects = length(tableProps.outerObject) + length(tableProps.innerObject);
fprintf("%.04f seconds to create %d spots!\n", cputime-fullTime, totalObjects);

end

%% Function to configure the properties of the ellipses objects to fixed aspect ratio mode of desired color
% This function makes the alternative of 2 separate cellfun operations 
% 2x faster [0.002 sec to 0.001 sec per ellipse]
function configureCircle(circleObject, circleColor)
    circleObject.setColor(circleColor);
    circleObject.setFixedAspectRatioMode('Y');
end
