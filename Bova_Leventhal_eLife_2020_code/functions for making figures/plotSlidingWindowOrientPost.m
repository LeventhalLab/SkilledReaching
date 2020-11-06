function plotSlidingWindowOrientPost(indivSlidingWindow,indivSlidingWindowPost,sess,numBins,sessType)

numRats = size(indivSlidingWindow(2).digEnd,3);

if sessType == 'o'
    figColor = [127/255 0/255 255/255];
    for i_rat = 1:numRats   % collect data from last day of occlusion
        occData(:,i_rat) = (indivSlidingWindow(2).orienation(:,22,i_rat)*180)/pi;
    end
    occData(occData == 0) = NaN;
    
    avgData = NaN(numBins,1);    % calculate averages and s.e.m. occlusion
    errbars = NaN(numBins,1);
    for i_trial = 1:numBins     
        curData(:,1) = occData(i_trial,:);
        for i_rat = 1:numRats
            if isnan(curData(i_rat,1)) % if rat drops out (i.e. no more trials) carry last score forward
                lastDataPt = ~isnan(occData(:,i_rat));
                rowNum = find(lastDataPt == 1,1,'last');
                if isempty(rowNum)
                    continue
                else
                curData(i_rat,1) = occData(rowNum,i_rat,i_sess);
                end
            end
        end
        avgData(i_trial,1) = nanmean(curData);  
        numDataPts = sum(~isnan(curData));
        errbars(i_trial,1) = nanstd(curData,0,1)./sqrt(numDataPts);
    end 
    
elseif sessType == 'l'
    figColor = [.12 .16 .67];
    for i_sess = 1:2    % collect data from first 2 days of laser on during
        for i_rat = 1:numRats
            lasData(:,i_rat,i_sess) = (indivSlidingWindowPost.orienation(:,i_sess,i_rat)*180)/pi;
        end 
    end 
    lasData(lasData == 0) = NaN;
    
    avgData = NaN(numBins,1);    % calculate averages and s.e.m. laser on
    errbars = NaN(numBins,1);
    for i_trial = 1:numBins     
        curData(:,1) = lasData(i_trial,:,sess);
        for i_rat = 1:numRats
            if isnan(curData(i_rat,1)) % if rat drops out (i.e. no more trials) carry last score forward
                lastDataPt = ~isnan(lasData(:,i_rat,sess));
                rowNum = find(lastDataPt == 1,1,'last');
                if isempty(rowNum)
                    continue
                else
                curData(i_rat,1) = lasData(rowNum,i_rat,sess);
                end
            end
        end
        avgData(i_trial,1) = nanmean(curData);  
        numDataPts = sum(~isnan(curData));
        errbars(i_trial,1) = nanstd(curData,0,1)./sqrt(numDataPts);
    end 
    
end

% plot figure
shadedErrorBar(1:numBins,avgData,errbars,'lineprops',{'color',figColor,'linewidth',1.5})    % plot data

% figure properties
ylabel('aperture at reach end(mm)')
xlabel('bin of 10 reaches')
set(gca,'xlim',[0 numBins]);
set(gca,'xtick',[15 30]);
set(gca,'ylim',[30 70]);
set(gca,'ytick',[30 50 70]);
set(gca,'FontSize',10);
box off