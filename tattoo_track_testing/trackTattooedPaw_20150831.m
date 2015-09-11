function [digitMirrorMask_dorsum,digitCenterMask] = ...
    trackTattooedPaw_20150831( video, rat_metadata, boxCalibration, BGimg_ud )
%
% INPUTS:
%   video - a videoReader object containing a single trial video
%   rat_metadata - rat metadata structure containing the following fields:
%       .ratID - integer containing the rat identification number
%       .localizers_present - boolean indicating whether or not box
%           localizers (e.g., beads/checkerboards are present in the video.
%       	probably not necessary, but will leave in for now. -DL 20150831
%       .camera_distance - camera focal length; this is now stored
%           elsewhere, will probably be able to get rid of this
%       .pawPref - string or cell containing a string 'left' or 'right'
%   boxCalibration - structure containing the box video calibration
%       information (from function calibrate_sr_box)
%       .boxMarkers - structure containing the locations of box markers
%           in the background image (beads and checkerboards)
%           .beadLocations - structure containing bead centroids - fairly
%               self-explanatory
%           .register_ROI - 3 x 4 array. Each row is [x,y,w,h] where [x,y]
%               is the top left corner, and w and h are the width and
%               height of the regions of interest. First row - left mirror,
%               second row - box direct view, third row - right mirrot
%           .cbLocations - structure containing locations of checkerboard
%               points; should be self-explanatory what each field is.
%           
%   BGimg_ud - undistorted background image

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

% ROI_to_find_trigger_frame = [0210         0590         0050         0070
%                              1740         0560         0050         0070];
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

minSideOverlap = 0.6;    % minimum that the projections of the mirror views
                         % must overlap with the front view
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
        case 'minsideoverlap',
            minSideOverlap = varargin{iarg + 1};
    end
end

BGimg_info = whos('BGimg_ud');
if strcmpi(BGimg_info.class,'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

% triggerFrame = 511;peakFrame = 532;   % hard code to speed up analysis % peak should be 532
% preReachFrame = triggerFrame - 25;
% find a mask for the paw in the lateral, central, and right mirrors for
% the peak frame
triggerTime = identifyTriggerTime( video, BGimg_ud, rat_metadata, boxCalibration);

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
[initDigitMasks, init_mask_bbox, digitMarkers, refImageTime] = ...
    initialDigitID_20150910(video, triggerTime, BGimg_ud, rat_metadata, boxCalibration, ...
                            'minsideoverlap',minSideOverlap);
% [initDigitMasks, init_mask_bbox, refImageTime] = ...
%     initialDigitID_20150831(video, triggerTime, BGimg_ud, rat_metadata, boxCalibration, ...
%                             'minsideoverlap',minSideOverlap);



centroids = track3Dpaw_20150831(video, ...
                                BGimg_ud, ...
                                refImageTime, ...
                                initDigitMasks, ...
                                init_mask_bbox, ...
                                digitMarkers, ...
                                rat_metadata, ...
                                boxCalibration);

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
                       BGimg_ud, ...
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
