function h_fig = plotAlternateOrientation(alternateKinematicSummaryHisto,plotArch,plotOffOn)

alternateOrientation = putAlternateOrientationIntoBlocks(alternateKinematicSummaryHisto); 
% each column is a different session, columns are divided into blocks of 5
% the first block is always laser off, second block is laser
% on, and it repeats off/on after that

if plotArch     % plot arch or ChR2 data
    grpSess = 11:24; %arch
else grpSess = 1:10; %chr
end 

% figure properties
plotIndiv = true; % plot individual data points for each rat under average

avgMarkerSize = 45;
indMarkerSize = 4;

if plotArch
    figColor = [0 .4 0.2];
else 
    figColor = [.12 .16 .67];
end 
indivColor = [.85 .85 .85];

% data must be corrected for left pawed rats - need to identify paw
% preference
rootPath = fullfile('/Volumes','SharedX','Neuro-Leventhal','analysis','alternating stim analysis');
cd(rootPath);   % set data directory with table with paw preference information

csvfname = fullfile(rootPath,'validAlternatingSessions.csv'); % load table 
sessionInfo = readtable(csvfname);

validRats = [1 2 4 5 7:27];     % identify rats to include in analysis (excludes rats w/ poor histology)

for i_rat = 1:size(validRats,2)     % pull out paw preference for valid rats
    paws(i_rat,1) = sessionInfo.Paw(validRats(i_rat));
end 

for i_sess = 1:size(alternateOrientation,2) % correct data for left-pawed rats
    if strcmp(paws(i_sess),'left')
        alternateOrientation(:,i_sess) = pi - alternateOrientation(:,i_sess);
    end
end 
        
alternateOrientation = (alternateOrientation*180)/pi;   % convert orientation to degrees

% calculate averages
avgOrientation = nanmean(alternateOrientation(:,grpSess),2); % average each row

for i = 1:5     % calculate average first reach laser off, second reach laser off, etc. 
    avgOff(i,1) = nanmean(avgOrientation(i:12:end));
end 

for i = 7:11    % laser on averages 
    avgOn(i-6,1) = nanmean(avgOrientation(i:12:end));
end 

% collect individual rat data into matrix
for i_sess = grpSess
    for i = 1:5     % laser off data in rows 1-5, each column different session
        indiData(i,i_sess) = nanmean(alternateOrientation(i:12:end,i_sess));
    end 
end

for i_sess = grpSess
    for i = 7:11    % laser on data in rows 6-10
        indiData(i-1,i_sess) = nanmean(alternateOrientation(i:12:end,i_sess));
    end 
end

% get data set up to calculate std dev
oData = alternateOrientation(:,grpSess);
offData = NaN(100,5);

rowSt = 1; %off trials
for row = 1:12:size(oData,1)
    col = 1;
    for i_row = row:row+4
        if i_row > size(oData,1)
            continue
        else    % column 1-5 = data from all sessions reach 1, reach 2, etc. in laser off blocks
            offData(rowSt:rowSt+size(oData,2)-1,col) = oData(i_row,:)';
            col = col+1;
        end
    end 
    rowSt = rowSt + size(oData,2);
end 

onData = NaN(100,5);
rowSt = 1; %on trials
for row = 7:12:size(oData,1)
    col = 1;
    for i_row = row:row+4
        if i_row > size(oData,1)
            continue
        else    % column 1-5 = data from all sessions reach 1, reach 2, etc. in laser on blocks
            onData(rowSt:rowSt+size(oData,2)-1,col) = oData(i_row,:)';
            col = col+1;
        end
    end 
    rowSt = rowSt + size(oData,2);
end 

for trNum = 1:5     % calculate s.e.m.
    numDtPts = sum(~isnan(offData(:,trNum)));
    erbarOff(1,trNum) = nanstd(offData(:,trNum),0,1)./sqrt(numDtPts);
end 

for trNum = 1:5     % calculate s.e.m.
    numDtPts = sum(~isnan(onData(:,trNum)));
    erbarOn(1,trNum) = nanstd(onData(:,trNum),0,1)./sqrt(numDtPts);
end


% plot individual data
if plotOffOn
    if plotIndiv
        for i_set = grpSess
            plot(1:10,indiData(:,i_set),'-o','MarkerSize',indMarkerSize,'Color',indivColor,'MarkerEdgeColor',indivColor,'MarkerFaceColor',indivColor)
            hold on
        end 
    end
end 

if plotArch
    minValue = 30;
    maxValue = 80;
else
    minValue = 0;
    maxValue = 100;
end

% plot averages
if plotOffOn
    scatter(1:5,avgOff(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor);
    hold on
    scatter(6:10,avgOn(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
    e = errorbar(1:5,avgOff(1:5,1),erbarOff(1,:)','linestyle','none');
    e1 = errorbar(6:10,avgOn(1:5,1),erbarOn(1,:)','linestyle','none');
    e.Color = figColor;
    e1.Color = figColor;
    
    patchX = [5.5 10.5 10.5 5.5];       % add background color to laser on blocks
    patchY = [minValue minValue maxValue maxValue];
    patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')
else
    scatter(1:5,avgOn(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor,'MarkerFaceColor',figColor);
    hold on
    scatter(6:10,avgOff(1:5,1),avgMarkerSize,'MarkerEdgeColor',figColor);
    e2 = errorbar(1:5,avgOn(1:5,1),erbarOn(1,:)','linestyle','none');
    e3 = errorbar(6:10,avgOff(1:5,1),erbarOff(1,:)','linestyle','none');
    e2.Color = figColor;
    e3.Color = figColor;
    
    patchX = [.5 5.5 5.5 .5];       % add background color to laser on blocks
    patchY = [minValue minValue maxValue maxValue];
    patch(patchX,patchY,figColor,'FaceAlpha',0.07,'LineStyle','none')
end 

% figure settings

ylabel('\theta at reach end (deg)')
xlabel('reach number in block')
set(gca,'xlim',[0 11],'ylim',[minValue maxValue]);
set(gca,'xtick',[1 5 6 10],'ytick',[0 50 100]);
set(gca,'xticklabels',[1 5 1 5]);
set(gca,'FontSize',10);
box off