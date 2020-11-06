function h_fig = plotBaselineTotalReach(exptSummaryHisto)

retrainIndiv = NaN(5,8);

for i_grp = 1:5 % calculate averages for each group
    exptSummaryHisto(i_grp).num_trials(isnan(exptSummaryHisto(i_grp).num_trials)) = 0; % replace NaNs with zeros
    
    numRats = size(exptSummaryHisto(i_grp).num_trials,2);
    retrainIndiv(i_grp,1:numRats) = nanmean(exptSummaryHisto(i_grp).num_trials(1:2,:)); % average last 2 days retraining
    
    avgRetrain(i_grp,1) = nanmean(retrainIndiv(i_grp,:));
end 

barCol = {[.12 .16 .67] [127/255 0/255 255/255] [0 .4 0.2] [255/255 128/255 0/255] [.84 .14 .63]}; % set colors for each group

% plot averages 
p1 = bar(1,avgRetrain(1,1),'FaceColor',barCol{1});
hold on
p2 = bar(2,avgRetrain(2,1),'FaceColor',barCol{2});
p3 = bar(3,avgRetrain(3,1),'FaceColor',barCol{3});
p4 = bar(4,avgRetrain(4,1),'FaceColor',barCol{4});
p5 = bar(5,avgRetrain(5,1),'FaceColor',barCol{5});

% plot individual rat data for each group
for i_grp = 1:5
    numRats = size(exptSummaryHisto(i_grp).num_trials,2);
    xVals = ones(1,numRats)*i_grp;
    scatter(xVals,retrainIndiv(i_grp,1:numRats),'k','filled')
end 

% figure properties
ylabel({'baseline'; 'trials/session'})
xlabel('group')
set(gca,'xtick',[]);
set(gca,'FontSize',10);
box off