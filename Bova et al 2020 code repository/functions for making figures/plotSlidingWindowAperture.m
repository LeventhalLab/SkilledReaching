function plotSlidingWindowAperture(indivSlidingWindow,session,i,yMin,yMax,numBins)

ratGrp = indivSlidingWindow(i).exptInfo.type; % set colors for each group
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

numRats = size(indivSlidingWindow(i).aperture,3);

data = indivSlidingWindow(i).aperture(:,:,:);
data(data == 0) = NaN;

avgData = NaN(numBins,1);
errbars = NaN(numBins,1);

for i_trial = 1:numBins     % calculate averages
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

% plot data
shadedErrorBar(1:numBins,avgData,errbars,'lineprops',{'color',figColor,'linewidth',1.5})

% figure properties
line([0 60],[0 0],'Color','k')
ylabel('aperture at reach end (mm)')
xlabel('bin of 10 reaches')
set(gca,'ylim',[yMin yMax]);
set(gca,'FontSize',10);
box off