function h_fig = plotTotalReachHisto(exptSummaryHisto,i,plotIndiv,plotPatch)

% set opacity of background color 
if i == 1 || i == 3 
    patchShade = 0.07;
elseif i == 2 || i == 4 || i == 5
    patchShade = 0.11;
end 

retrainSess = 1:2; % define test sessions
laserSess = 3:12;
occludedSess = 13:22;

ratGrp = exptSummaryHisto.experimentInfo.type; % define groups and figure colors
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

% replace NaNs with zeros, to remove gaps from individual line plots
exptSummaryHisto.num_trials(isnan(exptSummaryHisto.num_trials)) = 0;

% calculate averages, stdevs
avgRetrain = nanmean(exptSummaryHisto.num_trials(1:2,:));
for k = 1:size(avgRetrain,2)
    normData(:,k) = exptSummaryHisto.num_trials(1:22,k)./avgRetrain(k);
end
avgData = nanmean(normData,2);
numDataPts = sum(~isnan(exptSummaryHisto.num_trials),2);
errBars = nanstd(normData,0,2)./sqrt(numDataPts);

% set marker sizes
avgMarkerSize = 45;
indMarkerSize = 4;

% plot Indiv
if plotIndiv
    for i = 1:size(normData,2)
        plot(1:22,normData(:,i),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
        hold on
    end 
    set(gca,'ylim',[0 3],'ytick',[0 1 2 3]);
end 

% plot average & error bars
hold on
scatter(retrainSess,avgData(retrainSess),avgMarkerSize,'MarkerEdgeColor','k');
scatter(laserSess,avgData(laserSess),avgMarkerSize,'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
scatter(occludedSess,avgData(occludedSess),avgMarkerSize,'MarkerEdgeColor',figColor);
e = errorbar(retrainSess,avgData(retrainSess),errBars(retrainSess),'linestyle','none');
e1 = errorbar(3:22,avgData(3:22),errBars(3:22),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;

% figure properties
patchX = [2.5 12.5 12.5 2.5]; %set background color dimensions
patchY = [0 0 3 3];

line([0 23],[1 1],'Color','k') % create background color
if plotPatch == true
    patch(patchX,patchY,figColor,'FaceAlpha',patchShade,'LineStyle','none')
end 

ylabel({'normalized'; 'trials/session'})
xlabel('session number')
set(gca,'xlim',[0 23]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[9 10 1 10 1 10]);
set(gca,'FontSize',10);
box off