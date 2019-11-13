function plot_end_aperture_for_one_experiment(exptSummary,h_axes)

patchAlpha = 0.01;

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';

patchX = [2.5 2.5 12.5 12.5];

end_aperture_lim = [10 20];
markerSize = 6;
capSize = 3;

switch exptSummary.experimentInfo.type
    case 'chr2_during'
            laserOnColor = 'b';
    case 'chr2_between'
        laserOnColor = 'c';
    case 'arch_during'
        laserOnColor = 'g';
    case 'eyfp_during'
        laserOnColor = 'r';
end
    
axes(h_axes)

toPlot = squeeze(nanmean(exptSummary.mean_end_aperture,2));
numValidPts = sum(~isnan(exptSummary.mean_end_aperture),2);
e_bars = nanstd(exptSummary.mean_end_aperture,0,2) ./ sqrt(numValidPts);

set(gca,'ylim',end_aperture_lim,...
    'xtick',[1,2,3,12,13,22],...
    'xticklabel',[1,2,1,10,1,10],...
    'ytick',[10 15 20],...
    'fontsize',11,...
    'fontname','arial');

ylimits = get(gca,'ylim');
patchY = [ylimits(1) ylimits(2) ylimits(2) ylimits(1)];
patch(patchX,patchY,laserOnColor,'facealpha',patchAlpha);

hold on
h_retrain = scatter(retrainSessions,toPlot(retrainSessions),markerSize,'markeredgecolor',retrainColor);
h_on = scatter(laserOnSessions,toPlot(laserOnSessions),markerSize,'markeredgecolor',laserOnColor);
h_occlude = scatter(occludeSessions,toPlot(occludeSessions),markerSize,'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);

errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none','capsize',capSize);
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none','capsize',capSize);
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),laserOnColor,'linestyle','none','capsize',capSize);