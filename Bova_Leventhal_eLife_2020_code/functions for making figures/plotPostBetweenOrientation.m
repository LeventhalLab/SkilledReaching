function plotPostBetweenOrientation(exptSummaryHisto,btwPostSummary)

exptSummaryHisto(2).mean_end_orientations(22,:) = (exptSummaryHisto(2).mean_end_orientations(22,:)*180)/pi;
btwPostSummary.mean_end_orientations(1:2,:) = (btwPostSummary.mean_end_orientations(1:2,:)*180)/pi;

occlAvgEnd = nanmean(exptSummaryHisto(2).mean_end_orientations(22,:),2);    % average last occlusion session
errBars(1,1) = nanstd(exptSummaryHisto(2).mean_end_orientations(22,:),0,2)./sqrt(sum(~isnan(exptSummaryHisto(2).mean_end_orientations(22,:))));
avgEnd = nanmean(btwPostSummary.mean_end_orientations(1:2,:),2);    % average laser on during sessions
errBars(1,2:3) = nanstd(btwPostSummary.mean_end_orientations(1:2,:),0,2)./sqrt(sum(~isnan(btwPostSummary.mean_end_orientations(1:2,:)),2));

indivData = [exptSummaryHisto(2).mean_end_orientations(22,:); btwPostSummary.mean_end_orientations(1:2,:)];

% plot
avgMarkerSize = 45;
indMarkerSize = 4;
indivColor = [.85 .85 .85];
occColor = [127/255 0/255 255/255];
figColor = [.12 .16 .67];

for i_rat = 1:size(indivData,2) % plot individual
    num_sess = sum(~isnan(indivData(:,i_rat)),1);
    plot(1:num_sess,indivData(1:num_sess,i_rat),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
    hold on
end 

scatter(1,occlAvgEnd,avgMarkerSize,'MarkerEdgeColor',occColor)  % plot average
scatter(2:3,avgEnd,avgMarkerSize,'k','filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor)
e = errorbar(1,occlAvgEnd,errBars(1),'linestyle','none');
e1 = errorbar(2:3,avgEnd,errBars(2:3),'linestyle','none');

% figure properties
e.Color = occColor;
e1.Color = figColor;

patchX = [1.75 3.25 3.25 1.75];
patchY = [30 30 70 70];
patch(patchX,patchY,figColor,'FaceAlpha',0.06,'LineStyle','none')

ylabel({'\theta (deg) at';'reach end'},'FontSize',10)
set(gca,'ylim',[30 70])
set(gca,'ytick',[30 50 70])
set(gca,'xlim',[.75 3.25])
set(gca,'xtick',[1:3])
set(gca,'XTickLabels',{'O10','L1','L2'})

box off

% [h,p] = ttest(indivData(1,:),indivData(2,:));
% [h,p] = ttest(indivData(1,:),indivData(3,:));
% [h,p] = ttest(indivData(2,:),indivData(3,:));