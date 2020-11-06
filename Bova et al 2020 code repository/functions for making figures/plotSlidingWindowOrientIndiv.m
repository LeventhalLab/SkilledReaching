function plotSlidingWindowOrientIndiv(indivSlidingWindow,session,i,numBins)

lineW = 2;

% get data
data = indivSlidingWindow(i).orienation(:,:,:);

data(data==0) = NaN;
data = (data*180)/pi;   % convert to degrees

numRats = size(data,3);

% set colors
ratCol = {[255/255 102/255 178/255] [178/255 102/255 255/255] [102/255 178/255 255/255] [0/255 255/255 128/255]...
    [255/255 178/255 102/255] [204/255 0/255 0/255] [0/255 25/255 51/255] [0/255 102/255 0/255]};

% plot data
for i_rat = 1:numRats
    plot(1:numBins,data(1:numBins,session,i_rat),'LineWidth',lineW,'Color',ratCol{i_rat});
    hold on
end

ylabel('\theta at reach end (deg)')
set(gca,'xlim',[.5 numBins+.5]);
set(gca,'ylim',[0 100]);
set(gca,'ytick',[0 50 100]);
set(gca,'FontSize',10);
box off