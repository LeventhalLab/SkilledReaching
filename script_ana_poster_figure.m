% script ana_poster_figure

fontSize = 50;
reachingParentDir = '/Volumes/RecordingsLeventhal04/SkilledReaching/';
ratID = 'R0118';
ratDir = fullfile(reachingParentDir,ratID);
rawDataDir = fullfile(ratDir,[ratID '-rawdata']);
sessionDir = fullfile(rawDataDir,[ratID '_20160718a']);
fname = fullfile(sessionDir, 'R0118_20160718_13-32-04_025.avi');

PDFdir = '/Users/dan/Box Sync/Leventhal Lab/Meetings, Presentations/ANA 2016';
PDFname = fullfile(PDFdir, 'vidFrames.pdf');

v = VideoReader(fname);

ROI = [1850,580,90,43];
frameTime(1) = 0.9;
frameTime(2) = 1.0;
frameTime(3) = 306/300;
frameTime(4) = 330/300;
frameTime(5) = 390/300;
frameTime(6) = 540/300;

frames = cell(1,length(frameTime));
frames_text = cell(1,length(frameTime));

figProps.n = 2;
figProps.m = length(frameTime)/figProps.n;

figProps.height = 13*2.54;

figProps.colSpacing = 0.5;
figProps.rowSpacing = ones(1,figProps.m-1) * 0.1;
figProps.topMargin = 0.2;
figProps.panelHeight = ones(1,figProps.m) * ...
    ((figProps.height - figProps.topMargin) - sum(figProps.rowSpacing)) / figProps.m;
figProps.panelWidth = (2040/1024) * figProps.panelHeight(1) * ones(figProps.n,1);
figProps.width  = sum(figProps.panelWidth) + 0.5;

[h_fig, h_axes] = createFigPanels5(figProps);
for iFrame = 1 : length(frameTime)
    v.CurrentTime = frameTime(iFrame);
    frames{iFrame} = readFrame(v);
    
    ftext = sprintf('t = %1.2f s',frameTime(iFrame));
    
    switch iFrame
        case 2,
            textCol = 'red';
        case 3,
            textCol = 'green';
        otherwise,
            textCol = 'white';
    end

    frames_text{iFrame} = insertText(frames{iFrame}, [10 10], ftext,...
        'font','arial black',...
        'fontsize',fontSize,...
        'textcolor',textCol,...
        'boxcolor','black',...
        'boxopacity',0.4);
    
    frames_text{iFrame} = insertShape(frames_text{iFrame},'rectangle',ROI,...
                            'linewidth',2,...
                            'color','yellow',...
                            'opacity',0);
	rowNum = rem(iFrame,figProps.m);
    if rowNum == 0; rowNum = figProps.m; end
    colNum = ceil(iFrame/figProps.m);
    axes(h_axes(rowNum,colNum));
    imshow(frames_text{iFrame});
end

set(gcf,'paperpositionmode','auto');
print('-bestfit',PDFname,'-dpdf');