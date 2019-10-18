function plotNumTrials_normalized_acrossExperiments(exptSummary)
%
% exptSummary - types
%   1 - chr2 during
%   2 - chr2 between
%   3 - arch
%   4 - eyfp
minTrials = 20;
maxTrials = 80;

patchAlpha = 0.1;

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

summaries_to_plot = [1,2,3,4];
retrainColor = 'k';

patchX = [2.5 2.5 12.5 12.5];

n = zeros(length(exptSummary),1);

for i_exptType = 1 : length(summaries_to_plot)
    
    n(i_exptType) = size(exptSummary(i_exptType).num_trials,2);
    curSummary = exptSummary(summaries_to_plot(i_exptType));
    figure
    toPlot = nanmean(curSummary.num_trials,2);
    
    switch i_exptType
        case 1
            laserOnColor = 'b';
        case 2
            laserOnColor = 'c';
        case 3
            laserOnColor = 'g';
        case 4
            laserOnColor = 'r';
    end
    
    numValidPts = sum(~isnan(curSummary.num_trials),2);
    e_bars = nanstd(curSummary.num_trials,0,2) ./ sqrt(numValidPts);
    hold on
    scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor);
    scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor);
    scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    
%     for ii = 1 : n(i_exptType)
%         plot(retrainSessions,curSummary.num_trials(retrainSessions,ii),'color',retrainColor);
%     end
    errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
    errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
    errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),laserOnColor,'linestyle','none');
    
    set(gca,'ylim',[minTrials maxTrials],...
        'xtick',[1,2,3,12,13,22],...
        'xticklabel',[1,2,1,10,1,10],...
        'fontsize',16,...
        'fontname','arial');
    
    ylimits = get(gca,'ylim');
    patchY = [ylimits(1) ylimits(2) ylimits(2) ylimits(1)];
    patch(patchX,patchY,laserOnColor,'facealpha',patchAlpha);
    
    legend('baseline','laser on','occlude')
    
    ylabel('trials per session','fontname','arial','fontsize',18)
    xlabel('session number','fontname','arial','fontsize',18)
end

n 