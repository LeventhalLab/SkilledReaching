function [triggerframe,triggerframe2] = determineIf1SDok(filepath,filename,side)
videoFilename = fullfile(filepath,filename);
x = VideoReader(videoFilename);
assignin('base','x',x);
[~,mean_BG_subt_values] = identifyTriggerFrameVPedit(x,side);
smoothed_mean_BG_subt_values = smooth(mean_BG_subt_values,15);
smoothed_mean_BG_subt_values = reshape(smoothed_mean_BG_subt_values,size(mean_BG_subt_values));
% figure;
temp = zeros(1,450);
temp(1) = NaN;
temp2 = zeros(1,450);
temp2(1:2) = NaN;
if strcmp(side,'right')
%     plot(mean_BG_subt_values(1,:));
%     hold on;
%     plot(smoothed_mean_BG_subt_values(1,:));
%     hold on;
    first_diff_smoothed = diff(smoothed_mean_BG_subt_values(1,:));
    sec_diff_smoothed = diff(first_diff_smoothed);
    %first_diff_smoothed = reshape(first_diff_smoothed,size(mean_BG_subt_values));
    temp(2:end) = first_diff_smoothed;
    first_diff_smoothed = temp;
    temp2(3:end) = sec_diff_smoothed;
    sec_diff_smoothed = temp2;
%     plot(first_diff_smoothed);
%     hold on;
%     plot(sec_diff_smoothed);
    %meanDiff = mean(mean_BG_subt_values(1,1:150));
    %stdDiff = std(mean_BG_subt_values(1,1:150));
%     title(videoFilename(76:end));
    %     maxDiffFirstOneHundred = max(first_diff_smoothed(3:100));
    %     for i = 1:length(first_diff_smoothed(101:end))
    %     [h(i) p(i)] = ttest(first_diff_smoothed(100+i),maxDiffFirstOneHundred);
    %     end
    %     triggerframe = find(h(i)==1,1)+100;
    maxDiffFirstOneHundred = max(sec_diff_smoothed(4:100));
    %refline([0 maxDiffFirstOneHundred]);
    triggerframe = find(sec_diff_smoothed(101:end) > maxDiffFirstOneHundred,1)+100;
%     plot(triggerframe,sec_diff_smoothed(triggerframe),'linestyle','none','marker','*');
    meanFirstDiff = mean(first_diff_smoothed(3:100));
    stdFirstDiff = std(first_diff_smoothed(3:100));
%     refline([0 (meanFirstDiff+(3.*stdFirstDiff))])
%     refline([0 (meanFirstDiff-(3.*stdFirstDiff))])
    triggerframe2 = find(first_diff_smoothed(101:end) > (meanFirstDiff+(2.326.*stdFirstDiff)),1)+100;
%     plot(triggerframe2,first_diff_smoothed(triggerframe2),'linestyle','none','marker','*');
elseif strcmp(side,'left')
%     plot(mean_BG_subt_values(2,:));
%     hold on;
%     plot(smoothed_mean_BG_subt_values(2,:));
%     hold on;
    first_diff_smoothed = diff(smoothed_mean_BG_subt_values(2,:));
    %first_diff_smoothed = reshape(first_diff_smoothed,size(mean_BG_subt_values));
    sec_diff_smoothed = diff(first_diff_smoothed);
    temp(2:end) = first_diff_smoothed;
    first_diff_smoothed = temp;
    temp2(3:end) = sec_diff_smoothed;
    sec_diff_smoothed = temp2;
%     plot(first_diff_smoothed);
%     hold on;
%     plot(sec_diff_smoothed);
    %meanDiff = mean(mean_BG_subt_values(2,1:150));
    %stdDiff = std(mean_BG_subt_values(2,1:150));
%     title(videoFilename(76:end));
    maxDiffFirstOneHundred = max(sec_diff_smoothed(4:100));
    %     for i = 1:length(first_diff_smoothed(101:end))
    %     [h(i) p(i)] = ttest(first_diff_smoothed(100+i),maxDiffFirstOneHundred);
    %     end
    %     triggerframe = find(h(i)==1,1)+100;
%     refline([0 maxDiffFirstOneHundred]);
    triggerframe = find(sec_diff_smoothed(101:end) > maxDiffFirstOneHundred,1)+100;
%     plot(triggerframe,sec_diff_smoothed(triggerframe),'linestyle','none','marker','*');
    meanFirstDiff = mean(first_diff_smoothed(3:100));
    stdFirstDiff = std(first_diff_smoothed(3:100));
%     refline([0 (meanFirstDiff+(3.*stdFirstDiff))])
%     refline([0 (meanFirstDiff-(3.*stdFirstDiff))])
    triggerframe2 = find(first_diff_smoothed(101:end) > (meanFirstDiff+(2.326.*stdFirstDiff)),1)+100;
%     plot(triggerframe2,first_diff_smoothed(triggerframe2),'linestyle','none','marker','*');
end

%% try differential of smoothing function, determining where it first passes a certain threshold (and approaches infinity)
%% can also try different smoothing functions, or expand range of current function
%% or change ROI