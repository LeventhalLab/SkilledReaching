function [h_fig,h_axes,h_figAxis] = plotSessionSummary(trialTypeIdx,mean_euc_dist_from_trajectory,mean_xyz_from_trajectory,reachEndPoints,bodyparts,thisRatInfo,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,all_maxDigitReachFrame,validTypeNames,curSession,curSessionType,varargin)

% to plot:
%   mean distance from mean trajectory at each point for all, correct, no
%       pellet, and other trials (along with n)
%   all_firstPawDorsum, all_paw_through_slot_frame, and all_endPtFrame
%   

pawPref = thisRatInfo.pawPref;
if iscell(pawPref)
    pawPref = pawPref{1};
end

virus = thisRatInfo.Virus;
if iscell(virus)
    virus = virus{1};
end

figProps.m = 5;
figProps.n = 5;

figProps.panelWidth = ones(figProps.n,1) * 10;
figProps.panelHeight = ones(figProps.m,1) * 4;

figProps.colSpacing = ones(figProps.n-1,1) * 0.5;
figProps.rowSpacing = ones(figProps.m-1,1) * 1;

figProps.leftMargin = 2.54;
figProps.topMargin = 5;

figProps.width = sum(figProps.colSpacing) + sum(figProps.panelWidth) + figProps.leftMargin + 2.54;
figProps.height = 12 * 2.54;

numTrialTypes_to_analyze = size(trialTypeIdx,2);


var_lim = [0,5;
           0,5;
           0,10;
           0,10];
pawFrameLim = [0 400];

for iarg = 1 : 2 : nargin - 14
    switch lower(varargin{iarg})
        case 'var_lim'
            var_lim = varargin{iarg + 1};
        case 'pawframelim'
            pawFrameLim = varargin{iarg + 1};
    end
end
[h_fig(1),h_axes{1}] = createFigPanels5(figProps);
% [h_fig(2),h_axes{2}] = createFigPanels5(figProps);



% first row, plot 1 - frame limits
axes(h_axes{1}(1,1));
plot(trialNumbers(:,2),all_firstPawDorsumFrame);
% title('first paw dorsum frame')
% set(gca,'ylim',pawFrameLim);
hold on
% axes(h_axes{1}(1,2));
plot(trialNumbers(:,2),all_paw_through_slot_frame);
% title('paw through slot frame frame')
% set(gca,'ylim',pawFrameLim);

% axes(h_axes{1}(1,3));
plot(trialNumbers(:,2),all_endPtFrame);

plot(trialNumbers(:,2),all_maxDigitReachFrame);
title('event frames')
set(gca,'ylim',pawFrameLim);

% final z location as a function of trial #
[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
pd_endPts = squeeze(reachEndPoints{1}(pawDorsumIdx,:,:));
digit_endPts = squeeze(reachEndPoints{1}(digIdx(2),:,:));
for iDim = 1 : 3
    axes(h_axes{1}(1,1+iDim));
    try
    scatter(trialNumbers(:,2),pd_endPts(iDim,:));
    catch
        keyboard
    end
    hold on
    scatter(trialNumbers(:,2),digit_endPts(iDim,:));
    switch iDim
        case 1
            title('x-endpoints vs trial #')
        case 2
            title('y-endpoints vs trial #')
        case 3
            title('z-endpoints vs trial #')
    end
end


% histogram of paw dorsum endpoints
% [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts,pawPref);
axes(h_axes{1}(1,5));
[pd_N,pd_edges] = histcounts(pd_endPts(3,:),10);
[d2_N,d2_edges] = histcounts(digit_endPts(3,:),10);
pd_x = pd_edges(1:end-1) + diff(pd_edges)/2;
d2_x = d2_edges(1:end-1) + diff(d2_edges)/2;
plot(pd_x,pd_N);
hold on
plot(d2_x,d2_N);
% histogram(pd_endPts_z,10)
title('z-endpoints')
set(gca,'xdir','reverse');
legend({'paw dorsum','digit 2'},'location','northwest');

% histogram of second digit endpoints
% axes(h_axes{1}(1,5));
% histogram(digit_endPts_z,10)
% title('2nd digit z-endpoints')
% set(gca,'xdir','reverse');



% mean_dist_from_trajectory = zeros(size(mean_pd_trajectory,1),size(mean_pd_trajectory,2),numTrialTypes_to_analyze);
% mean_euc_dist_from_trajectory = zeros(size(mean_pd_trajectory,1),numTrialTypes_to_analyze);

for iType = 1 : numTrialTypes_to_analyze
%     numTrials = sum(trialTypeIdx(:,iType));
%     current_mean_trajectory = squeeze(mean_pd_trajectory(:,:,iType));
%     dist_from_trajectory = normalized_pd_trajectories(:,:,trialTypeIdx(:,iType)) - repmat(current_mean_trajectory,1,1,numTrials);
%     euclidean_dist_from_trajectory = sqrt(squeeze(sum(dist_from_trajectory.^2,2)));
%     mean_dist_from_trajectory(:,:,iType) = nanmean(abs(dist_from_trajectory),3);
%     mean_euc_dist_from_trajectory(:,iType) = nanmean(euclidean_dist_from_trajectory,2);
    
    for iDir = 1 : 3
        axes(h_axes{1}(iDir+1,iType))
        toPlot = squeeze(mean_xyz_from_trajectory(:,iDir,iType));
        plot(toPlot)
        set(gca,'ylim',var_lim(iDir,:));
        title(validTypeNames{iType})
        if iType == 1
            switch iDir
                case 1
                    ylabel('x')
                case 2
                    ylabel('y')
                case 3
                    ylabel('z')
            end
        end
    end
    axes(h_axes{1}(5,iType))
    toPlot = squeeze(mean_euc_dist_from_trajectory(:,iType));
    plot(toPlot)
    set(gca,'ylim',var_lim(4,:));
    title(validTypeNames{iType})
    ylabel('euc dist')
%     plot(mean_dist_from_trajectory
end

h_figAxis = zeros(length(h_fig),1);
for iFig = 1 : length(h_fig)
    h_figAxis(iFig) = createFigAxes(h_fig(iFig));
end

textString{1} = sprintf('%s session summary; %s (%s on score sheet), day %d, %d days left in block, Virus: %s', ...
    curSession, curSessionType.type, curSessionType.typeFromScoreSheet, curSessionType.sessionsInBlock, curSessionType.sessionsLeftInBlock, virus);
textString{2} = 'rows 2-4: mean absolute difference from mean trajectory in x, y, z for each trial type';
textString{3} = 'row 5: mean euclidean distance from mean trajectory for each trial type';
axes(h_figAxis(1));
text(figProps.leftMargin,figProps.height-0.75,textString,'units','centimeters','interpreter','none');

end
        