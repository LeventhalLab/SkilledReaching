function plotRotation(cylData,groups,combineChR)

% paw 1 = right; paw 2 = left
% ipsilateral/contralateral is relative to paw preference

for i_grp = groups  % get number rats in each group
    grpSz(find(groups == i_grp),:) = size(cylData(i_grp).paw,2);
end 

numCol = max(grpSz);

spins = NaN(size(groups,2),numCol,6);

for i_grp = groups
    numRats = size(cylData(i_grp).paw,2);
    for i_rat = 1:numRats
        paw = cylData(i_grp).paw(i_rat);
        if paw == 1 % get number of contralateral and ipsilateral spins based on paw preference
            ipsiSpin = cylData(i_grp).rightSpin(1,i_rat,:);
            contraSpin = cylData(i_grp).leftSpin(1,i_rat,:);
        elseif paw == 2
            ipsiSpin = cylData(i_grp).leftSpin(1,i_rat,:);
            contraSpin = cylData(i_grp).rightSpin(1,i_rat,:);
        end 
        spins(find(groups == i_grp),i_rat,:) = ipsiSpin - contraSpin;   % subtract contralateral spins from ipsilateral spins for each rat
    end 
end

if combineChR == true   % lump ChR2 rats together (Between + During)
    spins1 = NaN(size(groups,2)-2,numCol*2,6);
    for power = 1:6
        if size(spins,1) == 4
            spins1(1,:,power) = [spins(1,:,power) spins(2,:,power)];
            spins1(2,:,power) = [spins(3,:,power) spins(4,:,power)];
        elseif size(spins,1) > 4
            spins1(1,:,power) = [spins(1,:,power) spins(2,:,power)];
            spins1(2,:,power) = [spins(4,:,power) spins(5,:,power)];
            spins1(3,1:numCol,power) = spins(3,:,power);
            spins1(4,1:numCol,power) = spins(6,:,power);
        end 
    end
    avgSpins = nanmean(spins1,2);   % average across rats
    erBars = nanstd(spins1,0,2)./sqrt(sum(~isnan(spins1(1,:,1))));  % calculate s.e.m.
else
    avgSpins = nanmean(spins,2);
    erBars = nanstd(spins,0,2)./sqrt(sum(~isnan(spins(1,:,1))));
end 
        
% put data in format for plotting (rows laser power, columns groups ChR2
% day 1, ChR2 day 2, EYFP day 1, EYFP day 2)
avgPlot = [avgSpins(:,:,1)'; avgSpins(:,:,2)'; avgSpins(:,:,3)'; avgSpins(:,:,4)'; avgSpins(:,:,5)'; avgSpins(:,:,6)'];

% plot data
rotFig = bar(avgPlot);
hold on

rotFig(1).FaceColor = [.71 .82 .94];    % set colors of bars
rotFig(2).FaceColor = [.12 .16 .67];
rotFig(3).FaceColor = [.84 .71 .88];
rotFig(4).FaceColor = [.84 .14 .63];

% find center of bars to plot error bars
xdata1 = rotFig(1).XData;
xdata2 = rotFig(2).XData;
xdata3 = rotFig(3).XData;
xdata4 = rotFig(4).XData;
ydata1 = rotFig(1).YData;
ydata2 = rotFig(2).YData;
ydata3 = rotFig(3).YData;
ydata4 = rotFig(4).YData;

lineW = 1;

for r = 1:6 % add error bars
    errorbar(xdata1(r)-.27,ydata1(r),erBars(1,:,r),'k','LineWidth',lineW)
    errorbar(xdata2(r)-.1,ydata2(r),erBars(2,:,r),'k','LineWidth',lineW)
    errorbar(xdata3(r)+.09,ydata3(r),erBars(3,:,r),'k','LineWidth',lineW)
    errorbar(xdata4(r)+.27,ydata4(r),erBars(4,:,r),'k','LineWidth',lineW)
end

% plot individual data
indivColor = [.65 .65 .65];

for i_pow = 1:6
    xVals1 = [i_pow-.27 i_pow-.08];
    xVals2 = [i_pow+.08 i_pow + .27];
    for i_rat = 1:size(spins1,2)
        plot(xVals1,spins1(1:2,i_rat,i_pow),'Color',indivColor,'LineWidth',.5)
        plot(xVals2,spins1(3:4,i_rat,i_pow),'Color',indivColor,'LineWidth',.5)
    end
end 

% figure properties
ylabel({'rotations';'(contra - ipsi)'})
xlabel('estimated laser power at fiber tip (mW)')
set(gca,'ylim',[-2.5 18]);
set(gca,'ytick',[-2 0 6 12 18]);
set(gca,'xticklabels',[0 5 10 15 20 25]);
set(gca,'FontSize',10);
box off