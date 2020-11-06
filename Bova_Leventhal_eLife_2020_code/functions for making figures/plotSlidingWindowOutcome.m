function plotSlidingWindowOutcome(indivSlidingWindow,session,i,plotIndiv,numBins)

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

numRats = size(indivSlidingWindow(i).success,3);

for i_trial = 1:numBins
    curData(:,1) = indivSlidingWindow(i).success(i_trial,session,:);
    for i_rat = 1:numRats
        if isnan(curData(i_rat,1)) % if rat drops out (i.e. no more trials) carry last score forward
            lastDataPt = ~isnan(indivSlidingWindow(i).success(:,session,i_rat)); 
            rowNum = find(lastDataPt == 1,1,'last'); % find last data point
            if isempty(rowNum)
                continue
            else
            curData(i_rat,1) = indivSlidingWindow(i).success(rowNum,session,i_rat); % set current trial to last data point
            end
        end
    end
    numDataPts = sum(~isnan(curData));
    avgData(i_trial,1) = nanmean(curData); % calculate average
    errbars(i_trial,1) = nanstd(curData,0,1)./sqrt(numDataPts); % calculate s.e.m.
end

% plot data
p = shadedErrorBar(1:numBins,avgData(1:numBins,1),errbars(1:numBins,1),'lineprops',{'color',figColor,'linewidth',1.5});

indivColor = [.5 .5 .5]; % plot individual data if wanted
if plotIndiv == true
    for i_rat = 1:numRats
        plot(1:numBins,indivSlidingWindow(i).success(1:numBins,session,i_rat),'Color',indivColor);
        hold on
    end
end

% figure properties
ylabel({'first reach';'success rate'},'FontSize',10)
xlabel('bin of 10 reaches')
set(gca,'xlim',[.5 numBins+.5]);
set(gca,'ylim',[0 1]);
set(gca,'ytick',[0 1]);
set(gca,'yticklabels',[0 1]);
set(gca,'FontSize',10);
box off