function h_fig = plotOrientTrajAtPellet(exptSummaryHisto,grp,timeStamp)

retrainSess = 1:2; % define sessions
laserSess = 3:12;
occludedSess = 13:22;

minValue = 0;   % set y axis limits
maxValue = 100;

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

data = exptSummaryHisto(grp).mean_orientation_traj;

data = (data*180)/pi; % convert to degrees

% calculate averages
for i = 1:size(data,3)
    numDataPts = sum(~isnan(data(:,:,i)),1);
    avgData(:,i) = nanmean(data(:,:,i));     
    errbars(:,i) = nanstd(data(:,:,i),0,1)./sqrt(numDataPts);
end

% make plots
indivColor = [.85 .85 .85]; % set individual data properties
indMarkerSize = 2;

for i_rat = 1:size(data,1)  % plot individual rat data
    plot(1:22,data(i_rat,:,timeStamp),'-o','MarkerSize',indMarkerSize,...
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
ylabel({'\theta (deg) at';'z_{digit2} coordinate'})
xlabel('session number within block')
set(gca,'ylim',[minValue maxValue]);
set(gca,'xlim',[0 23]);
set(gca,'ytick',[0 50 100]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[9 10 1 10 1 10]);
set(gca,'FontSize',10);