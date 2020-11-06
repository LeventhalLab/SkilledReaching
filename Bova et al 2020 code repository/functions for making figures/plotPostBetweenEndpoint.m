function plotPostBetweenEndpoint(exptSummaryHisto,btwPostSummary)

exptSummaryHisto(2).mean_dig2_endPt(:,22,3) = exptSummaryHisto(2).mean_dig2_endPt(:,22,3)*-1;
btwPostSummary.mean_dig2_endPt(:,1:2,3) = btwPostSummary.mean_dig2_endPt(:,1:2,3)*-1;

occlAvgEnd = nanmean(exptSummaryHisto(2).mean_dig2_endPt(:,22,3),1);    % average last occlusion session
errBars(1,1) = nanstd(exptSummaryHisto(2).mean_dig2_endPt(:,22,3),0,1)./sqrt(sum(~isnan(exptSummaryHisto(2).mean_dig2_endPt(:,22,3))));
avgEnd = nanmean(btwPostSummary.mean_dig2_endPt(:,1:2,3),1);    % average during reach stimulation
errBars(1,2:3) = nanstd(btwPostSummary.mean_dig2_endPt(:,1:2,3),0,1)./sqrt(sum(~isnan(btwPostSummary.mean_dig2_endPt(:,1:2,3))));

indivData = [exptSummaryHisto(2).mean_dig2_endPt(:,22,3) btwPostSummary.mean_dig2_endPt(:,1:2,3)];

% plot
avgMarkerSize = 45;
indMarkerSize = 4;
indivColor = [.85 .85 .85];
occColor = [127/255 0/255 255/255];
figColor = [.12 .16 .67];
line([.75 3.25],[0 0],'Color','k')
hold on

for i_rat = 1:size(indivData,1) % plot individual
    num_sess = sum(~isnan(indivData(i_rat,:)));
    plot(1:num_sess,indivData(i_rat,1:num_sess),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
    hold on
end 

scatter(1,occlAvgEnd,avgMarkerSize,'MarkerEdgeColor',occColor)  % plot average
hold on
scatter(2:3,avgEnd,avgMarkerSize,'k','filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor)
e = errorbar(1,occlAvgEnd,errBars(1),'linestyle','none');
e1 = errorbar(2:3,avgEnd,errBars(2:3),'linestyle','none');

% figure properties
e.Color = occColor;
e1.Color = figColor;

patchX = [1.75 3.25 3.25 1.75];
patchY = [-10 -10 25 25];
patch(patchX,patchY,figColor,'FaceAlpha',0.06,'LineStyle','none')

ylabel({'final z_{digit2}';'w.r.t pellet (mm)'},'FontSize',10)
xlabel('session number within block','FontSize',10)
set(gca,'ylim',[-10 25])
set(gca,'xlim',[.75 3.25])
set(gca,'xtick',[1:3])
set(gca,'ytick',[-10 0 25])
set(gca,'XTickLabels',{'O10','L1','L2'})

box off

% stats
% [h,p] = ttest(indivData(:,1),indivData(:,2));
% [h,p] = ttest(indivData(:,1),indivData(:,3));
% [h,p] = ttest(indivData(:,2),indivData(:,3));



