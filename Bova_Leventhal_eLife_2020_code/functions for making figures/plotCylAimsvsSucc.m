function plotCylAimsvsSucc(cylData,exptSummaryHisto)

base = nanmean(exptSummaryHisto(1).firstReachSuccess(1:2,2:6)); % average last two retraining sessions
succData = exptSummaryHisto(1).firstReachSuccess(12,2:6) - base;    % calculate difference 
aimsData = (cylData(4).axialAmplitude(:,:,5).*cylData(4).axialBasic(:,:,5))+...
    (cylData(4).limbAmplitude(:,:,5).*cylData(4).limbBasic(:,:,5)); % calculate global aims scores

% plot
scatter(succData,aimsData,65,'MarkerFaceColor',[.12 .16 .67],'MarkerEdgeColor',[.12 .16 .67]);

% figure properties
xlim([-.8 .1])
ylim([0 14])
set(gca,'xtick',[-.8 -.35 .1])
set(gca,'ytick',[0 7 14])
xlabel('first reach success rate')
ylabel('global AIMs score')