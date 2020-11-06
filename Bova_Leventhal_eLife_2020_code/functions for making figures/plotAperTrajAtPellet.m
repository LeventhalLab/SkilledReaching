function h_fig = plotAperTrajAtPellet(exptSummaryHisto,grp,timeStamp)

% plots aperture at z coordinate defined by timeStamp

retrainSess = 1:2; % define sessions
laserSess = 3:12;
occludedSess = 13:22;

minValue = 5;   % set y axis limits
maxValue = 15;

% define figure colors for each group
ratGrp = exptSummaryHisto(grp).experimentInfo.type;
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

% calculate averages
for i = 1:size(exptSummaryHisto(grp).mean_aperture_traj,3)
    numDataPts = sum(~isnan(exptSummaryHisto(grp).mean_aperture_traj(:,:,i)),1);
    avgData(:,i) = nanmean(exptSummaryHisto(grp).mean_aperture_traj(:,:,i));     
    errbars(:,i) = nanstd(exptSummaryHisto(grp).mean_aperture_traj(:,:,i),0,1)./sqrt(numDataPts);
end

indivColor = [.85 .85 .85]; % set properties for individual data points
indMarkerSize = 2;

for i_rat = 1:size(exptSummaryHisto(grp).mean_aperture_traj,1) % plot individual rat data
    plot(1:22,exptSummaryHisto(grp).mean_aperture_traj(i_rat,:,timeStamp),'-o','MarkerSize',indMarkerSize,...
        'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor);
    hold on
end 

avgMarkerSize = 30; % plot average data
scatter(retrainSess,avgData(retrainSess,timeStamp),avgMarkerSize,'MarkerEdgeColor','k');
hold on
scatter(laserSess,avgData(laserSess,timeStamp),avgMarkerSize,'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
scatter(occludedSess,avgData(occludedSess,timeStamp),avgMarkerSize,'MarkerEdgeColor',figColor);

e = errorbar(retrainSess,avgData(retrainSess,timeStamp),errbars(retrainSess,timeStamp),'linestyle','none');
e1 = errorbar(3:22,avgData(3:22,timeStamp),errbars(3:22,timeStamp),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;

% figure properties
box off
ylabel({'aperture (mm)';'at z_{digit2} coordinate'},'FontSize',10)
xlabel('session number within block')
set(gca,'ylim',[minValue maxValue]);
set(gca,'xlim',[0 23]);
set(gca,'ytick',[5 10 15]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[9 10 1 10 1 10]);
set(gca,'FontSize',10);