function plotGlobalAims(cylData,groups,combineChR)

for i_grp = groups  % get number rats in each group
    grpSz(find(groups == i_grp),:) = size(cylData(i_grp).paw,2);
end 

numCol = max(grpSz);

indivAxial = NaN(size(groups,2),numCol,6);  
indivLimb = NaN(size(groups,2),numCol,6);

for i_grp = groups
    numRats = size(cylData(i_grp).paw,2);   % multiply amplitude and basic scores for axial and limb aims to get composite score
    indivAxial(find(groups == i_grp),1:numRats,:) = cylData(i_grp).axialAmplitude .* cylData(i_grp).axialBasic;
    indivLimb(find(groups == i_grp),1:numRats,:) = cylData(i_grp).limbAmplitude .* cylData(i_grp).limbBasic;
end 

if combineChR == true   % lump all ChR2 rats into one group (i.e., during + between)
    indivAxial2 = NaN(size(groups,2)-2,numCol*2,6);
    indivLimb2 = NaN(size(groups,2)-2,numCol*2,6);
    for power = 1:6
        if size(indivAxial,1) == 4
            indivAxial2(1,:,power) = [indivAxial(1,:,power) indivAxial(2,:,power)];
            indivAxial2(2,:,power) = [indivAxial(3,:,power) indivAxial(4,:,power)];
            indivLimb2(1,:,power) = [indivLimb(1,:,power) indivLimb(2,:,power)];
            indivLimb2(2,:,power) = [indivLimb(3,:,power) indivLimb(4,:,power)];
        elseif size(indivAxial,1) > 4
            indivAxial2(1,:,power) = [indivAxial(1,:,power) indivAxial(2,:,power)];
            indivAxial2(2,:,power) = [indivAxial(4,:,power) indivAxial(5,:,power)];
            indivAxial2(3,1:numCol,power) = indivAxial(3,:,power);
            indivAxial2(4,1:numCol,power) = indivAxial(6,:,power);
            indivLimb2(1,:,power) = [indivLimb(1,:,power) indivLimb(2,:,power)];
            indivLimb2(2,:,power) = [indivLimb(4,:,power) indivLimb(5,:,power)];
            indivLimb2(3,1:numCol,power) = indivLimb(3,:,power);
            indivLimb2(4,1:numCol,power) = indivLimb(6,:,power);
        end 
    end
    
    globalIndiv = indivAxial2 + indivLimb2;     % add axial and limb scores to get Global AIMs scores
else 
    globalIndiv = indivAxial + indivLimb;
end 

avgGlobal = nanmean(globalIndiv,2); 
erBars = nanstd(globalIndiv,0,2)./sqrt(sum(~isnan(globalIndiv(1,:,1))));    % calculate s.e.m.

% put data in format for plotting (rows laser power, columns groups ChR2
% day 1, ChR2 day 2, EYFP day 1, EYFP day 2)
avgPlot = [avgGlobal(:,:,1)'; avgGlobal(:,:,2)'; avgGlobal(:,:,3)'; avgGlobal(:,:,4)'; avgGlobal(:,:,5)'; avgGlobal(:,:,6)'];

% plot data
aimFig = bar(avgPlot);
hold on

aimFig(1).FaceColor = [.71 .82 .94];    % set colors of bars
aimFig(2).FaceColor = [.12 .16 .67];
aimFig(3).FaceColor = [.84 .71 .88];
aimFig(4).FaceColor = [.84 .14 .63];

% plot individual data
indivColor = [.65 .65 .65];
for i_pow = 1:6
    xVals = [i_pow-.27 i_pow-.08];
    for i_rat = 1:size(globalIndiv,2)
        plot(xVals,globalIndiv(1:2,i_rat,i_pow),'Color',indivColor,'LineWidth',.5)
    end
end 

% find center of bars to plot error bars
xdata1 = aimFig(1).XData;
xdata2 = aimFig(2).XData;
ydata1 = aimFig(1).YData;
ydata2 = aimFig(2).YData;

lineW = 1;

for r = 1:6 % add error bars
    errorbar(xdata1(r)-.27,ydata1(r),erBars(1,:,r),'k','LineWidth',lineW)
    errorbar(xdata2(r)-.08,ydata2(r),erBars(2,:,r),'k','LineWidth',lineW)
end

% figure properties
ylabel('global AIMs score')
xlabel('laser power')
set(gca,'ylim',[0 14]);
set(gca,'ytick',[0 7 14]);
set(gca,'xticklabels',[0 5 10 15 20 25]);
set(gca,'FontSize',10);
box off