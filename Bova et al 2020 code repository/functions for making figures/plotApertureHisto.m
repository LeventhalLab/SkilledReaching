function h_fig = plotApertureHisto(exptSummaryHisto)

plotIndiv = true; % set to true to plot individual rat data

retrainSess = 1:2;  % define sessions
laserSess = 3:12;
occludedSess = 13:22;

minValue = 5;
maxValue = 25;

patchX = [2.5 12.5 12.5 2.5]; % set background color dimensions
patchY = [minValue minValue maxValue maxValue];

avgMarkerSize = 45;
indMarkerSize = 4;

textLaser = 'Laser On';
textOcclude = 'Occluded';

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

% calculate averages, stdevs, and plot
avgData = nanmean(exptSummaryHisto.mean_end_aperture,2);
numDataPts = sum(~isnan(exptSummaryHisto.mean_end_aperture),2);
errBars = nanstd(exptSummaryHisto.mean_end_aperture,0,2)./sqrt(numDataPts);

% plot individual data points
if plotIndiv
    for i = 1:size(exptSummaryHisto.mean_end_aperture,2)
        plot(1:22,exptSummaryHisto.mean_end_aperture(:,i),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
        hold on
    end 
end 

% plot averaged data and s.e.m.
hold on
p1 = scatter(retrainSess,avgData(retrainSess),avgMarkerSize,'MarkerEdgeColor','k');
p2 = scatter(laserSess,avgData(laserSess),avgMarkerSize,'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
p3 = scatter(occludedSess,avgData(occludedSess),avgMarkerSize,'MarkerEdgeColor',figColor);
e = errorbar(retrainSess,avgData(retrainSess),errBars(retrainSess),'linestyle','none');
e1 = errorbar(3:22,avgData(3:22),errBars(3:22),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;

% figure settings
line([0 23],[0 0],'Color','k')
patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')

ylabel({'aperture at'; 'reach end (mm)'})
xlabel('session number')
set(gca,'ylim',[minValue maxValue],'ytick',[5 10 15 20 25]);
set(gca,'xlim',[0 23]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[1 2 1 10 1 10]);
set(gca,'FontSize',10);
box off

legend([p1 p2 p3],{'retraining','laser on','occluded'},'AutoUpdate','off','Location','southeast')
legend('boxoff')