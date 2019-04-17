function h_figs = plotMeanEndPoints(mean_endPoints)

ylimits = [-13,7];
meanPts_acrossExps = zeros(22,3,3);
stdPts_acrossExps = zeros(22,3,3);
markerSize = 50;

markerType = {'o','s','*'};

hold off
for ii = 1 : 3
    h_figs(ii) = figure(ii);
%     hold off

    cur_meanEndPt = nanmean(mean_endPoints{ii},3);
    cur_stdEndPt = nanstd(mean_endPoints{ii},1,3);
    meanPts_acrossExps(:,:,ii) = cur_meanEndPt;
    stdPts_acrossExps(:,:,ii) = cur_stdEndPt;

    scatter(1:2,squeeze(meanPts_acrossExps(1:2,3,ii)),markerSize,markerType{ii},'markeredgecolor','k','markerfacecolor','k')
    hold on
    scatter(3:12,squeeze(meanPts_acrossExps(3:12,3,ii)),markerSize,markerType{ii},'markeredgecolor','b','markerfacecolor','b')
    scatter(13:22,squeeze(meanPts_acrossExps(13:22,3,ii)),markerSize,markerType{ii},'markeredgecolor','r','markerfacecolor','r')
    
    errorbar(1:2,squeeze(meanPts_acrossExps(1:2,3,ii)),squeeze(stdPts_acrossExps(1:2,3,ii)),'color','k','linestyle','none')
    errorbar(3:12,squeeze(meanPts_acrossExps(3:12,3,ii)),squeeze(stdPts_acrossExps(3:12,3,ii)),'color','k','linestyle','none')
    errorbar(13:22,squeeze(meanPts_acrossExps(13:22,3,ii)),squeeze(stdPts_acrossExps(13:22,3,ii)),'color','k','linestyle','none')
    set(gca,'ylim',ylimits);
    ylabel('reach extent (mm)')
end

end


