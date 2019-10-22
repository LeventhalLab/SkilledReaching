function plot_z_coord_acrossExperiments(exptSummary)
%
% exptSummary - types
%   1 - chr2 during
%   2 - chr2 between
%   3 - arch
%   4 - eyfp

exptTypeIdx = [1,2,3,4];
reachEnd_zlim = [-15 20];

saveDir = '/Users/dleventh/Box/Leventhal Lab/Meetings, Presentations/SfN/SFN 2019/Bova/figures';
saveName = 'final_z_coord.pdf';
saveName = fullfile(saveDir,saveName);

figProps.m = 1;
figProps.n = 4;

figProps.topMargin = 0.5;
figProps.leftMargin = 2.5;

figProps.width = 39.01;
figProps.height = 12;

figProps.colSpacing = ones(figProps.n-1,1) * 0.5;
figProps.rowSpacing = 0.5;%ones(figProps.m-1,1) * 1;

figProps.panelWidth = ones(1,figProps.n)*((figProps.width - sum(figProps.colSpacing) - figProps.leftMargin - 0.5) / figProps.n);
figProps.panelHeight = 9;%ones(figProps.m,1) * 4;

[h_fig,h_axes] = createFigPanels5(figProps);

minTrials = 0;
maxTrials = 2;

patchAlpha = 0.01;

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';

patchX = [2.5 2.5 12.5 12.5];

n = zeros(length(exptSummary),1);

for i_exptType = 1 : length(exptTypeIdx)
    
    curSummary = exptSummary(exptTypeIdx(i_exptType));
    n(i_exptType) = size(curSummary.num_trials,2);
    numSessions = size(curSummary.num_trials,1);
    
    axes(h_axes(i_exptType));
    
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
    
    pd_z_endpt = squeeze(curSummary.mean_pd_endPt(:,:,3));
    pd_toPlot = squeeze(nanmean(pd_z_endpt,1));
    numValidPts = sum(~isnan(pd_z_endpt),2);
    pd_e_bars = nanstd(pd_z_endpt,0,1) ./ sqrt(numValidPts);
    
    dig2_z_endpt = squeeze(curSummary.mean_dig2_endPt(:,:,3));
    dig2_toPlot = squeeze(nanmean(dig2_z_endpt,1));
    numValidPts = sum(~isnan(dig2_z_endpt),2);
    dig2_e_bars = nanstd(dig2_z_endpt,0,1) ./ sqrt(numValidPts);
    
    set(gca,'ylim',reachEnd_zlim,...
        'xtick',[1,2,3,12,13,22],...
        'xticklabel',[1,2,1,10,1,10],...
        'fontsize',16,...
        'fontname','arial');
    
    ylimits = get(gca,'ylim');
    patchY = [ylimits(1) ylimits(2) ylimits(2) ylimits(1)];
    patch(patchX,patchY,laserOnColor,'facealpha',patchAlpha);
    
    hold on
    h_retrain = scatter(retrainSessions,pd_toPlot(retrainSessions),'markeredgecolor',retrainColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
    h_on = scatter(laserOnSessions,pd_toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
    h_occlude = scatter(occludeSessions,pd_toPlot(occludeSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
    
    errorbar(retrainSessions,pd_toPlot(retrainSessions),pd_e_bars(retrainSessions),retrainColor,'linestyle','none');
    errorbar(laserOnSessions,pd_toPlot(laserOnSessions),pd_e_bars(laserOnSessions),laserOnColor,'linestyle','none');
    errorbar(occludeSessions,pd_toPlot(occludeSessions),pd_e_bars(occludeSessions),laserOnColor,'linestyle','none');
    
    h_retrain = scatter(retrainSessions,dig2_toPlot(retrainSessions),'markeredgecolor',retrainColor);
    h_on = scatter(laserOnSessions,dig2_toPlot(laserOnSessions),'markeredgecolor',laserOnColor);
    h_occlude = scatter(occludeSessions,dig2_toPlot(occludeSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    
    errorbar(retrainSessions,dig2_toPlot(retrainSessions),dig2_e_bars(retrainSessions),retrainColor,'linestyle','none');
    errorbar(laserOnSessions,dig2_toPlot(laserOnSessions),dig2_e_bars(laserOnSessions),laserOnColor,'linestyle','none');
    errorbar(occludeSessions,dig2_toPlot(occludeSessions),dig2_e_bars(occludeSessions),laserOnColor,'linestyle','none');
    
    line([0,22],[0,0],'color','k')
    
%     h_leg = legend([h_retrain,h_on,h_occlude],'baseline','laser on','occlude');
%     h_leg.Location = 'southeast';
    
    if i_exptType == 1
        ylabel('final z w.r.t. pellet (mm)','fontname','arial','fontsize',18)
    else
        set(gca,'yticklabel',[]);
    end
    xlabel('session number','fontname','arial','fontsize',18)
end

n

print(h_fig,saveName,'-dpdf');