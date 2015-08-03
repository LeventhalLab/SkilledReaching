function [digitMirrorMask_dorsum,digitCenterMask] =trackTattooedPaw( video, rat_metadata, F, boxMarkers, varargin )
%
% INPUTS:
%   video - a videoReader object containing the video recorded from 


% ALGORITHM:
%   1) find the trigger frame
%   2)

% NOTES:
% - CONSIDER AN ALGORITHM WHERE WE LOOK FOR ALL THE DIGITS AND THE DORSUM
%   OF THE PAW; IF WE DON'T FIND IT, KEEP MOVING THROUGH FRAMES UNTIL WE DO
% - NEED TO THINK ABOUT EXACTLY WHAT WE NEED TO PULL OUT FOR ROBUST
%   ANALYSES. TO START, LET'S TRY JUST THE CENTROIDS OF THE PAW AND DIGITS
%   IN EACH PROJECTION

% might be able to set the ROI automatically based on automatic detection
% of the box edges
numBGframes = 50;
ROI_to_find_trigger_frame = [0210         0590         0050         0070
                             1740         0560         0050         0070];
gray_paw_limits = [60 125];
BGimg = [];
decorrStretchMean  = [100.5 127.5 100.5];
decorrStretchSigma = [025 050 025];

diff_threshold = 45;
extentLimit = 0.5;
minCenterPawArea = 3000;
maxCenterPawArea = 11000;

minMirrorPawArea = 3000;
maxMirrorPawArea = 11000;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGframes = varargin{iarg + 1};
        case 'trigger_roi',
            ROI_to_find_trigger_frame = varargin{iarg + 1};
        case 'graypawlimits',
            gray_paw_limits = varargin{iarg + 1};
        case 'bgimg',
            BGimg = varargin{iarg + 1};
    end
end

if isempty(BGimg)
    BGimg = extractBGimg( video, 'numbgframes', numBGframes);
end
BGimg = double(BGimg) / 255;
% put the line below back in when done debugging
% [triggerFrame, peakFrame]= identifyTriggerFrame( video, rat_metadata.pawPref, ...
%                                                   'bgimg', BGimg, ...
%                                                   'trigger_roi',ROI_to_find_trigger_frame,...
%                                                   'grylimits',gray_paw_limits);
triggerFrame = 511;peakFrame = 532;   % hard code to speed up analysis % peak should be 532
preReachFrame = triggerFrame - 25;
% find a mask for the paw in the lateral, central, and right mirrors for
% the peak frame
triggerTime = identifyTriggerTime( video, rat_metadata, boxMarkers);

% im_trigger = read(video,triggerFrame);
% im_peak = read(video,peakFrame);
% im_preReach = read(video,preReachFrame);    % this image may or may not turn out to be useful
% 
% peak_paw_img = cell(1,3);
% for ii = 1 : 3
%     peak_paw_img{ii} = im_peak(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
%                                register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3),:);
% 	if ii ~= 2
%         peak_paw_img{ii} = fliplr(peak_paw_img{ii});
%     end
% end
% imDiff = imabsdiff(im_preReach,im_peak);
digitMasks = initialDigitID(video, triggerTime, BGimg, rat_metadata, boxMarkers);

[P1, P2] = cameraMatricesFromFundMatrix(boxMarkers, rat_metadata);
% NOW NEED TO CALIBRATE THE CAMERA MATRICES BASED ON THE CHECKERBOARD
% POINTS


fundmat = zeros(2,3,3);
fundmat(1,:,:) = F.left;
fundmat(2,:,:) = F.right;
paw_mask = maskPaw(video, peakFrame, BGimg, register_ROI,fundmat,rat_metadata, boxMarkers, ...
                   'diffthreshold',diff_threshold,...
                   'extentlimit',extentLimit,...
                   'mincenterpawarea',minCenterPawArea,...
                   'maxcenterpawarea',maxCenterPawArea, ...
                   'minmirrorpawarea',minMirrorPawArea, ...
                   'maxmirrorpawarea',maxMirrorPawArea);
if strcmpi(rat_metadata.pawPref,'right')    % back of paw in the left mirror
    % looking in the left mirror for the digits
    dorsalFundMat = F.left;
    dorsalPawMaskIdx = 1;
else
    % looking in the right mirror for the digits
    dorsalFundMat = F.right;
    dorsalPawMaskIdx = 3;
end
% rgbMask  = repmat(uint8(paw_mask{dorsalPawMaskIdx}),1,1,3);
% digitImg = rgbMask .* peak_paw_img{dorsalPawMaskIdx};
% [pawRows,pawCols] = find(paw_mask{dorsalPawMaskIdx});
% digitImg_enh = decorrstretch(digitImg,'samplesubs',{pawRows,pawCols}, ...
%                              'targetmean',decorrStretchMean,...
%                              'targetsigma',decorrStretchSigma);
% digitImg_enh = rgbMask .* digitImg_enh;    % make sure non-paw pixels are set to [0 0 0]
% digitImg_enh = rgb2hsv(digitImg_enh);
% digitImg_enh(:,:,2) = imadjust(digitImg_enh(:,:,2));
% digitImg_enh(:,:,3) = imadjust(digitImg_enh(:,:,3));
% digitImg_enh = hsv2rgb(digitImg_enh);

rgbMask   = repmat(uint8(paw_mask{2}),1,1,3);
centerImg = rgbMask .* peak_paw_img{2};
% [pawRows,pawCols] = find(paw_mask{2});
% centerImg_enh = decorrstretch(centerImg,'samplesubs',{pawRows,pawCols}, ...
%                               'targetmean',decorrStretchMean,...
%                               'targetsigma',decorrStretchSigma);
% centerImg_enh = rgbMask .* centerImg_enh;   % make sure non-paw pixels are set to [0 0 0]
% centerImg_enh = rgb2hsv(centerImg_enh);
% centerImg_enh(:,:,2) = imadjust(centerImg_enh(:,:,2));
% centerImg_enh(:,:,3) = imadjust(centerImg_enh(:,:,3));
% centerImg_enh = hsv2rgb(centerImg_enh);

% find the digits in the mirror frame with the dorsum of the paw
% NEED TO FEED IN FULL DIGITIMG, NOT JUST THE MASKED VERSION

temp = fliplr(paw_mask{dorsalPawMaskIdx});
pawMask = false(size(im_peak,1),size(im_peak,2));
pawMask(register_ROI(dorsalPawMaskIdx,2):register_ROI(dorsalPawMaskIdx,2) + register_ROI(dorsalPawMaskIdx,4), ...
        register_ROI(dorsalPawMaskIdx,1):register_ROI(dorsalPawMaskIdx,1) + register_ROI(dorsalPawMaskIdx,3)) = temp;


% find the digits in the center frame
% digitCenterMask = identifyCenterDigits(centerImg, digitMirrorMask_dorsum, dorsalFundMat, rat_metadata);

% now have the digits and dorsum of the paw in 2 views from single frames,
% start to work on the image tracking. Need to think about whether 3-D
% reconstruction can contribute to the tracking cost function

centroids = track3Dpaw(video, ...
                       BGimg, ...
                       peakFrame, ...
                       fundmat, ...
                       paw_mask, ...
                       digitMirrorMask_dorsum, ...
                       digitCenterMask, ...
                       rat_metadata, ...
                       register_ROI, ...
                       boxMarkers);
                            
% figure(1)
% imshow(digitImg_enh)
% figure(2)
% imshow(palmImg)

% find the individual digits, as well as the palm to initiate tracking in
% the "color" image mirror (the one that sees the dorsum of the paw)

end    % end function trackTattooedPaw( video )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
