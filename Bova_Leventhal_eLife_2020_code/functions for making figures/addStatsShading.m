function addStatsShading(sigBins,yLims)

% adds black bar if trial is significantly significant from function
% withinSessStats.m

if yLims(2) <= 1
    yVal = yLims(2)*.93;
elseif yLims(2) > 5 && yLims(2) < 15
    yVal = yLims(2)*.855;
elseif yLims(2) == 15
    yVal = yLims(2)*.9;
else
    yVal = yLims(2)*.95;
end

for j = 1:size(sigBins,1)
    
    
    lneX = [sigBins(j)-.5 sigBins(j)+.5];
    lneY = [yVal yVal];
    
    line(lneX,lneY,'Color','k','LineWidth',1.5)

    
end 
