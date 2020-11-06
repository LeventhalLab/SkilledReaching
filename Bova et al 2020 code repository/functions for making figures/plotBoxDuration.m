function plotBoxDuration(durSummaryFull,i_grp)

% plots histogram of laser on durations across all rats in a group

if i_grp == 1
    figColor = [.12 .16 .67];
else
    figColor = [0 .4 0.2];
end 

durSummaryFull(durSummaryFull==0) = NaN;
durSummaryFull(durSummaryFull < 0) = NaN;

for i_sess = 1:10   % collect data from all rats
    curDurations = durSummaryFull(:,:,i_sess,i_grp);
    allDurations(:,i_sess) = curDurations(:);
    
    clear curDurations
end 

medVal = nanmedian(allDurations,'all'); % calculate duration median

line([5 5],[0 1500],'Color','k')
hold on

edges = [0:1:100];  % plot histogram
h = histogram(allDurations,edges,'FaceAlpha',.9);
hold on
line([medVal medVal],[0 2500],'Color','k','LineStyle','--','LineWidth',.65) % mark median
    
h.FaceColor = figColor;
h.EdgeColor = 'k';

box off 
ylim([0 1500])
xlim([0 20])
set(gca,'ytick',[0 750 1500])
set(gca,'xtick',[0 5 20])
ylabel('number of trials','FontSize',10)
xlabel('laser on duration (s)')


