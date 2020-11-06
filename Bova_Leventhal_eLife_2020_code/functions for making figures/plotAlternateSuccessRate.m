function h_fig = plotAlternateSuccessRate(alternateKinematicSummaryHisto,plotArch,plotOffOn)

alternateScores = putAlternateScoresIntoBlocks(alternateKinematicSummaryHisto); 
% each column is a different session, columns are divided into blocks of 5
% the first block is always laser off, second block is laser
% on, and it repeats off/on after that

if plotArch % plot arch or chR2 data
    grpSess = 11:24; % arch
else grpSess = 1:10; % chr
end

% figure properties
plotIndiv = true; % set to true to plot individual data points for each rat

avgMarkerSize = 45;
indMarkerSize = 4;

if plotArch
    figColor = [0 .4 0.2];
else 
    figColor = [.12 .16 .67];
end 
indivColor = [.85 .85 .85];

% calculate averages
for i_sess = grpSess
    for i_trial = 1:5   % calculate average for laser off trials for each session (i.e., average of all laser off reach 1, laser off reach 2, etc)
        numTrials = sum(~isnan(alternateScores(i_trial:12:end,i_sess)))-sum(alternateScores(i_trial:12:end,i_sess) == 0)-sum(alternateScores(i_trial:12:end,i_sess) == 8);
        numOnes = sum(alternateScores(i_trial:12:end,i_sess) == 1);
        offSuccRate(i_trial,i_sess) = (numOnes/numTrials);
    end
end 

avgOff(:,1) = nanmean(offSuccRate,2); % average laser off across sessions
avgOff(:,2) = nanstd(offSuccRate,0,2)./sqrt(size(grpSess,2));

for i_sess = grpSess
    for i_trial = 7:11 % calculate average for laser on trials for each session (i.e., average of all laser on reach 1, laser on reach 2, etc)
        numTrials = sum(~isnan(alternateScores(i_trial:12:end,i_sess)))-sum(alternateScores(i_trial:12:end,i_sess) == 0)-sum(alternateScores(i_trial:12:end,i_sess) == 8);
        numOnes = sum(alternateScores(i_trial:12:end,i_sess) == 1);
        onSuccRate(i_trial-6,i_sess) = (numOnes/numTrials);
    end
end 

avgOn(:,1) = nanmean(onSuccRate,2); % average laser on across sessions
avgOn(:,2) = nanstd(onSuccRate,0,2)./sqrt(size(grpSess,2));

% put individual data into matrix
indivData = [offSuccRate; onSuccRate];

% plot individual data
if plotOffOn
    if plotIndiv
        for i_set = 1:size(indivData,2)
            plot(1:10,indivData(:,i_set),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor)
            hold on
        end 
    end 
end 

minValue = 0;
maxValue = 1;

% plot average data
if plotOffOn
    scatter(1:5,avgOff(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor);
    hold on
    scatter(6:10,avgOn(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
    e = errorbar(1:5,avgOff(1:5,1),avgOff(1:5,2),'linestyle','none');
    e1 = errorbar(6:10,avgOn(1:5,1),avgOn(1:5,2),'linestyle','none');
    e.Color = figColor;
    e1.Color = figColor;
    
    patchX = [5.5 10.5 10.5 5.5]; % add background color to laser on sessions
    patchY = [minValue minValue maxValue maxValue];
    patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')
else
    scatter(1:5,avgOn(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
    hold on
    scatter(6:10,avgOff(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor);
    e2 = errorbar(1:5,avgOn(1:5,1),avgOn(1:5,2),'linestyle','none');
    e3 = errorbar(6:10,avgOff(1:5,1),avgOff(1:5,2),'linestyle','none');
    e2.Color = figColor;
    e3.Color = figColor;
    
    patchX = [.5 5.5 5.5 .5]; % add background color to laser on sessions
    patchY = [minValue minValue maxValue maxValue];
    patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')
end 

% figure properties
ylabel({'mean'; 'success rate'})
xlabel('reach number in block')
set(gca,'xlim',[0 11],'ylim',[minValue maxValue]);
set(gca,'xtick',[1 5 6 10],'ytick',[minValue:.5:maxValue]);
set(gca,'xticklabels',[1 5 1 5]);
set(gca,'FontSize',10);
box off