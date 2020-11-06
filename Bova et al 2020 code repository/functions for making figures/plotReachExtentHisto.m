function h_fig = plotReachExtentHisto(exptSummaryHisto,i_grp)

plotIndiv = true; % set to true to plot individual rat data

retrainSess = 1:2;  % define sessions to plot
laserSess = 3:12;
occludedSess = 13:22;

minValue = -20; % define y axis limits
maxValue = 28;

patchX = [2.5 12.5 12.5 2.5];   % define dimensions of background color
patchY = [minValue minValue maxValue maxValue];

avgMarkerSize = 45; % set marker sizes
indMarkerSize = 4;

% define figure colors for each group
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

exptSummaryHisto.mean_dig2_endPt = exptSummaryHisto.mean_dig2_endPt*-1; % change negative to before pellet, positive to past

% plot individual dig2 data points
if plotIndiv
    for i = 1:size(exptSummaryHisto.mean_dig2_endPt,1)
        plot(1:22,exptSummaryHisto.mean_dig2_endPt(i,:,3),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
        hold on
    end 
end 

% calculate averages and s.e.m.
avgData = nanmean(exptSummaryHisto.mean_dig2_endPt(:,:,3));
numDataPts = sum(~isnan(exptSummaryHisto.mean_dig2_endPt(:,:,3)));
errBars = nanstd(exptSummaryHisto.mean_dig2_endPt(:,:,3),0)./sqrt(numDataPts);

% plot average data
hold on
scatter(retrainSess,avgData(retrainSess),avgMarkerSize,'MarkerEdgeColor','k');
scatter(laserSess,avgData(laserSess),avgMarkerSize,'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
scatter(occludedSess,avgData(occludedSess),avgMarkerSize,'MarkerEdgeColor',figColor);
e = errorbar(retrainSess,avgData(retrainSess),errBars(retrainSess),'linestyle','none');
e1 = errorbar(3:22,avgData(3:22),errBars(3:22),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;
    
% figure settings

patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')   % add background color
if i_grp == 1
    line([0 17.8],[0 0],'Color','k')
else
    line([0 23],[0 0],'Color','k')
end 

ylabel('final z_{digit2} (mm)')
xlabel('session number within block')
set(gca,'ylim',[minValue maxValue])
set(gca,'xlim',[0 23]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[9 10 1 {'10 '} {' 1'} 10]);
set(gca,'FontSize',10);
box off


