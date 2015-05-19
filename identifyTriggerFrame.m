function [triggerFrame,peakFrame] = identifyTriggerFrame( video, pawPref, varargin )
%
% INPUTS:
%   video - a VideoReader object for the relevant video
%
% VARARGs:
%   numbgframes - number of frames to use at the beginning of the video to
%       calculate the background
%   firstdiffthreshold - minimum mean pixel-by-pixel difference from baseline
%       that could indicate a trigger event
%
% OUTPUTS:
%   triggerFrame - the frame at which the paw is fully through the slot

numFrames = video.numberOfFrames;
numBGFrames = 50;
frames_before_max = 50;
BGimg = [];
histWindow = [60 125];     % window within the grayscale histogram in which
                           % to look for an increase when the paw comes in

firstDiffThreshold = 50;   % threshold for first order difference to consider a reach

ROI_to_find_trigger_frame = [  0030         0570         0120         0095
                               1880         0550         0120         0095];
for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGFrames = varargin{iarg + 1};
        case 'trigger_roi',   % region of interest to look for trigger frame
            ROI_to_find_trigger_frame = varargin{iarg + 1};
        case 'bgimg',
            BGimg = varargin{iarg + 1};
        case 'histwindow',
            histWindow = varargin{iarg + 1};
        case 'firstdiffthreshold',
            firstDiffThreshold = varargin{iarg + 1};
    end
end

if isempty(BGimg)
    BGframes = uint8(zeros(numBGFrames, video.Height, video.Width, 3));
    for ii = 1 : numBGFrames
        BGframes(ii,:,:,:) = read(video, ii);
    end
    BGimg = uint8(squeeze(mean(BGframes, 1)));
end

if strcmpi(pawPref,'left')
    % use the right mirror for triggering
    mirror_idx = 2;
else
    % use the left mirror for triggering
    mirror_idx = 1;
end

% identify the frames where the paw is visible over the shelf
BG_lft = uint8(BGimg(ROI_to_find_trigger_frame(1,2):ROI_to_find_trigger_frame(1,2) + ROI_to_find_trigger_frame(1,4), ...
                     ROI_to_find_trigger_frame(1,1):ROI_to_find_trigger_frame(1,1) + ROI_to_find_trigger_frame(1,3), :));
BG_rgt = uint8(BGimg(ROI_to_find_trigger_frame(2,2):ROI_to_find_trigger_frame(2,2) + ROI_to_find_trigger_frame(2,4), ...
                     ROI_to_find_trigger_frame(2,1):ROI_to_find_trigger_frame(2,1) + ROI_to_find_trigger_frame(2,3), :));
% BG_lft_hsv = rgb2hsv(BG_lft);
% BG_rgt_hsv = rgb2hsv(BG_rgt);
[BG_lft_hist,~] = imhist(rgb2gray(BG_lft));
[BG_rgt_hist,histBins] = imhist(rgb2gray(BG_rgt));

hist_idx = zeros(1,2);    % start and end indices of histogram 
hist_idx(1) = find(histBins == histWindow(1));
hist_idx(2) = find(histBins == histWindow(2));

lftHist_baseline = sum(BG_lft_hist(hist_idx(1):hist_idx(2)));
rgtHist_baseline = sum(BG_rgt_hist(hist_idx(1):hist_idx(2)));
figure(1)
bar(histBins,BG_lft_hist)
title('background')
histDiff = zeros(2,numFrames);
for iFrame = 1 : numFrames
%     iFrame
    img = read(video, iFrame);
    
    lft_mirror_img = img(ROI_to_find_trigger_frame(1,2):ROI_to_find_trigger_frame(1,2) + ROI_to_find_trigger_frame(1,4), ...
                         ROI_to_find_trigger_frame(1,1):ROI_to_find_trigger_frame(1,1) + ROI_to_find_trigger_frame(1,3), :);
    rgt_mirror_img = img(ROI_to_find_trigger_frame(2,2):ROI_to_find_trigger_frame(2,2) + ROI_to_find_trigger_frame(2,4), ...
                         ROI_to_find_trigger_frame(2,1):ROI_to_find_trigger_frame(2,1) + ROI_to_find_trigger_frame(2,3), :);
                
	lft_mirror_gry = rgb2gray(lft_mirror_img);
    rgt_mirror_gry = rgb2gray(rgt_mirror_img);
    
    lft_hist = imhist(lft_mirror_gry);
    rgt_hist = imhist(rgt_mirror_gry);
    
    lftHistSum = sum(lft_hist(hist_idx(1):hist_idx(2)));
    rgtHistSum = sum(rgt_hist(hist_idx(1):hist_idx(2)));
    
    histDiff(1,iFrame) = lftHistSum - lftHist_baseline;
    histDiff(2,iFrame) = rgtHistSum - rgtHist_baseline;
% 	lft_mirror_hsv = rgb2hsv(lft_mirror_img);
%     rgt_mirror_hsv = rgb2hsv(rgt_mirror_img);
%     lft_mirror_img = rgb2gray(lft_mirror_img);
%     rgt_mirror_img = rgb2gray(rgt_mirror_img);
    
%     lft_mirror_BG = imabsdiff(lft_mirror_img, BG_lft);
%     rgt_mirror_BG = imabsdiff(rgt_mirror_img, BG_rgt);
%     
% 	lft_mirror_gry = rgb2gray(lft_mirror_BG);
%     rgt_mirror_gry = rgb2gray(rgt_mirror_BG);
%     
%     lft_values = reshape(lft_mirror_gry, [1, numel(lft_mirror_gry)]);
%     rgt_values = reshape(rgt_mirror_gry, [1, numel(rgt_mirror_gry)]);
%     mean_BG_subt_values(1, iFrame) = mean(lft_values);
%     mean_BG_subt_values(2, iFrame) = mean(rgt_values);

    figure(2)
    bar(histBins,lft_hist);
    title(num2str(iFrame))
    
    figure(3)
    bar(histBins,lft_hist-BG_lft_hist);
    title(['hist difference, ' num2str(iFrame)]);
    
end

firstDiff = diff(histDiff, 1, 2);
triggerFrame = find(firstDiff(mirror_idx,:) > firstDiffThreshold, 1, 'first');
peakFrame = 0;
% peakFrame = find(
% find frame with maximum difference between background and current frame
% in the region of interest
% diffFrame_delta = diff(mean_BG_subt_values(mirror_idx,:));
% maxDiffFrame = find(mean_BG_subt_values(mirror_idx,:) == max(mean_BG_subt_values(mirror_idx,:)));
% maxDeltaFrame = find(diffFrame_delta(maxDiffFrame-frames_before_max:maxDiffFrame) == ...
%                      max(diffFrame_delta(maxDiffFrame-frames_before_max:maxDiffFrame)));
%                  
% % now have frames that are significantly different from 
% % now find the frame with the first significant deviation from baseline
% triggerFrame = maxDeltaFrame + (maxDiffFrame-frames_before_max);

figure
plot(histDiff(1,:))
hold on
plot(histDiff(2,:),'r')
plot(triggerFrame, histDiff(mirror_idx,triggerFrame),'linestyle','none','marker','*')