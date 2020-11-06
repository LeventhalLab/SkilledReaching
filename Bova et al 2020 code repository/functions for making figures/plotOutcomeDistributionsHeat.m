function plotOutcomeDistributionsHeat(exptOutcomeSummary,i_grp)

ratGrp = exptOutcomeSummary(i_grp).experimentInfo.type; % define colors for each group
if strcmpi(ratGrp,'chr2_during')
    highColor = [17/255 73/255 156/255];
elseif strcmpi(ratGrp,'chr2_between')
    highColor = [127/255 0/255 255/255];
elseif strcmpi(ratGrp,'arch_during')
    highColor = [0 .4 0.2];
elseif strcmpi(ratGrp,'arch_between')
    highColor = [255/255 128/255 0/255];
else strcmpi(ratGrp,'eyfp')
    highColor = [.84 .14 .63];
end

length = 200;   % properties for colorbar
lowColor = [255/255 255/255 255/255];
colors_p = [linspace(lowColor(1),highColor(1),length)', linspace(lowColor(2),highColor(2),length)',...
    linspace(lowColor(3),highColor(3),length)'];

scoreNames = exptOutcomeSummary(i_grp).fullOutcomeNames;   % get outcome names  

curData = exptOutcomeSummary(i_grp).fullOutcomePercent;
curData = curData*100;
    
avgData = nanmean(curData(:,:,:),3);    % calculate average
plotData = avgData';

heatmap(1:22,scoreNames,plotData)   % plot data
caxis([0, 80])
colormap(gca,colors_p)

% set(gca,'xlabel','session in block')