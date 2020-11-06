function plotFiberEndPoint(coor,coorType)

coor.ML = abs(coor.ML); % no need to differentiate between hemispheres

figColors = {[.12 .16 .67],[127/255 0/255 255/255],[0 .4 0.2],[255/255 128/255 0/255],[.84 .14 .63]};
indivColor = [.85 .85 .85];

sortedData = NaN(8,5);  %sort data into columns for each group
for i_grp = 1:5
    
    curRats = find(coor.Virus == i_grp);   
    numRats = size(curRats,1);
    
    if coorType == 'ap'
        sortedData(1:numRats,i_grp) = coor.AP(curRats);
    elseif coorType == 'ml'
        sortedData(1:numRats,i_grp) = coor.ML(curRats);
    else
        sortedData(1:numRats,i_grp) = coor.DV(curRats);
    end 
    
end 

[p tbl] = anova1(sortedData,[],'off');  % run one-way ANOVA

avgMes = nanmean(sortedData,1); % calculate averages, std dev.
errBars = nanstd(sortedData,0,1)./sqrt(sum(~isnan(sortedData)));

for i_grp = 1:5     %plot individual data
    
    plotColor = figColors{i_grp};    
    
    numRats = sum(~isnan(sortedData(:,i_grp)));
    xvals = ones(1,numRats)*i_grp;
    
    curdata = sortedData(1:numRats,i_grp);
    [~, ind] =unique(curdata); % find repeat 
    if isempty(ind)
        scatter(i_grp,avgMes(i_grp),65,'MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor) 
        hold on
        e = errorbar(i_grp,avgMes(i_grp),errBars(i_grp),'linestyle','none');
        e.Color = plotColor;
        scatter(xvals,sortedData(1:numRats,i_grp),15,'MarkerFaceColor',indivColor,'MarkerEdgeColor',indivColor)
    else
        stRow = 1;
        for i = 1:length(ind)   %find duplicate data and spread out horizontally (so not on top of each other)
            dupes = find(sortedData(1:numRats,i_grp) == sortedData(ind(i),i_grp));
            if length(dupes) == 1
                plotMatrix(stRow,1) = i_grp;
                plotMatrix(stRow,2) = sortedData(ind(i),i_grp);
            elseif length(dupes) == 2
                plotMatrix(stRow:stRow+(length(dupes)-1),1) = [i_grp-.1 i_grp+.1]';
                plotMatrix(stRow:stRow+(length(dupes)-1),2) = [sortedData(ind(i),i_grp) sortedData(ind(i),i_grp)]';
            elseif length(dupes) == 3
                plotMatrix(stRow:stRow+(length(dupes)-1),1) = [i_grp-.2 i_grp i_grp+.2]';
                plotMatrix(stRow:stRow+(length(dupes)-1),2) = [sortedData(ind(i),i_grp) sortedData(ind(i),i_grp) sortedData(ind(i),i_grp)]';
            elseif length(dupes) == 4
                plotMatrix(stRow:stRow+(length(dupes)-1),1) = [i_grp-.3 i_grp-.1 i_grp+.1 i_grp+.3]';
                plotMatrix(stRow:stRow+(length(dupes)-1),2) = [sortedData(ind(i),i_grp) sortedData(ind(i),i_grp) sortedData(ind(i),i_grp) sortedData(ind(i),i_grp)]';
            end 
            stRow = stRow+length(dupes);
        end
        
        scatter(i_grp,avgMes(i_grp),65,'MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor) 
        hold on
        e = errorbar(i_grp,avgMes(i_grp),errBars(i_grp),'linestyle','none');
        e.Color = plotColor;
        scatter(plotMatrix(:,1),plotMatrix(:,2),15,'MarkerFaceColor',indivColor,'MarkerEdgeColor',indivColor)
        
    end 
    
end 

set(gca,'xlim',[.5 5.5])
set(gca,'xtick',1:5)
set(gca,'XTickLabels',{'ChR2','ChR2','Arch','Arch','EYFP'},'FontSize',8)
ylabel('coordinate (mm)')
if coorType == 'ap'
    set(gca,'ylim',[-6.2 -4.2])
    set(gca,'ytick',[-6.2 -5.2 -4.2])
    %ylabel('A-P coordinate (mm)')
elseif coorType == 'ml'
    set(gca,'ylim',[1 3])
    set(gca,'ytick',[1 2 3])
    %ylabel('M-L coordinate (mm)')
else
    set(gca,'ylim',[7 9])
    set(gca,'ytick',[7 8 9])
    %ylabel('D-V coordinate (mm)')
end 
        
    
   