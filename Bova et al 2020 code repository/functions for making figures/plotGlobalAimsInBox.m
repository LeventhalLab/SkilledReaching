function plotGlobalAimsInBox(aimsSummary)

for i_grp = 1:4 % calculate global aims score & calculate averages individual rats
    globalScores(:,:,i_grp) = aimsSummary(i_grp).limb(:,:) + aimsSummary(i_grp).axial(:,:);
    avgGlobalScores(i_grp,:) = nanmean(globalScores(:,:,i_grp));  
end

grpAvgs = nanmean(avgGlobalScores,2);   % calculate group averages

numDataPts = sum(~isnan(avgGlobalScores),2);    % std. devs
errBars = nanstd(avgGlobalScores,0,2)./sqrt(numDataPts);

% plot data
avgMarkerSize = 45; % set marker sizes
indMarkerSize = 10;

figColor = 'k';
indivColor = [.7 .7 .7];
    
% plot individual averages
p = scatter(1,grpAvgs(1),avgMarkerSize,'filled','MarkerEdgeColor',figColor,...  
    'MarkerFaceColor',figColor);
hold on
p1 = scatter(2,grpAvgs(2),avgMarkerSize,'filled','MarkerEdgeColor',figColor,...
    'MarkerFaceColor',figColor);
p2 = scatter(3,grpAvgs(3),avgMarkerSize,'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
p3 = scatter(4,grpAvgs(4),avgMarkerSize,'filled','MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);

e = errorbar(1,grpAvgs(1),errBars(1),'linestyle','none');
e1 = errorbar(2,grpAvgs(2),errBars(2),'linestyle','none');
e2 = errorbar(3,grpAvgs(3),errBars(3),'linestyle','none');
e3 = errorbar(4,grpAvgs(4),errBars(4),'linestyle','none');

e.Color = figColor;
e1.Color = figColor;
e2.Color = figColor;
e3.Color = figColor;

for i_grp = 1:4 % plot averages
    xes = ones(1,6)*i_grp;
    scatter(xes,avgGlobalScores(i_grp,:),indMarkerSize,'MarkerEdgeColor',indivColor,...
        'MarkerFaceColor',indivColor)
    hold on
end 

% figure properties
ylabel('AIMs score')
ylim([-.05 0.8])
set(gca,'ytick',[0 .4 .8])
xlim([.5 4.5])
set(gca,'xtick',[1:4])
set(gca,'xticklabels',{'ChR2','ChR2','ChR2','EYFP'});

legend([p p1 p2 p3],{'ChR2 Laser 2','ChR2 Laser 10','ChR2 Occluded 10','EYFP Laser 10'},...
    'AutoUpdate','off','Location','northeast') % create legend
legend('boxoff')

% xx = avgGlobalScores';
% [p,tbl,stats] = kruskalwallis(xx);




