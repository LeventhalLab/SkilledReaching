% look at R38, 1219a, trial 2

function plotEarlyMidLate(folderPaths)


showFrames = 100;
sFrames = [50 50 75];
eFrames = [sFrames(1)+showFrames sFrames(2)+showFrames sFrames(3)+showFrames];

h = figure('position',[400 400 800 800]);

for iFolder=1:3
    allxs = [];
    allys = [];
    allzs = [];

    scoreLookup = dir(fullfile(folderPaths{iFolder},'*.csv'));
    scoreData = csvread(fullfile(folderPaths{iFolder},scoreLookup(1).name));
    matLookup = dir(fullfile(folderPaths{iFolder},'_xyzData','*.mat'));
    load(fullfile(folderPaths{iFolder},'_xyzData',matLookup(1).name));
    
    for iTrial=1:numel(allAlignedXyzPawCenters)
        alignedXyzPawCenters = allAlignedXyzPawCenters{iTrial};
        if(size(alignedXyzPawCenters,1) > 5) %why are some [NaN NaN Nan] and others empty?
            u = smoothn({alignedXyzPawCenters(sFrames(iFolder):eFrames(iFolder)-1,1),...
                alignedXyzPawCenters(sFrames(iFolder):eFrames(iFolder)-1,2),...
                alignedXyzPawCenters(sFrames(iFolder):eFrames(iFolder)-1,3)},...
            1,'robust');
 
            lw = 1;
            ea = .2;

            allxs = [allxs u{1}];
            allys = [allys u{2}];
            allzs = [allzs u{3}];
        end
    end
    t=[1:showFrames]';
    subplot(3,3,1+((iFolder-1)*3));
    bColor = [61/255,166/255,59/255];
    cColor = [100/255,100/255,100/255];
    hold on;
    for ii=1:size(allxs,2)
        patchline(t,allxs(:,ii),'edgecolor',bColor,'linewidth',1,'edgealpha',ea);
    end
    patchline(t,mean(allxs,2),'edgecolor',bColor,'linewidth',5);
    y1 = mean(allxs,2) + std(allxs,[],2);
    y2 = mean(allxs,2) - std(allxs,[],2);
    X = [t;fliplr(t')'];
    Y = [y1;fliplr(y2')'];
    hold on;
    fill(X,Y,'r','EdgeColor','none','FaceAlpha',0.5,'FaceColor',bColor);
    grid on; xlim([1 showFrames]); ylim([0 25]);
    
    subplot(3,3,2+((iFolder-1)*3));
    bColor = [90/255,153/255,238/255];
    hold on;
    for ii=1:size(allys,2)
        patchline(t,allys(:,ii),'edgecolor',bColor,'linewidth',1,'edgealpha',ea);
    end
    patchline(t,mean(allys,2),'edgecolor',bColor,'linewidth',5);
    y1 = mean(allys,2) + std(allys,[],2);
    y2 = mean(allys,2) - std(allys,[],2);
    X = [t;fliplr(t')'];
    Y = [y1;fliplr(y2')'];
    hold on;
    fill(X,Y,'r','EdgeColor','none','FaceAlpha',0.5,'FaceColor',bColor);
    grid on; xlim([1 showFrames]); ylim([-40 5]);
    
    subplot(3,3,3+((iFolder-1)*3));
    bColor = [196/255,90/255,235/255];
    hold on;
    for ii=1:size(allzs,2)
        patchline(t,allzs(:,ii),'edgecolor',bColor,'linewidth',1,'edgealpha',ea);
    end
    patchline(t,mean(allzs,2),'edgecolor',bColor,'linewidth',5);
    y1 = mean(allzs,2) + std(allzs,[],2);
    y2 = mean(allzs,2) - std(allzs,[],2);
    X = [t;fliplr(t')'];
    Y = [y1;fliplr(y2')'];
    hold on;
    fill(X,Y,'r','EdgeColor','none','FaceAlpha',0.5,'FaceColor',bColor);
    grid on; xlim([1 showFrames]); ylim([-10 20]);
end

disp('end');
