function plotSlidingWindowOrientation(indivSlidingWindow,session,i,yMin,yMax,numBins)

ratGrp = indivSlidingWindow(i).exptInfo.type;   % set figure colors
if strcmpi(ratGrp,'chr2_during')
    figColor = [.12 .16 .67];
elseif strcmpi(ratGrp,'chr2_between')
    figColor = [127/255 0/255 255/255];
elseif strcmpi(ratGrp,'arch_during')
    figColor = [0 .4 0.2];
elseif strcmpi(ratGrp,'arch_between')
    figColor = [255/255 128/255 0/255];
else strcmpi(ratGrp,'eyfp')
    figColor = [.84 .14 .63];
end

numRats = size(indivSlidingWindow(i).orienation,3);

data = indivSlidingWindow(i).orienation(:,:,:);
data(data == 0) = NaN;
data = (data*180)/pi;   % convert to degrees

avgData = NaN(numBins,1);
errbars = NaN(numBins,1);

for i_trial = 1:numBins     % caclulate averages, s.e.m.
    curData(:,1) = data(i_trial,session,:);
    for i_rat = 1:numRats
        if isnan(curData(i_rat,1)) % if rat drops out (i.e. no more trials) carry last score forward
            lastDataPt = ~isnan(data(:,session,i_rat));
            rowNum = find(lastDataPt == 1,1,'last');
            if isempty(rowNum)
                continue
            else
            curData(i_rat,1) = data(rowNum,session,i_rat);
            end
        end
    end
    avgData(i_trial,1) = nanmean(curData);
    numDataPts = sum(~isnan(curData));
    errbars(i_trial,1) = nanstd(curData,0,1)./sqrt(numDataPts);
end

shadedErrorBar(1:numBins,avgData,errbars,'lineprops',{'color',figColor,'linewidth',1.5}) % plot data

% figure properties
line([0 numBins],[0 0],'Color','k')
ylabel({'orientation at'; 'reach end (deg)'})
xlabel('bin of 10 reaches')
set(gca,'xlim',[0 numBins]);
set(gca,'ylim',[yMin yMax]);
set(gca,'ytick',[yMin 50 yMax]);
set(gca,'FontSize',10);
box off