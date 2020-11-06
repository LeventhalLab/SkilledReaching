function h_fig = plotAperTrajAtDistOutcome(exptOutcomeSummary,i_grp,timeStamp)

% plots aperture at z coordinate defined by timeStamp

retrainSess = 1:2; % define sessions
laserSess = 3:12;
occludedSess = 13:22;

minValue = 6;   % set y axis limits
maxValue = 14;

sCol = [11/255 129/255 62/255]; % plot colors
fCol = [153/255 0/255 0/255];

% calculate averages
avgData = NaN(22,351,8);

for i_out = 1:8
    for i_pt = 1:size(exptOutcomeSummary(i_grp).mean_aperture_traj,2)
        avgData(:,i_pt,i_out) = nanmean(exptOutcomeSummary(i_grp).mean_aperture_traj(:,i_pt,i_out,:),4);        
    end
end 

for i_out = 1:8
    for i_sess = 1:22
        numDataPts = sum(~isnan(exptOutcomeSummary(i_grp).mean_aperture_traj(i_sess,timeStamp,i_out,:)),4);
        errbars(i_sess,i_out) = nanstd(exptOutcomeSummary(i_grp).mean_aperture_traj(i_sess,timeStamp,i_out,:),0,4)./sqrt(numDataPts);
    end
end 

% plot average data
avgMarkerSize = 30; 

scatter(retrainSess,avgData(retrainSess,timeStamp,2),avgMarkerSize,'MarkerEdgeColor',sCol);
hold on
scatter(laserSess,avgData(laserSess,timeStamp,2),avgMarkerSize,'filled','MarkerEdgeColor',sCol,'MarkerFaceColor',sCol);
scatter(occludedSess,avgData(occludedSess,timeStamp,2),avgMarkerSize,'MarkerEdgeColor',sCol);
scatter(retrainSess,avgData(retrainSess,timeStamp,5),avgMarkerSize,'MarkerEdgeColor',fCol);
scatter(laserSess,avgData(laserSess,timeStamp,5),avgMarkerSize,'filled','MarkerEdgeColor',fCol,'MarkerFaceColor',fCol);
scatter(occludedSess,avgData(occludedSess,timeStamp,5),avgMarkerSize,'MarkerEdgeColor',fCol);

e1 = errorbar(1:22,avgData(1:22,timeStamp,2),errbars(1:22,2),'linestyle','none');
e2 = errorbar(1:22,avgData(1:22,timeStamp,5),errbars(1:22,5),'linestyle','none');

e1.Color = sCol;
e2.Color = fCol;

% figure properties
box off
ylabel({'aperture (mm)';'at z_{digit2} coordinate'},'FontSize',10)
xlabel('session number within block')
set(gca,'ylim',[minValue maxValue]);
set(gca,'xlim',[0 23]);
set(gca,'ytick',[6 10 14]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[9 10 1 10 1 10]);
set(gca,'FontSize',10);