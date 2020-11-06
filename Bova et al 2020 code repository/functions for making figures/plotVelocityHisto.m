function h_fig = plotVelocityHisto(exptSummaryHisto)

plotIndiv = true;   % set to true to plot individual rat data

retrainSess = 1:2;  % define sessions
laserSess = 3:12;
occludedSess = 13:22;

if ~plotIndiv % sets y axis limits
    minValue = 500; 
    maxValue = 900;
else
    minValue = 250; 
    maxValue = 1250;
end

patchX = [2.5 12.5 12.5 2.5];   % set background color dimensions
patchY = [minValue minValue maxValue maxValue];

avgMarkerSize = 45;
indMarkerSize = 4;

txtSz = 12;

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

% calculate averages, s.e.m.
avgData = nanmean(exptSummaryHisto.mean_pd_v,2);
numDataPts = sum(~isnan(exptSummaryHisto.mean_pd_v),2);
errBars = nanstd(exptSummaryHisto.mean_pd_v,0,2)./sqrt(numDataPts);

% plot individual data points
if plotIndiv
    for i = 1:size(exptSummaryHisto.mean_pd_v,2)
        plot(1:22,exptSummaryHisto.mean_pd_v(:,i),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
        hold on
    end 
end 

% plot averages
hold on
p1 = scatter(retrainSess,avgData(retrainSess),avgMarkerSize,'MarkerEdgeColor','k');
p2 = scatter(laserSess,avgData(laserSess),avgMarkerSize,'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
p3 = scatter(occludedSess,avgData(occludedSess),avgMarkerSize,'MarkerEdgeColor',figColor);
e = errorbar(retrainSess,avgData(retrainSess),errBars(retrainSess),'linestyle','none');
e1 = errorbar(3:22,avgData(3:22),errBars(3:22),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;

%figure properties
line([0 23],[0 0],'Color','k')
patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')

ylabel({'max reach' ;'velocity (mm/s)'})
xlabel('session number within block')
set(gca,'xlim',[0 23],'ylim',[minValue maxValue],'xtick',[1 2 3 12 13 22],'ytick',minValue:250:maxValue);
set(gca,'xticklabels',[9 10 1 10 1 10]);
set(gca,'FontSize',10);
box off

legend([p1 p2 p3],{'retraining','laser on','occluded'},'AutoUpdate','off')
legend('boxoff')