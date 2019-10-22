function plot_end_orientation_acrossExperiments(exptSummary)
%
% exptSummary - types
%   1 - chr2 during
%   2 - chr2 between
%   3 - arch
%   4 - eyfp

exptTypeIdx = [1,2,3,4];
end_orientation_lim = [30 60];

saveDir = '/Users/dleventh/Box/Leventhal Lab/Meetings, Presentations/SfN/SFN 2019/Bova/figures';
saveName = 'final_end_orientation.pdf';
saveName = fullfile(saveDir,saveName);

figProps.m = 1;
figProps.n = 4;

figProps.topMargin = 0.5;
figProps.leftMargin = 2.5;

figProps.width = 39.01;
figProps.height = 10;

figProps.colSpacing = ones(figProps.n-1,1) * 0.5;
figProps.rowSpacing = 0.5;%ones(figProps.m-1,1) * 1;

figProps.panelWidth = ones(1,figProps.n)*((figProps.width - sum(figProps.colSpacing) - figProps.leftMargin - 0.5) / figProps.n);
figProps.panelHeight = 7;%ones(figProps.m,1) * 4;

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

    
    toPlot = nancirc_mean(curSummary.mean_end_orientations,[],2);
    toPlot = toPlot * 180 / pi;
    numValidPts = sum(~isnan(curSummary.mean_end_orientations),2);
    final_MRLs = nanmean(curSummary.end_MRL,2);
%     e_bars = nanstd(curSummary.mean_end_orientation,0,2) ./ sqrt(numValidPts);
    
    set(gca,'ylim',end_orientation_lim,...
        'xtick',[1,2,3,12,13,22],...
        'xticklabel',[1,2,1,10,1,10],...
        'fontsize',16,...
        'fontname','arial');
    
    ylimits = get(gca,'ylim');
    patchY = [ylimits(1) ylimits(2) ylimits(2) ylimits(1)];
    patch(patchX,patchY,laserOnColor,'facealpha',patchAlpha);
    
    hold on
    h_retrain = scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor);
    h_on = scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor);
    h_occlude = scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    
%     errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
%     errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
%     errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),laserOnColor,'linestyle','none');
    
%     h_leg = legend([h_retrain,h_on,h_occlude],'baseline','laser on','occlude');
%     h_leg.Location = 'southeast';
    
    if i_exptType == 1
        ylabel('orientation at reach end (deg)','fontname','arial','fontsize',18)
%         set(gca,'ytick',[0,pi/4,pi/2]);
        set(gca,'ytick',[30,60]);
        set(gca,'yticklabel',[30,60])
%         set(gca,'yticklabel',{'0','pi/4','pi/2'})
    else
        set(gca,'yticklabel',[]);
    end
    xlabel('session number','fontname','arial','fontsize',18)
end

n

print(h_fig,saveName,'-dpdf');