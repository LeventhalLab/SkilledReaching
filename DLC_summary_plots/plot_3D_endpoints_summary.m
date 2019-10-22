function plot_3D_endpoints_summary(exptSummary)
%
% exptSummary - types
%   1 - chr2 during
%   2 - chr2 between
%   3 - arch
%   4 - eyfp


reachEnd_zlim = [-15 20];
x_lim = [-30 10];
y_lim = [-20 10];

exptTypeIdx = [1,3];

saveDir = '/Users/dleventh/Box/Leventhal Lab/Meetings, Presentations/SfN/SFN 2019/Bova/figures';
saveName = '3D endpoint.pdf';
saveName = fullfile(saveDir,saveName);

figProps.m = 1;
figProps.n = 2;

figProps.topMargin = 0.5;
figProps.leftMargin = 2.5;

figProps.width = 39.01;
figProps.height = 12;

figProps.colSpacing = ones(figProps.n-1,1) * 0.5;
figProps.rowSpacing = 0.5;%ones(figProps.m-1,1) * 1;

figProps.panelWidth = ones(1,figProps.n)*((figProps.width - sum(figProps.colSpacing) - figProps.leftMargin - 0.5) / figProps.n);
figProps.panelHeight = 9;%ones(figProps.m,1) * 4;

[h_fig,h_axes] = createFigPanels5(figProps);

patchAlpha = 0.01;

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';

patchX = [2.5 2.5 12.5 12.5];

n = zeros(length(exptSummary),1);

for i_exptType = 1 : length(exptTypeIdx)
    
    curSummary = exptSummary(exptTypeIdx(i_exptType));
    n(i_exptType) = size(curSummary.firstReachSuccess,2);
    numSessions = size(curSummary.firstReachSuccess,1);
    
    axes(h_axes(i_exptType));
    
    switch exptTypeIdx(i_exptType)
        case 1
            laserOnColor = 'b';
        case 2
            laserOnColor = 'c';
        case 3
            laserOnColor = 'g';
        case 4
            laserOnColor = 'r';
    end
    
    
    % 3D pd endpoints
    pd_toPlot = squeeze(nanmean(curSummary.mean_pd_endPt,1));
    scatter3(pd_toPlot(retrainSessions,1),pd_toPlot(retrainSessions,3),pd_toPlot(retrainSessions,2),pd_markerSize,'markeredgecolor',retrainColor,'markerfacecolor',retrainColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
    hold on
    scatter3(pd_toPlot(laserOnSessions,1),pd_toPlot(laserOnSessions,3),pd_toPlot(laserOnSessions,2),pd_markerSize,'markeredgecolor',laserOnColor,'markeredgealpha',0.5);
    scatter3(pd_toPlot(occludeSessions,1),pd_toPlot(occludeSessions,3),pd_toPlot(occludeSessions,2),pd_markerSize,'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
    scatter3(0,0,0,pelletMarkerSize,'marker','*','markerfacecolor','k','markeredgecolor','k');

    % 3D dig2 endpoints
    axes(h_axes(1,i_exptType));
    dig2_toPlot = squeeze(nanmean(curSummary.mean_dig2_endPt,1));
    scatter3(dig2_toPlot(retrainSessions,1),dig2_toPlot(retrainSessions,3),dig2_toPlot(retrainSessions,2),dig_markerSize,'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
    hold on
    scatter3(dig2_toPlot(laserOnSessions,1),dig2_toPlot(laserOnSessions,3),dig2_toPlot(laserOnSessions,2),dig_markerSize,'markeredgecolor',laserOnColor);
    scatter3(dig2_toPlot(occludeSessions,1),dig2_toPlot(occludeSessions,3),dig2_toPlot(occludeSessions,2),dig_markerSize,'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    set(gca,'zdir','reverse','xlim',x_lim,'ylim',reachEnd_zlim,'zlim',y_lim,...
        'view',[-70,30])
    

    numValidPts = sum(~isnan(curSummary.num_trials),2);
    
    set(gca,'fontsize',16,...
        'fontname','arial');
    
%     h_leg = legend('laser on','occluded')
%     set(h_leg,'location','northeast','fontsize',18)
%     legend('boxoff')

    
    if i_exptType == 1
        ylabel('z (mm)');zlabel('y (mm)');
    else
        xlabel('x (mm)');ylabel('z (mm)');
        set(gca,'zticklabel',[]);
    end
end

n

print(h_fig,saveName,'-dpdf');