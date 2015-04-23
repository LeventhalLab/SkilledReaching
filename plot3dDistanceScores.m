% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% Work in progress
function h=plot3dDistanceScores(folderPath,plotFrames,superTitle,azel,lineColor)
    scoreLookup = dir(fullfile(folderPath,'*.csv'));
    scoreData = csvread(fullfile(folderPath,scoreLookup(1).name));
    matLookup = dir(fullfile(folderPath,'_xyzData','*.mat'));
    load(fullfile(folderPath,'_xyzData',matLookup(1).name));
    
    if(~isempty(superTitle))
        h = figure('Position', [0,0,500,500]);
        suptitle(superTitle);
    end

    startFrame = 50;
    plot1Avg = {};
    plot2Avg = {};
    for i=1:numel(allAlignedXyzPawCenters)
        alignedXyzPawCenters = allAlignedXyzPawCenters{i};
        if(size(alignedXyzPawCenters,1) > 5) %why are some [NaN NaN Nan] and others empty?
            xfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,1),2);
            xfilt = smoothn(xfilt,2,'robust');
            yfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,2),2);
            yfilt = smoothn(yfilt,2,'robust');
            zfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,3),2);
            zfilt = smoothn(zfilt,2,'robust');
            hold on;
            
            if(ismember(scoreData(i,2),[1,2,3,4,7]))
                switch(scoreData(i,2))
                    case 1
                        if(isempty(plot1Avg))
                            plot1Avg{1} = xfilt;
                            plot1Avg{2} = yfilt;
                            plot1Avg{3} = zfilt;
                        else
                            plot1Avg{1} = mean([xfilt,plot1Avg{1}],2);
                            plot1Avg{2} = mean([yfilt,plot1Avg{2}],2);
                            plot1Avg{3} = mean([zfilt,plot1Avg{3}],2);
                        end
                        plot3(xfilt,yfilt,zfilt,'color','b');
                    case {2,3,4,7}
                        if(isempty(plot2Avg))
                            plot2Avg{1} = xfilt;
                            plot2Avg{2} = yfilt;
                            plot2Avg{3} = zfilt;
                        else
                            plot2Avg{1} = mean([xfilt,plot2Avg{1}],2);
                            plot2Avg{2} = mean([yfilt,plot2Avg{2}],2);
                            plot2Avg{3} = mean([zfilt,plot2Avg{3}],2);
                        end
                        plot3(xfilt,yfilt,zfilt,'color','r');
                end
                hold on;
%                 colormapline(xfilt,yfilt,zfilt);
            end
        end
    end
    grid on;
    view([37.5,30]);

    for k=1:2
        h(k) = subplot(1,2,k);
        %view(h(k),[37.5,30]); % az,el
        view(h(k),azel); % az,el
        xlabel(h(k),'x');
        ylabel(h(k),'y');
        zlabel(h(k),'z');
        %legend on;
        grid(h(k));
        box(h(k));
%         axis(h(k),[-5 25 -60 0 -25 10]); % x y z
        hold on;
        
        switch k
            case 1
                title(h(k),'First Trial Success - 1');
                plot3(plot1Avg{1},plot1Avg{2},plot1Avg{3},'Color',lineColor,'lineWidth',3,'Marker','o');
            case 2
                title(h(k),'Unsuccessful - {2,3,4,7}');
                plot3(plot2Avg{1},plot2Avg{2},plot2Avg{3},'Color',lineColor,'lineWidth',3,'Marker','o');
        end
    end
    h=h(1);
end