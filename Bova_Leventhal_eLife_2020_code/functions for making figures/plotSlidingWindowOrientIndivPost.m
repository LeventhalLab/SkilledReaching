function plotSlidingWindowOrientIndivPost(indivSlidingWindow,indivSlidingWindowPost,sess,numBins,sessType)

if sessType == 'o'
    data = indivSlidingWindow(2).orienation(:,sess,:); % get data
else
    data = indivSlidingWindowPost.orienation(:,sess,:);
end 

data(data==0) = NaN;
data = (data*180)/pi;

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
    patchY = [30 30 70 70];

    patch(patchX,patchY,[.23 .84 .94],'FaceAlpha',0.1,'LineStyle','none')
end

ylabel({'\theta at'; 'reach end (deg)'})
set(gca,'xlim',[.5 numBins+.5]);
set(gca,'ylim',[30 70]);
set(gca,'ytick',[30 50 70]);
set(gca,'FontSize',10);
box off