function plotIndivAlternateZ(alternateKinematicSummaryHisto,session)

alternateEndpoint = putAlternateEndpointIntoBlocks(alternateKinematicSummaryHisto); % divides data into blocks of 5 for laser on/off

rows = 1:6:100;
for i_row = rows % put z endpoint data into table without NaNs between blocks of 5
    rowStart = i_row - find(rows == i_row) + 1; % to set row for data in plotData
    if i_row == 1
        plotData(i_row:i_row+4,1) = alternateEndpoint(i_row:i_row+4,session,3);
    else
        plotData(rowStart:rowStart+4,1) = alternateEndpoint(i_row:i_row+4,session,3);
    end
end 

plotData = plotData*-1;

% plot data
avgMarkerSize = 15;

numDataPts = size(plotData);
figColor = [.12 .16 .67];

for i_row = 1:10:numDataPts % plot laser off data
    scatter(i_row:i_row+4,plotData(i_row:i_row+4,1),avgMarkerSize,'MarkerEdgeColor',figColor);
    hold on
end 

for i_row = 6:10:numDataPts % plot laser on data
    scatter(i_row:i_row+4,plotData(i_row:i_row+4,1),avgMarkerSize,'MarkerEdgeColor',...
        figColor,'MarkerFaceColor',figColor);
    hold on
end 

xl = xlim; % get axis limits
xl(2) = 55;
yl = ylim;

line([0 xl(2)],[0 0],'Color','k') % add line at 0 for pellet

for i_patch = 5.5:10:xl(2)-5 % add background color behind laser on sessions
    patchX = [i_patch i_patch+5 i_patch+5 i_patch];
    patchY = [yl(1) yl(1) yl(2) yl(2)];
    patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')
    hold on
end 

% figure properties
ylabel({'final'; 'z_{digit2} (mm)'},'FontSize',10)
xlabel('trial number')
set(gca,'xlim',[0 xl(2)],'ylim',[yl(1) yl(2)]);
set(gca,'ytick',[yl(1) 0 yl(2)]);
set(gca,'xtick',5:5:xl(2))
set(gca,'FontSize',10);
box off