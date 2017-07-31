function [plateImage, splitFilenames, plateProps] = splitFullPlate(imageName)
% splitFullPlate: function to split a large image with multiple plates into
% individual plate images. This function utilizes simple object
% identification functions to locate the centroid positions of each
% individual plate, then use that location to 
% 
% Usage:
% [plateImage, splitFilenames, plateProps] = splitFullPlate(imageName)
%
% Input
% imageName:
% 
% Output
% plateImage: 
% splitFilenames: 
% plateProps: 
% 

tic;
im_fullPlate = imread(imageName);
imageInfo = imfinfo(imageName);

% Determine user's OS
if (isunix == 1)
    filename_find = strfind(imageInfo.Filename,'/');
elseif (ispc == 1)
    filename_find = strfind(imageInfo.Filename,'\');
else
    filename_find = strfind(imageInfo.Filename, 'DefaultImageName');
end

filename_base = imageInfo.Filename(filename_find(end)+1:end-4);

[im_bw, ~] = autoSegment(im_fullPlate);
im_bounds_refine = bwareaopen(im_bw, 10000, 8);
plateProps = regionprops(im_bounds_refine, 'all'); % Structure doesn't contain WeightedCentroid

splitFilenames = cell({1:length(plateProps)});

for i = 1:length(plateProps)
    plateProps(i).WeightedCentroid = plateProps(i).Centroid; % spotReIndex uses WeightedCentroid
end

[~, plateProps] = spotReIndex(plateProps, 60);

plateImage = {1:length(plateProps)};
for i = 1:length(plateProps)
    columnCenter = round(plateProps(i).Centroid(1));
    columnRange  = round(plateProps(i).MajorAxisLength / 2);
    rowCenter = round(plateProps(i).Centroid(2));
    rowRange = round(plateProps(i).MinorAxisLength / 2);    
   
    plateImage{i} = im_fullPlate((rowCenter-rowRange):(rowCenter+rowRange), (columnCenter-columnRange):(columnCenter+columnRange));
    imageName = sprintf('%s_imageExport_%d.tif', filename_base, i);
    splitFilenames{i} = imageName;
    imwrite(plateImage{i},imageName,'tif');
end

hold off;
fprintf("%0.4f seconds to split plate.\n", toc);

