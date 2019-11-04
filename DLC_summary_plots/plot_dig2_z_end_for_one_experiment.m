function plot_dig2_z_end_for_one_experiment(exptSummary,h_axes)

patchAlpha = 0.01;

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';

patchX = [2.5 2.5 12.5 12.5];

reachEnd_zlim = [-15 10];
markerSize = 6;
capSize = 3;

switch exptSummary.experimentInfo.type
    case 'chr2_during'
            laserOnColor = 'b';
    case 'chr2_between'
        laserOnColor = 'c';
    case 'arch_during'
        laserOnColor = 'g';
    case 'eyfp'
        laserOnColor = 'r';
end
    
axes(h_axes)

dig2_z_endpt = squeeze(exptSummary.mean_dig2_endPt(:,:,3));
dig2_toPlot = squeeze(nanmean(dig2_z_endpt,1));
numValidPts = sum(~isnan(dig2_z_endpt),2);
dig2_e_bars = nanstd(dig2_z_endpt,0,1) ./ sqrt(numValidPts);
    
toPlot = squeeze(nanmean(exptSummary.mean_end_aperture,2));
numValidPts = sum(~isnan(exptSummary.mean_end_aperture),2);
e_bars = nanstd(exptSummary.mean_end_aperture,0,2) ./ sqrt(numValidPts);

% set(gca,'ylim',reachEnd_zlim,...
%     'xtick',[1,2,3,12,13,22],...
%     'xticklabel',[1,2,1,10,1,10],...
%     'fontsize',11,...
%     'fontname','arial');

set(gca,'ylim',reachEnd_zlim,...
    'xtick',[1,2,3,12,13,22],...
    'fontsize',11,...
    'fontname','arial');

ylimits = get(gca,'ylim');
patchY = [ylimits(1) ylimits(2) ylimits(2) ylimits(1)];
patch(patchX,patchY,laserOnColor,'facealpha',patchAlpha);

hold on
h_retrain = scatter(retrainSessions,dig2_toPlot(retrainSessions),markerSize,'markeredgecolor',retrainColor);
h_on = scatter(laserOnSessions,dig2_toPlot(laserOnSessions),markerSize,'markeredgecolor',laserOnColor);
h_occlude = scatter(occludeSessions,dig2_toPlot(occludeSessions),markerSize,'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);

errorbar(retrainSessions,dig2_toPlot(retrainSessions),dig2_e_bars(retrainSessions),retrainColor,'linestyle','none','capsize',capSize);
errorbar(laserOnSessions,dig2_toPlot(laserOnSessions),dig2_e_bars(laserOnSessions),laserOnColor,'linestyle','none','capsize',capSize);
errorbar(occludeSessions,dig2_toPlot(occludeSessions),dig2_e_bars(occludeSessions),laserOnColor,'linestyle','none','capsize',capSize);

line([0,22],[0,0],'color','k')