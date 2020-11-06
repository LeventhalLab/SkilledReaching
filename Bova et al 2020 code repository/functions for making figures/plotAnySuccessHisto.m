function plotAnySuccessHisto(exptSummaryHisto,i_grp)

plotIndiv = true; % plot individual data points for each rat under average

retrainSess = 1:2;
laserSess = 3:12;
occludedSess = 13:22;

indMarkerSize = 4;

%define figure colors for each group
ratGrp = exptSummaryHisto.experimentInfo.type;
if strcmpi(ratGrp,'chr2_during')
    figColor = [.12 .16 .67];
elseif strcmpi(ratGrp,'chr2_between')
    figColor = [127/255 0/255 255/255];
elseif strcmpi(ratGrp,'arch_during')
    figColor = [0 .4 0.2];
elseif strcmpi(ratGrp,'arch_between')
    figColor = [255/255 128/255 0/255];
else strcmpi(ratGrp,'eyfp')
    figColor = [.84 .14 .63];
end

indivColor = [.85 .85 .85];

% calculate averages, stdevs, and plot
avgRetrain = nanmean(exptSummaryHisto.anyReachSuccess(1:2,:));
for i = 1:size(avgRetrain,2)
    normData(:,i) = exptSummaryHisto.anyReachSuccess(1:22,i)./avgRetrain(i);
end
avgData = nanmean(normData,2);
numDataPts = sum(~isnan(exptSummaryHisto.anyReachSuccess),2);
errBars = nanstd(normData,0,2)./sqrt(numDataPts);

% plot individual
if plotIndiv
    for i = 1:size(normData,2)
        plot(1:22,normData(:,i),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
        hold on
    end 
    set(gca,'ylim',[-.25 3],'ytick',[0 1 2 3]);
end 

hold on     % plot average
scatter(retrainSess,avgData(retrainSess),'MarkerEdgeColor','k');
scatter(laserSess,avgData(laserSess),'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
scatter(occludedSess,avgData(occludedSess),'MarkerEdgeColor',figColor);
e = errorbar(retrainSess,avgData(retrainSess),errBars(retrainSess),'linestyle','none');
e1 = errorbar(3:22,avgData(3:22),errBars(3:22),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;

line([0 23],[1 1],'Color','k')

% set background color opacity
if i_grp == 1 || i_grp == 3
    patchShade = 0.07;
elseif i_grp == 2 || i_grp == 4 || i_grp == 5
    patchShade = 0.11;
end

patchX = [2.5 12.5 12.5 2.5]; % set background color dimensions
patchY = [-.25 -.25 3 3];

patch(patchX,patchY,figColor,'FaceAlpha',patchShade,'LineStyle','none')

ylabel({'normalized any';'reach success rate'},'FontSize',10)
xlabel('session number')
set(gca,'ylim',[-.25 3],'ytick',[0 1 2 3]);
set(gca,'xlim',[0 23]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[9 10 1 10  1 10]);
set(gca,'FontSize',10);

box off