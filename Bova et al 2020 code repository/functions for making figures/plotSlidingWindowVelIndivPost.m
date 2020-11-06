function plotSlidingWindowVelIndivPost(indivSlidingWindow,indivSlidingWindowPost,sess,numBins,sessType)

if sessType == 'o'
    data = indivSlidingWindow(2).velocity(:,sess,:); % get data
else
    data = indivSlidingWindowPost.velocity(:,sess,:);
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
    patchY = [200 200 1000 1000];

    patch(patchX,patchY,[.23 .84 .94],'FaceAlpha',0.1,'LineStyle','none')
end

ylabel({'max reach'; 'velocity (mm/s)'})
set(gca,'xlim',[.5 numBins+.5]);
set(gca,'xtick',[15 30])
set(gca,'ylim',[200 1000]);
set(gca,'ytick',[200 600 1000]);
set(gca,'FontSize',10);
box off