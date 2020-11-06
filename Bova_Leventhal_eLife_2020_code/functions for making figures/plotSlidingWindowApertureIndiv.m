function plotSlidingWindowApertureIndiv(indivSlidingWindow,session,i,numBins)

data = indivSlidingWindow(i).aperture(:,:,:);   % get data

data(data==0) = NaN;

numRats = size(data,3);

% set colors
ratCol = {[255/255 102/255 178/255] [178/255 102/255 255/255] [102/255 178/255 255/255] [0/255 255/255 128/255]...
    [255/255 178/255 102/255] [204/255 0/255 0/255] [0/255 25/255 51/255] [0/255 102/255 0/255]};

lineW = 2;

% plot data
for i_rat = 1:numRats
    plot(1:numBins,data(1:numBins,session,i_rat),'LineWidth',lineW,'Color',ratCol{i_rat});
    hold on
end

% figure properties
ylabel('aperture at reach end (mm)')
set(gca,'xlim',[.5 numBins+.5]);
set(gca,'ylim',[5 25]);
set(gca,'ytick',[5 15 25]);
set(gca,'FontSize',10);
box off