function spotProps_update = getSpotProps(im, spotProps_old, innerRadius, outerRadius)
% Function spotProps = maskOnCircles(im, spotProps, innerRadius, outerRadius)
% This function will take an image with pre-defined objects and re-mask
% those objects with inner and outer circles of inputted radii.
% The spotProps_old structure array contains the Weighted Centroid
% parameter that is used to designate the center of the circles. 
%
% The posititions for the circle centers is determined by the original
% centroid x,y positions - inner/outer radius. This is because the
% imellipse() function uses minumum x/y positions rather than the position
% for the center of the circle itself. A new mask is created from the inner
% and outer circles, then the pixel locations from that mask is used to
% define the ROI for the inputted image.  
%
% This latest version creates draggable and resizable circles so that the
% user can refine the shape and positions of the original objects. Running
% the output with getSpotData() will update the spotData structure array
% with the newly-defined spot properties.
%
% It is important to note that because of the large amount of pixel
% information on the figure, this new method is extremely heavy
% computationally. I need to find a more efficient method that still allows
% the flexibility of revising spot sizes and positions. 
%
% Input:
%                 im: inputted 8-bit or 16-bit image. 
%      spotProps_old: original regionprops() output structure containing
%                     properties of spot objects
%        innerRadius: user-defined radius for the inner circle
%        outerRadius: user-defined radius for the outer circle
%
% Output:
%   spotProps_update: updated spotProps structure array containing updated
%                     inner and outer masks and circle properties

% Updated function to create draggable and resizable circles
outerMask = cell(1,length(spotProps_old));
innerMask = cell(1,length(spotProps_old));
outerCircles = cell(1,length(spotProps_old));
innerCircles = cell(1,length(spotProps_old));

% Set Position of ellipse to Weighted Centroid
tableProps = struct2table(spotProps_old);
outerMin = tableProps.WeightedCentroid - outerRadius;
innerMin = tableProps.WeightedCentroid - innerRadius;

outerD = 2*outerRadius;
innerD = 2*innerRadius;

outerPositionParams = [outerMin(:,1) outerMin(:,2)];
outerPositionParams(:,3:4) = outerD;
innerPositionParams = [innerMin(:,1) innerMin(:,2)];
innerPositionParams(:,3:4) = innerD;

h = gca;

for i = 1:length(spotProps_old)
% Create inner and outer ellipses at Weighted Centroid of set Diameter    
    outerMask{i} = imellipse(h, outerPositionParams(i,:));
    drawnow limitrate nocallbacks;
    outerMask{i}.setColor('g'); 
    outerMask{i}.setFixedAspectRatioMode('on');
    innerMask{i} = imellipse(h, innerPositionParams(i,:));
    drawnow limitrate nocallbacks;
    innerMask{i}.setColor('b'); 
    innerMask{i}.setFixedAspectRatioMode('on');
    
    % Create inner and outer circles from generated mask    
    outerCircles{i} = im(outerMask{i}.createMask());
    innerCircles{i} = im(innerMask{i}.createMask()); 
    
    % Overwrite previous circle data    
    spotProps_old(i).outerMask = outerMask{i}.createMask();
    spotProps_old(i).outerCircles = outerCircles{i};
    spotProps_old(i).innerMask = innerMask{i}.createMask();
    spotProps_old(i).innerCircles = innerCircles{i};
end

hold on;
spotProps_update = spotProps_old;
clear spotProps_old;