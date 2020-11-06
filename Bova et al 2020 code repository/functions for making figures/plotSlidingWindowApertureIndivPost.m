function plotSlidingWindowApertureIndivPost(indivSlidingWindow,indivSlidingWindowPost,sess,numBins,sessType)

if sessType == 'o'
    data = indivSlidingWindow(2).aperture(:,sess,:); % get data
else
    data = indivSlidingWindowPost.aperture(:,sess,:);
end 

data(data==0) = NaN;
numRats = size(data,3);

% set colors
ratCol = {[255/255 102/255 178/255] [178/255 102/255 255/255] [102/255 178/255 255/255] [0/255 255/255 128/255]...
    [255/255 178/255 102/255] [204/255 0/255 0/255] [0/255 25/255 51/255] [0/255 102/255 0/255]};

lineW = 2;  % set line width

% plot
for i_rat = 1:numRats
    plot(1:numBins,data(1:numBins,:,i_rat),'LineWidth',lineW,'Color',ratCol{i_rat});
    hold on
end

if sessType == 'l'
    patchX = [0 30 30 0];
    patchY = [8 8 20 20];
    patch(patchX,patchY,[.23 .84 .94],'FaceAlpha',0.1,'LineStyle','none')
end

ylabel({'aperture at'; 'reach end (mm)'})
set(gca,'xlim',[.5 numBins+.5]);
set(gca,'ylim',[8 20]);
set(gca,'ytick',[8 14 20]);
set(gca,'FontSize',10);
box off