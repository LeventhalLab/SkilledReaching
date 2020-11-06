function plotIndivDurationDistr(durSummaryFull,i_grp,i_rat)

% plots individual histogram of individual laser on durations for rat in a
% group

if i_grp == 1
    figColor = [.12 .16 .67];
else
    figColor = [0 .4 0.2];
end 

durSummaryFull(durSummaryFull==0) = NaN;
durSummaryFull(durSummaryFull < 0) = NaN;

for i_sess = 1:10   % collect durations for rat from all 10 sessions
    curDurations = durSummaryFull(i_rat,:,i_sess,i_grp);
    allDurations(:,i_sess) = curDurations(:);
    
    clear curDurations
end 

medVal = nanmedian(allDurations,'all'); % calculate median

line([5 5],[0 500],'Color','k') % mark 5 sec mark
hold on

edges = [0:1:100];  % plot histogram
h = histogram(allDurations,edges,'FaceAlpha',.6);
hold on
line([medVal medVal],[0 800],'Color','k','LineStyle','--','LineWidth',.65)  % mark histogram

h.FaceColor = figColor;
h.EdgeColor = 'k';

% boxplot([testY(:,1) testY(:,2) testY(:,3) testY(:,4) testY(:,5) testY(:,6)...
%     testY(:,7) testY(:,8) testY(:,9) testY(:,10)])

box off 
ylim([0 500])
xlim([0 20])
set(gca,'ytick',[0 250 500])
set(gca,'xtick',[0 5 20])
ylabel('number of trials')
xlabel('laser on duration (s)')

