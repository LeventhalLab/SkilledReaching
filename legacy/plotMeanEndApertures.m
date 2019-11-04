function plotMeanEndApertures(mean_endApertures)

ylimits = [8,12];
meanApertures_acrossExps = zeros(22,3);
stdApertures_acrossExps = zeros(22,3);
markerSize = 50;

markerType = {'o','s','*'};
figure(5)
hold off
for ii = 1 : 3
    figure(5);
%     hold off

    cur_meanEndAperture = nanmean(mean_endApertures{ii},2);
    cur_stdEndAperture = nanstd(mean_endApertures{ii},1,2);
    meanApertures_acrossExps(:,ii) = cur_meanEndAperture;
    stdApertures_acrossExps(:,ii) = cur_stdEndAperture;

    scatter(1:2,squeeze(meanApertures_acrossExps(1:2,ii)),markerSize,markerType{ii},'markeredgecolor','k','markerfacecolor','k')
    hold on
    scatter(3:12,squeeze(meanApertures_acrossExps(3:12,ii)),markerSize,markerType{ii},'markeredgecolor','b','markerfacecolor','b')
    scatter(13:22,squeeze(meanApertures_acrossExps(13:22,ii)),markerSize,markerType{ii},'markeredgecolor','r','markerfacecolor','r')
    
    errorbar(1:2,squeeze(meanApertures_acrossExps(1:2,ii)),squeeze(stdApertures_acrossExps(1:2,ii)),'color','k','linestyle','none')
    errorbar(3:12,squeeze(meanApertures_acrossExps(3:12,ii)),squeeze(stdApertures_acrossExps(3:12,ii)),'color','k','linestyle','none')
    errorbar(13:22,squeeze(meanApertures_acrossExps(13:22,ii)),squeeze(stdApertures_acrossExps(13:22,ii)),'color','k','linestyle','none')
    set(gca,'ylim',ylimits);
    ylabel('reach extent (mm)')
end

end


