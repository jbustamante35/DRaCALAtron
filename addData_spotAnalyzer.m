function [new_spotData, new_spotProps] = addData_spotAnalyzer(im, centroid_position)
% Function to append newly-added data to the current index of spotData and
% spotProps
% Input: 
%   - im_raw:       original image
%   - im:           processed original image
%   - centroid_position:  coordinates of new spot
%   - newIndex:     index number of new spot
%   - innerRadius:  inner circle radius in pixels
%   - outerRadius:  outer circle radius in pixels
%
% Output:
%   - 


% Use meshgrid function to form new innerMask/outerMask from that position
[xgrid, ygrid] = meshgrid(1:size(im,2), 1:size(im,1));        
newOuterMask = ((xgrid - newCentroid(1)).^2 + (ygrid - newCentroid(2)).^2) <= (radiusOut).^2;
newInnerMask = ((xgrid - newCentroid(1)).^2 + (ygrid - newCentroid(2)).^2) <= (radiusIn).^2;
newOuterCircle = im(newOuterMask);
newInnerCircle = im(newInnerMask);         

% Add new properties to spotProps(end + 1) 
spotProps(newIndex).WeightedCentroid = newCentroid;
spotProps(newIndex).innerMask = newInnerMask;
spotProps(newIndex).innerCircles = newInnerCircle;
spotProps(newIndex).outerMask = newOuterMask;
spotProps(newIndex).outerCircles = newOuterCircle;       


innFactor = 1; % If I figure out scaling factor used by Image Quant
outFactor = 1;  
% Add new data to spotData(end + 1)        
spotData(newIndex).SpotNum = newIndex;
spotData(newIndex).Ainn = length(spotProps(newIndex).innerCircles);
spotData(newIndex).Aout = length(spotProps(newIndex).outerCircles);
spotData(newIndex).Iinn = sum(spotProps(newIndex).innerCircles/innFactor);
spotData(newIndex).Iout = sum(spotProps(newIndex).outerCircles/outFactor);
spotData(newIndex).Ibg = spotData(newIndex).Ainn * ((spotData(newIndex).Iout - spotData(newIndex).Iinn) / (spotData(newIndex).Aout - spotData(newIndex).Ainn));
spotData(newIndex).fractionBound = ((spotData(newIndex).Iinn - spotData(newIndex).Ibg) / spotData(newIndex).Iout);

text(spotProps(newIndex).WeightedCentroid(1,1)-12, spotProps(newIndex).WeightedCentroid(1,2)+25, sprintf('%0.2f', spotData(newIndex).fractionBound), 'Color', 'white', 'FontSize', 8, 'FontWeight', 'Bold', 'BackgroundColor', 'black');   
text(spotProps(newIndex).WeightedCentroid(1,1)-35, spotProps(newIndex).WeightedCentroid(1,2)+35, num2str(spotData(newIndex).SpotNum), 'Color','white','FontSize',14);
