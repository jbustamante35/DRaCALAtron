function [plateImage, splitFilenames, plateProps] = splitFullPlate(imageName)

% imageName = uigetfile({'*.tif;*.tiff;*.gel'}, 'Select Full Image', 'MultiSelect', 'on'); % Version for batch
% imageName = uigetfile({'*.tif;*.tiff;*.gel'}, 'Select Full Image'); 

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

% figure(1);
% imagesc(im_fullPlate), colormap gray, axis image, axis off;

plateImage = {1:length(plateProps)};
for i = 1:length(plateProps)
    columnCenter = round(plateProps(i).Centroid(1));
    columnRange  = round(plateProps(i).MajorAxisLength / 2);
    rowCenter = round(plateProps(i).Centroid(2));
    rowRange = round(plateProps(i).MinorAxisLength / 2);    
%     columnBuffer = columnRange / 10; 
%     rowBuffer = rowRange / 10;
       
%     figure(1);
%     subplot(3, 2, i);    
%     imagesc(im_fullPlate((rowCenter-rowRange):(rowCenter+rowRange), (columnCenter-columnRange):(columnCenter+columnRange)));
%     title(sprintf('Plate Number: %d', i));
%     colormap gray, axis image, axis off;   
%     
%     figure(2);
%     hold on;   
%     text(plateProps(i).WeightedCentroid(1), plateProps(i).WeightedCentroid(2), sprintf('Sort %d',i));
    
    plateImage{i} = im_fullPlate((rowCenter-rowRange):(rowCenter+rowRange), (columnCenter-columnRange):(columnCenter+columnRange));
    imageName = sprintf('%s_imageExport_%d.tif', filename_base, i);
    splitFilenames{i} = imageName;
    imwrite(plateImage{i},imageName,'tif');
end

hold off;

