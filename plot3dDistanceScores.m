function h=plot3dDistanceScores(allAlignedXyzPawCenters,plotFrames,azel,superTitle)
    disp('Select the scoring CSV file...');
    %[scoreFile,scorePath] = uigetfile({'.csv'});
    scoreFile = 'Quant scoring R28 20140426.csv'; %REMOVE
    scorePath = 'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140426a\'; %REMOVE
    scoreData = csvread(fullfile(scorePath,scoreFile));
    
    h = figure('Position', [100, 100, 1000, 800]);
    suptitle(superTitle);

    startFrame = 2;
    plot1Avg = {};
    plot2Avg = {};
    plot3Avg = {};
    plot4Avg = {};
    for i=1:numel(allAlignedXyzPawCenters)
        alignedXyzPawCenters = allAlignedXyzPawCenters{i};
        if(isa(alignedXyzPawCenters,'double'))
            xfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,1),4);
            xfilt = smoothn(xfilt,3,'robust');
            yfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,2),4);
            yfilt = smoothn(yfilt,3,'robust');
            zfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,3),4);
            zfilt = smoothn(zfilt,3,'robust');
            hold on;
            
            if(ismember(scoreData(i,2),[1,2,3,4,7]))
                switch(scoreData(i,2))
                    case 1
                        subplot(2,2,1);
                        if(isempty(plot1Avg))
                            plot1Avg{1} = xfilt;
                            plot1Avg{2} = yfilt;
                            plot1Avg{3} = zfilt;
                        else
                            plot1Avg{1} = mean([xfilt,plot1Avg{1}],2);
                            plot1Avg{2} = mean([yfilt,plot1Avg{2}],2);
                            plot1Avg{3} = mean([zfilt,plot1Avg{3}],2);
                        end
                    case 2
                        subplot(2,2,2);
                        if(isempty(plot2Avg))
                            plot2Avg{1} = xfilt;
                            plot2Avg{2} = yfilt;
                            plot2Avg{3} = zfilt;
                        else
                            plot2Avg{1} = mean([xfilt,plot2Avg{1}],2);
                            plot2Avg{2} = mean([yfilt,plot2Avg{2}],2);
                            plot2Avg{3} = mean([zfilt,plot2Avg{3}],2);
                        end
                    case {3,4}
                        subplot(2,2,3);
                        if(isempty(plot3Avg))
                            plot3Avg{1} = xfilt;
                            plot3Avg{2} = yfilt;
                            plot3Avg{3} = zfilt;
                        else
                            plot3Avg{1} = mean([xfilt,plot3Avg{1}],2);
                            plot3Avg{2} = mean([yfilt,plot3Avg{2}],2);
                            plot3Avg{3} = mean([zfilt,plot3Avg{3}],2);
                        end
                    case 7
                        subplot(2,2,4);
                        if(isempty(plot4Avg))
                            plot4Avg{1} = xfilt;
                            plot4Avg{2} = yfilt;
                            plot4Avg{3} = zfilt;
                        else
                            plot4Avg{1} = mean([xfilt,plot4Avg{1}],2);
                            plot4Avg{2} = mean([yfilt,plot4Avg{2}],2);
                            plot4Avg{3} = mean([zfilt,plot4Avg{3}],2);
                        end
                end
                %colormapline(xfilt,yfilt,zfilt);
            end
        end
    end

    for k=1:4
        h(k) = subplot(2,2,k);
        %view(h(k),[37.5,30]); % az,el
        view(h(k),azel); % az,el
        xlabel(h(k),'x');
        ylabel(h(k),'y');
        zlabel(h(k),'z');
        %legend on;
        grid(h(k));
        box(h(k));
        axis(h(k),[-5 25 -60 0 -25 10]); % x y z
        
        switch k
            case 1
                title(h(k),'First Trial Success - 1');
                plot3(plot1Avg{1},plot1Avg{2},plot1Avg{3},'Color','magenta','Marker','o');
            case 2
                title(h(k),'Success - 2');
                plot3(plot2Avg{1},plot2Avg{2},plot2Avg{3},'Color','magenta','Marker','o');
            case 3
                title(h(k),'Forelimb Advance, Unsuccessful - 3+4');
                plot3(plot3Avg{1},plot3Avg{2},plot3Avg{3},'Color','magenta','Marker','o');
            case 4
                title(h(k),'Reached, Pellet on Shelf - 7');
                plot3(plot4Avg{1},plot4Avg{2},plot4Avg{3},'Color','magenta','Marker','o');
        end
    end
end