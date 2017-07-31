function [im_bw, im_mask] = autoSegment(im)
% autoSegment: function to segment image for analysis. The current settings 
% as of version 1.0 (7/09/2017) segments image im using auto-generated code 
% from the imageSegmenter app. The final segmentation is returned in
% im_bw, and a masked image is returned in im_mask.
%
% Eventually this will call a new window to allow the user to manually
% segment difficult images. This function will be called upon the pushing
% of the 'Segmentation' push button.
%
% Usage:
%   [im_bw, im_mask] = autoSegment(im) 
%
% Input:
%   im: inputted 8-bit or 16-bit image. Preferably will be PSL-converted
%       pixel values for optimal results (see ql2psl.m). 
% 
% Output:
%   im_bw: binarized black-and-white image.
%   im_mask: mask of inputted image overlaid on segmented image. In other
%       words, im pixels will be filled where im_bw == 1.
% 

% Normalize input data to range in [0,1].
tic;
Xmin = min(im(:));
Xmax = max(im(:));
if isequal(Xmax,Xmin)
    im = 0*im;
else
    im = (im - Xmin) ./ (Xmax - Xmin);
end

% Threshold image - adaptive threshold
im_bw = imbinarize(im, 'adaptive', 'Sensitivity', 0.24, 'ForegroundPolarity', 'dark');

% Clear borders
im_bw = imclearborder(im_bw);

% Open mask with disk
radius = 8;
decomposition = 6;
se = strel('disk', radius, decomposition);
im_bw = imopen(im_bw, se);

% Create masked image.
im_mask = im;
im_mask(~im_bw) = 0;
fprintf("%0.4f seconds to binarize and segment image.\n", toc);
end

% Think about using homemade imageSegmenter for QuantDRaCALA