function spotProps_old = maskOnCircles(im, spotProps_old, innerRadius, outerRadius)
% Function spotProps = maskOnCircles(im, spotProps, innerRadius, outerRadius)
% Function to re-mask image using circle properties
% Inputted image im may go through ql2psl function (function to convert QL
% to PSL pixel values)

% Remask with Inner and Outer Circles          
outerCircles = {};
outerMask = {};
innerCircles = {};
innerMask = {};
[xgrid, ygrid] = meshgrid(1:size(im,2), 1:size(im,1));
for i = 1:length(spotProps_old)            
    outerMask{i} = ((xgrid - spotProps_old(i).WeightedCentroid(1,1)).^2 + (ygrid - spotProps_old(i).WeightedCentroid(1,2)).^2) <= (outerRadius).^2;
    innerMask{i} = ((xgrid - spotProps_old(i).WeightedCentroid(1,1)).^2 + (ygrid - spotProps_old(i).WeightedCentroid(1,2)).^2) <= (innerRadius).^2;
    outerCircles{i} = im(outerMask{i});
    innerCircles{i} = im(innerMask{i});

    spotProps_old(i).innerMask = innerMask{i};
    spotProps_old(i).innerCircles = innerCircles{i};
    spotProps_old(i).outerMask = outerMask{i};
    spotProps_old(i).outerCircles = outerCircles{i};
end