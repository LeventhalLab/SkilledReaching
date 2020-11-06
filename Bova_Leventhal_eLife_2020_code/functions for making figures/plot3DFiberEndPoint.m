function plot3DFiberEndPoint(coor)

figColors = {[.12 .16 .67],[127/255 0/255 255/255],[0 .4 0.2],[255/255 128/255 0/255],[.84 .14 .63]};

coor.ML = abs(coor.ML);

sortedData = NaN(8,5,3);  %sort data into columns for each group
for i_grp = 1:5
    
    curRats = find(coor.Virus == i_grp);   
    numRats = size(curRats,1);
    
    sortedData(1:numRats,i_grp,1) = coor.AP(curRats);

    sortedData(1:numRats,i_grp,2) = coor.ML(curRats);

    sortedData(1:numRats,i_grp,3) = coor.DV(curRats);
    
end 

avgMes = nanmean(sortedData,1); % get average 

for i_grp = 1:5 % plot averages and individual data
    
    plotColor = figColors{i_grp};
    
    curRats = find(coor.Virus == i_grp);   
    numRats = size(curRats,1);
    
    for i_rat = 1:numRats   % plot individual
        cur_row = curRats(i_rat);
        scatter3(coor.ML(cur_row),coor.AP(cur_row),coor.DV(cur_row),10,'MarkerFaceColor',plotColor,...
            'MarkerEdgeColor',plotColor,'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.4)
        hold on
    end 
    
    scatter3(avgMes(:,i_grp,2),avgMes(:,i_grp,1),avgMes(:,i_grp,3),'MarkerFaceColor',plotColor,...
            'MarkerEdgeColor',plotColor)    % plot averages
        
end 

xlabel('M-L')
ylabel('A-P')
zlabel('D-V')


