function plotAimsvsSuccBtwn(cylData,btwPostSummary,exptSummaryHisto)

base = nanmean(exptSummaryHisto(2).firstReachSuccess(21:22,[1:6 8]));   % average last 2 occlusion sessions
succData = btwPostSummary.firstReachSuccess(1,[1:6 8]) - base;  % find difference baseline and laser on day 1
aimsData = (cylData(5).axialAmplitude(:,:,5).*cylData(5).axialBasic(:,:,5))+...
    (cylData(5).limbAmplitude(:,:,5).*cylData(5).limbBasic(:,:,5)); % calculate global aims scores (aims test 2)

% plot
scatter(succData,aimsData,65,'MarkerFaceColor',[.12 .16 .67],'MarkerEdgeColor',[.12 .16 .67]);

% figure properties
xlim([-.8 .1])
ylim([0 14])
set(gca,'xtick',[-.8 -.35 .1])
set(gca,'ytick',[0 7 14])
xlabel('first reach success rate')
ylabel('global AIMs score')