function [h_figs] = plotOverallSummaryFigs(meanOrientations,MRL,endApertures,mean_dig_trajectories,mean_pd_trajectories,first_reachEndPoints,experimentType,sessionType)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

labelfontsize = 24;
ticklabelfontsize = 18;

% (paw_endAngle,endApertures,mean_dig_trajectories,mean_pd_trajectories,all_reachEndPoints,experimentType,sessionType)
numRats = length(experimentType);
digitIdx = 10;
% collect all reach endpoints for each experiment type for baseline, laser
% on, and occlusion sessions

mean_endPoints = cell(3,1);
mean_endAngle = cell(3,1);
mean_MRL = cell(3,1);
mean_endApertures = cell(3,1);
numExperiments = zeros(3,1);
for ii = 1 : 3
    numExperiments(ii) = sum(experimentType == ii);
    
    mean_endPoints{ii} = zeros(22,3,numExperiments(ii));   % 22 = 2 baseline sessions + 10 laser + 10 occlusion
    mean_endAngle{ii} = zeros(22,numExperiments(ii));   % 22 = 2 baseline sessions + 10 laser + 10 occlusion
    mean_MRL{ii} = zeros(22,numExperiments(ii));
    mean_endApertures{ii} = zeros(22,numExperiments(ii));
    
end
    
idx_to_collect = zeros(22,1);
expTypeIdx = zeros(3,1);
for i_rat = 1 : numRats

    % find the last 2 baseline sessions
    if experimentType(i_rat) == 0
        continue;
    end
    currentExpType = experimentType(i_rat);
    expTypeIdx(currentExpType) = expTypeIdx(currentExpType) + 1;
%     [baselineIdx,laserIdx,occIdx] = findSessionIndices(sessionType{i_rat});
%     idx_to_collect(1:2) = baselineIdx(end-1:end);
%     idx_to_collect(3:12) = laserIdx(1:10);
%     idx_to_collect(13:22) = occIdx(1:10);
    idx_to_collect = 1 : 22;
    for ii = 1 : length(idx_to_collect)
        cur_endPoints = squeeze(first_reachEndPoints{i_rat}{ii}{1}(digitIdx,:,:));
        mean_endPoint = nanmean(cur_endPoints,2);
        mean_endPoints{currentExpType}(ii,:,expTypeIdx(currentExpType)) = mean_endPoint;
        
        curApertures = sqrt(sum(endApertures{i_rat}{ii}.^2,2));
        mean_aperture = nanmean(curApertures);
        mean_endApertures{currentExpType}(ii,expTypeIdx(currentExpType)) = mean_aperture;
%         mean_endAngle{currentExpType}(ii,expTypeIdx(currentExpType)) = 
%         mean_MRL{currentExpType}(ii,expTypeIdx(currentExpType)) = 
    end
    
end
h_figs = plotMeanEndPoints(mean_endPoints);

end

