function plotSlidingWindowOutcomeIndiv(indivSlidingWindow,session,i,numBins)

% plots individual rat success rate data within sessions 

numRats = size(indivSlidingWindow(i).success,3); % find number of rats 

ratCol = {[255/255 102/255 178/255] [178/255 102/255 255/255] [102/255 178/255 255/255] [0/255 255/255 128/255]...
    [255/255 178/255 102/255] [204/255 0/255 0/255] [0/255 25/255 51/255] [0/255 102/255 0/255]}; % set colors

for i_rat = 1:numRats % plot data
    plot(1:numBins,indivSlidingWindow(i).success(1:numBins,session,i_rat),'LineWidth',2,'Color',ratCol{i_rat});
    hold on
end

% figure properties
ylabel('first reach success rate')
xlabel('bin of 10 reaches')
set(gca,'xlim',[.5 numBins+.5]);
set(gca,'ylim',[0 1]);
set(gca,'ytick',[0 1]);
set(gca,'xtick',[15 30]);
set(gca,'yticklabels',[0 1]);
set(gca,'FontSize',10);
box off