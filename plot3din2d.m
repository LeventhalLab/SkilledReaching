% look at R38, 1219a, trial 2

function plot3din2d(folderPathEarly,folderPathLate)

startFrame = 60;
endFrame = ;

ht = figure('position',[100 100 1100 400]);
h = figure('position',[400 400 800 800]);

hs(1) = subplot(221); title('Early Miss / Early Success'); hold on; grid on; view([22,40]); xlabel('x'); ylabel('y'); zlabel('z');
hs(2) = subplot(222); title('Late Miss / Late Success'); hold on; grid on; view([22,40]); xlabel('x'); ylabel('y'); zlabel('z');
hs(3) = subplot(223); title('Early Miss / Late Miss'); hold on; grid on; view([22,40]); xlabel('x'); ylabel('y'); zlabel('z');
hs(4) = subplot(224); title('Early Success / Late Success'); hold on; grid on; view([22,40]); xlabel('x'); ylabel('y'); zlabel('z');

xfiltsSuccess = [];
yfiltsSuccess = [];
zfiltsSuccess = [];

xfiltsMiss = [];
yfiltsMiss = [];
zfiltsMiss = [];

for iFolder=1:2
    if(iFolder==1)
        folderPath = folderPathEarly;
    else
        folderPath = folderPathLate;
    end
    scoreLookup = dir(fullfile(folderPath,'*.csv'));
    scoreData = csvread(fullfile(folderPath,scoreLookup(1).name));
    matLookup = dir(fullfile(folderPath,'_xyzData','*.mat'));
    load(fullfile(folderPath,'_xyzData',matLookup(1).name));
    
    for iTrial=1:numel(allAlignedXyzPawCenters)
        alignedXyzPawCenters = allAlignedXyzPawCenters{iTrial};
        if(size(alignedXyzPawCenters,1) > 5) %why are some [NaN NaN Nan] and others empty?
            u = smoothn({alignedXyzPawCenters(startFrame:endFrame-1,1),...
                alignedXyzPawCenters(startFrame:endFrame-1,2),...
                alignedXyzPawCenters(startFrame:endFrame-1,3)},...
            5,'robust');
 
            lw = 1;
            ea = .5;
%             ht=figure;
%             plot(linspace(startFrame,endFrame,endFrame-startFrame),u{3}); hold on; plot(u2{3}); hold on; plot(alignedXyzPawCenters(startFrame:plotFrames,3));
%             close(ht);
            if(ismember(scoreData(iTrial,2),[1,2,3,4,7]))
                switch(scoreData(iTrial,2))
                    case 1
                        if(iFolder==1)
                            subplot(221);
                            patchline(u{1},u{2},u{3},'edgecolor',[30/255 83/255 130/255],'linewidth',lw,'edgealpha',ea);
                            subplot(224);
                            patchline(u{1},u{2},u{3},'edgecolor',[30/255 83/255 130/255],'linewidth',lw,'edgealpha',ea);
                            
                            figure(ht);
                            subplot(131); hold on; plot(linspace(startFrame,endFrame,endFrame-startFrame),u{1},'color',[30/255 83/255 130/255]); xlim([startFrame endFrame]); title('x');
                            subplot(132); hold on; plot(linspace(startFrame,endFrame,endFrame-startFrame),u{2},'color',[30/255 83/255 130/255]); xlim([startFrame endFrame]); title('y');
                            subplot(133); hold on; plot(linspace(startFrame,endFrame,endFrame-startFrame),u{3},'color',[30/255 83/255 130/255]); xlim([startFrame endFrame]); title('z');
                            figure(h);
                        else
                            subplot(222);
                            patchline(u{1},u{2},u{3},'edgecolor',[30/255 83/255 255/255],'linewidth',lw,'edgealpha',ea);
                            subplot(224);
                            patchline(u{1},u{2},u{3},'edgecolor',[30/255 83/255 255/255],'linewidth',lw,'edgealpha',ea);
                            figure(ht);
                            subplot(131); hold on; plot(linspace(startFrame,endFrame,endFrame-startFrame),u{1},'color',[30/255 83/255 255/255]); xlim([startFrame endFrame]); title('x');
                            subplot(132); hold on; plot(linspace(startFrame,endFrame,endFrame-startFrame),u{2},'color',[30/255 83/255 255/255]); xlim([startFrame endFrame]); title('y');
                            subplot(133); hold on; plot(linspace(startFrame,endFrame,endFrame-startFrame),u{3},'color',[30/255 83/255 255/255]); xlim([startFrame endFrame]); title('z');
                            figure(h);
                        end
                        xfiltsSuccess = [xfiltsSuccess;u{1}'];
                        yfiltsSuccess = [yfiltsSuccess;u{2}'];
                        zfiltsSuccess = [zfiltsSuccess;u{3}'];
                    case {2,3,4,7}
                        if(iFolder==1)
                            subplot(221);
                            patchline(u{1},u{2},u{3},'edgecolor',[159/255 30/255 30/255],'linewidth',lw,'edgealpha',ea);
                            subplot(223);
                            patchline(u{1},u{2},u{3},'edgecolor',[159/255 30/255 30/255],'linewidth',lw,'edgealpha',ea);
                        else
                            subplot(222);
                            patchline(u{1},u{2},u{3},'edgecolor',[251/255 30/255 30/255],'linewidth',lw,'edgealpha',ea);
                            subplot(223);
                            patchline(u{1},u{2},u{3},'edgecolor',[251/255 30/255 30/255],'linewidth',lw,'edgealpha',ea);
                        end
                        xfiltsMiss = [xfiltsMiss;u{1}'];
                        yfiltsMiss = [yfiltsMiss;u{2}'];
                        zfiltsMiss = [zfiltsMiss;u{3}'];
                end
            end

        end
    end
%     if(iFolder==1)
%         subplot(221);
%         patchline(mean(xfiltsSuccess),mean(yfiltsSuccess),mean(zfiltsSuccess),'edgecolor',[30/255 83/255 255/255],'linewidth',3,'edgealpha',1);
%         subplot(221);
%         patchline(mean(xfiltsMiss),mean(yfiltsMiss),mean(zfiltsMiss),'edgecolor',[159/255 30/255 30/255],'linewidth',3,'edgealpha',1);
%         subplot(223);
%         patchline(mean(xfiltsMiss),mean(yfiltsMiss),mean(zfiltsMiss),'edgecolor',[159/255 30/255 30/255],'linewidth',3,'edgealpha',1);
%         subplot(224);
%         patchline(mean(xfiltsSuccess),mean(yfiltsSuccess),mean(zfiltsSuccess),'edgecolor',[30/255 83/255 255/255],'linewidth',3,'edgealpha',1);
%     else
%         subplot(222);
%         patchline(mean(xfiltsSuccess),mean(yfiltsSuccess),mean(zfiltsSuccess),'edgecolor',[30/255 83/255 255/255],'linewidth',3,'edgealpha',1);
%         subplot(222);
%         patchline(mean(xfiltsMiss),mean(yfiltsMiss),mean(zfiltsMiss),'edgecolor',[159/255 30/255 30/255],'linewidth',3,'edgealpha',1);
%         subplot(223);
%         patchline(mean(xfiltsMiss),mean(yfiltsMiss),mean(zfiltsMiss),'edgecolor',[159/255 30/255 30/255],'linewidth',3,'edgealpha',1);
%         subplot(224);
%         patchline(mean(xfiltsSuccess),mean(yfiltsSuccess),mean(zfiltsSuccess),'edgecolor',[30/255 83/255 255/255],'linewidth',3,'edgealpha',1);
%     end
end
