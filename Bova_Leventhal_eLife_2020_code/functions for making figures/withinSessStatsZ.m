function withinSessStatsZ(indivSlidingWindow,groups,session,numBins)

% runs wilcoxon rank sum test to compare trials between 2 groups within
% session analysis

for i_bin = 1:numBins
        curData = NaN(size(indivSlidingWindow(i_grp).aperture,3),2);
    for i_grp = groups
        
        data = indivSlidingWindow(i_grp).digEnd(:,:,:)*-1;
        data(data == 0) = NaN;
        
        if i_grp == groups(2)
            col = 2;
        else
            col = 1;
        end
        
        for i_rat = 1:size(indivSlidingWindow(i_grp).digEnd,3)
            curData(i_rat,col) = data(i_bin,session,i_rat);
            
            if isnan(curData(i_rat,col)) % if rat drops out (i.e. no more trials) carry last score forward
                lastDataPt = ~isnan(data(:,session,i_rat));
                rowNum = find(lastDataPt == 1,1,'last');
                if isempty(rowNum)
                    continue
                else
                    curData(i_rat,col) = data(rowNum,session,i_rat);
                end
            end
        end 
    end 
    
    pVals(i_bin,1) = ranksum(curData(:,1),curData(:,2));    % run stats
 
end 

sigBins = find(pVals < .01);

yLims = [-10 15];

addStatsShading(sigBins,yLims)