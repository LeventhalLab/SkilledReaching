function [h_fig,h_axes,h_figAxis] = plot_multiReachInfo(reachFrames,reach_endPoints,bodyparts,thisRatInfo,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,all_maxDigitReachFrame,trialTypeIdx,validTypeNames,curSession,curSessionType,trialTypeColors,varargin)

% to plot:
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

numTrials = size(trialNumbers,1);

% first row, plot 1 - number of reaches
axes(h_axes{1}(1,1));
hold on
for iTrial = 1 : numTrials
    for iType = 2 : numTrialTypes_to_analyze
        if trialTypeIdx(iTrial,iType)
            plotColor = trialTypeColors{iType};
            break;
        else
            plotColor = 'y';   % if not one of the trials we defined at the top of the script
        end
    end
    trialNum = trialNumbers(iTrial,2);
    scatter(trialNum,length(reachFrames{iTrial}),36,plotColor);
    
end



% first row, plot 2 - reach indices for each trial. color code by trial
% reported outcome
axes(h_axes{1}(1,2));
hold on
for iTrial = 1 : numTrials
    for iType = 2 : numTrialTypes_to_analyze
        if trialTypeIdx(iTrial,iType)
            plotColor = trialTypeColors{iType};
            break;
        else
            plotColor = 'y';   % if not one of the trials we defined at the top of the script
        end
    end
    trialNum = trialNumbers(iTrial,2);
    curTrialNumReaches = length(reachFrames{iTrial});
    trialNum = ones(curTrialNumReaches,1) * trialNum;

    scatter(trialNum,reachFrames{iTrial},36,plotColor);
    
end



% first row, plot 3 - all reach endpoints for each trial, digit 2
axes(h_axes{1}(1,3));
hold on
for iTrial = 1 : numTrials
    for iType = 2 : numTrialTypes_to_analyze
        if trialTypeIdx(iTrial,iType)
            plotColor = trialTypeColors{iType};
            break;
        else
            plotColor = 'y';   % if not one of the trials we defined at the top of the script
        end
    end
    curTrialNumReaches = length(reachFrames{iTrial});
    toPlot = squeeze(reach_endPoints{iTrial}(1,3,:));
    plot(1:curTrialNumReaches,toPlot,'marker','o','color',plotColor,'markerfacecolor',plotColor);
    
end
title('digit 2 z')
xlabel('reach number')


% first row, plot 4 - all reach endpoints for each trial, digit 2
axes(h_axes{1}(1,4));
hold on
for iTrial = 1 : numTrials
    for iType = 2 : numTrialTypes_to_analyze
        if trialTypeIdx(iTrial,iType)
            plotColor = trialTypeColors{iType};
            break;
        else
            plotColor = 'y';   % if not one of the trials we defined at the top of the script
        end
    end
    curTrialNumReaches = length(reachFrames{iTrial});
    toPlot = squeeze(reach_endPoints{iTrial}(2,3,:));
    plot(1:curTrialNumReaches,toPlot,'marker','o','color',plotColor,'markerfacecolor',plotColor);
    
end
title('digit 3 z')
xlabel('reach number')


h_figAxis = zeros(length(h_fig),1);
for iFig = 1 : length(h_fig)
    h_figAxis(iFig) = createFigAxes(h_fig(iFig));
end

textString{1} = sprintf('%s session summary; %s (%s on score sheet), day %d, %d days left in block, Virus: %s', ...
    curSession, curSessionType.type, curSessionType.typeFromScoreSheet, curSessionType.sessionsInBlock, curSessionType.sessionsLeftInBlock, virus);
% textString{2} = 'rows 2-4: mean absolute difference from mean trajectory in x, y, z for each trial type';
% textString{3} = 'row 5: mean euclidean distance from mean trajectory for each trial type';
axes(h_figAxis(1));
text(figProps.leftMargin,figProps.height-0.75,textString,'units','centimeters','interpreter','none');

end
