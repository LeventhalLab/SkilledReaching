function [paw_img,thresh_mask,mask] = maskPaw( img, BGimg, ROI_to_mask_paw, varargin )
%
% usage:
%
% INPUTS:
%   img - the image in which to find the paw mask
%   ROI_to_mask_paw - 

diff_threshold = 45;

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'diffthreshold',
            diff_threshold = varargin{iarg + 1};
    end
end

paw_img = cell(1,3);
thresh_mask = cell(1,3);
paw_mask = cell(1,3);
bg_subtracted_image = imabsdiff(img, BGimg);

for ii = 1 : 3
    paw_img{ii} = bg_subtracted_image(ROI_to_mask_paw(ii,2):ROI_to_mask_paw(ii,2) + ROI_to_mask_paw(ii,4),...
                                      ROI_to_mask_paw(ii,1):ROI_to_mask_paw(ii,1) + ROI_to_mask_paw(ii,3),:);
	thresh_mask{ii} = rgb2gray(paw_img{ii}) > diff_threshold;
end

% work on the left and right images first...
for ii = 1 : 2 : 3
    paw_mask{ii} = bwdist(thresh_mask{ii}) < 2;
    SE = strel('disk',3);
    paw_mask{ii} = imopen(paw_mask{ii}, SE);
    paw_mask{ii} = imclose(paw_mask{ii},SE);
    paw_mask{ii} = imfill(paw_mask{ii},'holes');
end

% given the fundamental transformation matrix from the background, we
% should be able to constrain where the paw is in the front view


% mask out the purple digit

% WORKING HERE...
% START BY THRESHOLDING BASED ON IMAGE SUBTRACTION, THEN GO BACK TO
% IDENTIFY COLORS IN THE PREVIOUSLY MASKED IMAGE
% LOOK INTO WHETHER ANY OF THE MATLAB IMAGE TRACKING ALGORITHMS WILL FOLLOW
% THE PAW AND/OR DIGITS ONCE IDENTIFIED IN THE FIRST FRAME
% ALSO NEED TO FIGURE OUT WHAT TO DO ABOUT THE CENTER WHERE THE BG
% SUBTRACTION ISN'T AS CLEAN

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
