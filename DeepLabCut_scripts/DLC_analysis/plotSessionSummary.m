function [h_fig,h_axes] = plotSessionSummary(trialTypeIdx,mean_pd_trajectory,normalized_pd_trajectories,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,validTypeNames,varargin)

% to plot:
%   mean distance from mean trajectory at each point for all, correct, no
%       pellet, and other trials (along with n)
%   all_firstPawDorsum, all_paw_through_slot_frame, and all_endPtFrame
%   
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

for iarg = 1 : 2 : nargin - 8
    switch lower(varargin{iarg})
        case 'var_lim'
            var_lim = varargin{iarg + 1};
        case 'pawframelim'
            pawFrameLim = varargin{iarg + 1};
    end
end
[h_fig,h_axes] = createFigPanels5(figProps);

% first row - frame limits
axes(h_axes(1,1));
plot(trialNumbers,all_firstPawDorsumFrame);
title('first paw dorsum frame')
set(gca,'ylim',pawFrameLim);

axes(h_axes(1,2));
plot(trialNumbers,all_paw_through_slot_frame);
title('paw through slot frame frame')
set(gca,'ylim',pawFrameLim);

axes(h_axes(1,3));
plot(trialNumbers,all_endPtFrame);
title('reach endpoint frames')
set(gca,'ylim',pawFrameLim);

mean_dist_from_trajectory = zeros(size(mean_pd_trajectory,1),size(mean_pd_trajectory,2),numTrialTypes_to_analyze);
mean_euc_dist_from_trajectory = zeros(size(mean_pd_trajectory,1),numTrialTypes_to_analyze);

for iType = 1 : numTrialTypes_to_analyze
    numTrials = sum(trialTypeIdx(:,iType));
    current_mean_trajectory = squeeze(mean_pd_trajectory(:,:,iType));
    dist_from_trajectory = normalized_pd_trajectories(:,:,trialTypeIdx(:,iType)) - repmat(current_mean_trajectory,1,1,numTrials);
    euclidean_dist_from_trajectory = sqrt(squeeze(sum(dist_from_trajectory.^2,2)));
    mean_dist_from_trajectory(:,:,iType) = nanmean(abs(dist_from_trajectory),3);
    mean_euc_dist_from_trajectory(:,iType) = nanmean(euclidean_dist_from_trajectory,2);
    
    for iDir = 1 : 3
        axes(h_axes(iDir+1,iType))
        toPlot = squeeze(mean_dist_from_trajectory(:,iDir,iType));
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
    axes(h_axes(5,iType))
    toPlot = squeeze(mean_euc_dist_from_trajectory(:,iType));
    plot(toPlot)
    set(gca,'ylim',var_lim(4,:));
    title(validTypeNames{iType})
    ylabel('euc dist')
%     plot(mean_dist_from_trajectory
end

end
        