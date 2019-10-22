function plot_end_orientation_polar_acrossExperiments(exptSummary)
%
% exptSummary - types
%   1 - chr2 during
%   2 - chr2 between
%   3 - arch
%   4 - eyfp

exptTypeIdx = [1,2,3,4];
end_aperture_lim = [10 20];

saveDir = '/Users/dleventh/Box/Leventhal Lab/Meetings, Presentations/SfN/SFN 2019/Bova/figures';
saveName = 'final_end_orientation_polar.pdf';
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

[h_fig,h_axes] = createPolarFigPanels(figProps);

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';

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
    
    
%     set(gca,'ylim',end_aperture_lim,...
%         'xtick',[1,2,3,12,13,22],...
%         'xticklabel',[1,2,1,10,1,10],...
%         'ytick',[10 15 20],...
%         'fontsize',16,...
%         'fontname','arial');
    
    % mean paw orientation at reach end
    final_orientations = nancirc_mean(curSummary.mean_end_orientations,[],2);
    final_MRLs = nanmean(curSummary.end_MRL,2);
    toPlot = final_MRLs .* exp(1i*final_orientations);
%     h_line = compass(toPlot(retrainSessions));
    polarplot(toPlot(retrainSessions),'linestyle','none','marker','o','markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
    hold on
    polarplot(toPlot(laserOnSessions),'linestyle','none','marker','o','markeredgecolor',laserOnColor);
    polarplot(toPlot(occludeSessions),'linestyle','none','marker','o','markeredgecolor',laserOnColor,'markerfacecolor',retrainColor);
    
    thetalim([0,90])
    set(gca,'rtick',[0 0.5 1],'fontname','arial','fontsize',18)
    
%     if i_exptType == 1
%         ylabel('aperture at reach end (mm)','fontname','arial','fontsize',18)
%         set(gca,'yticklabel',[10 15 20]);
%     else
%         set(gca,'yticklabel',[]);
%     end
%     xlabel('session number','fontname','arial','fontsize',18)
end

n

print(h_fig,saveName,'-dpdf');