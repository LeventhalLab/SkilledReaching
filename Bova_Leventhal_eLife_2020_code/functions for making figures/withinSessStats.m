function withinSessStats(indivSlidingWindow,groups,session,numBins)

% performs Wilcoxon rank sum test comparing each trial/bin between 2 groups

for i_bin = 1:numBins
    for i_grp = groups
        
        if i_grp == groups(2)
            col = 2;
        else
            col = 1;
        end
        
        for i_rat = 1:size(indivSlidingWindow(i_grp).success,3)
            curData(i_rat,col) = indivSlidingWindow(i_grp).success(i_bin,session,i_rat);
        end 
    end 
    
    pVals(i_bin,1) = ranksum(curData(:,1),curData(:,2));
end 

sigBins = find(pVals < .01); % identify trials with p < 0.01

yLims = [0 1];

addStatsShading(sigBins,yLims)

    
