function [digitImg_enh,palmImg,paw_img] =trackTattooedPaw( video,  rat_metadata, Fleft, Fright, register_ROI, varargin )
%
% INPUTS:
%   video - a videoReader object containing the video recorded from 


% ALGORITHM:
%   1) find the trigger frame
%   2)


% might be able to set the ROI automatically based on automatic detection
% of the box edges
numBGframes = 50;
ROI_to_find_trigger_frame = [0210         0590         0050         0070
                             1740         0560         0050         0070];
ROI_to_mask_paw = [0090 0540 0180 0145
                   0930 0520 0180 0200
                   1730 0520 0180 0165];
gray_paw_limits = [60 125];
BGimg = [];

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGframes = varargin{iarg + 1};
        case 'trigger_roi',
            ROI_to_find_trigger_frame = varargin{iarg + 1};
        case 'graypawlimits',
            gray_paw_limits = varargin{iarg + 1};
        case 'mask_roi',
            ROI_to_mask_paw = varargin{iarg + 1};
        case 'bgimg',
            BGimg = varargin{iarg + 1};
    end
end

if isempty(BGimg)
    BGimg = extractBGimg( video, 'numbgframes', numBGframes);
end

% [triggerFrame, peakFrame]= identifyTriggerFrame( video, rat_metadata.pawPref, ...
%                                                   'bgimg', BGimg, ...
%                                                   'trigger_roi',ROI_to_find_trigger_frame,...
%                                                   'grylimits',gray_paw_limits);
triggerFrame = 511;peakFrame = 532;   % hard code to speed up analysis
preReachFrame = triggerFrame - 25;
% find a mask for the paw in the lateral, central, and right mirrors for
% the peak frame

im_trigger = read(video,triggerFrame);
im_peak = read(video,peakFrame);
im_preReach = read(video,preReachFrame);    % this image may or may not turn out to be useful

imDiff = imabsdiff(im_preReach,im_peak);

[digitImg,palmImg,paw_img,paw_mask] = maskPaw(im_peak, BGimg, register_ROI,Fleft,Fright,register_ROI,rat_metadata);
if strcmpi(rat_metadata.pawPref,'right')    % back of paw in the left mirror
    % looking in the left mirror for the digits
    dorsalPawMask = paw_mask{1};
else
    % looking in the right mirror for the digits
    dorsalPawMask = paw_mask{3};
end
digitMask = identifyDigits(digitImg, dorsalPawMask, rat_metadata);


digit_gray = rgb2gray(digitImg);digitMask = digit_gray > 0;
[pawRows,pawCols] = find(digit_gray);
digitImg_enh = decorrstretch(digitImg,'samplesubs',{pawRows,pawCols});
figure(1)
imshow(digitImg_enh)
figure(2)
imshow(palmImg)

% find the individual digits, as well as the palm to initiate tracking in
% the "color" image mirror (the one that sees the dorsum of the paw)

end    % end function trackTattooedPaw( video )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
